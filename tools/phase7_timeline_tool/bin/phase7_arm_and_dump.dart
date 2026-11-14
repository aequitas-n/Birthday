import 'dart:convert';
import 'dart:io';

import 'package:vm_service/vm_service_io.dart';

/// Arm timeline streams, wait `seconds`, dump without an intermediate clear
/// after wait starts (clear happens once at arm time).
Future<void> main(List<String> args) async {
  if (args.length < 3) {
    stderr.writeln(
      'Usage: dart run bin/phase7_arm_and_dump.dart <ws> <out.json> <seconds>',
    );
    exit(64);
  }
  final ws = args[0];
  final out = args[1];
  final seconds = int.parse(args[2]);

  final service = await vmServiceConnectUri(ws);
  await service.setVMTimelineFlags(['Dart', 'Embedder', 'GC', 'API']);
  await service.clearVMTimeline();
  stderr.writeln('ARMED; recording ${seconds}s');
  await Future<void>.delayed(Duration(seconds: seconds));

  final timeline = await service.getVMTimeline();
  final events = timeline.traceEvents ?? [];
  final raw = [
    for (final e in events) Map<String, Object?>.from(e.json ?? const {}),
  ];
  await File(out).writeAsString(
    const JsonEncoder.withIndent('  ').convert({
      'type': 'Phase7TimelineDump',
      'eventCount': raw.length,
      'traceEvents': raw,
    }),
  );
  stderr.writeln('WROTE ${raw.length} -> $out');

  final byName = <String, List<double>>{};
  for (final e in raw) {
    if (e['ph'] != 'X') continue;
    final name = (e['name'] as String?) ?? '';
    final dur = (e['dur'] as num?)?.toDouble();
    if (dur == null || dur <= 0) continue;
    byName.putIfAbsent('$name | tid=${e['tid']}', () => <double>[]).add(dur);
  }
  final ranked = byName.entries.toList()
    ..sort((a, b) {
      final am = a.value.reduce((x, y) => x > y ? x : y);
      final bm = b.value.reduce((x, y) => x > y ? x : y);
      return bm.compareTo(am);
    });
  stderr.writeln('=== Top 50 by max µs ===');
  for (final e in ranked.take(50)) {
    final max = e.value.reduce((x, y) => x > y ? x : y);
    stderr.writeln(
      '${max.round().toString().padLeft(8)} max  '
      'n=${e.value.length.toString().padLeft(4)}  ${e.key}',
    );
  }

  // Widget BUILD events (from debugProfileBuildsEnabled)
  final builds = ranked.where((e) {
    final n = e.key;
    return n.contains('BUILD ') ||
        n.startsWith('BUILD') ||
        n.contains('| BUILD') ||
        (n.contains('BUILD') && !n.contains('Shader'));
  });
  stderr.writeln('=== BUILD-like events (top 40) ===');
  for (final e in builds.take(40)) {
    final max = e.value.reduce((x, y) => x > y ? x : y);
    stderr.writeln(
      '${max.round().toString().padLeft(8)} max  n=${e.value.length}  ${e.key}',
    );
  }

  final paints = ranked.where((e) => e.key.toUpperCase().contains('PAINT'));
  stderr.writeln('=== PAINT-like events (top 40) ===');
  for (final e in paints.take(40)) {
    final max = e.value.reduce((x, y) => x > y ? x : y);
    stderr.writeln(
      '${max.round().toString().padLeft(8)} max  n=${e.value.length}  ${e.key}',
    );
  }

  await service.dispose();
}
