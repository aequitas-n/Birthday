@Tags(['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/design/components/journal/q_journal_add_fragment_cue.dart';
import 'package:kin/design/components/journal/q_journal_photo_print.dart';
import 'package:kin/design/components/surfaces/q_screen.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/domain/models/journal_day.dart';
import 'package:kin/domain/models/journal_entry.dart';
import 'package:kin/domain/models/journal_fragment.dart';
import 'package:kin/domain/models/journal_mood.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/domain/repositories/journal_repository.dart';
import 'package:kin/features/journal/application/journal_providers.dart';
import 'package:kin/features/journal/presentation/journal_day_screen.dart';
import 'package:kin/features/journal/presentation/journal_entry_screen.dart';
import 'package:kin/features/journal/presentation/journal_home_screen.dart';
import 'package:kin/features/journal/presentation/journal_month_calendar.dart';

import '../../../support/quiet_test_app.dart';

/// Product-surface goldens for Journal Phase 3.
void main() {
  setUpAll(loadQuietFonts);

  final specimens = <String, ({Widget child, Size size})>{
    'month-empty': (
      child: ProviderScope(
        overrides: [
          journalTodayProvider.overrideWithValue(
            const LocalCalendarDate(year: 2026, month: 10, day: 15),
          ),
          journalMonthMarkersProvider.overrideWith(
            (ref, key) => Stream.value(const []),
          ),
        ],
        child: const JournalHomeScreen(),
      ),
      size: const Size(390, 844),
    ),
    'month-mixed-moods': (
      child: const _MonthSpecimen(
        markers: [
          JournalDayMarker(
            localDate: LocalCalendarDate(year: 2026, month: 10, day: 3),
            entryCount: 1,
            hasEntries: true,
            dayMood: JournalMood.joyful,
          ),
          JournalDayMarker(
            localDate: LocalCalendarDate(year: 2026, month: 10, day: 8),
            entryCount: 0,
            dayMood: JournalMood.sad,
          ),
          JournalDayMarker(
            localDate: LocalCalendarDate(year: 2026, month: 10, day: 12),
            entryCount: 2,
            hasEntries: true,
            dayMood: JournalMood.reflective,
          ),
          JournalDayMarker(
            localDate: LocalCalendarDate(year: 2026, month: 10, day: 20),
            entryCount: 3,
            hasEntries: true,
            dayMood: JournalMood.grateful,
          ),
        ],
      ),
      size: const Size(390, 520),
    ),
    'month-many-memories': (
      child: _MonthSpecimen(
        markers: [
          for (var day = 1; day <= 28; day += 2)
            JournalDayMarker(
              localDate: LocalCalendarDate(year: 2026, month: 10, day: day),
              entryCount: (day % 3) + 1,
              hasEntries: true,
              dayMood: JournalMood.values[day % JournalMood.values.length],
            ),
        ],
      ),
      size: const Size(390, 520),
    ),
    'day-empty': (
      child: ProviderScope(
        overrides: [
          journalDayProvider.overrideWith((ref, key) => Stream.value(null)),
          journalEntriesProvider.overrideWith(
            (ref, key) => Stream.value(const []),
          ),
          clockProvider.overrideWithValue(const _FixedClock()),
        ],
        child: const QScreen(child: JournalDayScreen(dateKey: '2026-10-24')),
      ),
      size: const Size(390, 844),
    ),
    'day-one-memory': (
      child: _DaySpecimen(
        entries: [
          JournalEntry(
            id: 'e1',
            localDate: const LocalCalendarDate(year: 2026, month: 10, day: 24),
            title: 'Found an old letter',
            body: 'In the desk drawer, sealed and quiet.',
            mood: JournalMood.nostalgic,
            position: 0,
            createdAt: DateTime.utc(2026, 10, 24),
            updatedAt: DateTime.utc(2026, 10, 24),
          ),
        ],
        mood: JournalMood.nostalgic,
      ),
      size: const Size(390, 844),
    ),
    'day-multiple-fragments': (
      child: _DaySpecimen(
        entries: [
          JournalEntry(
            id: 'e1',
            localDate: const LocalCalendarDate(year: 2026, month: 10, day: 24),
            title: 'Found an old letter',
            body: 'In the desk drawer.',
            mood: JournalMood.nostalgic,
            position: 0,
            createdAt: DateTime.utc(2026, 10, 24),
            updatedAt: DateTime.utc(2026, 10, 24),
          ),
          JournalEntry(
            id: 'e2',
            localDate: const LocalCalendarDate(year: 2026, month: 10, day: 24),
            title: 'Walked through the rain',
            body: 'Quiet streets after midnight.',
            mood: JournalMood.calm,
            position: 1,
            createdAt: DateTime.utc(2026, 10, 24, 18),
            updatedAt: DateTime.utc(2026, 10, 24, 18),
          ),
          JournalEntry(
            id: 'e3',
            localDate: const LocalCalendarDate(year: 2026, month: 10, day: 24),
            title: 'Coffee with someone',
            body: 'We talked about nothing important.',
            position: 2,
            createdAt: DateTime.utc(2026, 10, 24, 20),
            updatedAt: DateTime.utc(2026, 10, 24, 20),
          ),
        ],
        mood: JournalMood.reflective,
      ),
      size: const Size(390, 1100),
    ),
    'day-photo-prints': (
      child: const _PhotoPrintsSpecimen(),
      size: const Size(390, 420),
    ),
    'memory-detail': (
      child: ProviderScope(
        overrides: [
          journalEntryProvider.overrideWith(
            (ref, id) => Stream.value(
              JournalEntry(
                id: 'e1',
                localDate: const LocalCalendarDate(
                  year: 2026,
                  month: 10,
                  day: 24,
                ),
                title: 'A strange evening',
                body:
                    'I was not planning to go anywhere today.\n\n'
                    '• Met Kavin\n• Had dinner',
                mood: JournalMood.nostalgic,
                position: 0,
                createdAt: DateTime.utc(2026, 10, 24),
                updatedAt: DateTime.utc(2026, 10, 24),
              ),
            ),
          ),
          journalEntryFragmentsProvider.overrideWith(
            (ref, id) => Stream.value([
              JournalFragment(
                id: 'f1',
                entryId: 'e1',
                kind: JournalFragmentKind.writing,
                position: 0,
                textBody: 'I was not planning to go anywhere today.',
                createdAt: DateTime.utc(2026, 10, 24),
                updatedAt: DateTime.utc(2026, 10, 24),
              ),
              JournalFragment(
                id: 'f2',
                entryId: 'e1',
                kind: JournalFragmentKind.list,
                position: 1,
                textBody: JournalFragment.encodeListItems(const [
                  'Met Kavin',
                  'Had dinner',
                  'Walked around the temple',
                ]),
                createdAt: DateTime.utc(2026, 10, 24),
                updatedAt: DateTime.utc(2026, 10, 24),
              ),
              JournalFragment(
                id: 'f3',
                entryId: 'e1',
                kind: JournalFragmentKind.writing,
                position: 2,
                textBody: 'The whole evening felt quieter than I expected.',
                createdAt: DateTime.utc(2026, 10, 24),
                updatedAt: DateTime.utc(2026, 10, 24),
              ),
            ]),
          ),
          journalEntryPhotosProvider.overrideWith(
            (ref, id) => Stream.value(const []),
          ),
        ],
        child: const QScreen(
          child: JournalEntryScreen(
            dateKey: '2026-10-24',
            entryId: 'e1',
          ),
        ),
      ),
      size: const Size(390, 844),
    ),
    'add-memory': (
      child: const _AddMemorySpecimen(),
      size: const Size(390, 720),
    ),
  };

  for (final specimen in specimens.entries) {
    group(specimen.key, () {
      for (final theme in quietThemes.entries) {
        testWidgets(theme.key, (tester) async {
          await tester.pumpQuiet(
            specimen.value.child,
            theme: theme.value,
            surfaceSize: specimen.value.size,
          );
          await tester.pump(const Duration(milliseconds: 600));
          await expectLater(
            find.byType(QuietTestApp),
            matchesGoldenFile(
              '_goldens/journal_${specimen.key}.${theme.key}.png',
            ),
          );
        });
      }
    });
  }
}

void _noop() {}

class _AddMemorySpecimen extends StatelessWidget {
  const _AddMemorySpecimen();

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final j = q.journal;
    return QScreen(
      child: Padding(
        padding: EdgeInsets.all(q.space.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'October 24, 2026',
              textAlign: TextAlign.center,
              style: q.text.archiveMeta.tinted(j.inkMuted),
            ),
            SizedBox(height: q.space.lg),
            Text(
              'Untitled',
              style: q.text.voiceLg.tinted(
                j.inkMuted.withValues(alpha: 0.45),
              ),
            ),
            SizedBox(height: q.space.lg),
            Row(
              children: [
                CustomPaint(
                  size: const Size(18, 8),
                  painter: _GoldenMoodStain(color: j.rule),
                ),
                SizedBox(width: q.space.sm),
                Text(
                  'Add mood',
                  style: q.text.archiveMeta.tinted(j.inkMuted),
                ),
              ],
            ),
            SizedBox(height: q.space.xl),
            Text(
              'What do you want to remember?',
              style: q.text.archiveBody.tinted(j.inkMuted),
            ),
            SizedBox(height: q.space.lg),
            const QJournalAddFragmentCue(
              choices: [
                ('Writing', _noop),
                ('List', _noop),
                ('Photograph', _noop),
                ('Audio', _noop),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GoldenMoodStain extends CustomPainter {
  const _GoldenMoodStain({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.35);
    canvas.drawOval(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _GoldenMoodStain oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _PhotoPrintsSpecimen extends StatelessWidget {
  const _PhotoPrintsSpecimen();

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    return QScreen(
      child: Padding(
        padding: EdgeInsets.all(q.space.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QJournalPhotoPrint(
              width: 148,
              rotation: -0.02,
              indexLabel: 'No. 1',
              caption: 'The envelope',
              child: ColoredBox(color: q.journal.paperSunken),
            ),
            SizedBox(width: q.space.md),
            QJournalPhotoPrint(
              width: 148,
              rotation: 0.03,
              indexLabel: 'No. 2',
              child: ColoredBox(color: q.color.sunken),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthSpecimen extends StatelessWidget {
  const _MonthSpecimen({required this.markers});

  final List<JournalDayMarker> markers;

  @override
  Widget build(BuildContext context) {
    return JournalMonthCalendar(
      year: 2026,
      month: 10,
      today: const LocalCalendarDate(year: 2026, month: 10, day: 15),
      markers: markers,
      onDaySelected: (_) {},
    );
  }
}

class _DaySpecimen extends StatelessWidget {
  const _DaySpecimen({required this.entries, this.mood});

  final List<JournalEntry> entries;
  final JournalMood? mood;

  @override
  Widget build(BuildContext context) {
    const date = LocalCalendarDate(year: 2026, month: 10, day: 24);
    return ProviderScope(
      overrides: [
        journalDayProvider.overrideWith(
          (ref, key) => Stream.value(
            JournalDay(
              localDate: date,
              mood: mood,
              createdAt: DateTime.utc(2026, 10, 24),
              updatedAt: DateTime.utc(2026, 10, 24),
            ),
          ),
        ),
        journalEntriesProvider.overrideWith(
          (ref, key) => Stream.value(entries),
        ),
        journalEntryPhotosProvider.overrideWith(
          (ref, id) => Stream.value(const []),
        ),
        clockProvider.overrideWithValue(const _FixedClock()),
      ],
      child: const QScreen(child: JournalDayScreen(dateKey: '2026-10-24')),
    );
  }
}

class _FixedClock extends Clock {
  const _FixedClock();

  @override
  DateTime now() => DateTime.utc(2026, 10, 24, 12);
}
