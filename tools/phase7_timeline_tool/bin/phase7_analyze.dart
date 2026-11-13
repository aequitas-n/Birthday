import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

void main(List<String> args) {
  final path = args.first;
  final d = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  final ev = (d['traceEvents'] as List).cast<Map<String, dynamic>>();
  stdout.writeln('count=${ev.length}');

  final ph = <String, int>{};
  final names = <String, int>{};
  for (final e in ev) {
    ph['${e['ph']}'] = (ph['${e['ph']}'] ?? 0) + 1;
    names['${e['name']}'] = (names['${e['name']}'] ?? 0) + 1;
  }
  stdout.writeln('ph=$ph');
  stdout.writeln('\nTop names by count:');
  final nameRank = names.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  for (final e in nameRank.take(40)) {
    stdout.writeln('  ${e.value}\t${e.key}');
  }

  stdout.writeln('\nSample events:');
  for (final e in ev.take(12)) {
    stdout.writeln(
      '  ph=${e['ph']} name=${e['name']} dur=${e['dur']} '
      'tdur=${e['tdur']} ts=${e['ts']} tid=${e['tid']} cat=${e['cat']}',
    );
  }

  final xs =
      ev
          .where((e) => e['ph'] == 'X' && e['dur'] is num)
          .map(
            (e) => (
              (e['dur'] as num).toDouble(),
              '${e['name']}',
              e['tid'],
              '${e['cat']}',
            ),
          )
          .toList()
        ..sort((a, b) => b.$1.compareTo(a.$1));
  stdout.writeln('\nTop ph=X by dur (µs): ${xs.length} events');
  for (final e in xs.take(40)) {
    stdout.writeln(
      '  ${e.$1.round().toString().padLeft(8)}  ${e.$2}  tid=${e.$3} cat=${e.$4}',
    );
  }

  // Pair B/E
  final stack = <String, List<num>>{};
  final be = <(double, String, Object?)>[];
  for (final e in ev) {
    final name = '${e['name']}';
    final tid = e['tid'];
    final key = '$tid::$name';
    final ts = e['ts'];
    if (e['ph'] == 'B' && ts is num) {
      stack.putIfAbsent(key, () => <num>[]).add(ts);
    } else if (e['ph'] == 'E' && ts is num) {
      final s = stack[key];
      if (s != null && s.isNotEmpty) {
        final b = s.removeLast();
        be.add(((ts - b).toDouble(), name, tid));
      }
    }
  }
  be.sort((a, b) => b.$1.compareTo(a.$1));
  stdout.writeln('\nTop B/E spans (µs):');
  for (final e in be.take(50)) {
    stdout.writeln(
      '  ${e.$1.round().toString().padLeft(8)}  ${e.$2}  tid=${e.$3}',
    );
  }

  // Interesting filters
  bool interesting(String n) {
    final x = n.toLowerCase();
    return x.contains('build') ||
        x.contains('layout') ||
        x.contains('paint') ||
        x.contains('raster') ||
        x.contains('shader') ||
        x.contains('image') ||
        x.contains('picture') ||
        x.contains('layer') ||
        x.contains('phase7') ||
        x.contains('frame') ||
        x.contains('impeller') ||
        x.contains('clip') ||
        x.contains('opacity') ||
        x.contains('savelayer') ||
        x.contains('animate') ||
        x.contains('composit');
  }

  stdout.writeln('\nInteresting X events:');
  for (final e in xs.where((e) => interesting(e.$2)).take(50)) {
    stdout.writeln('  ${e.$1.round().toString().padLeft(8)}  ${e.$2}');
  }
  stdout.writeln('\nInteresting B/E spans:');
  for (final e in be.where((e) => interesting(e.$2)).take(50)) {
    stdout.writeln('  ${e.$1.round().toString().padLeft(8)}  ${e.$2}');
  }

  // PHASE7 marks
  stdout.writeln('\nPHASE7 markers:');
  for (final e in ev.where((e) => '${e['name']}'.contains('PHASE7'))) {
    stdout.writeln('  ph=${e['ph']} name=${e['name']} ts=${e['ts']}');
  }
}
