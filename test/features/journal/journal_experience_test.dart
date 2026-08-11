import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/design/components/journal/q_journal_fragment.dart';
import 'package:kin/design/components/journal/q_journal_mood_picker.dart';
import 'package:kin/design/components/surfaces/q_screen.dart';
import 'package:kin/domain/models/journal_day.dart';
import 'package:kin/domain/models/journal_entry.dart';
import 'package:kin/domain/models/journal_mood.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/domain/repositories/journal_repository.dart';
import 'package:kin/features/journal/application/journal_providers.dart';
import 'package:kin/features/journal/presentation/journal_day_screen.dart';
import 'package:kin/features/journal/presentation/journal_home_screen.dart';
import 'package:kin/features/journal/presentation/journal_month_calendar.dart';

import '../../support/quiet_test_app.dart';

void main() {
  setUpAll(loadQuietFonts);

  testWidgets('month calendar marks mood and memories', (tester) async {
    const today = LocalCalendarDate(year: 2026, month: 10, day: 15);
    await tester.pumpQuiet(
      JournalMonthCalendar(
        year: 2026,
        month: 10,
        today: today,
        markers: const [
          JournalDayMarker(
            localDate: LocalCalendarDate(year: 2026, month: 10, day: 3),
            entryCount: 2,
            hasEntries: true,
            dayMood: JournalMood.calm,
          ),
          JournalDayMarker(
            localDate: LocalCalendarDate(year: 2026, month: 10, day: 10),
            entryCount: 1,
            hasEntries: true,
          ),
        ],
        onDaySelected: (_) {},
      ),
      surfaceSize: const Size(390, 520),
    );

    expect(find.text('3'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
  });

  testWidgets('empty journal day shows invitation to write', (tester) async {
    await tester.pumpQuiet(
      ProviderScope(
        overrides: [
          journalDayProvider.overrideWith(
            (ref, key) => Stream.value(null),
          ),
          journalEntriesProvider.overrideWith(
            (ref, key) => Stream.value(const []),
          ),
          clockProvider.overrideWithValue(const _FixedClock()),
        ],
        child: const QScreen(
          child: JournalDayScreen(dateKey: '2026-10-24'),
        ),
      ),
    );

    expect(find.text('Nothing written here yet.'), findsOneWidget);
    expect(find.text('Add memory'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
  });

  testWidgets('day with memories renders archival fragments', (tester) async {
    const date = LocalCalendarDate(year: 2026, month: 10, day: 24);
    final entries = [
      JournalEntry(
        id: 'e1',
        localDate: date,
        title: 'Found an old letter',
        body: 'In the desk drawer.',
        mood: JournalMood.nostalgic,
        position: 0,
        createdAt: DateTime.utc(2026, 10, 24),
        updatedAt: DateTime.utc(2026, 10, 24),
      ),
      JournalEntry(
        id: 'e2',
        localDate: date,
        title: 'Walked through the rain',
        body: 'Quiet streets.',
        position: 1,
        createdAt: DateTime.utc(2026, 10, 24, 18),
        updatedAt: DateTime.utc(2026, 10, 24, 18),
      ),
    ];

    await tester.pumpQuiet(
      ProviderScope(
        overrides: [
          journalDayProvider.overrideWith(
            (ref, key) => Stream.value(
              JournalDay(
                localDate: date,
                mood: JournalMood.reflective,
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
        child: const QScreen(
          child: JournalDayScreen(dateKey: '2026-10-24'),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Found an old letter'), findsOneWidget);
    expect(find.text('Walked through the rain'), findsOneWidget);
    expect(find.byType(QJournalFragment), findsNWidgets(2));
    expect(find.text('Reflective'), findsOneWidget);
  });

  testWidgets('mood picker communicates label and selection', (tester) async {
    String? selected;
    await tester.pumpQuiet(
      StatefulBuilder(
        builder: (context, setState) {
          return QJournalMoodPicker(
            selectedId: selected,
            options: const [
              ('calm', 'Calm'),
              ('joyful', 'Joyful'),
            ],
            onSelected: (id) => setState(() => selected = id),
          );
        },
      ),
      surfaceSize: const Size(390, 200),
    );

    await tester.tap(find.text('Calm'));
    await tester.pump();
    expect(selected, 'calm');
  });

  testWidgets('journal home shows month title', (tester) async {
    await tester.pumpQuiet(
      ProviderScope(
        overrides: [
          journalTodayProvider.overrideWithValue(
            const LocalCalendarDate(year: 2026, month: 8, day: 11),
          ),
          journalMonthMarkersProvider.overrideWith(
            (ref, key) => Stream.value(const []),
          ),
        ],
        child: const JournalHomeScreen(),
      ),
    );

    expect(find.text('Journal'), findsOneWidget);
    expect(find.text('AUGUST 2026'), findsOneWidget);
    expect(find.textContaining('days'), findsOneWidget);
  });
}

class _FixedClock extends Clock {
  const _FixedClock();

  @override
  DateTime now() => DateTime.utc(2026, 10, 24, 12);
}
