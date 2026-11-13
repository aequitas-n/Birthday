import 'dart:convert';
import 'dart:io';

void main() {
  final d = jsonDecode(File(r'e:\~Work\Birthday\tmp\phase7\tabs_session.json').readAsStringSync());
  final ev = (d['traceEvents'] as List).cast<Map>();
  final names = <String>{};
  for (final e in ev) {
    final n = '${e['name']}';
    if (n.contains('Home') ||
        n.contains('Kin') ||
        n.contains('Gallery') ||
        n.contains('Portrait') ||
        n.contains('PHASE7') ||
        n.contains('Journal') ||
        n.contains('Calendar') ||
        n.contains('GridView') ||
        n.contains('ImageFiltered') ||
        n.contains('Decompress')) {
      names.add(n);
    }
  }
  print(names.join('\n'));
  print('---');
  // Find first HomeScreen or similar B/E
  final stack = <String, List<num>>{};
  final durs = <(double, String)>[];
  for (final e in ev) {
    final name = '${e['name']}';
    final tid = e['tid'];
    final key = '$tid::$name';
    final ts = e['ts'];
    if (ts is! num) continue;
    if (e['ph'] == 'B') stack.putIfAbsent(key, () => <num>[]).add(ts);
    if (e['ph'] == 'E' && (stack[key]?.isNotEmpty ?? false)) {
      final b = stack[key]!.removeLast();
      if (name.contains('Home') ||
          name.contains('Gallery') ||
          name.contains('Portrait') ||
          name.contains('Journal') ||
          name.contains('GridView') ||
          name.contains('Calendar') ||
          name.contains('ImageFiltered') ||
          name.contains('Decompress') ||
          name.contains('LAYOUT') ||
          name == 'BUILD') {
        durs.add(((ts - b).toDouble(), name));
      }
    }
  }
  durs.sort((a, b) => b.$1.compareTo(a.$1));
  for (final e in durs.take(40)) {
    print('${e.$1.round().toString().padLeft(8)}  ${e.$2}');
  }
}
