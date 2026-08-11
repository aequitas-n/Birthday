import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/app/place_picker_sheet.dart';
import 'package:kin/app/profile_launcher.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/data/timezone/city_dataset.dart';
import 'package:kin/design/components/buttons/q_button.dart';
import 'package:kin/design/components/buttons/q_icon_button.dart';
import 'package:kin/design/components/feedback/q_arc.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/fields/q_date_field.dart';
import 'package:kin/design/components/fields/q_field.dart';
import 'package:kin/design/components/media/q_photo.dart';
import 'package:kin/design/components/rows/q_section_title.dart';
import 'package:kin/design/components/rows/q_setting_row.dart';
import 'package:kin/design/components/sheets/q_choice_sheet.dart';
import 'package:kin/design/components/sheets/q_sheet.dart';
import 'package:kin/design/components/sheets/q_sheet_route.dart';
import 'package:kin/design/components/surfaces/q_hairline.dart';
import 'package:kin/design/components/surfaces/q_screen.dart';
import 'package:kin/design/components/surfaces/q_surface.dart';
import 'package:kin/design/components/text/q_voice.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/domain/models/note.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/domain/models/profile.dart';
import 'package:kin/features/person/application/person_detail_providers.dart';
import 'package:kin/notifications/application/notification_coordinator.dart';
// ignore: always_use_package_imports -- ARCH-03: relative within a feature
import 'detail_kind_picker.dart';
// ignore: always_use_package_imports -- ARCH-03: relative within a feature
import 'memory_actions.dart';
// ignore: always_use_package_imports -- ARCH-03: relative within a feature
import 'photo_memory_flow.dart';

/// A person, opened from Birthdays or People.
///
/// Above the fold: who they are, the countdown, the photograph. Birthday date
/// and location live behind Edit — the journal (Moments + Notes) owns the
/// rest of the viewport.
class PersonScreen extends ConsumerStatefulWidget {
  const PersonScreen({required this.personId, super.key});

  final String personId;

  @override
  ConsumerState<PersonScreen> createState() => _PersonScreenState();
}

class _PersonScreenState extends ConsumerState<PersonScreen> {
  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final summary = ref.watch(personSummaryProvider(widget.personId));

    if (summary == null) {
      return QScreen(
        child: Center(
          child: SizedBox.square(
            dimension: 16,
            child: QArc(color: q.color.textTertiary),
          ),
        ),
      );
    }

    // Horizontal padding is intentionally the larger editorial gutter for this
    // composition. The global phone gutter is tighter; this screen needs the
    // extra 4pt so the portrait and identity breathe against the edge.
    final pad = q.space.xl;

    return QScreen(
      child: QMeasure(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad - q.space.sm),
              child: _TopBar(summary: summary),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Compact identity — enough for name + countdown + portrait,
                  // then hand the remaining ~75% to Moments and Notes.
                  final identityBudget = (constraints.maxHeight * 0.22).clamp(
                    120.0,
                    168.0,
                  );
                  final portraitSide = identityBudget.clamp(112.0, 156.0);

                  return Padding(
                    padding: EdgeInsets.fromLTRB(pad, q.space.sm, pad, pad),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: identityBudget,
                          child: _IdentityHeader(
                            summary: summary,
                            portraitSide: portraitSide,
                          ),
                        ),
                        SizedBox(height: q.space.lg),
                        Expanded(
                          child: _MemoryArea(summary: summary),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.summary});

  final PersonSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        QIconButton(
          glyph: QuietGlyph.chevronLeft,
          onPressed: () => context.pop(),
          semanticLabel: 'Back',
        ),
        const Spacer(),
        QButton.tertiary(
          label: 'Edit',
          onPressed: () => _showPersonActions(context, ref, summary),
        ),
      ],
    );
  }
}

/// Left: who. Right: the photograph.
///
/// Roughly 45 / 55. The portrait is a square clipped to the xl radius —
/// large enough to be the visual anchor, never stretched, never carrying type.
class _IdentityHeader extends ConsumerWidget {
  const _IdentityHeader({
    required this.summary,
    required this.portraitSide,
  });

  final PersonSummary summary;
  final double portraitSide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = context.quiet;
    final person = summary.person;
    final photo = ref.watch(personPhotoProvider(summary.profile?.photoId));
    final relationship = summary.profile?.relationshipDisplayLabel.trim();
    final nickname = summary.profile?.nickname?.trim();
    final hasNickname =
        nickname != null &&
        nickname.isNotEmpty &&
        nickname.toLowerCase() != person.displayName.trim().toLowerCase();

    return Row(
      children: [
        Expanded(
          flex: 45,
          child: Padding(
            padding: EdgeInsets.only(right: q.space.md),
            child: _IdentityCopy(
              relationship: relationship,
              title: hasNickname ? nickname : person.displayName,
              legalName: hasNickname ? person.displayName : null,
              metric: _metric(summary),
              support: _support(summary),
            ),
          ),
        ),
        Expanded(
          flex: 55,
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox.square(
              dimension: portraitSide,
              child: _SquarePortrait(
                displayName: hasNickname ? nickname : person.displayName,
                seed: person.id,
                photo: photo.asData?.value,
                heroTag: 'person-${person.id}',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IdentityCopy extends StatelessWidget {
  const _IdentityCopy({
    required this.title,
    required this.metric,
    required this.support,
    this.relationship,
    this.legalName,
  });

  final String? relationship;

  /// What you actually call them — nickname when set, otherwise their name.
  final String title;

  /// Legal / full name, shown under the nickname when both differ.
  final String? legalName;
  final String metric;
  final String support;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (relationship != null && relationship!.isNotEmpty) ...[
          Text(
            relationship!.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textScaler: context.structuralTextScaler,
            style: q.text.eyebrow.tinted(q.color.accent),
          ),
          SizedBox(height: q.space.xs),
        ],
        QVoice(
          title,
          maxLines: 2,
          textScaler: context.nameTextScaler,
          style: q.text.voiceLg.tinted(q.color.textPrimary),
        ),
        if (legalName != null && legalName!.isNotEmpty) ...[
          SizedBox(height: q.space.xs),
          Text(
            legalName!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textScaler: context.nameTextScaler,
            style: q.text.body.tinted(q.color.textSecondary),
          ),
        ],
        SizedBox(height: q.space.sm),
        // No icon beside the countdown: the left column is narrow once the
        // portrait takes its half, and a badge next to "222 days" was what
        // truncated the number. The full phrase always wraps instead of
        // ending in an ellipsis.
        Text(
          metric,
          softWrap: true,
          textScaler: context.nameTextScaler,
          style: q.text.numeralMd.tinted(q.color.textPrimary),
        ),
        SizedBox(height: q.space.xs),
        Text(
          support,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: q.text.metadata.tinted(q.color.textSecondary),
        ),
      ],
    );
  }
}

class _SquarePortrait extends StatelessWidget {
  const _SquarePortrait({
    required this.displayName,
    required this.seed,
    this.photo,
    this.heroTag,
  });

  final String displayName;
  final String seed;
  final ImageProvider? photo;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final image = QPhoto(
      displayName: displayName,
      seed: seed,
      photo: photo,
    );

    return QClip(
      radius: q.radius.xl,
      child: heroTag == null ? image : Hero(tag: heroTag!, child: image),
    );
  }
}

/// Two plates: Moments (photos) and Notes (text details). Owns most of the
/// viewport — birthday date and location stay behind Edit.
class _MemoryArea extends ConsumerWidget {
  const _MemoryArea({required this.summary});

  final PersonSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = context.quiet;
    final profile = summary.profile;
    final notes = profile == null
        ? const <Note>[]
        : (ref.watch(personNotesProvider(summary.person.id)).asData?.value ??
              const <Note>[]);
    final photos = notes.where((n) => n.isPhotoMemory).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final details = notes
        .where((n) => !n.isPhotoMemory)
        .toList(growable: false);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _MomentsPlate(
          photos: photos,
          displayName: summary.person.displayName,
          person: summary.person,
          profile: profile,
          nextPosition: notes.length,
        ),
        SizedBox(height: q.space.xl),
        _NotesPlate(
          details: details,
          person: summary.person,
          profile: profile,
          nextPosition: notes.length,
        ),
      ],
    );
  }
}

class _MomentsPlate extends ConsumerWidget {
  const _MomentsPlate({
    required this.photos,
    required this.displayName,
    required this.person,
    required this.nextPosition,
    this.profile,
  });

  final List<Note> photos;
  final String displayName;
  final Person person;
  final RelationshipProfile? profile;
  final int nextPosition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = context.quiet;

    return QSurface(
      elevation: QuietElevationLevel.hairline,
      radius: q.radius.xl,
      padding: EdgeInsets.all(q.space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Moments',
                  style: q.text.headline.tinted(q.color.textPrimary),
                ),
              ),
              QButton.tertiary(
                label: 'Add',
                glyph: QuietGlyph.camera,
                onPressed: () => addPhotoMemory(
                  context: context,
                  ref: ref,
                  person: person,
                  profile: profile,
                  nextPosition: nextPosition,
                ),
              ),
            ],
          ),
          SizedBox(height: q.space.base),
          if (photos.isEmpty)
            Text(
              'Save a photo of a moment you want to keep.',
              style: q.text.body.tinted(q.color.textSecondary),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MomentsStack(
                  photos: photos,
                  displayName: displayName,
                ),
                SizedBox(height: q.space.md),
                QPressable(
                  onTap: () => showMomentsGallery(
                    context: context,
                    ref: ref,
                    person: person,
                    photos: photos,
                    displayName: displayName,
                    profile: profile,
                  ),
                  radius: q.radius.md,
                  semanticLabel: 'Open all moments',
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: q.space.sm),
                    child: Text(
                      photos.length == 1
                          ? 'Tap to open'
                          : photos.length == 2
                          ? '1 more behind — tap to see all'
                          : '${photos.length - 1} more behind — tap to see all',
                      style: q.text.metadata.tinted(q.color.accent),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Recent photo in front; older ones sit behind like a deck.
class _MomentsStack extends ConsumerStatefulWidget {
  const _MomentsStack({
    required this.photos,
    required this.displayName,
  });

  final List<Note> photos;
  final String displayName;

  @override
  ConsumerState<_MomentsStack> createState() => _MomentsStackState();
}

class _MomentsStackState extends ConsumerState<_MomentsStack> {
  String? _heldCaption;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final visible = widget.photos.take(3).toList(growable: false);
    const cardWidth = 108.0;
    const cardHeight = 144.0;
    final stackWidth = cardWidth + (visible.length - 1) * 18.0;
    final stackHeight = cardHeight + (visible.length - 1) * 10.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: stackHeight,
          width: double.infinity,
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: stackWidth,
              height: stackHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (var i = visible.length - 1; i >= 0; i--)
                    Positioned(
                      left: i * 18.0,
                      top: i * 10.0,
                      child: Transform.scale(
                        alignment: Alignment.topLeft,
                        scale: 1 - (i * 0.045),
                        child: Opacity(
                          opacity: 1 - (i * 0.18),
                          child: _StackCard(
                            note: visible[i],
                            displayName: widget.displayName,
                            width: cardWidth,
                            height: cardHeight,
                            isFront: i == 0,
                            onHoldCaption: (caption) =>
                                setState(() => _heldCaption = caption),
                            onReleaseCaption: () =>
                                setState(() => _heldCaption = null),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (_heldCaption != null && _heldCaption!.isNotEmpty) ...[
          SizedBox(height: q.space.md),
          Text(
            _heldCaption!,
            style: q.text.body.tinted(q.color.textPrimary),
          ),
        ],
      ],
    );
  }
}

class _StackCard extends ConsumerWidget {
  const _StackCard({
    required this.note,
    required this.displayName,
    required this.width,
    required this.height,
    required this.isFront,
    required this.onHoldCaption,
    required this.onReleaseCaption,
  });

  final Note note;
  final String displayName;
  final double width;
  final double height;
  final bool isFront;
  final ValueChanged<String?> onHoldCaption;
  final VoidCallback onReleaseCaption;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = context.quiet;
    final image = ref.watch(personPhotoProvider(note.photoId)).asData?.value;

    return Listener(
      onPointerUp: (_) => onReleaseCaption(),
      onPointerCancel: (_) => onReleaseCaption(),
      child: GestureDetector(
        onTap: isFront && image != null
            ? () => showPhotoMemoryReview(
                context: context,
                photo: image,
                caption: note.caption,
                displayName: displayName,
              )
            : null,
        onLongPressStart: isFront && note.caption != null
            ? (_) => onHoldCaption(note.caption)
            : null,
        onLongPressEnd: isFront ? (_) => onReleaseCaption() : null,
        child: SizedBox(
          width: width,
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(q.radius.lg),
              boxShadow: [
                BoxShadow(
                  color: q.color.scrim.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: QClip(
              radius: q.radius.lg,
              child: QPhoto(
                displayName: displayName,
                seed: note.id,
                photo: image,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotesPlate extends ConsumerStatefulWidget {
  const _NotesPlate({
    required this.details,
    required this.person,
    required this.nextPosition,
    this.profile,
  });

  final List<Note> details;
  final Person person;
  final RelationshipProfile? profile;
  final int nextPosition;

  @override
  ConsumerState<_NotesPlate> createState() => _NotesPlateState();
}

class _NotesPlateState extends ConsumerState<_NotesPlate> {
  List<DetailKindSection> _order = List<DetailKindSection>.from(
    DetailKindSection.defaultOrder,
  );

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final order = await loadDetailKindSectionOrder();
    if (!mounted) return;
    setState(() => _order = order);
  }

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final grouped = groupNotesByDetailSection(
      widget.details,
      order: _order,
    );

    return QSurface(
      elevation: QuietElevationLevel.hairline,
      radius: q.radius.xl,
      padding: EdgeInsets.all(q.space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Notes',
                  style: q.text.headline.tinted(q.color.textPrimary),
                ),
              ),
              QButton.tertiary(
                label: 'Add',
                glyph: QuietGlyph.plus,
                onPressed: () => addDetailMemory(
                  context: context,
                  ref: ref,
                  person: widget.person,
                  profile: widget.profile,
                  nextPosition: widget.nextPosition,
                ),
              ),
            ],
          ),
          SizedBox(height: q.space.md),
          if (widget.details.isEmpty)
            Text(
              'What they love, gift ideas, or a plan you want to make for them.',
              style: q.text.body.tinted(q.color.textSecondary),
            )
          else
            for (var s = 0; s < grouped.length; s++) ...[
              if (s > 0) SizedBox(height: q.space.lg),
              Text(
                grouped[s].$1.title.toUpperCase(),
                textScaler: context.structuralTextScaler,
                style: q.text.eyebrow.tinted(q.color.textTertiary),
              ),
              SizedBox(height: q.space.xs),
              for (final (header, note) in notesWithKindHeaders(
                grouped[s].$1,
                grouped[s].$2,
              )) ...[
                if (header != null) ...[
                  if (note != grouped[s].$2.first) SizedBox(height: q.space.md),
                  Text(
                    header,
                    textScaler: context.structuralTextScaler,
                    style: q.text.metadata.tinted(q.color.textSecondary),
                  ),
                  SizedBox(height: q.space.xs),
                ] else if (note != grouped[s].$2.first)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: q.space.xs),
                    child: const QHairline(),
                  ),
                _DetailMemoryRow(
                  note: note,
                  person: widget.person,
                  profile: widget.profile,
                  nextPosition: widget.nextPosition,
                ),
              ],
            ],
        ],
      ),
    );
  }
}

class _DetailMemoryRow extends ConsumerWidget {
  const _DetailMemoryRow({
    required this.note,
    required this.person,
    required this.nextPosition,
    this.profile,
  });

  final Note note;
  final Person person;
  final RelationshipProfile? profile;
  final int nextPosition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = context.quiet;
    final subtitle = noteRowSubtitle(note);
    final semantic = subtitle == null
        ? (DetailKindSection.forKind(note.kind) == DetailKindSection.favorites
              ? '${detailKindLabel(note.kind)}: ${note.value}'
              : note.value)
        : '$subtitle: ${note.value}';

    return QPressable(
      onTap: () => addDetailMemory(
        context: context,
        ref: ref,
        person: person,
        profile: profile,
        nextPosition: nextPosition,
        initialKind: note.kind,
      ),
      onLongPress: () => addDetailMemory(
        context: context,
        ref: ref,
        person: person,
        profile: profile,
        nextPosition: note.position,
        note: note,
      ),
      radius: q.radius.md,
      semanticLabel: semantic,
      semanticHint: 'Add another detail. Long press to remove.',
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: q.space.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.value,
              style: q.text.body.tinted(q.color.textPrimary),
            ),
            if (subtitle != null) ...[
              SizedBox(height: q.space.xs),
              Text(
                subtitle,
                style: q.text.metadata.tinted(q.color.textTertiary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _metric(PersonSummary summary) {
  return switch (summary.daysUntilBirthday) {
    0 => 'Today',
    1 => 'Tomorrow',
    final days => '$days days',
  };
}

String _support(PersonSummary summary) {
  final date = _dateLabel(summary.nextBirthday);
  final age = summary.turningAge;
  return switch (summary.daysUntilBirthday) {
    0 => age == null ? 'Their birthday is today' : 'Turns $age today',
    _ => age == null ? 'Their birthday is $date' : 'Turns $age on $date',
  };
}

Future<void> _showPersonActions(
  BuildContext context,
  WidgetRef ref,
  PersonSummary summary,
) async {
  final person = summary.person;
  final profile = summary.profile;
  final hasProfile = profile != null;
  final choices = <QChoice>[
    if (hasProfile)
      QChoice(
        profile.isPinned ? 'Unpin from top' : 'Pin to top',
        support: profile.isPinned
            ? 'Return them to alphabetical order.'
            : 'Keep them at the front of People.',
      ),
    QChoice(
      hasProfile ? 'Edit Profile' : 'Create Profile',
      support: hasProfile
          ? 'Name, photo, nickname, how you know them, and memories.'
          : 'Start remembering more than the date.',
    ),
    const QChoice(
      'Edit Birthday',
      support: 'Birthday date and where they live.',
    ),
    const QChoice('Delete', destructive: true),
  ];
  final choice = await showQChoiceSheet(
    context: context,
    title: person.displayName,
    choices: choices,
  );
  if (choice == null || !context.mounted) return;

  var index = choice;
  if (hasProfile) {
    if (index == 0) {
      await ref
          .read(profileRepositoryProvider)
          .save(
            profile.copyWith(
              isPinned: !profile.isPinned,
              updatedAt: ref.read(clockProvider).now(),
            ),
          );
      return;
    }
    index -= 1;
  }

  switch (index) {
    case 0:
      await showProfileFlow(
        context: context,
        ref: ref,
        person: person,
        profile: profile,
      );
    case 1:
      await showQSheet<void>(
        context: context,
        builder: (context) => _EditBirthdaySheet(person: person),
      );
    case 2:
      await ref.read(personRepositoryProvider).softDelete(person.id);
      try {
        await ref.read(notificationCoordinatorProvider).synchronize();
      } on Object {
        // Reminder sync is best-effort.
      }
      if (context.mounted) context.pop();
  }
}

class _EditBirthdaySheet extends ConsumerStatefulWidget {
  const _EditBirthdaySheet({required this.person});

  final Person person;

  @override
  ConsumerState<_EditBirthdaySheet> createState() => _EditBirthdaySheetState();
}

class _EditBirthdaySheetState extends ConsumerState<_EditBirthdaySheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _dayController;
  late final TextEditingController _yearController;
  CityRecord? _location;
  int? _month;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.person.displayName);
    _dayController = TextEditingController(
      text: widget.person.birthday.day.toString(),
    );
    _yearController = TextEditingController(
      text: widget.person.birthday.year?.toString() ?? '',
    );
    _month = widget.person.birthday.month;
    final currentLocation = widget.person.location?.label;
    _location = currentLocation == null
        ? null
        : () {
            for (final city in cityDataset) {
              if (city.label == currentLocation) return city;
            }
            return null;
          }();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QSheet(
      title: 'Edit birthday',
      bottom: QBottomActions(
        children: [
          QButton.tertiary(
            label: 'Not now',
            onPressed: () => Navigator.of(context).pop(),
          ),
          QButton.primary(label: 'Save', onPressed: _save),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QField(
              controller: _nameController,
              label: 'Name',
              placeholder: 'Name',
            ),
            QDateField(
              dayController: _dayController,
              yearController: _yearController,
              monthLabel: _month == null ? null : _monthNames[_month! - 1],
              onMonthPressed: () => _showMonthPicker(
                context: context,
                onSelected: (value) => setState(() => _month = value),
                selectedMonth: _month,
              ),
              helper: 'The year is optional.',
            ),
            const QSectionTitle(
              'Where they live',
              support: 'So the day arrives at the right time for them.',
            ),
            QSettingRow(
              label: _location?.city ?? 'Choose a city',
              subtitle:
                  _location?.label ??
                  (widget.person.location?.label ??
                      'Tap to search — reminders follow their local time.'),
              showChevron: true,
              onTap: () async {
                final city = await showPlacePickerSheet(context: context);
                if (city == null || !mounted) return;
                setState(() => _location = city);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final day = int.tryParse(_dayController.text.trim());
    final year = _yearController.text.trim().isEmpty
        ? null
        : int.tryParse(_yearController.text.trim());
    if (_nameController.text.trim().isEmpty || day == null || _month == null) {
      return;
    }
    await ref
        .read(personRepositoryProvider)
        .save(
          widget.person.copyWith(
            displayName: _nameController.text.trim(),
            birthday: PartialDate(month: _month!, day: day, year: year),
            location: _location == null
                ? widget.person.location
                : LocationModel(
                    label: _location!.label,
                    timezone: TimezoneModel(_location!.ianaTimezone),
                  ),
          ),
        );
    try {
      await ref.read(notificationCoordinatorProvider).synchronize();
    } on Object {
      // Reminder sync is best-effort.
    }
    if (mounted) Navigator.of(context).pop();
  }
}

Future<void> _showMonthPicker({
  required BuildContext context,
  required ValueChanged<int> onSelected,
  int? selectedMonth,
}) async {
  final index = await showQChoiceSheet(
    context: context,
    title: 'Month',
    choices: [for (final month in _monthNames) QChoice(month)],
    selectedIndex: selectedMonth == null ? null : selectedMonth - 1,
  );
  if (index != null) onSelected(index + 1);
}

String _dateLabel(DateTime date) =>
    '${date.day} ${_monthNames[date.month - 1]}';

const _monthNames = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
