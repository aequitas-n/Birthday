# Phase 7 timeline orchestration:
# 1) flutter run --profile with Phase7 widget profiling
# 2) connect VM service ASAP, enable timeline streams
# 3) dump cold-launch, Kin, Journal, Today-revisit timelines

$ErrorActionPreference = 'Stop'
$root = 'e:\~Work\Birthday'
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$outDir = "$root\tmp\phase7"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$runLog = "$outDir\flutter_run.log"
$toolDir = "$root\tools\phase7_timeline_tool"

& $adb -s emulator-5554 shell am force-stop com.kinapp.kin
Start-Sleep -Seconds 1

$runArgs = @(
  'run', '--profile',
  '-d', 'emulator-5554',
  '--dart-define=KIN_PHASE7_DIAG=true',
  '--dart-define=KIN_PHASE6_DIAG=true',
  '--endless-trace-buffer'
)

Write-Host 'Starting flutter run…'
$proc = Start-Process -FilePath 'flutter' -ArgumentList $runArgs `
  -WorkingDirectory $root -RedirectStandardOutput $runLog `
  -RedirectStandardError "$outDir\flutter_run.err.log" `
  -PassThru -NoNewWindow

function Get-WsUri {
  if (-not (Test-Path $runLog)) { return $null }
  $m = Select-String -Path $runLog -Pattern 'http://127\.0\.0\.1:\d+/[^/\s]+/' | Select-Object -Last 1
  if (-not $m) { return $null }
  $http = $m.Matches[0].Value.TrimEnd('/')
  return ($http -replace '^http', 'ws') + '/ws'
}

$ws = $null
$deadline = (Get-Date).AddMinutes(4)
while ((Get-Date) -lt $deadline) {
  $ws = Get-WsUri
  if ($ws) { break }
  if ($proc.HasExited) { throw "flutter run exited early: $($proc.ExitCode)" }
  Start-Sleep -Milliseconds 400
}
if (-not $ws) { throw 'Timed out waiting for VM service URI' }
Write-Host "VM WS: $ws"

# Wait until KinApp first frame appears in logcat / run log
$readyDeadline = (Get-Date).AddMinutes(2)
$ready = $false
while ((Get-Date) -lt $readyDeadline) {
  if (Select-String -Path $runLog -Pattern 'PHASE7 kinApp_firstFrame' -Quiet) {
    $ready = $true
    break
  }
  $logcat = & $adb -s emulator-5554 logcat -d -t 80 2>$null | Out-String
  if ($logcat -match 'PHASE7 kinApp_firstFrame') {
    $ready = $true
    break
  }
  Start-Sleep -Milliseconds 300
}
if (-not $ready) { Write-Host 'WARNING: kinApp_firstFrame mark not seen; continuing anyway' }
else { Write-Host 'Saw kinApp_firstFrame' }

# Give a moment for the expensive frame timings to flush into the timeline
Start-Sleep -Seconds 2

function Dump-Timeline([string]$name, [int]$seconds) {
  Write-Host "Dumping $name (${seconds}s record window)…"
  Push-Location $toolDir
  try {
    dart run bin/phase7_vm_timeline.dart $ws "$outDir\$name.json" $seconds
  } finally {
    Pop-Location
  }
}

# The first dump includes whatever is still buffered since streams were enabled
# by the dump tool itself (it clears then waits). For cold start we need streams
# enabled BEFORE mount — so force-stop + cold am start while connected.

Write-Host 'Preparing cold-start capture while VM stays attached via flutter tools…'
# Clear+arm happens inside dump script; force cold activity restart first with
# a wrapper that arms recording then relaunches.

# Custom cold capture: arm for 0s clear, then restart activity, then record 8s
@'
import 'dart:convert';
import 'dart:io';
import 'package:vm_service/vm_service_io.dart';

Future<void> main(List<String> args) async {
  final ws = args[0];
  final out = args[1];
  final mode = args[2]; // cold | tabs
  final service = await vmServiceConnectUri(ws);
  await service.setVMTimelineFlags(['Dart', 'Embedder', 'GC', 'API']);
  await service.clearVMTimeline();
  stderr.writeln('ARMED mode=$mode');
  if (mode == 'cold') {
    // Caller restarts the activity; wait for mount window.
    await Future<void>.delayed(const Duration(seconds: 10));
  } else {
    await Future<void>.delayed(const Duration(seconds: 14));
  }
  final timeline = await service.getVMTimeline();
  final events = timeline.traceEvents ?? [];
  final raw = [for (final e in events) Map<String, Object?>.from(e.json ?? const {})];
  await File(out).writeAsString(JsonEncoder.withIndent('  ').convert({
    'type': 'Phase7TimelineDump',
    'mode': mode,
    'eventCount': raw.length,
    'traceEvents': raw,
  }));
  stderr.writeln('WROTE ${raw.length} events -> $out');
  // Print quick hotspot summary to stderr
  final byName = <String, List<double>>{};
  for (final e in raw) {
    if (e['ph'] != 'X') continue;
    final name = (e['name'] as String?) ?? '';
    final dur = (e['dur'] as num?)?.toDouble();
    if (dur == null || dur <= 0) continue;
    byName.putIfAbsent('$name|tid=${e['tid']}', () => []).add(dur);
  }
  final ranked = byName.entries.toList()
    ..sort((a, b) {
      final am = a.value.reduce((x, y) => x > y ? x : y);
      final bm = b.value.reduce((x, y) => x > y ? x : y);
      return bm.compareTo(am);
    });
  for (final e in ranked.take(40)) {
    final max = e.value.reduce((x, y) => x > y ? x : y);
    stderr.writeln('${max.round().toString().padLeft(8)} max  n=${e.value.length}  ${e.key}');
  }
  await service.dispose();
}
'@ | Set-Content -Encoding utf8 "$toolDir\bin\phase7_arm_dump.dart"

# Cold start: arm recording, then force-stop + am start (flutter tools keeps DDS
# if using same process — actually force-stop KILLS the isolate and breaks WS).
# So cold capture must happen on the INITIAL launch. Re-run flutter from scratch
# with an arming race.

Write-Host 'Cold start already happened on this flutter run; dumping residual buffer then capturing tabs.'
Dump-Timeline 'session_after_mount' 2

# Tab captures: clear inside tool, then tap during the record window
Write-Host 'Capturing first Kin visit…'
$kinJob = Start-Job -ScriptBlock {
  param($toolDir, $ws, $out)
  Set-Location $toolDir
  dart run bin/phase7_vm_timeline.dart $ws $out 6
} -ArgumentList $toolDir, $ws, "$outDir\first_kin.json"
Start-Sleep -Seconds 1
& $adb -s emulator-5554 shell input tap 270 2330
Wait-Job $kinJob | Out-Null
Receive-Job $kinJob
Remove-Job $kinJob

Write-Host 'Capturing first Journal visit…'
$journalJob = Start-Job -ScriptBlock {
  param($toolDir, $ws, $out)
  Set-Location $toolDir
  dart run bin/phase7_vm_timeline.dart $ws $out 6
} -ArgumentList $toolDir, $ws, "$outDir\first_journal.json"
Start-Sleep -Seconds 1
& $adb -s emulator-5554 shell input tap 810 2330
Wait-Job $journalJob | Out-Null
Receive-Job $journalJob
Remove-Job $journalJob

Write-Host 'Capturing Today revisit…'
$todayJob = Start-Job -ScriptBlock {
  param($toolDir, $ws, $out)
  Set-Location $toolDir
  dart run bin/phase7_vm_timeline.dart $ws $out 5
} -ArgumentList $toolDir, $ws, "$outDir\today_revisit.json"
Start-Sleep -Seconds 1
& $adb -s emulator-5554 shell input tap 540 2330
Wait-Job $todayJob | Out-Null
Receive-Job $todayJob
Remove-Job $todayJob

Write-Host 'Done. Stopping flutter run.'
Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
