import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/domain/models/journal_entry.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/features/home/application/home_providers.dart';
import 'package:kin/features/journal/application/journal_providers.dart';
import 'package:kin/features/today/application/today_providers.dart';
import 'package:kin/features/today/presentation/today_screen.dart';

import '../../support/quiet_test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const today = LocalCalendarDate(year: 2026, month: 8, day: 11);
  const clock = _FixedClock();

  testWidgets('Today empty journal invites writing', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpQuiet(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(clock),
          journalTodayProvider.overrideWithValue(today),
          journalEntriesProvider.overrideWith(
            (ref, key) => Stream.value(const []),
          ),
          todayUpcomingProvider.overrideWithValue(const []),
          todayBirthdayProvider.overrideWithValue(const []),
          peopleStreamProvider.overrideWith((ref) => Stream.value(const [])),
          profilesStreamProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: const TodayScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nothing written yet.'), findsOneWidget);
    expect(find.text('What do you want to remember?'), findsOneWidget);
    expect(find.text('Add memory'), findsOneWidget);
    expect(find.text('No birthdays coming up.'), findsOneWidget);
    expect(find.text('Add someone'), findsWidgets);
  });

  testWidgets('Today shows journal previews and upcoming birthdays', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final people = [
      Person(
        id: 'p1',
        displayName: 'Kavin',
        birthday: const PartialDate(month: 3, day: 8),
        sortKey: 'kavin',
        location: const LocationModel(label: 'Chennai'),
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
      Person(
        id: 'p2',
        displayName: 'Shivani',
        birthday: const PartialDate(month: 7, day: 7),
        sortKey: 'shivani',
        location: const LocationModel(label: 'Chennai'),
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    ];

    final upcoming = [
      HomeEntry(
        person: people[0],
        nextBirthday: DateTime(2027, 3, 8),
        daysUntil: 209,
        turningAge: null,
      ),
      HomeEntry(
        person: people[1],
        nextBirthday: DateTime(2027, 7, 7),
        daysUntil: 330,
        turningAge: null,
      ),
    ];

    await tester.pumpQuiet(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(clock),
          journalTodayProvider.overrideWithValue(today),
          journalEntriesProvider.overrideWith(
            (ref, key) => Stream.value([
              JournalEntry(
                id: 'e1',
                localDate: today,
                title: 'The rain came just before dinner',
                body: 'Walked home without an umbrella.',
                position: 0,
                createdAt: DateTime.utc(2026, 8, 11),
                updatedAt: DateTime.utc(2026, 8, 11),
              ),
              JournalEntry(
                id: 'e2',
                localDate: today,
                title: 'A conversation I was not expecting',
                body: '',
                position: 1,
                createdAt: DateTime.utc(2026, 8, 11, 18),
                updatedAt: DateTime.utc(2026, 8, 11, 18),
              ),
            ]),
          ),
          todayUpcomingProvider.overrideWithValue(upcoming),
          todayBirthdayProvider.overrideWithValue(const []),
          peopleStreamProvider.overrideWith((ref) => Stream.value(people)),
          profilesStreamProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: const TodayScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('The rain came just before dinner'), findsOneWidget);
    expect(find.text('A conversation I was not expecting'), findsOneWidget);
    expect(find.text('View day'), findsOneWidget);
    expect(find.text('Kavin'), findsOneWidget);
    expect(find.text('Shivani'), findsOneWidget);
    expect(find.text('See all birthdays'), findsOneWidget);
  });

  testWidgets('Today prioritizes a birthday on the day', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final person = Person(
      id: 'p1',
      displayName: 'Kavin',
      birthday: const PartialDate(month: 8, day: 11, year: 1998),
      sortKey: 'kavin',
      location: const LocationModel(label: 'Chennai'),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    final entry = HomeEntry(
      person: person,
      nextBirthday: DateTime(2026, 8, 11),
      daysUntil: 0,
      turningAge: 28,
    );

    await tester.pumpQuiet(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(clock),
          journalTodayProvider.overrideWithValue(today),
          journalEntriesProvider.overrideWith(
            (ref, key) => Stream.value(const []),
          ),
          todayBirthdayProvider.overrideWithValue([entry]),
          todayUpcomingProvider.overrideWithValue([entry]),
          peopleStreamProvider.overrideWith((ref) => Stream.value([person])),
          profilesStreamProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: const TodayScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Birthday today'), findsOneWidget);
    expect(find.text('Kavin'), findsWidgets);
  });
}

class _FixedClock extends Clock {
  const _FixedClock();

  @override
  DateTime now() => DateTime.utc(2026, 8, 11, 12);
}
