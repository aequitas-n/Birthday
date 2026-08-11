import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/design/components/buttons/q_button.dart';
import 'package:kin/design/components/buttons/q_icon_button.dart';
import 'package:kin/design/components/controls/q_collection_picker.dart';
import 'package:kin/design/components/feedback/q_chip.dart';
import 'package:kin/design/components/feedback/q_empty_state.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/fields/q_field.dart';
import 'package:kin/design/components/media/q_avatar.dart';
import 'package:kin/design/components/rows/q_person_row.dart';
import 'package:kin/design/components/rows/q_section_header.dart';
import 'package:kin/design/components/rows/q_section_title.dart';
import 'package:kin/design/components/sheets/q_choice_sheet.dart';
import 'package:kin/design/components/surfaces/q_card.dart';
import 'package:kin/design/components/text/q_voice.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/quiet_collection.dart';
import 'package:kin/design/theme/quiet_theme.dart';

import '../support/quiet_test_app.dart';

void main() {
  group('QButton', () {
    testWidgets('a null callback disables it', (tester) async {
      var taps = 0;
      await tester.pumpQuiet(
        Center(
          child: QButton.primary(label: 'Save', onPressed: () => taps++),
        ),
      );
      await tester.tap(find.text('Save'));
      expect(taps, 1);

      await tester.pumpQuiet(
        const Center(child: QButton.primary(label: 'Save', onPressed: null)),
      );
      await tester.tap(find.text('Save'), warnIfMissed: false);
      expect(taps, 1);
    });

    testWidgets('does not resize while loading', (tester) async {
      await tester.pumpQuiet(
        const Center(child: QButton.primary(label: 'Save', onPressed: null)),
      );
      final restWidth = tester.getSize(find.byType(QButton)).width;

      await tester.pumpQuiet(
        const Center(
          child: QButton.primary(label: 'Save', onPressed: null, loading: true),
        ),
      );
      expect(tester.getSize(find.byType(QButton)).width, restWidth);
    });

    testWidgets('meets the minimum touch target', (tester) async {
      await tester.pumpQuiet(
        Center(
          child: QButton(label: 'Ok', onPressed: () {}),
        ),
      );
      expect(
        tester.getSize(find.byType(QButton)).height,
        greaterThanOrEqualTo(QButton.minHeight),
      );
    });
  });

  group('QIconButton', () {
    testWidgets('decouples hit area from glyph size', (tester) async {
      await tester.pumpQuiet(
        Center(
          child: QIconButton(
            glyph: QuietGlyph.plus,
            onPressed: () {},
            semanticLabel: 'Add someone',
            glyphSize: 12,
          ),
        ),
      );
      final size = tester.getSize(find.byType(QIconButton));
      expect(size.width, QIconButton.target);
      expect(size.height, QIconButton.target);
    });

    testWidgets('always announces itself', (tester) async {
      await tester.pumpQuiet(
        Center(
          child: QIconButton(
            glyph: QuietGlyph.search,
            onPressed: () {},
            semanticLabel: 'Search',
          ),
        ),
      );
      expect(find.bySemanticsLabel('Search'), findsOneWidget);
    });
  });

  group('QAvatar', () {
    test('monogram takes the first and last initial', () {
      expect(QAvatar.monogramFor('Priya Raman'), 'PR');
      expect(QAvatar.monogramFor('Priya'), 'P');
      expect(QAvatar.monogramFor('  Sara   Maria Lindqvist '), 'SL');
      expect(QAvatar.monogramFor(''), '');
    });

    testWidgets('falls back to a monogram rather than a person glyph', (
      tester,
    ) async {
      await tester.pumpQuiet(
        const Center(
          child: QAvatar(displayName: 'Priya Raman', seed: 'a1'),
        ),
      );
      expect(find.text('PR'), findsOneWidget);
    });

    testWidgets('sizes match the token', (tester) async {
      await tester.pumpQuiet(
        const Center(
          child: QAvatar(
            displayName: 'Priya Raman',
            seed: 'a1',
            size: QAvatarSize.lg,
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(QAvatar)).width,
        QAvatarSize.lg.diameter,
      );
    });
  });

  group('QPersonRow', () {
    testWidgets('shows a countdown on an ordinary day', (tester) async {
      await tester.pumpQuiet(
        const QPersonRow(
          displayName: 'Arjun Mehta',
          seed: 'b2',
          daysUntil: 3,
          nextBirthdayLine: '12 August · Mumbai',
        ),
      );
      expect(find.text('3 days'), findsOneWidget);
      expect(find.text('12 August · Mumbai'), findsOneWidget);
    });

    testWidgets('replaces the subtitle with the age on the day itself', (
      tester,
    ) async {
      await tester.pumpQuiet(
        const QPersonRow(
          displayName: 'Priya Raman',
          seed: 'a1',
          daysUntil: 0,
          turningAge: 29,
          nextBirthdayLine: 'Turns 29 · 28 July · Chennai',
        ),
      );
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Turns 29 · 28 July · Chennai'), findsOneWidget);
      expect(find.text('in 0'), findsNothing);
    });

    testWidgets('announces one coherent sentence', (tester) async {
      await tester.pumpQuiet(
        const QPersonRow(
          displayName: 'Arjun Mehta',
          seed: 'b2',
          daysUntil: 3,
          nextBirthdayLine: '12 August · Mumbai',
        ),
      );
      expect(
        find.bySemanticsLabel('Arjun Mehta, 12 August · Mumbai, 3 days'),
        findsOneWidget,
      );
    });

    testWidgets('restacks instead of truncating at large text scales', (
      tester,
    ) async {
      await tester.pumpQuiet(
        const QPersonRow(
          displayName: 'Sara Lindqvist',
          seed: 'c3',
          daysUntil: 6,
          nextBirthdayLine: '3 August · Stockholm',
        ),
        textScale: 1.6,
      );
      final height = tester.getSize(find.byType(QPersonRow)).height;
      expect(
        height,
        greaterThan(const QuietTheme.light().layout.personRowHeight),
      );
    });
  });

  group('QField', () {
    testWidgets('reserves the helper line so errors never shift layout', (
      tester,
    ) async {
      await tester.pumpQuiet(
        const Center(
          child: QField(label: 'Name', placeholder: 'Who?'),
        ),
      );
      final restHeight = tester.getSize(find.byType(QField)).height;

      await tester.pumpQuiet(
        const Center(
          child: QField(
            label: 'Name',
            placeholder: 'Who?',
            error: 'Pick a date.',
          ),
        ),
      );
      expect(tester.getSize(find.byType(QField)).height, restHeight);
    });

    testWidgets('shows the placeholder only while empty', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpQuiet(
        Center(
          child: QField(controller: controller, placeholder: 'Who?'),
        ),
      );
      expect(find.text('Who?'), findsOneWidget);

      controller.text = 'Priya';
      await tester.pump();
      expect(find.text('Who?'), findsNothing);
    });

    testWidgets('renders its label as an eyebrow', (tester) async {
      await tester.pumpQuiet(
        const Center(child: QField(label: 'Favourite flower')),
      );
      expect(find.text('FAVOURITE FLOWER'), findsOneWidget);
    });
  });

  group('QEmptyState', () {
    testWidgets('is a composed screen, not a placeholder', (tester) async {
      await tester.pumpQuiet(
        QEmptyState(
          headline: 'No one here yet.',
          support: "Add someone you'd hate to forget.",
          action: QButton.primary(label: 'Add someone', onPressed: () {}),
        ),
      );
      expect(find.text('No one here yet.'), findsOneWidget);
      expect(find.text("Add someone you'd hate to forget."), findsOneWidget);
      expect(find.text('Add someone'), findsOneWidget);
    });
  });

  group('QSectionHeader', () {
    testWidgets('uppercases the label', (tester) async {
      await tester.pumpQuiet(const QSectionHeader('This week'));
      expect(find.text('THIS WEEK'), findsOneWidget);
    });
  });

  group('QSectionTitle', () {
    testWidgets('keeps the title in sentence case, unlike the eyebrow', (
      tester,
    ) async {
      await tester.pumpQuiet(
        const QSectionTitle(
          'What you remember',
          support: 'Tap anything to change it.',
          trailing: QSectionCount(3),
        ),
      );
      expect(find.text('What you remember'), findsOneWidget);
      expect(find.text('WHAT YOU REMEMBER'), findsNothing);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('is set in the Voice, so a section reads as a chapter', (
      tester,
    ) async {
      await tester.pumpQuiet(const QSectionTitle('Their year'));
      final style = tester.widget<Text>(find.text('Their year')).style!;
      expect(style.fontFamily, 'Fraunces');
    });
  });

  group('QVoice', () {
    testWidgets('nudges large display type left, and leaves small type be', (
      tester,
    ) async {
      const q = QuietTheme.light();

      await tester.pumpQuiet(
        Align(
          alignment: Alignment.topLeft,
          child: QVoice('Priya', style: q.text.voiceXxl),
        ),
      );
      final display = tester.getTopLeft(find.text('Priya')).dx;

      await tester.pumpQuiet(
        Align(
          alignment: Alignment.topLeft,
          child: QVoice('Priya', style: q.text.body),
        ),
      );
      final body = tester.getTopLeft(find.text('Priya')).dx;

      // The glyph edge, not the box edge, aligns to the gutter — so the
      // display line sits further left than its box would.
      expect(display, lessThan(body));
      expect(body, 0);
    });
  });

  group('QChip', () {
    testWidgets('is read-only, so it announces no button', (tester) async {
      await tester.pumpQuiet(const Center(child: QChip('Peonies')));
      expect(find.text('Peonies'), findsOneWidget);
      expect(
        find.ancestor(
          of: find.text('Peonies'),
          matching: find.byType(QPressable),
        ),
        findsNothing,
      );
    });
  });

  group('QCard', () {
    testWidgets('an invitation is roomier than a memory', (tester) async {
      await tester.pumpQuiet(
        const Align(
          alignment: Alignment.topLeft,
          child: QCard(child: Text('Peonies')),
        ),
      );
      final memory = tester.getSize(find.byType(QCard)).height;

      await tester.pumpQuiet(
        const Align(
          alignment: Alignment.topLeft,
          child: QCard(tone: QCardTone.invitation, child: Text('Peonies')),
        ),
      );
      expect(tester.getSize(find.byType(QCard)).height, greaterThan(memory));
    });

    testWidgets('only a tappable card is a button', (tester) async {
      await tester.pumpQuiet(
        const QCard(child: Text('Peonies')),
      );
      expect(find.byType(QPressable), findsNothing);

      await tester.pumpQuiet(
        QCard(
          onTap: () {},
          semanticLabel: 'Open profile',
          child: const Text('Peonies'),
        ),
      );
      expect(find.byType(QPressable), findsOneWidget);
    });
  });

  group('showQChoiceSheet', () {
    testWidgets('returns the chosen index and marks the current one', (
      tester,
    ) async {
      int? chosen;
      await tester.pumpQuiet(
        Builder(
          builder: (context) => Center(
            child: QButton(
              label: 'Pick',
              onPressed: () async {
                chosen = await showQChoiceSheet(
                  context: context,
                  title: 'Month',
                  choices: const [
                    QChoice('March'),
                    QChoice('July'),
                    QChoice('August'),
                  ],
                  selectedIndex: 1,
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      expect(find.text('July'), findsOneWidget);

      await tester.tap(find.text('August'));
      await tester.pumpAndSettle();
      expect(chosen, 2);
    });
  });

  group('QCollectionPicker', () {
    testWidgets('paints every collection in its own paper', (tester) async {
      QuietCollection? picked;
      await tester.pumpQuiet(
        QCollectionPicker(
          selected: QuietCollection.ember,
          onSelected: (value) => picked = value,
        ),
      );

      // A name alone would tell the user nothing about what they are choosing.
      expect(find.text('Autumn Ember'), findsOneWidget);
      expect(find.text('Ocean Mist'), findsOneWidget);

      await tester.tap(find.text('Ocean Mist'));
      expect(picked, QuietCollection.ocean);
    });

    testWidgets('survives large text without clipping its names', (
      tester,
    ) async {
      await tester.pumpQuiet(
        QCollectionPicker(
          selected: QuietCollection.ember,
          onSelected: (_) {},
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
