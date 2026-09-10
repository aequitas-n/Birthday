import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/design/components/buttons/q_button.dart';
import 'package:kin/design/components/buttons/q_icon_button.dart';
import 'package:kin/design/components/feedback/q_arc.dart';
import 'package:kin/design/components/feedback/q_chip.dart';
import 'package:kin/design/components/feedback/q_empty_state.dart';
import 'package:kin/design/components/fields/q_field.dart';
import 'package:kin/design/components/fields/q_note_kind_picker.dart';
import 'package:kin/design/components/media/q_avatar.dart';
import 'package:kin/design/components/rows/q_person_row.dart';
import 'package:kin/design/components/rows/q_section_header.dart';
import 'package:kin/design/components/rows/q_section_title.dart';
import 'package:kin/design/components/sheets/q_sheet.dart';
import 'package:kin/design/components/sheets/q_sheet_route.dart';
import 'package:kin/design/components/surfaces/q_card.dart';
import 'package:kin/design/components/surfaces/q_hairline.dart';
import 'package:kin/design/components/surfaces/q_screen.dart';
import 'package:kin/design/components/surfaces/q_surface.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Every component, in every state, in every theme.
///
/// This exists so the design language can be reviewed and golden-tested before
/// a single product screen is built. Phase 1 does not ship screens; it ships
/// this. See docs/13-roadmap.md.
class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = context.quiet;

    return QScreen(
      child: QMeasure(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            context.gutter,
            q.space.base,
            context.gutter,
            q.space.emptiness,
          ),
          children: const [
            _GalleryTitle(),
            _CollectionSection(),
            _TypographySection(),
            _ColourSection(),
            _CardSection(),
            _ChipSection(),
            _ButtonSection(),
            _IconAndGlyphSection(),
            _AvatarSection(),
            _PersonRowSection(),
            _FieldSection(),
            _PillSection(),
            _FeedbackSection(),
            _SheetSection(),
            _EmptyStateSection(),
          ],
        ),
      ),
    );
  }
}

class _GalleryTitle extends StatelessWidget {
  const _GalleryTitle();

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    return Padding(
      padding: EdgeInsets.only(bottom: q.space.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quiet', style: q.text.pageTitle.tinted(q.color.textPrimary)),
          SizedBox(height: q.space.xs),
          Text(
            'The design language for Kin.',
            style: q.text.body.tinted(q.color.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _CollectionSection extends StatelessWidget {
  const _CollectionSection();

  @override
  Widget build(BuildContext context) {
    return const QSectionTitle(
      'Vintage Diary',
      support: 'The sole product theme — an old personal journal.',
      isFirst: true,
    );
  }
}

class _TypographySection extends StatelessWidget {
  const _TypographySection();

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final ink = q.color.textPrimary;

    // In descending order of voice, so the specimen list is itself a diagram
    // of the hierarchy.
    final specimens = <(String, TextStyle)>[
      ('pageTitle — Today', q.text.pageTitle),
      ('sectionTitle — Today’s journal', q.text.sectionTitle),
      ('displayTitle — celebratory', q.text.displayTitle),
      ('journalPrompt — Nothing written yet', q.text.journalPrompt),
      ('editorialBody — 26', q.text.editorialBody),
      ('personName — Ganesh', q.text.personName),
      ('memoryTitle — memory title', q.text.memoryTitle),
      ('journalWriting — What do you want to remember?', q.text.journalWriting),
      ('uiDate — 26 August 2026', q.text.uiDate),
      ('uiTimestamp — 7:30 PM', q.text.uiTimestamp),
      ('uiMetadata — 12 memories', q.text.uiMetadata),
      ('uiButton — Add memory', q.text.uiButton),
      ('uiNavigation — Today', q.text.uiNavigation),
      ('uiBody — Nothing planned yet.', q.text.uiBody),
      ('uiCount — 346 days', q.text.uiCount),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const QSectionHeader('Typography'),
        for (final (caption, style) in specimens) ...[
          Text(caption, style: style.tinted(ink)),
          SizedBox(height: q.space.md),
        ],
      ],
    );
  }
}

class _ColourSection extends StatelessWidget {
  const _ColourSection();

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final c = q.color;

    final roles = <(String, Color)>[
      ('canvas', c.canvas),
      ('surface', c.surface),
      ('raised', c.raised),
      ('sunken', c.sunken),
      ('hairline', c.hairline),
      ('hairlineStrong', c.hairlineStrong),
      ('accent', c.accent),
      ('accentWash', c.accentWash),
      ('danger', c.danger),
      ('textPrimary', c.textPrimary),
      ('textSecondary', c.textSecondary),
      ('textTertiary', c.textTertiary),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const QSectionHeader('Colour'),
        Wrap(
          spacing: q.space.md,
          runSpacing: q.space.md,
          children: [
            for (final (name, colour) in roles)
              SizedBox(
                width: 92,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 44,
                      decoration: ShapeDecoration(
                        color: colour,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: c.hairline,
                            width: context.hairlineWidth,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(q.radius.sm),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: q.space.xs),
                    Text(name, style: q.text.caption.tinted(c.textTertiary)),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// The card tones, in one column, so the differences between them are visible
/// rather than theoretical.
class _CardSection extends StatelessWidget {
  const _CardSection();

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    const tones = <(QCardTone, String, String)>[
      (
        QCardTone.invitation,
        'Remember more than the date',
        'The one card that carries a shadow at rest.',
      ),
      (QCardTone.context, 'Born 28 July 1997', 'Facts, on a quiet surface.'),
      (
        QCardTone.memory,
        'Peonies, the pale ones',
        'Something she said once.',
      ),
      (QCardTone.secondary, 'Everything else', 'Hairline only, no lift.'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const QSectionHeader('Cards'),
        for (final (tone, title, support) in tones) ...[
          QCard(
            tone: tone,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: q.text.headline.tinted(q.color.textPrimary)),
                SizedBox(height: q.space.xs),
                Text(
                  support,
                  style: q.text.body.tinted(q.color.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(height: q.space.base),
        ],
      ],
    );
  }
}

class _ChipSection extends StatelessWidget {
  const _ChipSection();

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const QSectionHeader('Chips'),
        Wrap(
          spacing: q.space.sm,
          runSpacing: q.space.sm,
          children: const [
            QChip('Peonies'),
            QChip('Flat white, oat'),
            QChip('A handwritten letter', tone: QChipTone.accent),
          ],
        ),
      ],
    );
  }
}

class _ButtonSection extends StatefulWidget {
  const _ButtonSection();

  @override
  State<_ButtonSection> createState() => _ButtonSectionState();
}

class _ButtonSectionState extends State<_ButtonSection> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const QSectionHeader('Buttons'),
        Wrap(
          spacing: q.space.md,
          runSpacing: q.space.md,
          children: [
            QButton.primary(label: 'Add someone', onPressed: () {}),
            QButton(label: 'Choose a photo', onPressed: () {}),
            QButton.tertiary(label: 'Not now', onPressed: () {}),
            QButton.destructive(label: 'Remove', onPressed: () {}),
          ],
        ),
        SizedBox(height: q.space.md),
        Wrap(
          spacing: q.space.md,
          runSpacing: q.space.md,
          children: [
            const QButton.primary(label: 'Disabled', onPressed: null),
            const QButton(label: 'Disabled', onPressed: null),
            QButton.primary(
              label: 'Save',
              loading: _loading,
              onPressed: () => setState(() => _loading = !_loading),
            ),
            QButton(
              label: 'With a glyph',
              glyph: QuietGlyph.gift,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _IconAndGlyphSection extends StatelessWidget {
  const _IconAndGlyphSection();

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const QSectionHeader('Glyphs'),
        Wrap(
          spacing: q.space.sm,
          runSpacing: q.space.sm,
          children: [
            for (final glyph in QuietGlyph.values)
              QSurface(
                radius: q.radius.md,
                elevation: QuietElevationLevel.hairline,
                width: 56,
                height: 56,
                child: Center(
                  child: QGlyphIcon(glyph, color: q.color.textPrimary),
                ),
              ),
          ],
        ),
        SizedBox(height: q.space.md),
        Row(
          children: [
            QIconButton(
              glyph: QuietGlyph.plus,
              onPressed: () {},
              semanticLabel: 'Add someone',
            ),
            QIconButton(
              glyph: QuietGlyph.search,
              onPressed: () {},
              semanticLabel: 'Search',
            ),
            QIconButton(
              glyph: QuietGlyph.close,
              onPressed: () {},
              semanticLabel: 'Close',
              tone: QIconTone.secondary,
            ),
            const QIconButton(
              glyph: QuietGlyph.ellipsis,
              onPressed: null,
              semanticLabel: 'More, disabled',
            ),
          ],
        ),
      ],
    );
  }
}

class _AvatarSection extends StatelessWidget {
  const _AvatarSection();

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const QSectionHeader('Avatars'),
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
      ],
    );
  }
}

class _PersonRowSection extends StatelessWidget {
  const _PersonRowSection();

  @override
  Widget build(BuildContext context) {
    final indent = personRowHairlineIndent(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const QSectionHeader('Today'),
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

class _FieldSection extends StatelessWidget {
  const _FieldSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QSectionHeader('Fields'),
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
        QField(
          label: 'A longer note',
          placeholder: 'Something she mentioned',
          maxLines: 4,
          maxLength: 280,
        ),
      ],
    );
  }
}

class _PillSection extends StatefulWidget {
  const _PillSection();

  @override
  State<_PillSection> createState() => _PillSectionState();
}

class _PillSectionState extends State<_PillSection> {
  String _selected = 'flower';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const QSectionHeader('Note kinds'),
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
          selected: _selected,
          onSelected: (value) => setState(() => _selected = value),
        ),
      ],
    );
  }
}

class _FeedbackSection extends StatelessWidget {
  const _FeedbackSection();

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const QSectionHeader('Surfaces and loading'),
        Row(
          children: [
            QSurface(
              radius: q.radius.lg,
              elevation: QuietElevationLevel.hairline,
              width: 96,
              height: 72,
              child: Center(
                child: Text(
                  'hairline',
                  style: q.text.caption.tinted(q.color.textSecondary),
                ),
              ),
            ),
            SizedBox(width: q.space.md),
            QSurface(
              radius: q.radius.lg,
              elevation: QuietElevationLevel.lift,
              width: 96,
              height: 72,
              child: Center(
                child: Text(
                  'lift',
                  style: q.text.caption.tinted(q.color.textSecondary),
                ),
              ),
            ),
            SizedBox(width: q.space.md),
            QSurface(
              level: QuietLevel.sunken,
              radius: q.radius.lg,
              width: 96,
              height: 72,
              child: Center(child: QArc(color: q.color.textTertiary)),
            ),
          ],
        ),
      ],
    );
  }
}

class _SheetSection extends StatelessWidget {
  const _SheetSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const QSectionHeader('Sheets'),
        QButton(
          label: 'Present a sheet',
          onPressed: () => showQSheet<void>(
            context: context,
            builder: (context) => QSheet(
              title: 'Add someone',
              bottom: QBottomActions(
                children: [
                  QButton.tertiary(
                    label: 'Skip',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  QButton.primary(
                    label: 'Next',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  QField(label: 'Name', placeholder: 'Who are you adding?'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyStateSection extends StatelessWidget {
  const _EmptyStateSection();

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const QSectionHeader('Empty state'),
        QSurface(
          level: QuietLevel.canvas,
          radius: q.radius.lg,
          elevation: QuietElevationLevel.hairline,
          height: 320,
          child: QEmptyState(
            headline: 'No one here yet.',
            support: "Add someone you'd hate to forget.",
            action: QButton.primary(label: 'Add someone', onPressed: () {}),
          ),
        ),
      ],
    );
  }
}
