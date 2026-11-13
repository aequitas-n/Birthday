# Phase 8: fresh-process first-Kin capture.
# Arm timeline AFTER Today is ready and BEFORE Kin tap.

$ErrorActionPreference = 'Stop'
$root = 'e:\~Work\Birthday'
$outDir = "$root\tmp\phase8"
$tool = "$root\tools\phase7_timeline_tool"
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

# Kill prior flutter runs
Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
  Where-Object { $_.CommandLine -and $_.CommandLine -match 'flutter run' } |
  ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
& $adb -s emulator-5554 shell am force-stop com.kinapp.kin
Start-Sleep -Seconds 2

$runLog = "$outDir\flutter_run.log"
Remove-Item $runLog, "$outDir\flutter_run.err.log" -ErrorAction SilentlyContinue

$proc = Start-Process -FilePath 'flutter' -ArgumentList @(
  'run', '--profile', '-d', 'emulator-5554',
  '--dart-define=KIN_PHASE7_DIAG=true',
  '--dart-define=KIN_PHASE6_DIAG=true',
  '--endless-trace-buffer'
) -WorkingDirectory $root -RedirectStandardOutput $runLog `
  -RedirectStandardError "$outDir\flutter_run.err.log" -PassThru -NoNewWindow

Write-Host "flutter pid=$($proc.Id)"

function Get-WsUri {
  if (-not (Test-Path $runLog)) { return $null }
  $m = Select-String -Path $runLog -Pattern 'http://127\.0\.0\.1:\d+/[^/\s]+/' | Select-Object -Last 1
  if (-not $m) { return $null }
  $http = $m.Matches[0].Value.TrimEnd('/')
  return ($http -replace '^http', 'ws') + '/ws'
}

$ws = $null
for ($i = 0; $i -lt 900; $i++) {
  if ($proc.HasExited) { throw "flutter exited early: $($proc.ExitCode)" }
  $ws = Get-WsUri
  if ($ws) { break }
  Start-Sleep -Milliseconds 250
}
if (-not $ws) { throw 'No VM URI' }
Write-Host "WS=$ws"

# Wait until Today first frame; ensure no Kin tab mark yet
$todayReady = $false
for ($i = 0; $i -lt 120; $i++) {
  if (Select-String -Path $runLog -Pattern 'PHASE7 kinApp_firstFrame' -Quiet) {
    $todayReady = $true
    break
  }
  Start-Sleep -Milliseconds 250
}
if (-not $todayReady) { throw 'kinApp_firstFrame not seen' }
if (Select-String -Path $runLog -Pattern 'PHASE7 tab_kin' -Quiet) {
  throw 'Kin was already visited before arm — aborting'
}
Write-Host 'Today ready; Kin not visited. Arming timeline…'
Start-Sleep -Seconds 2

# Arm 22s covering Kin + Journal + Today revisit
Remove-Item "$outDir\arm.err.txt", "$outDir\arm.out.txt" -ErrorAction SilentlyContinue
$arm = Start-Process -FilePath 'dart' -ArgumentList @(
  'run', 'bin/phase7_arm_and_dump.dart', $ws, "$outDir\fresh_session.json", '22'
) -WorkingDirectory $tool -RedirectStandardError "$outDir\arm.err.txt" `
  -RedirectStandardOutput "$outDir\arm.out.txt" -PassThru -NoNewWindow

for ($i = 0; $i -lt 80; $i++) {
  if ((Test-Path "$outDir\arm.err.txt") -and
      (Select-String -Path "$outDir\arm.err.txt" -Pattern '^ARMED' -Quiet)) {
    break
  }
  Start-Sleep -Milliseconds 150
}
if (-not (Select-String -Path "$outDir\arm.err.txt" -Pattern '^ARMED' -Quiet)) {
  throw 'ARMED not seen'
}
Write-Host 'ARMED confirmed — tapping Kin (first visit)'
Start-Sleep -Milliseconds 200
& $adb -s emulator-5554 shell input tap 540 2240
Start-Sleep -Seconds 4
Write-Host 'Tapping Journal (first visit)'
& $adb -s emulator-5554 shell input tap 886 2240
Start-Sleep -Seconds 4
Write-Host 'Tapping Today revisit'
& $adb -s emulator-5554 shell input tap 194 2240
Wait-Process -Id $arm.Id -Timeout 60

Write-Host '--- arm stderr ---'
Get-Content "$outDir\arm.err.txt" | Select-Object -First 15
Select-String "$outDir\fresh_session.json" -Pattern eventCount | Select-Object -First 1

# Verify markers in flutter log during this run
Write-Host '--- tab marks in run log ---'
Select-String -Path $runLog -Pattern 'PHASE7 tab_|PHASE7 kinApp' | Select-Object -Last 10

Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
Write-Host 'Capture complete'
