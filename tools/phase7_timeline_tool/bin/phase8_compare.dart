import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final path = args.first;
  final d = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  final ev = (d['traceEvents'] as List).cast<Map<String, dynamic>>();
  print('file=$path eventCount=${ev.length}');
  final marks = <String, num>{};
  for (final e in ev) {
    final n = '${e['name']}';
    if (n.startsWith('PHASE7_') && e['ph'] == 'B') {
      marks[n] = e['ts'] as num;
      print('mark $n');
    }
  }
  final sortedMarks = marks.entries.toList()
    ..sort((a, b) => a.value.compareTo(b.value));
  for (var i = 0; i < sortedMarks.length; i++) {
    final start = sortedMarks[i].value;
    final end = i + 1 < sortedMarks.length
        ? sortedMarks[i + 1].value
        : start + 5000000;
    final stack = <String, List<num>>{};
    final durs = <(double, String)>[];
    for (final e in ev) {
      final ts = e['ts'];
      if (ts is! num || ts < start || ts > end) continue;
      final name = '${e['name']}';
      final key = '${e['tid']}::$name';
      if (e['ph'] == 'B') {
        stack.putIfAbsent(key, () => <num>[]).add(ts);
      } else if (e['ph'] == 'E' && (stack[key]?.isNotEmpty ?? false)) {
        final b = stack[key]!.removeLast();
        durs.add(((ts - b).toDouble(), name));
      }
    }
    durs.sort((a, b) => b.$1.compareTo(a.$1));
    print('\n=== ${sortedMarks[i].key} ===');
    for (final e in durs.take(18)) {
      print('  ${e.$1.round().toString().padLeft(8)}  ${e.$2}');
    }
  }

  // exclusive LAYOUT/BUILD/GridView for journal window
  final kin = marks['PHASE7_tab_kin'];
  final journal = marks['PHASE7_tab_journal'];
  final today = marks['PHASE7_tab_today'];
  if (journal == null || today == null) return;
  Object? uiTid;
  for (final e in ev) {
    if (e['name'] == 'BUILD' && e['ph'] == 'B') {
      uiTid = e['tid'];
      break;
    }
  }
  final stack = <_Open>[];
  double layoutEx = 0;
  double buildEx = 0;
  double gridIncl = 0;
  double layoutIncl = 0;
  double frame = 0;
  final sorted = ev.where((e) => e['tid'] == uiTid).toList()
    ..sort(
      (a, b) => ((a['ts'] as num?) ?? 0).compareTo((b['ts'] as num?) ?? 0),
    );
  for (final e in sorted) {
    final ts = e['ts'];
    if (ts is! num || ts < journal || ts > today) continue;
    final name = '${e['name']}';
    if (e['ph'] == 'B') {
      stack.add(_Open(name, ts.toDouble()));
    } else if (e['ph'] == 'E' && stack.isNotEmpty) {
      var idx = stack.length - 1;
      while (idx >= 0 && stack[idx].name != name) {
        idx--;
      }
      if (idx < 0) continue;
      final open = stack.removeAt(idx);
      final incl = ts.toDouble() - open.start;
      final excl = incl - open.child;
      if (name == 'LAYOUT' && excl > layoutEx) layoutEx = excl;
      if (name == 'BUILD' && excl > buildEx) buildEx = excl;
      if (name == 'LAYOUT' && incl > layoutIncl) layoutIncl = incl;
      if (name == 'GridView' && incl > gridIncl) gridIncl = incl;
      if (name == 'VsyncProcessCallback' && incl > frame) frame = incl;
      if (stack.isNotEmpty) stack.last.child += incl;
    }
  }
  print(
    '\nJOURNAL summary: frame=${frame.round()} layoutEx=${layoutEx.round()} layoutIncl=${layoutIncl.round()} buildEx=${buildEx.round()} gridIncl=${gridIncl.round()}',
  );
  if (kin != null) {
    print('Kin mark present (first visit armed before tap)');
  }
}

class _Open {
  _Open(this.name, this.start);
  final String name;
  final double start;
  double child = 0;
}
