import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/app/router.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/design/components/buttons/q_button.dart';
import 'package:kin/design/components/buttons/q_icon_button.dart';
import 'package:kin/design/components/journal/q_journal_fragment.dart';
import 'package:kin/design/components/journal/q_journal_mood_picker.dart';
import 'package:kin/design/components/sheets/q_sheet.dart';
import 'package:kin/design/components/sheets/q_sheet_route.dart';
import 'package:kin/design/components/surfaces/q_screen.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/motion/quiet_motion.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/domain/models/journal_day.dart';
import 'package:kin/domain/models/journal_entry.dart';
import 'package:kin/domain/models/journal_mood.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/features/journal/application/journal_providers.dart';
// ignore: always_use_package_imports -- ARCH-03
import 'journal_fragment_layout.dart';
// ignore: always_use_package_imports -- ARCH-03
import 'journal_memory_editor.dart';

/// One journal day — an opened diary page of archival fragments.
class JournalDayScreen extends ConsumerWidget {
  const JournalDayScreen({required this.dateKey, super.key});

  final String dateKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = context.quiet;
    final j = q.journal;
    final date = LocalCalendarDate.parseStorage(dateKey);
    final day = ref.watch(journalDayProvider(dateKey));
    final entries = ref.watch(journalEntriesProvider(dateKey));
    final entryList = entries.asData?.value ?? const <JournalEntry>[];
    final dayMood = day.asData?.value?.mood;

    return QScreen(
      canvasColor: j.desk,
      child: QMeasure(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.gutter - q.space.sm,
                q.space.base,
                context.gutter,
                0,
              ),
              child: Row(
                children: [
                  QIconButton(
                    glyph: QuietGlyph.chevronLeft,
                    onPressed: () => context.pop(),
                    semanticLabel: 'Back',
                  ),
                  const Spacer(),
                  QIconButton(
                    glyph: QuietGlyph.plus,
                    onPressed: () => _addEntry(context, ref, date, entryList),
                    semanticLabel: 'Add memory',
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  context.gutter,
                  q.space.md,
                  context.gutter,
                  q.space.emptiness,
                ),
                children: [
                  _DayHeader(date: date, mood: dayMood),
                  SizedBox(height: q.space.lg),
                  if (entryList.isEmpty)
                    _EmptyDay(
                      onAdd: () => _addEntry(context, ref, date, entryList),
                    )
                  else
                    _ArchiveComposition(
                      dateKey: dateKey,
                      entries: entryList,
                    ),
                  SizedBox(height: q.space.xl),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: QButton.tertiary(
                      label: dayMood == null
                          ? "Set the day's mood"
                          : 'Change day mood',
                      onPressed: () => _setDayMood(
                        context,
                        ref,
                        date,
                        day.asData?.value,
                      ),
                    ),
                  ),
                  if (entryList.isNotEmpty) ...[
                    SizedBox(height: q.space.md),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: QButton.primary(
                        label: 'Add memory',
                        onPressed: () =>
                            _addEntry(context, ref, date, entryList),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addEntry(
    BuildContext context,
    WidgetRef ref,
    LocalCalendarDate date,
    List<JournalEntry> entries,
  ) async {
    final created = await openJournalMemoryEditor(
      context: context,
      date: date,
      position: entries.length,
    );
    if (created == null || !context.mounted) return;
    await context.pushNamed(
      AppRoute.journalEntry.name,
      pathParameters: {'date': date.storageKey, 'entryId': created.id},
    );
  }

  Future<void> _setDayMood(
    BuildContext context,
    WidgetRef ref,
    LocalCalendarDate date,
    JournalDay? existing,
  ) async {
    var selected = existing?.mood;
    final result = await showQSheet<JournalMood?>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final q = context.quiet;
            final j = q.journal;
            return QSheet(
              title: 'Day mood',
              bottom: QBottomActions(
                children: [
                  QButton.tertiary(
                    label: 'Not now',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  QButton.primary(
                    label: 'Save',
                    onPressed: () => Navigator.of(context).pop(selected),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'MOOD',
                    textScaler: context.structuralTextScaler,
                    style: q.text.archiveLabel.tinted(j.inkMuted),
                  ),
                  SizedBox(height: q.space.md),
                  QJournalMoodPicker(
                    selectedId: selected?.storageValue,
                    options: [
                      for (final mood in JournalMood.values)
                        (mood.storageValue, mood.displayName),
                    ],
                    onSelected: (id) {
                      setModalState(() {
                        selected = id == null
                            ? null
                            : JournalMood.fromStorage(id);
                      });
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (result == null && selected == null) return;
    final mood = result;
    if (mood == null) return;
    final now = ref.read(clockProvider).now();
    await ref
        .read(journalRepositoryProvider)
        .upsertDay(
          JournalDay(
            localDate: date,
            mood: mood,
            createdAt: existing?.createdAt ?? now,
            updatedAt: now,
          ),
        );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.date, this.mood});

  final LocalCalendarDate date;
  final JournalMood? mood;

  static const _months = [
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

  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final j = q.journal;
    final weekday =
        _weekdays[DateTime(date.year, date.month, date.day).weekday - 1];

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: j.rule, width: context.hairlineWidth),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: q.space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _months[date.month - 1].toUpperCase(),
              textScaler: context.structuralTextScaler,
              style: q.text.archiveLabel.tinted(j.inkMuted),
            ),
            Text(
              '${date.day}',
              textScaler: context.nameTextScaler,
              style: q.text.voiceXl.tinted(j.ink),
            ),
            SizedBox(height: q.space.xs),
            Text(
              weekday,
              style: q.text.archiveMeta.tinted(j.inkMuted),
            ),
            if (mood != null) ...[
              SizedBox(height: q.space.xs),
              Text(
                mood!.displayName,
                textScaler: context.structuralTextScaler,
                style: q.text.archiveLabel.tinted(j.inkMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final j = q.journal;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: q.space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nothing written here yet.',
            style: q.text.voiceMd.tinted(j.ink),
          ),
          SizedBox(height: q.space.sm),
          Text(
            'Begin with something you remember.',
            style: q.text.archiveBody.tinted(j.inkMuted),
          ),
          SizedBox(height: q.space.xl),
          QButton.primary(label: 'Add memory', onPressed: onAdd),
        ],
      ),
    );
  }
}

class _ArchiveComposition extends ConsumerWidget {
  const _ArchiveComposition({
    required this.dateKey,
    required this.entries,
  });

  final String dateKey;
  final List<JournalEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final motion = QuietMotion.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, entry) in entries.indexed)
          _FragmentSlot(
            key: ValueKey(entry.id),
            dateKey: dateKey,
            entry: entry,
            index: index,
            delay: motion.staggerFor(index),
          ),
      ],
    );
  }
}

class _FragmentSlot extends ConsumerStatefulWidget {
  const _FragmentSlot({
    required this.dateKey,
    required this.entry,
    required this.index,
    required this.delay,
    super.key,
  });

  final String dateKey;
  final JournalEntry entry;
  final int index;
  final Duration delay;

  @override
  ConsumerState<_FragmentSlot> createState() => _FragmentSlotState();
}

class _FragmentSlotState extends ConsumerState<_FragmentSlot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;
  var _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final motion = QuietMotion.of(context);
    _controller.duration = motion.move(const Duration(milliseconds: 280));
    if (motion.reduced) {
      _controller.value = 1;
      return;
    }
    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = ref.watch(journalEntryPhotosProvider(widget.entry.id));
    final photoList = photos.asData?.value ?? const [];
    final hasPhotos = photoList.isNotEmpty;
    final layout = JournalFragmentLayout.resolve(
      entryId: widget.entry.id,
      position: widget.entry.position,
      dateKey: widget.dateKey,
      hasPhotos: hasPhotos,
      bodyLength: widget.entry.body.length,
      title: widget.entry.title,
    );

    Widget? thumb;
    if (hasPhotos) {
      final first = photoList.first;
      final image = ref.watch(journalPhotoProvider(first.photoId));
      thumb = image.when(
        data: (provider) => provider == null
            ? const SizedBox.expand()
            : Image(image: provider, fit: BoxFit.cover),
        loading: () => const SizedBox.expand(),
        error: (_, _) => const SizedBox.expand(),
      );
    }

    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: Padding(
          padding: EdgeInsets.only(
            top: layout.topGap,
            left: layout.leadingInset,
            right: layout.trailingInset,
          ),
          child: QJournalFragment(
            title: widget.entry.title,
            bodyPreview: widget.entry.body.isEmpty ? null : widget.entry.body,
            moodId: widget.entry.mood?.storageValue,
            moodLabel: widget.entry.mood?.displayName,
            archiveIndex: 'No. ${widget.index + 1}',
            kind: layout.kind,
            hasPhotos: hasPhotos,
            photoThumb: thumb,
            rotation: layout.rotation,
            widthFactor: layout.widthFactor,
            showTape: layout.showTape,
            showClip: layout.showClip,
            seed: layout.seed,
            onTap: () {
              context.pushNamed(
                AppRoute.journalEntry.name,
                pathParameters: {
                  'date': widget.dateKey,
                  'entryId': widget.entry.id,
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
