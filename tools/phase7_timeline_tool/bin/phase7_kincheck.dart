import 'dart:convert';
import 'dart:io';

void main() {
  final d =
      jsonDecode(
            File(
              r'e:\~Work\Birthday\tmp\phase7\first_kin_only.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final ev = (d['traceEvents'] as List<dynamic>).cast<Map<String, dynamic>>();
  print('count=${ev.length}');
  for (final e in ev) {
    final n = '${e['name']}';
    if (n.contains('PHASE7') ||
        n.contains('Home') ||
        n.contains('Gallery') ||
        n.contains('Portrait')) {
      print('${e['ph']} $n');
    }
  }
  final stack = <String, List<num>>{};
  final durs = <(double, String)>[];
  for (final e in ev) {
    final name = '${e['name']}';
    final key = '${e['tid']}::$name';
    final ts = e['ts'];
    if (ts is! num) continue;
    if (e['ph'] == 'B') stack.putIfAbsent(key, () => <num>[]).add(ts);
    if (e['ph'] == 'E' && (stack[key]?.isNotEmpty ?? false)) {
      final b = stack[key]!.removeLast();
      durs.add(((ts - b).toDouble(), name));
    }
  }
  durs.sort((a, b) => b.$1.compareTo(a.$1));
  print('Top spans:');
  for (final e in durs.take(25)) {
    print('  ${e.$1.round()} ${e.$2}');
  }
}
