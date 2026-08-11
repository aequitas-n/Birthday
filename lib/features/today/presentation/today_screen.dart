import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/app/journal_memory_launcher.dart';
import 'package:kin/app/person_editor_launcher.dart';
import 'package:kin/app/router.dart';
import 'package:kin/design/components/buttons/q_button.dart';
import 'package:kin/design/components/buttons/q_icon_button.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/rows/q_person_row.dart';
import 'package:kin/design/components/surfaces/q_hairline.dart';
import 'package:kin/design/components/surfaces/q_screen.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/domain/models/journal_entry.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/features/home/application/home_providers.dart';
import 'package:kin/features/journal/application/journal_providers.dart';
import 'package:kin/features/person/application/person_detail_providers.dart';
import 'package:kin/features/today/application/today_providers.dart';

/// Universal front door — what matters today across Journal and Kin.
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = context.quiet;
    final j = q.journal;
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

    return QScreen(
      canvasColor: j.desk,
      child: QMeasure(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.gutter,
                q.space.base,
                context.gutter,
                0,
              ),
              child: _Masthead(
                onSettings: () => context.push('/settings'),
                onAddPerson: () => showAddPersonFlow(context, ref),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  context.gutter,
                  q.space.xl,
                  context.gutter,
                  q.space.emptiness,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DateIdentity(today: today),
                    SizedBox(height: q.space.xl),
                    const QHairline(),
                    SizedBox(height: q.space.xl),
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
                    if (birthdaysToday.isNotEmpty) ...[
                      SizedBox(height: q.space.xxl),
                      const QHairline(),
                      SizedBox(height: q.space.xl),
                      _BirthdayTodaySection(entries: birthdaysToday),
                    ],
                    SizedBox(height: q.space.xxl),
                    const QHairline(),
                    SizedBox(height: q.space.xl),
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

class _Masthead extends StatelessWidget {
  const _Masthead({
    required this.onSettings,
    required this.onAddPerson,
  });

  final VoidCallback onSettings;
  final VoidCallback onAddPerson;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final j = q.journal;

    return Row(
      children: [
        Expanded(
          child: ExcludeSemantics(
            child: Text(
              'Kin',
              textScaler: context.nameTextScaler,
              style: q.text.voiceLg.tinted(j.ink),
            ),
          ),
        ),
        QIconButton(
          glyph: QuietGlyph.plus,
          onPressed: onAddPerson,
          semanticLabel: 'Add someone',
        ),
        QIconButton(
          glyph: QuietGlyph.settings,
          onPressed: onSettings,
          semanticLabel: 'Settings',
        ),
      ],
    );
  }
}

class _DateIdentity extends StatelessWidget {
  const _DateIdentity({required this.today});

  final LocalCalendarDate today;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final j = q.journal;
    final weekday =
        TodayScreen._weekdays[DateTime(
              today.year,
              today.month,
              today.day,
            ).weekday -
            1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today',
          textScaler: context.nameTextScaler,
          style: q.text.sectionTitle.tinted(j.ink),
        ),
        SizedBox(height: q.space.xs),
        Text(
          '${today.day} ${TodayScreen._months[today.month - 1]} ${today.year}',
          style: q.text.archiveMeta.tinted(j.inkMuted),
        ),
        SizedBox(height: q.space.hair),
        Text(
          weekday,
          style: q.text.archiveCaption.tinted(j.inkMuted),
        ),
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
    final j = q.journal;
    final preview = entries.take(3).toList(growable: false);
    final hasEntries = preview.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                "Today's journal",
                textScaler: context.nameTextScaler,
                style: q.text.sectionTitle.tinted(j.ink),
              ),
            ),
            if (hasEntries)
              QButton.tertiary(
                label: 'View day',
                onPressed: onOpenDay,
              ),
          ],
        ),
        SizedBox(height: q.space.md),
        if (!hasEntries) ...[
          Text(
            '${today.day}',
            textScaler: context.nameTextScaler,
            style: q.text.voiceXl.tinted(j.ink),
          ),
          Text(
            TodayScreen._months[today.month - 1],
            style: q.text.archiveMeta.tinted(j.inkMuted),
          ),
          SizedBox(height: q.space.lg),
          Text(
            'Nothing written yet.',
            style: q.text.voiceMd.tinted(j.ink),
          ),
          SizedBox(height: q.space.sm),
          Text(
            'What do you want to remember?',
            style: q.text.archiveBody.tinted(j.inkMuted),
          ),
          SizedBox(height: q.space.xl),
          Align(
            alignment: Alignment.centerLeft,
            child: QButton.primary(
              label: 'Add memory',
              onPressed: onAddMemory,
            ),
          ),
        ] else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${today.day}',
                    textScaler: context.nameTextScaler,
                    style: q.text.voiceXl.tinted(j.ink),
                  ),
                  Text(
                    TodayScreen._months[today.month - 1],
                    style: q.text.archiveMeta.tinted(j.inkMuted),
                  ),
                ],
              ),
              SizedBox(width: q.space.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (index, entry) in preview.indexed) ...[
                      if (index > 0) SizedBox(height: q.space.md),
                      _MemoryPreviewLine(
                        entry: entry,
                        onTap: () => onOpenEntry(entry),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: q.space.xl),
          Align(
            alignment: Alignment.centerLeft,
            child: QButton.primary(
              label: 'Add memory',
              onPressed: onAddMemory,
            ),
          ),
        ],
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
    final j = q.journal;

    return QPressable(
      onTap: onTap,
      radius: q.radius.sm,
      semanticLabel: entry.title,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: q.space.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: q.text.archiveTitle.tinted(j.ink),
            ),
            if (entry.body.trim().isNotEmpty) ...[
              SizedBox(height: q.space.hair),
              Text(
                entry.body.trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: q.text.archiveBody.tinted(j.inkMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BirthdayTodaySection extends StatelessWidget {
  const _BirthdayTodaySection({required this.entries});

  final List<HomeEntry> entries;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final j = q.journal;
    final indent = personRowHairlineIndent(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Birthday today',
          textScaler: context.nameTextScaler,
          style: q.text.sectionTitle.tinted(j.ink),
        ),
        SizedBox(height: q.space.md),
        for (var index = 0; index < entries.length; index++) ...[
          _TodayPersonRow(
            entry: entries[index],
            heroPrefix: 'today-bday',
          ),
          if (index < entries.length - 1) QHairline(indent: indent),
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
    final j = q.journal;
    final indent = personRowHairlineIndent(context);

    // When birthday-today already highlighted above, still show the same
    // people in Coming up only if they are the only upcoming — preview stays
    // honest about who is next without inventing a second list.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Coming up',
          textScaler: context.nameTextScaler,
          style: q.text.sectionTitle.tinted(j.ink),
        ),
        SizedBox(height: q.space.md),
        if (loading)
          const SizedBox.shrink()
        else if (entries.isEmpty) ...[
          Text(
            'No birthdays coming up.',
            style: q.text.voiceSm.tinted(j.ink),
          ),
          SizedBox(height: q.space.sm),
          Text(
            'Add someone you would hate to forget.',
            style: q.text.archiveBody.tinted(j.inkMuted),
          ),
          SizedBox(height: q.space.xl),
          Align(
            alignment: Alignment.centerLeft,
            child: QButton.primary(
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
            if (index < entries.length - 1) QHairline(indent: indent),
          ],
          SizedBox(height: q.space.xl),
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
