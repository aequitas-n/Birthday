import 'dart:convert';
import 'dart:io';

/// Compute exclusive (self) time for nested B/E events on one thread.
void main(List<String> args) {
  final path = args.first;
  final d = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  final ev = (d['traceEvents'] as List).cast<Map<String, dynamic>>();

  // Map tid -> thread name
  final threadNames = <Object?, String>{};
  for (final e in ev) {
    if (e['ph'] == 'M' && e['name'] == 'thread_name') {
      final argsMap = e['args'];
      if (argsMap is Map && argsMap['name'] != null) {
        threadNames[e['tid']] = '${argsMap['name']}';
      }
    }
  }
  stdout.writeln('Threads:');
  for (final e in threadNames.entries) {
    stdout.writeln('  tid=${e.key} name=${e.value}');
  }

  // Find UI thread as the one with BUILD events
  Object? uiTid;
  for (final e in ev) {
    if (e['name'] == 'BUILD' && e['ph'] == 'B') {
      uiTid = e['tid'];
      break;
    }
  }
  stdout.writeln('UI tid=$uiTid (${threadNames[uiTid]})');

  // Build inclusive spans then exclusive via nest stack
  final stack = <_Open>[];
  final exclusive = <String, _Agg>{};
  final inclusive = <String, _Agg>{};

  void add(Map<String, _Agg> m, String name, double us) {
    final a = m.putIfAbsent(name, _Agg.new);
    a.count++;
    a.totalUs += us;
    if (us > a.maxUs) a.maxUs = us;
  }

  final sorted = ev.where((e) => e['tid'] == uiTid).toList()
    ..sort((a, b) {
      final ats = (a['ts'] as num?) ?? 0;
      final bts = (b['ts'] as num?) ?? 0;
      final c = ats.compareTo(bts);
      if (c != 0) return c;
      // Process ends before begins at same ts for proper nesting? Actually
      // Chrome format processes B before E at same timestamp typically by order.
      return 0;
    });

  for (final e in sorted) {
    final ph = e['ph'];
    final name = '${e['name']}';
    final ts = (e['ts'] as num?)?.toDouble();
    if (ts == null) continue;
    if (ph == 'B') {
      stack.add(_Open(name, ts));
    } else if (ph == 'E' && stack.isNotEmpty) {
      // Find matching name from top
      var idx = stack.length - 1;
      while (idx >= 0 && stack[idx].name != name) {
        idx--;
      }
      if (idx < 0) continue;
      final open = stack.removeAt(idx);
      final incl = ts - open.startTs;
      final excl = incl - open.childUs;
      add(inclusive, name, incl);
      add(exclusive, name, excl);
      if (stack.isNotEmpty) {
        stack.last.childUs += incl;
      }
    }
  }

  void printTop(String title, Map<String, _Agg> m, {int n = 40}) {
    stdout.writeln('\n=== $title ===');
    final ranked = m.entries.toList()
      ..sort((a, b) => b.value.maxUs.compareTo(a.value.maxUs));
    for (final e in ranked.take(n)) {
      final a = e.value;
      stdout.writeln(
        '${a.maxUs.round().toString().padLeft(8)} max  '
        '${a.totalUs.round().toString().padLeft(10)} sum  '
        'n=${a.count.toString().padLeft(4)}  ${e.key}',
      );
    }
  }

  printTop('UI exclusive max (self time)', exclusive, n: 60);
  printTop('UI inclusive max', inclusive, n: 40);

  // Raster-ish threads
  stdout.writeln('\n=== Non-UI thread long B/E spans ===');
  final stack2 = <Object?, List<_Open>>{};
  final rasterExcl = <String, _Agg>{};
  for (final e in ev) {
    final tid = e['tid'];
    if (tid == uiTid) continue;
    final ph = e['ph'];
    final name = '${e['name']}';
    final ts = (e['ts'] as num?)?.toDouble();
    if (ts == null) continue;
    final st = stack2.putIfAbsent(tid, () => <_Open>[]);
    if (ph == 'B') {
      st.add(_Open(name, ts));
    } else if (ph == 'E' && st.isNotEmpty) {
      var idx = st.length - 1;
      while (idx >= 0 && st[idx].name != name) {
        idx--;
      }
      if (idx < 0) continue;
      final open = st.removeAt(idx);
      final incl = ts - open.startTs;
      final excl = incl - open.childUs;
      final key = '$name [${threadNames[tid] ?? tid}]';
      add(rasterExcl, key, excl);
      if (st.isNotEmpty) st.last.childUs += incl;
    }
  }
  printTop('Non-UI exclusive', rasterExcl, n: 40);

  // Highlight design-system widgets
  stdout.writeln('\n=== Kin/Quiet widget exclusive (filtered) ===');
  final filtered = exclusive.entries.where((e) {
    final n = e.key;
    return n.startsWith('Q') ||
        n.contains('Today') ||
        n.contains('Journal') ||
        n.contains('Home') ||
        n.contains('Mood') ||
        n.contains('Nav') ||
        n.contains('Theme') ||
        n.contains('Backdrop') ||
        n.contains('Screen') ||
        n.contains('Card') ||
        n.contains('Image') ||
        n.contains('Paint') ||
        n.contains('Clip') ||
        n.contains('Opacity') ||
        n.contains('Fade') ||
        n.contains('Animated') ||
        n.contains('CustomPaint') ||
        n.contains('ImageFiltered') ||
        n.contains('ShaderMask') ||
        n.contains('BackdropFilter') ||
        n.contains('SaveLayer') ||
        n == 'BUILD' ||
        n == 'LAYOUT' ||
        n == 'PAINT' ||
        n.startsWith('LAYOUT') ||
        n.startsWith('PAINT');
  }).toList()..sort((a, b) => b.value.maxUs.compareTo(a.value.maxUs));
  for (final e in filtered.take(50)) {
    stdout.writeln(
      '${e.value.maxUs.round().toString().padLeft(8)} max  ${e.key}',
    );
  }
}

final class _Open {
  _Open(this.name, this.startTs);
  final String name;
  final double startTs;
  double childUs = 0;
}

final class _Agg {
  var count = 0;
  var totalUs = 0.0;
  var maxUs = 0.0;
}
