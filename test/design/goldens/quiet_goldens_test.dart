@Tags(['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/design/components/buttons/q_button.dart';
import 'package:kin/design/components/buttons/q_icon_button.dart';
import 'package:kin/design/components/feedback/q_chip.dart';
import 'package:kin/design/components/feedback/q_empty_state.dart';
import 'package:kin/design/components/fields/q_field.dart';
import 'package:kin/design/components/fields/q_note_kind_picker.dart';
import 'package:kin/design/components/media/q_avatar.dart';
import 'package:kin/design/components/rows/q_person_row.dart';
import 'package:kin/design/components/rows/q_section_header.dart';
import 'package:kin/design/components/rows/q_section_title.dart';
import 'package:kin/design/components/sheets/q_sheet.dart';
import 'package:kin/design/components/surfaces/q_card.dart';
import 'package:kin/design/components/surfaces/q_hairline.dart';
import 'package:kin/design/components/surfaces/q_surface.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

import '../../support/quiet_test_app.dart';

/// Every component, in every theme, at both text scales.
///
/// A component without goldens is not done. Regenerate with:
///   flutter test --update-goldens --tags golden
void main() {
  setUpAll(loadQuietFonts);

  final specimens = <String, ({Widget child, Size size})>{
    'typography': (
      child: const _TypographySpecimen(),
      size: const Size(390, 940),
    ),
    'cards-chips': (
      child: const _CardChipSpecimen(),
      size: const Size(390, 560),
    ),
    'collections': (
      child: const _CollectionSpecimen(),
      size: const Size(390, 260),
    ),
    'buttons': (child: const _ButtonSpecimen(), size: const Size(390, 400)),
    'person-rows': (
      child: const _PersonRowSpecimen(),
      size: const Size(390, 460),
    ),
    'fields': (child: const _FieldSpecimen(), size: const Size(390, 460)),
    'avatars-glyphs': (
      child: const _AvatarGlyphSpecimen(),
      size: const Size(390, 400),
    ),
    'pills-surfaces': (
      child: const _PillSurfaceSpecimen(),
      size: const Size(390, 340),
    ),
    'empty-state': (
      child: const _EmptyStateSpecimen(),
      size: const Size(390, 420),
    ),
    'sheet': (child: const _SheetSpecimen(), size: const Size(390, 420)),
  };

  for (final specimen in specimens.entries) {
    group(specimen.key, () {
      for (final theme in quietThemes.entries) {
        for (final scale in quietTextScales.entries) {
          testWidgets('${theme.key} @ ${scale.key}', (tester) async {
            await tester.pumpQuiet(
              specimen.value.child,
              theme: theme.value,
              textScale: scale.value,
              surfaceSize: specimen.value.size,
            );

            await expectLater(
              find.byType(QuietTestApp),
              matchesGoldenFile(
                '_goldens/${specimen.key}.${theme.key}.${scale.key}.png',
              ),
            );
          });
        }
      }
    });
  }
}

/// Shared frame so every specimen sits on the canvas with the real gutter.
class _Frame extends StatelessWidget {
  const _Frame({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: context.gutter,
        vertical: q.space.base,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _TypographySpecimen extends StatelessWidget {
  const _TypographySpecimen();

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final ink = q.color.textPrimary;
    return _Frame(
      children: [
        Text('Today', style: q.text.pageTitle.tinted(ink)),
        Text("Today's journal", style: q.text.sectionTitle.tinted(ink)),
        Text('Priya Raman', style: q.text.personName.tinted(ink)),
        Text('Nothing written yet.', style: q.text.diaryNote.tinted(ink)),
        Text('Journal body on paper', style: q.text.journalWriting.tinted(ink)),
        SizedBox(height: q.space.md),
        Text('25 August 2026', style: q.text.uiDate.tinted(ink)),
        Text('Tuesday · 7:30 PM', style: q.text.uiTimestamp.tinted(ink)),
        Text('12 memories · 347 days', style: q.text.uiCount.tinted(ink)),
        Text('Add memory', style: q.text.uiButton.tinted(ink)),
        Text('Today · Kin · Journal', style: q.text.uiNavigation.tinted(ink)),
        Text('Sister · Chennai', style: q.text.uiBody.tinted(ink)),
      ],
    );
  }
}

/// The card tones and the two chip tones, so a regression in the hierarchy
/// between them shows up as a picture rather than as a bug report.
class _CardChipSpecimen extends StatelessWidget {
  const _CardChipSpecimen();

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final ink = q.color.textPrimary;

    return _Frame(
      children: [
        const QSectionTitle('What you remember', isFirst: true),
        for (final tone in const [
          QCardTone.invitation,
          QCardTone.context,
          QCardTone.memory,
          QCardTone.secondary,
        ]) ...[
          QCard(
            tone: tone,
            child: Text(tone.name, style: q.text.headline.tinted(ink)),
          ),
          SizedBox(height: q.space.base),
        ],
        Wrap(
          spacing: q.space.sm,
          runSpacing: q.space.sm,
          children: const [
            QChip('Peonies'),
            QChip('A handwritten letter', tone: QChipTone.accent),
          ],
        ),
      ],
    );
  }
}

class _CollectionSpecimen extends StatelessWidget {
  const _CollectionSpecimen();

  @override
  Widget build(BuildContext context) {
    return const _Frame(
      children: [
        QSectionTitle(
          'Vintage Diary',
          support: 'The sole product theme.',
          isFirst: true,
        ),
      ],
    );
  }
}

class _ButtonSpecimen extends StatelessWidget {
  const _ButtonSpecimen();

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    return _Frame(
      children: [
        const QSectionHeader('Buttons', isFirst: true),
        Wrap(
          spacing: q.space.md,
          runSpacing: q.space.md,
          children: [
            QButton.primary(label: 'Add someone', onPressed: () {}),
            QButton(label: 'Choose a photo', onPressed: () {}),
            QButton.tertiary(label: 'Not now', onPressed: () {}),
            QButton.destructive(label: 'Remove', onPressed: () {}),
            QButton(label: 'Gift', glyph: QuietGlyph.gift, onPressed: () {}),
            const QButton.primary(label: 'Disabled', onPressed: null),
            const QButton(label: 'Disabled', onPressed: null),
          ],
        ),
      ],
    );
  }
}

class _PersonRowSpecimen extends StatelessWidget {
  const _PersonRowSpecimen();

  @override
  Widget build(BuildContext context) {
    final indent = personRowHairlineIndent(context);
    return _Frame(
      children: [
        const QSectionHeader('Today', isFirst: true),
        const QPersonRow(
          displayName: 'Priya Raman',
          seed: 'a1',
          daysUntil: 0,
          turningAge: 29,
          subtitle: 'Sister · Chennai',
        ),
        const QSectionHeader('This week'),
        const QPersonRow(
          displayName: 'Arjun Mehta',
          seed: 'b2',
          daysUntil: 3,
          subtitle: 'Friend · Mumbai',
        ),
        QHairline(indent: indent),
        const QPersonRow(
          displayName: 'Sara Lindqvist',
          seed: 'c3',
          daysUntil: 6,
          subtitle: 'Colleague · Stockholm',
        ),
        QHairline(indent: indent),
        const QPersonRow(displayName: 'Daniel Cole', seed: 'd4', daysUntil: 14),
      ],
    );
  }
}

class _FieldSpecimen extends StatelessWidget {
  const _FieldSpecimen();

  @override
  Widget build(BuildContext context) {
    return const _Frame(
      children: [
        QSectionHeader('Fields', isFirst: true),
        QField(label: 'Name', placeholder: 'Who are you adding?'),
        QField(
          label: 'Favourite flower',
          placeholder: 'Peonies, the pale ones',
          helper: 'Small details make good gifts.',
        ),
        QField(
          label: 'Birthday',
          placeholder: '4 March',
          error: 'Pick a date.',
        ),
        QField(label: 'Disabled', placeholder: 'Not editable', enabled: false),
      ],
    );
  }
}

class _AvatarGlyphSpecimen extends StatelessWidget {
  const _AvatarGlyphSpecimen();

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    return _Frame(
      children: [
        const QSectionHeader('Avatars', isFirst: true),
        Wrap(
          spacing: q.space.base,
          runSpacing: q.space.base,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            QAvatar(displayName: 'Priya Raman', seed: 'a1'),
            QAvatar(displayName: 'Arjun Mehta', seed: 'b2'),
            QAvatar(displayName: 'Sara Lindqvist', seed: 'c3'),
            QAvatar(
              displayName: 'Daniel Cole',
              seed: 'd4',
              size: QAvatarSize.sm,
            ),
            QAvatar(
              displayName: 'Priya Raman',
              seed: 'a1',
              size: QAvatarSize.lg,
            ),
          ],
        ),
        const QSectionHeader('Glyphs'),
        Wrap(
          spacing: q.space.sm,
          runSpacing: q.space.sm,
          children: [
            for (final glyph in QuietGlyph.values)
              QSurface(
                radius: q.radius.md,
                elevation: QuietElevationLevel.hairline,
                width: 48,
                height: 48,
                child: Center(
                  child: QGlyphIcon(glyph, color: q.color.textPrimary),
                ),
              ),
          ],
        ),
        Row(
          children: [
            QIconButton(
              glyph: QuietGlyph.plus,
              onPressed: () {},
              semanticLabel: 'Add',
            ),
            QIconButton(
              glyph: QuietGlyph.search,
              onPressed: () {},
              semanticLabel: 'Search',
            ),
            const QIconButton(
              glyph: QuietGlyph.ellipsis,
              onPressed: null,
              semanticLabel: 'More',
            ),
          ],
        ),
      ],
    );
  }
}

class _PillSurfaceSpecimen extends StatelessWidget {
  const _PillSurfaceSpecimen();

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    return _Frame(
      children: [
        const QSectionHeader('Note kinds', isFirst: true),
        QPillGroup(
          options: const [
            'flower',
            'dessert',
            'colour',
            'coffee',
            'movie',
            'food',
            'gift idea',
            'note',
          ],
          selected: 'flower',
          onSelected: (_) {},
        ),
        const QSectionHeader('Surfaces'),
        Row(
          children: [
            QSurface(
              radius: q.radius.lg,
              elevation: QuietElevationLevel.hairline,
              width: 88,
              height: 64,
              child: const SizedBox.expand(),
            ),
            SizedBox(width: q.space.md),
            QSurface(
              radius: q.radius.lg,
              elevation: QuietElevationLevel.lift,
              width: 88,
              height: 64,
              child: const SizedBox.expand(),
            ),
            SizedBox(width: q.space.md),
            QSurface(
              level: QuietLevel.sunken,
              radius: q.radius.lg,
              width: 88,
              height: 64,
              child: const SizedBox.expand(),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyStateSpecimen extends StatelessWidget {
  const _EmptyStateSpecimen();

  @override
  Widget build(BuildContext context) {
    return QEmptyState(
      headline: 'No one here yet.',
      support: "Add someone you'd hate to forget.",
      action: QButton.primary(label: 'Add someone', onPressed: () {}),
    );
  }
}

class _SheetSpecimen extends StatelessWidget {
  const _SheetSpecimen();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: QSheet(
        title: 'Add someone',
        bottom: QBottomActions(
          children: [
            QButton.tertiary(label: 'Skip', onPressed: () {}),
            QButton.primary(label: 'Next', onPressed: () {}),
          ],
        ),
        child: const QField(label: 'Name', placeholder: 'Who are you adding?'),
      ),
    );
  }
}
