// Architecture guard for Kin.
//
// The analyzer cannot express "this layer may not import that layer" or
// "this widget is banned in this folder", and those are precisely the rules
// that keep the product from drifting back into looking like a stock Flutter
// app. This script enforces them.
//
// Run:  dart run tool/check_architecture.dart
// CI runs it on every push; a violation fails the build.
//
// Rules are specified in docs/03-design-philosophy.md and docs/09-architecture.md.

import 'dart:io';

void main(List<String> args) {
  final violations = <Violation>[];
  final libDir = Directory('lib');

  if (!libDir.existsSync()) {
    stderr.writeln('No lib/ directory found. Run from the project root.');
    exit(2);
  }

  final files = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.endsWith('.g.dart'))
      .where((f) => !f.path.endsWith('.freezed.dart'))
      .toList();

  for (final file in files) {
    final path = file.path.replaceAll(r'\', '/');
    final lines = file.readAsLinesSync();

    for (final rule in _rules) {
      if (!rule.appliesTo(path)) continue;
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (_isComment(line)) continue;
        if (rule.pattern.hasMatch(line)) {
          violations.add(
            Violation(
              path: path,
              line: i + 1,
              source: line.trim(),
              rule: rule,
            ),
          );
        }
      }
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('Architecture check passed. ${files.length} files scanned.');
    exit(0);
  }

  stderr.writeln(
    'Architecture check FAILED: ${violations.length} violation(s)\n',
  );

  final byRule = <String, List<Violation>>{};
  for (final v in violations) {
    byRule.putIfAbsent(v.rule.id, () => []).add(v);
  }

  for (final entry in byRule.entries) {
    final rule = entry.value.first.rule;
    stderr
      ..writeln('${rule.id}  ${rule.description}')
      ..writeln('    see ${rule.reference}');
    for (final v in entry.value) {
      stderr.writeln('    ${v.path}:${v.line}  ${v.source}');
    }
    stderr.writeln();
  }

  exit(1);
}

bool _isComment(String line) {
  final t = line.trimLeft();
  return t.startsWith('//') || t.startsWith('*') || t.startsWith('/*');
}

class Violation {
  Violation({
    required this.path,
    required this.line,
    required this.source,
    required this.rule,
  });

  final String path;
  final int line;
  final String source;
  final Rule rule;
}

class Rule {
  const Rule({
    required this.id,
    required this.description,
    required this.reference,
    required this.pattern,
    required this.include,
    this.exclude = const [],
  });

  final String id;
  final String description;
  final String reference;
  final RegExp pattern;

  /// Path fragments this rule applies to.
  final List<String> include;

  /// Path fragments that opt out.
  final List<String> exclude;

  bool appliesTo(String path) {
    if (exclude.any(path.contains)) return false;
    return include.any(path.contains);
  }
}

/// Widgets that carry an unmistakable Material signature. Banned outright in
/// the presentation layers; see docs/03 "Anti-patterns".
const _bannedWidgets = [
  'AppBar',
  'SliverAppBar',
  'Scaffold',
  'Card',
  'ListTile',
  'FloatingActionButton',
  'AlertDialog',
  'SimpleDialog',
  'CupertinoAlertDialog',
  'BottomNavigationBar',
  'NavigationBar',
  'NavigationRail',
  'Drawer',
  'TabBar',
  'Chip',
  'ActionChip',
  'FilterChip',
  'InputChip',
  'Divider',
  'VerticalDivider',
  'ElevatedButton',
  'FilledButton',
  'OutlinedButton',
  'TextButton',
  'IconButton',
  'TextField',
  'TextFormField',
  'Switch',
  'Checkbox',
  'Radio',
  'Slider',
  'SnackBar',
  'PopupMenuButton',
  'DropdownButton',
  'ExpansionTile',
  'CircularProgressIndicator',
  'LinearProgressIndicator',
  'showModalBottomSheet',
  'showDialog',
  'showDatePicker',
  'showTimePicker',
];

final _bannedWidgetPattern = RegExp(
  '(?<![A-Za-z0-9_])(${_bannedWidgets.join('|')})'
  r'\s*[(<.]',
);

final _rules = <Rule>[
  // ── Layer boundaries ────────────────────────────────────────────────────
  Rule(
    id: 'ARCH-01',
    description: 'domain/ must stay pure Dart — no Flutter, no persistence.',
    reference: 'docs/09-architecture.md §1',
    pattern: RegExp(
      r'''^\s*import\s+['"]package:(flutter|drift|firebase|cloud_firestore|flutter_riverpod)''',
    ),
    include: ['lib/domain/'],
  ),
  Rule(
    id: 'ARCH-02',
    description: 'design/ must not know about features or data.',
    reference: 'docs/09-architecture.md §1',
    pattern: RegExp(r'''^\s*import\s+['"].*(features|data|domain)/'''),
    include: ['lib/design/'],
  ),
  Rule(
    id: 'ARCH-03',
    description: 'A feature must not reach into another feature.',
    reference: 'docs/09-architecture.md §1',
    pattern: RegExp(r'''^\s*import\s+['"].*features/[a-z_]+/presentation/'''),
    include: ['lib/features/'],
  ),
  Rule(
    id: 'ARCH-04',
    description:
        'Widgets must not import raw tokens; read them from QuietTheme.',
    reference: 'docs/04-design-system.md §11',
    pattern: RegExp(r'''^\s*import\s+['"].*design/tokens/'''),
    include: ['lib/features/', 'lib/design/components/'],
  ),

  // ── Design-system integrity ─────────────────────────────────────────────
  Rule(
    id: 'STYLE-01',
    description: 'Material components are banned. Compose from primitives.',
    reference: 'docs/03-design-philosophy.md, docs/08-components.md',
    pattern: _bannedWidgetPattern,
    include: ['lib/features/', 'lib/design/components/'],
    exclude: ['lib/design/theme/material_shim.dart'],
  ),
  Rule(
    id: 'STYLE-02',
    description: 'No Material colour palette. Use QuietTheme roles.',
    reference: 'docs/06-color.md §5',
    pattern: RegExp(r'(?<![A-Za-z0-9_])(Colors|CupertinoColors)\.'),
    include: ['lib/'],
    exclude: ['lib/design/tokens/'],
  ),
  Rule(
    id: 'STYLE-03',
    description: 'No raw colour literals outside the token files.',
    reference: 'docs/04-design-system.md §11',
    pattern: RegExp(
      r'(?<![A-Za-z0-9_])Color(\.fromARGB|\.fromRGBO)?\s*\(\s*0x',
    ),
    include: ['lib/'],
    exclude: ['lib/design/tokens/', 'lib/app/desktop/'],
  ),
  Rule(
    id: 'STYLE-04',
    description: 'No inline TextStyle. Every style is a typography token.',
    reference: 'docs/05-typography.md §7',
    pattern: RegExp(r'(?<![A-Za-z0-9_])TextStyle\s*\('),
    include: ['lib/'],
    exclude: ['lib/design/tokens/', 'lib/design/theme/', 'lib/app/desktop/'],
  ),
  Rule(
    id: 'STYLE-05',
    description: "Don't read Material's theme. Use context.quiet.",
    reference: 'docs/04-design-system.md',
    pattern: RegExp(r'Theme\.of\(\s*context\s*\)\.(colorScheme|textTheme)'),
    include: ['lib/'],
    exclude: ['lib/design/theme/'],
  ),
  Rule(
    id: 'STYLE-06',
    description: 'ColorScheme.fromSeed produces the Material tonal look.',
    reference: 'docs/06-color.md §5',
    pattern: RegExp(r'ColorScheme\.fromSeed'),
    include: ['lib/'],
  ),

  // ── Correctness ─────────────────────────────────────────────────────────
  Rule(
    id: 'TIME-01',
    description: 'Use the injected Clock. Timezone tests depend on it.',
    reference: 'docs/09-architecture.md §7',
    pattern: RegExp(r'DateTime\.now\s*\('),
    include: ['lib/'],
    exclude: ['lib/core/clock.dart'],
  ),
  Rule(
    id: 'TIME-02',
    description: 'Never construct a local DateTime for a birthday instant.',
    reference: 'docs/11-notifications.md §1',
    pattern: RegExp(r'DateTime\.parse\s*\('),
    include: ['lib/domain/'],
  ),
];
