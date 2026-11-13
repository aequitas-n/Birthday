import 'dart:convert';
import 'dart:io';

void main() {
  final d = jsonDecode(File(r'e:\~Work\Birthday\tmp\phase7\tabs_session.json').readAsStringSync());
  final ev = (d['traceEvents'] as List).cast<Map>();
  final marks = <String, num>{};
  for (final e in ev) {
    final n = '${e['name']}';
    if (n.startsWith('PHASE7_') && e['ph'] == 'B') marks[n] = e['ts'] as num;
  }
  print('marks=$marks');
  final sorted = marks.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
  for (var i = 0; i < sorted.length; i++) {
    final start = sorted[i].value;
    final end = i + 1 < sorted.length ? sorted[i + 1].value : start + 5000000;
    final stack = <String, List<num>>{};
    final durs = <(double, String)>[];
    for (final e in ev) {
      final ts = e['ts'];
      if (ts is! num || ts < start || ts > end) continue;
      final name = '${e['name']}';
      final tid = e['tid'];
      final key = '$tid::$name';
      if (e['ph'] == 'B') {
        stack.putIfAbsent(key, () => <num>[]).add(ts);
      }
      if (e['ph'] == 'E' && (stack[key]?.isNotEmpty ?? false)) {
        final b = stack[key]!.removeLast();
        durs.add(((ts - b).toDouble(), name));
      }
    }
    durs.sort((a, b) => b.$1.compareTo(a.$1));
    print('\n=== Window ${sorted[i].key} ===');
    for (final e in durs.take(20)) {
      print('  ${e.$1.round()}  ${e.$2}');
    }
  }
}
