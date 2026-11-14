import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/app/journal_memory_launcher.dart';
import 'package:kin/app/person_editor_launcher.dart';
import 'package:kin/app/phase5_diag.dart';
import 'package:kin/app/phase6_diag.dart';
import 'package:kin/app/router.dart';
import 'package:kin/design/components/buttons/q_button.dart';
import 'package:kin/design/components/buttons/q_icon_button.dart';
import 'package:kin/design/components/feedback/q_arc.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/journal/q_ambient_scene.dart';
import 'package:kin/design/components/journal/q_illustrated_journal_invite.dart';
import 'package:kin/design/components/journal/q_mood_illustration.dart';
import 'package:kin/design/components/journal/q_today_empty_journal_invite.dart';
import 'package:kin/design/components/navigation/q_diary_top_bar.dart';
import 'package:kin/design/components/rows/q_person_row.dart';
import 'package:kin/design/components/surfaces/q_hairline.dart';
import 'package:kin/design/components/surfaces/q_screen.dart';
import 'package:kin/design/components/surfaces/q_theme_surfaces.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/domain/models/journal_entry.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/domain/models/personal_reminder.dart';
import 'package:kin/features/home/application/home_providers.dart';
import 'package:kin/features/journal/application/journal_providers.dart';
import 'package:kin/features/person/application/person_detail_providers.dart';
import 'package:kin/features/reminders/application/reminder_providers.dart';
import 'package:kin/features/today/application/today_providers.dart';

/// Universal front door — what matters today across Journal, Reminders, and Kin.
///
/// One editorial daily page: compact identity, generous journal card, tight
/// section rhythm so Coming up reaches the first viewport without feeling dense.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

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

  /// Memories shown on Today — invitation, not the full day archive.
  static const _journalPreviewLimit = 2;

  /// Reminders shown before “View all”.
  static const _reminderPreviewLimit = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Phase5Diag.timedValue('today_build', () {
      return Phase6Diag.timedValue('today_build', () {
        final q = context.quiet;
        final space = q.space;
        final today = ref.watch(journalTodayProvider);
        final dateKey = today.storageKey;
        final entries =
            ref.watch(journalEntriesProvider(dateKey)).asData?.value ??
            const <JournalEntry>[];
        final birthdaysToday = ref.watch(todayBirthdayProvider);
        final upcoming = [
          for (final entry in ref.watch(todayUpcomingProvider))
            if (entry.daysUntil > 0) entry,
        ];
        final peopleLoading = ref.watch(peopleStreamProvider).isLoading;
        final reminders = [
          ...ref.watch(todayActiveRemindersProvider),
        ]..sort((a, b) => a.localTime.compareTo(b.localTime));

        if (!peopleLoading) {
          Phase6Diag.onTodayUsable();
        }
        return QScreen(
          child: QMeasure(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                QDiaryTopBar(
                  title: 'Today',
                  actions: [
                    QIconButton(
                      glyph: QuietGlyph.plus,
                      onPressed: () => showAddPersonFlow(context, ref),
                      semanticLabel: 'Add someone',
                    ),
                    QIconButton(
                      glyph: QuietGlyph.settings,
                      onPressed: () => context.push('/settings'),
                      semanticLabel: 'Settings',
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      context.gutter,
                      q.space.sectionLead,
                      context.gutter,
                      space.pageBottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DateStamp(today: today),
                        SizedBox(height: space.sectionGap),
                        _TodayJournalSection(
                          today: today,
                          entries: entries,
                          onAddMemory: () =>
                              _addMemory(context, ref, today, entries),
                          onOpenDay: () => context.pushNamed(
                            AppRoute.journalDay.name,
                            pathParameters: {'date': dateKey},
                          ),
                          onOpenEntry: (entry) => context.pushNamed(
                            AppRoute.journalEntry.name,
                            pathParameters: {
                              'date': dateKey,
                              'entryId': entry.id,
                            },
                          ),
                        ),
                        SizedBox(height: space.cardToSection),
                        _TodayRemindersSection(
                          reminders: reminders,
                          onOpen: () => context.push(AppRoute.reminders.path),
                        ),
                        if (birthdaysToday.isNotEmpty) ...[
                          SizedBox(height: space.sectionGap),
                          _BirthdayTodaySection(entries: birthdaysToday),
                        ],
                        SizedBox(height: space.sectionGap),
                        _ComingUpSection(
                          entries: upcoming,
                          loading: peopleLoading,
                          onSeeAll: () => context.goNamed(AppRoute.kin.name),
                          onAdd: () => showAddPersonFlow(context, ref),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });
    });
  }

  Future<void> _addMemory(
    BuildContext context,
    WidgetRef ref,
    LocalCalendarDate date,
    List<JournalEntry> entries,
  ) async {
    final created = await openJournalMemoryEditorFlow(
      context: context,
      date: date,
      position: entries.length,
    );
    if (created == null || !context.mounted) return;
    await context.pushNamed(
      AppRoute.journalEntry.name,
      pathParameters: {
        'date': date.storageKey,
        'entryId': created.id,
      },
    );
  }
}

/// Date + weekday under the parchment top strip.
class _DateStamp extends StatelessWidget {
  const _DateStamp({required this.today});

  final LocalCalendarDate today;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final weekday =
        TodayScreen._weekdays[DateTime(
              today.year,
              today.month,
              today.day,
            ).weekday -
            1];

    final stamp = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${today.day} ${TodayScreen._months[today.month - 1]} ${today.year}',
          style: q.inked(q.text.uiDate, tone: QuietInkTone.secondary),
        ),
        SizedBox(height: q.space.hair),
        Text(
          weekday,
          style: q.inked(q.text.uiCaption, tone: QuietInkTone.tertiary),
        ),
      ],
    );
    if (context.appTheme.art == null) return stamp;
    return Row(
      children: [
        Expanded(child: stamp),
        const SizedBox(width: 8),
        const QAmbientScene(width: 130),
      ],
    );
  }
}

class _TodayJournalSection extends StatelessWidget {
  const _TodayJournalSection({
    required this.today,
    required this.entries,
    required this.onAddMemory,
    required this.onOpenDay,
    required this.onOpenEntry,
  });

  final LocalCalendarDate today;
  final List<JournalEntry> entries;
  final VoidCallback onAddMemory;
  final VoidCallback onOpenDay;
  final ValueChanged<JournalEntry> onOpenEntry;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final space = q.space;
    final preview = entries
        .take(TodayScreen._journalPreviewLimit)
        .toList(growable: false);
    final hasEntries = preview.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QPressable(
          onTap: onOpenDay,
          radius: q.radius.sm,
          semanticLabel: "Open today's journal",
          child: Text(
            "Today's journal",
            textScaler: context.nameTextScaler,
            style: q.inked(q.text.sectionTitle),
          ),
        ),
        SizedBox(height: space.sectionLead),
        if (!hasEntries && context.appTheme.art != null)
          QIllustratedJournalInvite(
            dateLabel: '${today.day} ${TodayScreen._months[today.month - 1]}',
            onAdd: onAddMemory,
          )
        else if (!hasEntries)
          QTodayEmptyJournalInvite(
            child: QJournalCardSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${today.day}',
                    textScaler: context.nameTextScaler,
                    style: q.inked(
                      q.text.editorialBody,
                      surface: QuietSurfaceKind.paper,
                    ),
                  ),
                  Text(
                    TodayScreen._months[today.month - 1],
                    style: q.inked(
                      q.text.decorativeLabel,
                      surface: QuietSurfaceKind.paper,
                      tone: QuietInkTone.secondary,
                    ),
                  ),
                  SizedBox(height: space.md),
                  Text(
                    'Nothing written yet.',
                    style: q.inked(
                      q.text.journalPrompt,
                      surface: QuietSurfaceKind.paper,
                    ),
                  ),
                  SizedBox(height: space.xs),
                  Text(
                    'What do you want to remember?',
                    style: q.inked(
                      q.text.journalWriting,
                      surface: QuietSurfaceKind.paper,
                      tone: QuietInkTone.secondary,
                    ),
                  ),
                  SizedBox(height: space.base),
                  QButton.primary(
                    label: 'Add memory',
                    onPressed: onAddMemory,
                  ),
                ],
              ),
            ),
          )
        else
          QMoodDecoratedPaper(
            moodId: preview.first.mood?.storageValue,
            secondMoodId: preview.length > 1
                ? preview[1].mood?.storageValue
                : null,
            placement: MoodCardPlacement.todayFirstOverlap,
            child: QJournalCardSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${today.day} ${TodayScreen._months[today.month - 1]}',
                    style: q.inked(
                      q.text.decorativeLabel,
                      surface: QuietSurfaceKind.paper,
                      tone: QuietInkTone.secondary,
                    ),
                  ),
                  SizedBox(height: space.sm),
                  for (final (index, entry) in preview.indexed) ...[
                    if (index > 0) SizedBox(height: space.listItem),
                    _MemoryPreviewLine(
                      entry: entry,
                      onTap: () => onOpenEntry(entry),
                    ),
                  ],
                  SizedBox(height: space.sm),
                  QButton.tertiary(
                    label: "Open today's journal",
                    onPressed: onOpenDay,
                  ),
                  SizedBox(height: space.xs),
                  QButton.primary(
                    label: 'Add memory',
                    onPressed: onAddMemory,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _MemoryPreviewLine extends StatelessWidget {
  const _MemoryPreviewLine({
    required this.entry,
    required this.onTap,
  });

  final JournalEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final body = entry.body.trim();

    return QPressable(
      onTap: onTap,
      radius: q.radius.sm,
      semanticLabel: entry.title,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: q.space.hair),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: q.inked(
                q.text.memoryTitle,
                surface: QuietSurfaceKind.paper,
              ),
            ),
            if (body.isNotEmpty) ...[
              SizedBox(height: q.space.hair),
              Text(
                body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: q.inked(
                  q.text.journalWriting,
                  surface: QuietSurfaceKind.paper,
                  tone: QuietInkTone.secondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TodayRemindersSection extends StatelessWidget {
  const _TodayRemindersSection({
    required this.reminders,
    required this.onOpen,
  });

  final List<PersonalReminder> reminders;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final space = q.space;
    final preview = reminders
        .take(TodayScreen._reminderPreviewLimit)
        .toList(growable: false);
    final hasMore = reminders.length > preview.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QPressable(
          onTap: onOpen,
          radius: q.radius.sm,
          semanticLabel: 'Reminders',
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Reminders',
                  textScaler: context.nameTextScaler,
                  style: q.inked(q.text.sectionTitle),
                ),
              ),
              QGlyphIcon(
                QuietGlyph.bell,
                color: q.color.textTertiary,
                size: context.structuralTextScaler.scale(18),
              ),
            ],
          ),
        ),
        SizedBox(height: space.sectionLead),
        if (preview.isEmpty)
          QPressable(
            onTap: onOpen,
            radius: q.radius.sm,
            semanticLabel: 'View all reminders',
            child: Text(
              'Nothing planned yet.',
              style: q.inked(
                q.text.emptyStateBody,
                tone: QuietInkTone.secondary,
              ),
            ),
          )
        else ...[
          for (final (index, reminder) in preview.indexed) ...[
            if (index > 0) SizedBox(height: space.listItem),
            QPressable(
              onTap: onOpen,
              radius: q.radius.sm,
              semanticLabel: reminder.text,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: space.hair),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: context.structuralTextScaler.scale(72),
                      child: Text(
                        reminder.localTime.displayLabel,
                        style: q.inked(
                          q.text.uiTimestamp,
                          tone: QuietInkTone.tertiary,
                        ),
                      ),
                    ),
                    SizedBox(width: space.md),
                    Expanded(
                      child: Text(
                        reminder.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: q.inked(q.text.uiBody),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          SizedBox(height: space.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: QButton.tertiary(
              label: hasMore ? 'View all reminders' : 'Open reminders',
              onPressed: onOpen,
            ),
          ),
        ],
      ],
    );
  }
}

class _BirthdayTodaySection extends StatelessWidget {
  const _BirthdayTodaySection({required this.entries});

  final List<HomeEntry> entries;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final space = q.space;
    final indent = personRowHairlineIndent(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Birthday today',
          textScaler: context.nameTextScaler,
          style: q.inked(q.text.sectionTitle),
        ),
        SizedBox(height: space.sectionLead),
        for (var index = 0; index < entries.length; index++) ...[
          _TodayPersonRow(
            entry: entries[index],
            heroPrefix: 'today-bday',
          ),
          if (index < entries.length - 1)
            if (personRowUsesPaperStrip(context))
              SizedBox(height: space.sm)
            else
              QHairline(indent: indent),
        ],
      ],
    );
  }
}

class _ComingUpSection extends StatelessWidget {
  const _ComingUpSection({
    required this.entries,
    required this.loading,
    required this.onSeeAll,
    required this.onAdd,
  });

  final List<HomeEntry> entries;
  final bool loading;
  final VoidCallback onSeeAll;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final space = q.space;
    final indent = personRowHairlineIndent(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Coming up',
          textScaler: context.nameTextScaler,
          style: q.inked(q.text.sectionTitle),
        ),
        SizedBox(height: space.sectionLead),
        if (loading)
          Padding(
            padding: EdgeInsets.symmetric(vertical: space.md),
            child: Center(
              child: SizedBox.square(
                dimension: 16,
                child: QArc(color: q.color.textTertiary),
              ),
            ),
          )
        else if (entries.isEmpty) ...[
          Text(
            'No birthdays coming up soon.',
            style: q.inked(q.text.emptyStateBody, tone: QuietInkTone.secondary),
          ),
          SizedBox(height: space.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: QButton.tertiary(
              label: 'Add someone',
              onPressed: onAdd,
            ),
          ),
        ] else ...[
          for (var index = 0; index < entries.length; index++) ...[
            _TodayPersonRow(
              entry: entries[index],
              heroPrefix: 'today-up',
            ),
            if (index < entries.length - 1)
              if (personRowUsesPaperStrip(context))
                SizedBox(height: space.sm)
              else
                QHairline(indent: indent),
          ],
          SizedBox(height: space.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: QButton.tertiary(
              label: 'See all birthdays',
              onPressed: onSeeAll,
            ),
          ),
        ],
      ],
    );
  }
}

class _TodayPersonRow extends ConsumerWidget {
  const _TodayPersonRow({
    required this.entry,
    required this.heroPrefix,
  });

  final HomeEntry entry;
  final String heroPrefix;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = ref.watch(personPhotoProvider(entry.profile?.photoId));

    return QPersonRow(
      displayName: entry.person.displayName,
      seed: entry.person.id,
      daysUntil: entry.daysUntil,
      turningAge: entry.turningAge,
      nextBirthdayLine: entry.nextBirthdayLine,
      countdownText: entry.countdownText,
      photo: photo.asData?.value,
      heroTag: '$heroPrefix-${entry.person.id}',
      onTap: () => context.pushNamed(
        AppRoute.person.name,
        pathParameters: {'id': entry.person.id},
      ),
    );
  }
}
