# Theme asset optimization — lossless PNG + high-quality WebP + conservative resize.
# Usage:
#   powershell -File tools/optimize_theme_assets.ps1
#   powershell -File tools/optimize_theme_assets.ps1 -Apply

param(
  [switch]$Apply
)

$ErrorActionPreference = "Continue"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$Theme = Join-Path $Root "assets\themes\Vintage-Diary"
$Trial = Join-Path $Root "tools\_opt_trial"
$Backup = Join-Path $Root "tools\_opt_backup_png"

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path","User")

function Ensure-Dir($p) {
  if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p | Out-Null }
}

Ensure-Dir $Trial
Ensure-Dir $Backup

$Opaque = @(
  "vintage-bg.png",
  "Journal-Card.png",
  "Calendar.png",
  "profile_card.png"
)

$TransparentChrome = @(
  "bottom-navbar.png",
  "user-strip.png",
  "search.png"
)

$Moods = @(
  "Mood-Illustrations\Calm-Mood.png",
  "Mood-Illustrations\Anxious-Mood.png",
  "Mood-Illustrations\Affection-Mood.png",
  "Mood-Illustrations\Sad-Mood.png",
  "Mood-Illustrations\Frustrated-Mood.png",
  "Mood-Illustrations\Surprised-Mood.png",
  "Mood-Illustrations\Neutral-Mood.png",
  "Mood-Illustrations\Joyful-Mood.png",
  "Mood-Illustrations\Excited-home.png"
)

$Report = @()

function Invoke-Tool {
  param([string]$Exe, [string[]]$ArgumentList)
  $out = Join-Path $env:TEMP "opt_stdout.txt"
  $err = Join-Path $env:TEMP "opt_stderr.txt"
  $p = Start-Process -FilePath $Exe -ArgumentList $ArgumentList -NoNewWindow -Wait -PassThru `
    -RedirectStandardOutput $out -RedirectStandardError $err
  return $p.ExitCode
}

function Opt-One {
  param(
    [string]$RelPath,
    [int]$WebpQuality,
    [int]$MaxEdge = 0,
    [switch]$HasAlpha
  )

  $src = Join-Path $Theme $RelPath
  if (-not (Test-Path $src)) { throw "Missing $src" }

  $name = [IO.Path]::GetFileNameWithoutExtension($RelPath)
  $dirRel = [IO.Path]::GetDirectoryName($RelPath)
  $outDir = if ($dirRel) { Join-Path $Trial $dirRel } else { $Trial }
  Ensure-Dir $outDir

  $origSize = (Get-Item $src).Length
  $srcAbs = (Resolve-Path $src).Path

  $resizeArgs = @()
  if ($MaxEdge -gt 0) {
    Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue
    $img = [System.Drawing.Image]::FromFile($srcAbs)
    $w = $img.Width; $h = $img.Height
    $img.Dispose()
    $long = [Math]::Max($w, $h)
    if ($long -gt $MaxEdge) {
      $scale = $MaxEdge / $long
      $nw = [Math]::Max(1, [int][Math]::Round($w * $scale))
      $nh = [Math]::Max(1, [int][Math]::Round($h * $scale))
      $resizeArgs = @("-resize", "$nw", "$nh")
      Write-Host "  resize ${w}x${h} -> ${nw}x${nh}"
    }
  }

  $oxiPng = Join-Path $outDir "$name.oxi.png"
  Copy-Item $src $oxiPng -Force
  Invoke-Tool -Exe "oxipng" -ArgumentList @("-o","4","--strip","safe","--alpha", $oxiPng) | Out-Null
  $oxiSize = (Get-Item $oxiPng).Length

  $webp = Join-Path $outDir "$name.webp"
  $cwebpArgs = [System.Collections.Generic.List[string]]::new()
  $cwebpArgs.AddRange([string[]]@("-q", "$WebpQuality", "-m", "6", "-mt"))
  if ($HasAlpha) {
    $cwebpArgs.AddRange([string[]]@("-alpha_q", "100", "-exact"))
  }
  foreach ($a in $resizeArgs) { $cwebpArgs.Add($a) }
  $cwebpArgs.AddRange([string[]]@($srcAbs, "-o", $webp))
  Invoke-Tool -Exe "cwebp" -ArgumentList $cwebpArgs.ToArray() | Out-Null
  $webpSize = if (Test-Path $webp) { (Get-Item $webp).Length } else { [int]::MaxValue }

  $webpLossless = Join-Path $outDir "$name.lossless.webp"
  $llArgs = [System.Collections.Generic.List[string]]::new()
  $llArgs.AddRange([string[]]@("-lossless", "-z", "9", "-mt"))
  foreach ($a in $resizeArgs) { $llArgs.Add($a) }
  $llArgs.AddRange([string[]]@($srcAbs, "-o", $webpLossless))
  Invoke-Tool -Exe "cwebp" -ArgumentList $llArgs.ToArray() | Out-Null
  $llSize = if (Test-Path $webpLossless) { (Get-Item $webpLossless).Length } else { [int]::MaxValue }

  $bestKind = "original"
  $bestSize = $origSize
  $bestPath = $src

  if ($oxiSize -lt $bestSize) {
    $bestKind = "oxipng"; $bestSize = $oxiSize; $bestPath = $oxiPng
  }
  if ($webpSize -lt $bestSize) {
    $bestKind = "webp-q$WebpQuality"; $bestSize = $webpSize; $bestPath = $webp
  }
  if ($llSize -lt $bestSize) {
    $bestKind = "webp-lossless"; $bestSize = $llSize; $bestPath = $webpLossless
  }

  $row = [pscustomobject]@{
    File = $RelPath
    OrigKB = [math]::Round($origSize/1KB,1)
    OxiKB = [math]::Round($oxiSize/1KB,1)
    WebpKB = [math]::Round($webpSize/1KB,1)
    WebpLosslessKB = [math]::Round($llSize/1KB,1)
    Best = $bestKind
    BestKB = [math]::Round($bestSize/1KB,1)
    SavedKB = [math]::Round(($origSize - $bestSize)/1KB,1)
    BestPath = $bestPath
  }
  $script:Report += $row
  Write-Host ("{0}: {1}KB -> {2} ({3}KB) save {4}KB" -f $RelPath, $row.OrigKB, $row.Best, $row.BestKB, $row.SavedKB)
}

Write-Host "=== OPAQUE BACKGROUNDS / CARDS (WebP q=92) ==="
foreach ($f in $Opaque) { Opt-One -RelPath $f -WebpQuality 92 }

Write-Host "=== TRANSPARENT CHROME (WebP q=90 + alpha) ==="
foreach ($f in $TransparentChrome) { Opt-One -RelPath $f -WebpQuality 90 -HasAlpha }

Write-Host "=== MOOD ILLUSTRATIONS (max edge 768, WebP q=90 + alpha) ==="
foreach ($f in $Moods) { Opt-One -RelPath $f -WebpQuality 90 -MaxEdge 768 -HasAlpha }

Write-Host ""
Write-Host "=== TRIAL SUMMARY ==="
$Report | Format-Table -AutoSize
$orig = ($Report | Measure-Object OrigKB -Sum).Sum
$best = ($Report | Measure-Object BestKB -Sum).Sum
Write-Host ("Optimized set: {0:N0} KB -> {1:N0} KB  ({2:N0} KB saved, {3:N1}% )" -f $orig, $best, ($orig-$best), (100*($orig-$best)/$orig))
$Report | Export-Csv -Path (Join-Path $Trial "report.csv") -NoTypeInformation

if (-not $Apply) {
  Write-Host ""
  Write-Host "Trial only. Re-run with -Apply to replace assets."
  exit 0
}

Write-Host ""
Write-Host "=== APPLYING ==="
foreach ($row in $Report) {
  $src = Join-Path $Theme $row.File
  $bak = Join-Path $Backup ($row.File -replace '[\\/]', '__')
  Copy-Item $src $bak -Force

  if ($row.Best -like "webp*") {
    $destWebp = [IO.Path]::ChangeExtension($src, ".webp")
    Copy-Item $row.BestPath $destWebp -Force
    Remove-Item $src -Force
    Write-Host "Replaced $($row.File) -> $([IO.Path]::GetFileName($destWebp))"
  } elseif ($row.Best -eq "oxipng") {
    Copy-Item $row.BestPath $src -Force
    Write-Host "Lossless-optimized $($row.File)"
  } else {
    Write-Host "Kept original $($row.File)"
  }
}

Write-Host "Done applying."
