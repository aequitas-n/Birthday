import 'dart:convert';
import 'dart:io';

void main() {
  final d = jsonDecode(File(r'e:\~Work\Birthday\tmp\phase8\fresh_session.json').readAsStringSync());
  final ev = (d['traceEvents'] as List).cast<Map>();
  final marks = <String, num>{
    for (final e in ev)
      if ('${e['name']}'.startsWith('PHASE7_') && e['ph'] == 'B')
        '${e['name']}': e['ts'] as num,
  };

  void exclusiveWindow(String label, num start, num end) {
    // UI thread = tid of BUILD
    Object? uiTid;
    for (final e in ev) {
      if (e['name'] == 'BUILD' && e['ph'] == 'B') {
        uiTid = e['tid'];
        break;
      }
    }
    final stack = <_Open>[];
    final excl = <String, double>{};
    final incl = <String, double>{};
    void add(Map<String, double> m, String n, double us) {
      m[n] = (m[n] ?? 0) > us ? m[n]! : us; // store max
    }

    final sorted = ev.where((e) => e['tid'] == uiTid).toList()
      ..sort((a, b) => ((a['ts'] as num?) ?? 0).compareTo((b['ts'] as num?) ?? 0));
    for (final e in sorted) {
      final ts = e['ts'];
      if (ts is! num || ts < start || ts > end) continue;
      final name = '${e['name']}';
      if (e['ph'] == 'B') {
        stack.add(_Open(name, ts.toDouble()));
      } else if (e['ph'] == 'E' && stack.isNotEmpty) {
        var idx = stack.length - 1;
        while (idx >= 0 && stack[idx].name != name) idx--;
        if (idx < 0) continue;
        final open = stack.removeAt(idx);
        final i = ts.toDouble() - open.start;
        final x = i - open.child;
        add(incl, name, i);
        add(excl, name, x);
        if (stack.isNotEmpty) stack.last.child += i;
      }
    }
    print('\n=== $label UI exclusive max ===');
    final er = excl.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    for (final e in er.take(25)) {
      print('  ${e.value.round().toString().padLeft(8)}  ${e.key}');
    }
    print('=== $label UI inclusive max ===');
    final ir = incl.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    for (final e in ir.take(20)) {
      print('  ${e.value.round().toString().padLeft(8)}  ${e.key}');
    }
  }

  final kin = marks['PHASE7_tab_kin']!;
  final journal = marks['PHASE7_tab_journal']!;
  final today = marks['PHASE7_tab_today']!;
  exclusiveWindow('KIN', kin, journal);
  exclusiveWindow('JOURNAL', journal, today);
}

class _Open {
  _Open(this.name, this.start);
  final String name;
  final double start;
  double child = 0;
}
