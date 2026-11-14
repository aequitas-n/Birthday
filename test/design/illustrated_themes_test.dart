import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/design/components/buttons/q_button.dart';
import 'package:kin/design/components/feedback/q_empty_state.dart';
import 'package:kin/design/components/journal/q_animated_illustration.dart';
import 'package:kin/design/components/journal/q_illustrated_journal_invite.dart';
import 'package:kin/design/components/navigation/q_primary_nav.dart';
import 'package:kin/design/components/sheets/q_theme_picker.dart';
import 'package:kin/design/components/surfaces/q_theme_surfaces.dart';
import 'package:kin/design/theme/app_theme_definition.dart';
import 'package:kin/design/theme/material_shim.dart';
import 'package:kin/design/theme/product_theme_id.dart';
import 'package:kin/design/theme/product_themes.dart';

double contrast(Color a, Color b) {
  final first = a.computeLuminance();
  final second = b.computeLuminance();
  return (math.max(first, second) + 0.05) / (math.min(first, second) + 0.05);
}

Widget preview(
  AppThemeDefinition theme, {
  double scale = 1,
  bool reduced = true,
  VoidCallback? onAdd,
  ValueChanged<PrimaryDestination>? onTab,
}) => MaterialApp(
  theme: buildMaterialShim(theme.quiet, appTheme: theme),
  home: MediaQuery(
    data: MediaQueryData(
      size: const Size(320, 700),
      textScaler: TextScaler.linear(scale),
      disableAnimations: reduced,
    ),
    child: QThemeCanvas(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: QIllustratedJournalInvite(
                dateLabel: '14 November',
                onAdd: onAdd ?? () {},
              ),
            ),
          ),
          QPrimaryNav(
            selected: PrimaryDestination.today,
            onSelected: onTab ?? (_) {},
          ),
        ],
      ),
    ),
  ),
);

void main() {
  test('all theme identifiers round-trip without migration', () {
    expect(ProductThemes.all.length, 8);
    for (final id in ProductThemeId.values) {
      expect(ProductThemeId.fromStorage(id.storageKey), id);
      expect(ProductThemes.resolve(id).id, id);
    }
  });

  for (final theme in ProductThemes.all.where((theme) => theme.art != null)) {
    test('${theme.label}: complete art and readable text', () {
      final art = theme.art!;
      expect(File(art.atlas).existsSync(), isTrue);
      expect(File(art.background).existsSync(), isTrue);
      expect(File(art.scene).existsSync(), isTrue);
      expect(contrast(art.ink, art.canvas), greaterThanOrEqualTo(4.5));
      expect(contrast(art.muted, art.paper), greaterThanOrEqualTo(4.5));
      expect(contrast(art.accentInk, art.accent), greaterThanOrEqualTo(4.5));
    });

    testWidgets('${theme.label}: small phone at 200% keeps actions reachable', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var added = false;
      PrimaryDestination? tab;
      await tester.pumpWidget(
        preview(
          theme,
          scale: 2,
          onAdd: () => added = true,
          onTab: (value) => tab = value,
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Add memory'));
      await tester.tap(find.text('Add memory'));
      expect(added, isTrue);
      await tester.tap(find.text('Journal'));
      expect(tab, PrimaryDestination.journal);
      expect(tester.takeException(), isNull);
      // Reduced motion leaves no continuously scheduled animation frame.
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
    });
  }

  testWidgets(
    'animation responds to reduced motion without losing the drawing',
    (tester) async {
      final theme = ProductThemes.sundayComics;
      await tester.pumpWidget(preview(theme, reduced: false));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(QAnimatedIllustration), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.pumpWidget(preview(theme));
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(find.byType(QAnimatedIllustration), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('theme gallery scrolls to the last theme and returns selection', (
    tester,
  ) async {
    ProductThemeId? selected;
    const theme = ProductThemes.quietDefault;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildMaterialShim(theme.quiet, appTheme: theme),
        home: Builder(
          builder: (context) => Center(
            child: QButton.primary(
              label: 'Choose a theme',
              onPressed: () async {
                selected = await showQThemePicker(
                  context: context,
                  selected: ProductThemeId.quietDefault,
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Choose a theme'));
    await tester.pumpAndSettle();
    expect(find.text('Make yourself at home'), findsOneWidget);
    await tester.ensureVisible(find.text('Midnight Storybook'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Midnight Storybook'));
    await tester.pumpAndSettle();
    expect(selected, ProductThemeId.midnightStorybook);
    expect(tester.takeException(), isNull);
  });
  testWidgets('illustrated empty states scroll in a small pane at large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final theme = ProductThemes.botanicalSketchbook;
    var added = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildMaterialShim(theme.quiet, appTheme: theme),
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 300),
            textScaler: TextScaler.linear(2),
            disableAnimations: true,
          ),
          child: QEmptyState(
            headline: 'No one here yet.',
            support: 'Keep the people who matter close.',
            action: QButton.primary(
              label: 'Add someone',
              onPressed: () => added = true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Add someone'));
    await tester.tap(find.text('Add someone'));
    expect(added, isTrue);
    expect(tester.takeException(), isNull);
  });
}
