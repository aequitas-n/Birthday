import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/app/router.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/design/components/buttons/q_button.dart';
import 'package:kin/design/components/buttons/q_icon_button.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/journal/q_journal_card_deck.dart';
import 'package:kin/design/components/journal/q_journal_mood_picker.dart';
import 'package:kin/design/components/journal/q_mood_illustration.dart';
import 'package:kin/design/components/navigation/q_diary_top_bar.dart';
import 'package:kin/design/components/sheets/q_sheet.dart';
import 'package:kin/design/components/sheets/q_sheet_route.dart';
import 'package:kin/design/components/surfaces/q_screen.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/mood_illustration_metrics.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/domain/models/journal_day.dart';
import 'package:kin/domain/models/journal_entry.dart';
import 'package:kin/domain/models/journal_mood.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/features/journal/application/journal_providers.dart';
// ignore: always_use_package_imports -- ARCH-03
import 'journal_memory_editor.dart';

/// One journal day — a physical deck of identical diary memory cards.
class JournalDayScreen extends ConsumerStatefulWidget {
  const JournalDayScreen({required this.dateKey, super.key});

  final String dateKey;

  @override
  ConsumerState<JournalDayScreen> createState() => _JournalDayScreenState();
}

class _JournalDayScreenState extends ConsumerState<JournalDayScreen> {
  static const _moodSheetCancelled = Object();
  final _deckKey = GlobalKey<QJournalCardDeckState>();
  var _frontPosition = 1;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final date = LocalCalendarDate.parseStorage(widget.dateKey);
    final day = ref.watch(journalDayProvider(widget.dateKey));
    final entries = ref.watch(journalEntriesProvider(widget.dateKey));
    final entryList = entries.asData?.value ?? const <JournalEntry>[];
    final dayMood = day.asData?.value?.mood;

    return QScreen(
      child: QMeasure(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            QDiaryTopBar(
              leading: QIconButton(
                glyph: QuietGlyph.chevronLeft,
                onPressed: () => context.pop(),
                semanticLabel: 'Back',
              ),
              actions: [
                QIconButton(
                  glyph: QuietGlyph.plus,
                  onPressed: () => _addEntry(context, date, entryList),
                  semanticLabel: 'Add memory',
                ),
              ],
            ),
            // Stable screen header — not part of the card flex region.
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.gutter,
                q.space.sm,
                context.gutter,
                q.space.sm,
              ),
              child: _DayHeader(date: date, mood: dayMood),
            ),
            if (entryList.isEmpty)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.gutter),
                  child: _EmptyDay(
                    onAdd: () => _addEntry(context, date, entryList),
                  ),
                ),
              )
            else
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.gutter),
                  child: _StableDeckColumn(
                    deckKey: _deckKey,
                    dateKey: widget.dateKey,
                    entries: entryList,
                    frontPosition: _frontPosition,
                    onOpen: (entry) {
                      context.pushNamed(
                        AppRoute.journalEntry.name,
                        pathParameters: {
                          'date': widget.dateKey,
                          'entryId': entry.id,
                        },
                      );
                    },
                    onFrontChanged: (position) {
                      if (_frontPosition != position) {
                        setState(() => _frontPosition = position);
                      }
                    },
                  ),
                ),
              ),
            // Mood action — reserved band; illustration may hang upward.
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.gutter,
                entryList.isEmpty ? 0 : q.space.md,
                context.gutter,
                q.space.md + MediaQuery.paddingOf(context).bottom * 0.25,
              ),
              child: _DayMoodFooter(
                mood: dayMood,
                onPressed: () => _setDayMood(
                  context,
                  date,
                  day.asData?.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addEntry(
    BuildContext context,
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
    LocalCalendarDate date,
    JournalDay? existing,
  ) async {
    var selected = existing?.mood;
    final result = await showQSheet<Object?>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final q = context.quiet;
            return QSheet(
              title: 'Day mood',
              bottom: QBottomActions(
                children: [
                  QButton.tertiary(
                    label: 'Not now',
                    onPressed: () =>
                        Navigator.of(context).pop(_moodSheetCancelled),
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
                    'How did this day feel?',
                    style: q.inked(
                      q.text.uiBody,
                      surface: QuietSurfaceKind.paper,
                      tone: QuietInkTone.secondary,
                    ),
                  ),
                  SizedBox(height: q.space.lg),
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
    if (identical(result, _moodSheetCancelled)) return;
    final mood = result as JournalMood?;
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

class _StableDeckColumn extends ConsumerWidget {
  const _StableDeckColumn({
    required this.deckKey,
    required this.dateKey,
    required this.entries,
    required this.frontPosition,
    required this.onOpen,
    required this.onFrontChanged,
  });

  final GlobalKey<QJournalCardDeckState> deckKey;
  final String dateKey;
  final List<JournalEntry> entries;
  final int frontPosition;
  final ValueChanged<JournalEntry> onOpen;
  final ValueChanged<int> onFrontChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = context.quiet;
    final viewportH = MediaQuery.sizeOf(context).height;
    final targetH = (viewportH * q.layout.journalDayCardHeightFraction).clamp(
      q.layout.journalDayCardMinHeight,
      q.layout.journalDayCardMaxHeight,
    );

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Cap from viewport — do not stretch into leftover Expanded space.
              final deckH = math.min(targetH, constraints.maxHeight);
              return Center(
                child: SizedBox(
                  height: deckH,
                  width: constraints.maxWidth,
                  child: _DeckRegion(
                    deckKey: deckKey,
                    dateKey: dateKey,
                    entries: entries,
                    onOpen: onOpen,
                    onFrontChanged: onFrontChanged,
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: q.space.xs, bottom: q.space.sm),
          child: QJournalDeckCounter(
            position: frontPosition.clamp(1, entries.length),
            total: entries.length,
          ),
        ),
      ],
    );
  }
}

class _DeckRegion extends ConsumerWidget {
  const _DeckRegion({
    required this.deckKey,
    required this.dateKey,
    required this.entries,
    required this.onOpen,
    required this.onFrontChanged,
  });

  final GlobalKey<QJournalCardDeckState> deckKey;
  final String dateKey;
  final List<JournalEntry> entries;
  final ValueChanged<JournalEntry> onOpen;
  final ValueChanged<int> onFrontChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = <QJournalDeckItem>[
      for (final entry in entries)
        QJournalDeckItem(
          id: entry.id,
          title: entry.title,
          body: entry.body,
          moodId: entry.mood?.storageValue,
          moodLabel: entry.mood?.displayName,
          fragmentLabel: _fragmentLabel(ref, entry),
          photo: _photoFor(ref, entry),
        ),
    ];

    final byId = {for (final e in entries) e.id: e};

    return QJournalCardDeck(
      key: deckKey,
      items: items,
      onOpen: (item) {
        final entry = byId[item.id];
        if (entry != null) onOpen(entry);
      },
      onFrontChanged: (item) {
        final index = entries.indexWhere((e) => e.id == item.id);
        if (index >= 0) onFrontChanged(index + 1);
      },
    );
  }

  String? _fragmentLabel(WidgetRef ref, JournalEntry entry) {
    final photos = ref.watch(journalEntryPhotosProvider(entry.id));
    final list = photos.asData?.value ?? const [];
    if (list.isNotEmpty) return 'photograph';
    if (entry.body.trim().isNotEmpty) return 'writing';
    return null;
  }

  Widget? _photoFor(WidgetRef ref, JournalEntry entry) {
    final photos = ref.watch(journalEntryPhotosProvider(entry.id));
    final list = photos.asData?.value ?? const [];
    if (list.isEmpty) return null;
    final image = ref.watch(journalPhotoProvider(list.first.photoId));
    return image.when(
      data: (provider) =>
          provider == null ? null : Image(image: provider, fit: BoxFit.cover),
      loading: () => const SizedBox.expand(),
      error: (_, _) => null,
    );
  }
}

class _DayMoodFooter extends StatelessWidget {
  const _DayMoodFooter({
    required this.mood,
    required this.onPressed,
  });

  final JournalMood? mood;
  final VoidCallback onPressed;

  /// Day-mood companion art — hangs upward; only a fraction reserves layout.
  static const _artWidthOfViewport = 0.26;

  /// How much of the art height participates in layout (rest hangs up).
  static const _artLayoutFraction = 0.42;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final moodId = mood?.storageValue;
    final label = mood == null ? "Set the day's mood" : 'Change day mood';
    final screenW = MediaQuery.sizeOf(context).width;
    final artWidth = screenW * _artWidthOfViewport;
    final artHeight = artWidth / MoodIllustrationMetrics.aspectRatio;
    final layoutArtH = artHeight * _artLayoutFraction;

    // Stable action-band height — illustration may overflow upward into the
    // deck breathing room without collapsing the card when mood appears.
    final actionBand = context.structuralTextScaler.scale(48.0);
    final bandH = moodId == null
        ? actionBand
        : math.max(actionBand, layoutArtH);

    return SizedBox(
      height: bandH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _DiaryMoodAction(
              label: label,
              onPressed: onPressed,
            ),
          ),
          if (moodId != null)
            Positioned(
              right: 0,
              bottom: -q.space.xs,
              child: IgnorePointer(
                child: QMoodIllustration(
                  moodId: moodId,
                  size: MoodIllustrationSize.dayFooter,
                  width: artWidth,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Courier diary action with a hairline underline — clickable, not Material.
class _DiaryMoodAction extends StatelessWidget {
  const _DiaryMoodAction({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final ink = q.inked(q.text.uiBody).color ?? q.canvas.primary;

    return QPressable(
      onTap: onPressed,
      radius: q.radius.sm,
      semanticLabel: label,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: q.space.sm,
          horizontal: q.space.xs,
        ),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                textScaler: context.structuralTextScaler,
                style: q.inked(q.text.uiBody),
              ),
              SizedBox(height: q.space.xs),
              ColoredBox(
                color: ink.withValues(alpha: 0.55),
                child: SizedBox(height: context.hairlineWidth),
              ),
            ],
          ),
        ),
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
    final weekday =
        _weekdays[DateTime(date.year, date.month, date.day).weekday - 1];

    return Column(
      children: [
        Text(
          'Journal of the Day',
          textAlign: TextAlign.center,
          textScaler: context.nameTextScaler,
          style: q.inked(q.text.pageTitle),
        ),
        SizedBox(height: q.space.xs),
        Text(
          'Your memories, one card at a time.',
          textAlign: TextAlign.center,
          textScaler: context.structuralTextScaler,
          style: q.inked(q.text.uiCaption, tone: QuietInkTone.secondary),
        ),
        SizedBox(height: q.space.sm),
        Text(
          '${_months[date.month - 1]} ${date.day} · $weekday',
          textAlign: TextAlign.center,
          textScaler: context.structuralTextScaler,
          style: q.inked(q.text.uiDate, tone: QuietInkTone.secondary),
        ),
        if (mood != null) ...[
          SizedBox(height: q.space.hair),
          Text(
            mood!.displayName.toUpperCase(),
            textAlign: TextAlign.center,
            textScaler: context.structuralTextScaler,
            style: q.inked(
              q.text.uiMetadata,
              tone: QuietInkTone.secondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: q.space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nothing written here yet.',
            style: q.inked(q.text.emptyStateTitle),
          ),
          SizedBox(height: q.space.sm),
          Text(
            'Begin with something you remember.',
            style: q.inked(q.text.emptyStateBody, tone: QuietInkTone.secondary),
          ),
          SizedBox(height: q.space.xl),
          QButton.primary(label: 'Add memory', onPressed: onAdd),
        ],
      ),
    );
  }
}
