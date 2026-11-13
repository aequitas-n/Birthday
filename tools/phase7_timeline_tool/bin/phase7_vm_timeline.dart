/// Phase 7: connect to a Flutter VM service and dump a DevTools-compatible
/// timeline JSON, plus a hotspot summary.
///
/// Usage:
///   dart run tools/phase7_vm_timeline.dart <ws-uri> <out.json> [seconds]
///
/// Example ws-uri (from `flutter run` / logcat):
///   ws://127.0.0.1:12345/authCode=/ws
library;

import 'dart:convert';
import 'dart:io';

import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

Future<void> main(List<String> args) async {
  if (args.length < 2) {
    stderr.writeln(
      'Usage: dart run tools/phase7_vm_timeline.dart '
      '<ws-uri> <out.json> [recordSeconds=12]',
    );
    exit(64);
  }

  final uri = args[0];
  final outPath = args[1];
  final seconds = args.length > 2 ? int.parse(args[2]) : 12;

  stdout.writeln('Connecting to $uri');
  final service = await vmServiceConnectUri(uri);

  await service.setVMTimelineFlags([
    'Dart',
    'Embedder',
    'GC',
    'API',
  ]);
  await service.clearVMTimeline();
  stdout.writeln('Timeline recording for ${seconds}s …');
  await Future<void>.delayed(Duration(seconds: seconds));

  final timeline = await service.getVMTimeline();
  final events = timeline.traceEvents ?? <TimelineEvent>[];
  stdout.writeln('Collected ${events.length} timeline events');

  final raw = <Map<String, Object?>>[
    for (final e in events) Map<String, Object?>.from(e.json ?? const {}),
  ];

  final file = File(outPath);
  await file.parent.create(recursive: true);
  await file.writeAsString(
    const JsonEncoder.withIndent('  ').convert({
      'type': 'Phase7TimelineDump',
      'eventCount': raw.length,
      'traceEvents': raw,
    }),
  );
  stdout.writeln('Wrote $outPath');

  _printHotspots(raw);
  await service.dispose();
}

void _printHotspots(List<Map<String, Object?>> events) {
  // Aggregate complete events (ph=X) by name on UI vs GPU/raster threads.
  final byName = <String, _Agg>{};

  for (final e in events) {
    final ph = e['ph'] as String?;
    if (ph != 'X' && ph != 'B' && ph != 'E') continue;
    final name = (e['name'] as String?) ?? '(unnamed)';
    final dur = (e['dur'] as num?)?.toDouble(); // microseconds for ph=X
    if (dur == null || dur <= 0) continue;
    final tid = e['tid'];
    final key = '$name | tid=$tid';
    final agg = byName.putIfAbsent(key, _Agg.new);
    agg.count++;
    agg.totalUs += dur;
    if (dur > agg.maxUs) agg.maxUs = dur;
  }

  final ranked = byName.entries.toList()
    ..sort((a, b) => b.value.maxUs.compareTo(a.value.maxUs));

  stdout.writeln('\n=== Top 40 events by max duration (µs) ===');
  for (final entry in ranked.take(40)) {
    final a = entry.value;
    stdout.writeln(
      '${a.maxUs.round().toString().padLeft(8)} max  '
      '${a.totalUs.round().toString().padLeft(10)} sum  '
      'n=${a.count.toString().padLeft(4)}  ${entry.key}',
    );
  }

  // Highlight Flutter framework categories of interest.
  final interesting = ranked.where((e) {
    final n = e.key.toLowerCase();
    return n.contains('build') ||
        n.contains('layout') ||
        n.contains('paint') ||
        n.contains('raster') ||
        n.contains('shader') ||
        n.contains('image') ||
        n.contains('picture') ||
        n.contains('layer') ||
        n.contains('phase7') ||
        n.contains('frame') ||
        n.contains('impeller') ||
        n.contains('savelayer') ||
        n.contains('clip') ||
        n.contains('opacity');
  }).toList();

  stdout.writeln('\n=== Filtered framework/raster-interest (top 50 by max) ===');
  for (final entry in interesting.take(50)) {
    final a = entry.value;
    stdout.writeln(
      '${a.maxUs.round().toString().padLeft(8)} max  '
      'n=${a.count.toString().padLeft(4)}  ${entry.key}',
    );
  }
}

final class _Agg {
  var count = 0;
  var totalUs = 0.0;
  var maxUs = 0.0;
}
