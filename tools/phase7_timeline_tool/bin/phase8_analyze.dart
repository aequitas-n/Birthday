import 'dart:convert';
import 'dart:io';

void main() {
  final path = r'e:\~Work\Birthday\tmp\phase8\fresh_session.json';
  final d = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  final ev = (d['traceEvents'] as List).cast<Map<String, dynamic>>();
  print('eventCount=${ev.length}');

  final marks = <String, num>{};
  for (final e in ev) {
    final n = '${e['name']}';
    if (n.startsWith('PHASE7_') && e['ph'] == 'B') {
      marks[n] = e['ts'] as num;
      print('mark $n ts=${e['ts']}');
    }
  }

  bool interesting(String n) =>
      n.contains('Home') ||
      n.contains('Birthday') ||
      n.contains('Gallery') ||
      n.contains('Portrait') ||
      n.contains('Relationship') ||
      n.contains('Journal') ||
      n.contains('GridView') ||
      n.contains('Calendar') ||
      n.contains('PageView') ||
      n.contains('LAYOUT') ||
      n == 'BUILD' ||
      n.contains('Decompress') ||
      n.contains('GPURaster') ||
      n.contains('ImageFiltered') ||
      n.contains('Timeline') ||
      n.contains('QScreen') ||
      n.contains('QMeasure');

  final names = <String>{};
  for (final e in ev) {
    final n = '${e['name']}';
    if (interesting(n)) names.add(n);
  }
  print('interesting names:\n${names.join('\n')}');

  final sortedMarks = marks.entries.toList()
    ..sort((a, b) => a.value.compareTo(b.value));

  // Also synthesize a start-of-recording window before first mark
  final windows = <MapEntry<String, num>>[
    if (sortedMarks.isNotEmpty)
      MapEntry('BEFORE_FIRST_MARK', sortedMarks.first.value - 1),
    ...sortedMarks,
  ];

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
    for (final e in durs.take(25)) {
      print('  ${e.$1.round().toString().padLeft(8)}  ${e.$2}');
    }
  }

  // Verify HomeScreen first build exists after tab_kin
  final kinTs = marks['PHASE7_tab_kin'];
  if (kinTs == null) {
    print('\nFAIL: PHASE7_tab_kin missing — not a valid first-Kin capture');
    return;
  }
  var homeBuilds = 0;
  var birthdayBuilds = 0;
  var galleryBuilds = 0;
  for (final e in ev) {
    final ts = e['ts'];
    if (ts is! num || ts < kinTs) continue;
    if (e['ph'] != 'B') continue;
    final n = '${e['name']}';
    if (n == 'HomeScreen') homeBuilds++;
    if (n.contains('BirthdayTimeline')) birthdayBuilds++;
    if (n.contains('RelationshipGallery') || n.contains('PortraitGallery')) {
      galleryBuilds++;
    }
  }
  print('\nAfter tab_kin: HomeScreen B=$homeBuilds BirthdayTimeline B=$birthdayBuilds Gallery/Portrait B=$galleryBuilds');
  if (homeBuilds > 0) {
    print('SUCCESS: first Kin mount includes HomeScreen builds');
  } else {
    print('WARN: HomeScreen build events not found (profiling name mismatch?)');
  }
}
