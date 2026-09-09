import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/design/components/journal/q_today_empty_journal_invite.dart';
import 'package:kin/design/theme/material_shim.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/domain/models/journal_entry.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/domain/models/local_clock_time.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/domain/models/personal_reminder.dart';
import 'package:kin/domain/models/reminder_day_part.dart';
import 'package:kin/domain/models/settings.dart';
import 'package:kin/domain/services/personal_reminder_temporal.dart';
import 'package:kin/features/home/application/home_providers.dart';
import 'package:kin/features/journal/application/journal_providers.dart';
import 'package:kin/features/reminders/application/reminder_providers.dart';
import 'package:kin/features/today/application/today_providers.dart';
import 'package:kin/features/today/presentation/today_screen.dart';
import 'package:riverpod/misc.dart' show Override;
import 'package:timezone/data/latest_all.dart' as tzdata;

import '../../support/quiet_test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    loadQuietFonts();
    tzdata.initializeTimeZones();
  });

  const today = LocalCalendarDate(year: 2026, month: 8, day: 11);
  const clock = _FixedClock();
  const reminderSettings = AppSettings(reminderTimezone: 'Asia/Kolkata');

  List<Override> baseOverrides({
    List<JournalEntry> entries = const [],
    List<PersonalReminder> reminders = const [],
    List<HomeEntry> upcoming = const [],
    List<HomeEntry> birthdaysToday = const [],
    List<Person> people = const [],
  }) {
    return [
      clockProvider.overrideWithValue(clock),
      journalTodayProvider.overrideWithValue(today),
      reminderTodayProvider.overrideWithValue(today),
      initialAppSettingsProvider.overrideWithValue(reminderSettings),
      appSettingsProvider.overrideWith((ref) => Stream.value(reminderSettings)),
      remindersForDateProvider.overrideWith(
        (ref, key) => Stream.value(reminders),
      ),
      todayActiveRemindersProvider.overrideWith((ref) {
        return filterActivePersonalReminders(
          reminders: reminders,
          nowUtc: ref.watch(clockProvider).now(),
          reminderTimeZone: watchReminderIanaSync(ref),
        );
      }),
      journalEntriesProvider.overrideWith(
        (ref, key) => Stream.value(entries),
      ),
      todayUpcomingProvider.overrideWithValue(upcoming),
      todayBirthdayProvider.overrideWithValue(birthdaysToday),
      peopleStreamProvider.overrideWith((ref) => Stream.value(people)),
      profilesStreamProvider.overrideWith((ref) => Stream.value(const [])),
    ];
  }

  Future<void> pumpToday(
    WidgetTester tester, {
    required List<Override> overrides,
    Size size = const Size(390, 844),
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildMaterialShim(const QuietTheme.light()),
          home: Builder(
            builder: (context) => ColoredBox(
              color: context.quiet.color.canvas,
              child: DefaultTextStyle(
                style: context.quiet.text.body.tinted(
                  context.quiet.color.textPrimary,
                ),
                child: const TodayScreen(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Today empty journal invites writing', (tester) async {
    await pumpToday(tester, overrides: baseOverrides());

    expect(find.text('Today'), findsWidgets);
    expect(find.text('11 August 2026'), findsOneWidget);
    expect(find.text('Tuesday'), findsOneWidget);
    expect(find.text('Nothing written yet.'), findsOneWidget);
    expect(find.text('What do you want to remember?'), findsOneWidget);
    expect(find.text('Add memory'), findsOneWidget);
    expect(find.text('Nothing planned yet.'), findsOneWidget);
    expect(find.text('No birthdays coming up soon.'), findsOneWidget);
    expect(find.text('Add someone'), findsWidgets);
    expect(find.byType(QTodayEmptyJournalInvite), findsOneWidget);
  });

  testWidgets('Today populated journal hides empty-state invite art', (
    tester,
  ) async {
    final entries = [
      JournalEntry(
        id: 'e1',
        localDate: today,
        title: 'Morning light',
        body: 'Quiet start.',
        position: 0,
        createdAt: DateTime.utc(2026, 8, 11),
        updatedAt: DateTime.utc(2026, 8, 11),
      ),
    ];
    await pumpToday(
      tester,
      overrides: baseOverrides(entries: entries),
    );

    expect(find.text('Morning light'), findsOneWidget);
    expect(find.text('Nothing written yet.'), findsNothing);
    expect(find.byType(QTodayEmptyJournalInvite), findsNothing);
  });

  testWidgets('Today shows journal previews and upcoming birthdays', (
    tester,
  ) async {
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

    await pumpToday(
      tester,
      size: const Size(390, 1200),
      overrides: baseOverrides(
        people: people,
        upcoming: upcoming,
        entries: [
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
        ],
      ),
    );

    expect(find.text('The rain came just before dinner'), findsOneWidget);
    expect(find.text('A conversation I was not expecting'), findsOneWidget);
    expect(find.text("Open today's journal"), findsOneWidget);
    expect(find.text('Kavin'), findsOneWidget);
    expect(find.text('Shivani'), findsOneWidget);
    expect(find.text('See all birthdays'), findsOneWidget);
  });

  testWidgets('Today shows only active reminder preview sorted by time', (
    tester,
  ) async {
    final reminders = [
      PersonalReminder(
        id: 'r2',
        text: 'Did you wake up?',
        localDate: today,
        localTime: const LocalClockTime(hour: 7, minute: 0),
        dayPart: ReminderDayPart.morning,
        timezone: 'Asia/Kolkata',
        position: 1,
        createdAt: DateTime.utc(2026, 8, 11),
        updatedAt: DateTime.utc(2026, 8, 11),
      ),
      PersonalReminder(
        id: 'r1',
        text: 'Go and sleep dude',
        localDate: today,
        localTime: const LocalClockTime(hour: 4, minute: 10),
        dayPart: ReminderDayPart.evening,
        timezone: 'Asia/Kolkata',
        position: 0,
        createdAt: DateTime.utc(2026, 8, 11),
        updatedAt: DateTime.utc(2026, 8, 11),
      ),
      PersonalReminder(
        id: 'r3',
        text: 'Finish project',
        localDate: today,
        localTime: const LocalClockTime(hour: 15, minute: 0),
        dayPart: ReminderDayPart.afternoon,
        timezone: 'Asia/Kolkata',
        position: 2,
        createdAt: DateTime.utc(2026, 8, 11),
        updatedAt: DateTime.utc(2026, 8, 11),
      ),
      PersonalReminder(
        id: 'r4',
        text: 'Watch movie',
        localDate: today,
        localTime: const LocalClockTime(hour: 20, minute: 0),
        dayPart: ReminderDayPart.evening,
        timezone: 'Asia/Kolkata',
        position: 3,
        createdAt: DateTime.utc(2026, 8, 11),
        updatedAt: DateTime.utc(2026, 8, 11),
      ),
    ];

    await pumpToday(
      tester,
      overrides: baseOverrides(reminders: reminders),
    );

    expect(find.text('Go and sleep dude'), findsNothing);
    expect(find.text('Did you wake up?'), findsNothing);
    expect(find.text('Finish project'), findsNothing);
    expect(find.text('Watch movie'), findsOneWidget);
    expect(find.text('View all reminders'), findsNothing);
  });

  testWidgets('Today hides all past reminders without leaving placeholders', (
    tester,
  ) async {
    await pumpToday(
      tester,
      overrides: baseOverrides(
        reminders: [
          PersonalReminder(
            id: 'r1',
            text: 'Did you wake up?',
            localDate: today,
            localTime: const LocalClockTime(hour: 7, minute: 0),
            dayPart: ReminderDayPart.morning,
            timezone: 'Asia/Kolkata',
            position: 0,
            createdAt: DateTime.utc(2026, 8, 11),
            updatedAt: DateTime.utc(2026, 8, 11),
          ),
        ],
      ),
    );

    expect(find.text('Did you wake up?'), findsNothing);
    expect(find.text('Nothing planned yet.'), findsOneWidget);
  });

  testWidgets('Today prioritizes a birthday on the day', (tester) async {
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

    await pumpToday(
      tester,
      size: const Size(390, 1200),
      overrides: baseOverrides(
        people: [person],
        birthdaysToday: [entry],
        upcoming: [entry],
      ),
    );

    expect(find.text('Birthday today'), findsOneWidget);
    expect(find.text('Kavin'), findsWidgets);
  });

  testWidgets('Coming up heading is above the fold on a phone viewport', (
    tester,
  ) async {
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
    ];
    final upcoming = [
      HomeEntry(
        person: people[0],
        nextBirthday: DateTime(2027, 3, 8),
        daysUntil: 209,
        turningAge: null,
      ),
    ];

    await pumpToday(
      tester,
      overrides: baseOverrides(
        people: people,
        upcoming: upcoming,
        reminders: [
          PersonalReminder(
            id: 'r1',
            text: 'Morning note',
            localDate: today,
            localTime: const LocalClockTime(hour: 20, minute: 0),
            dayPart: ReminderDayPart.morning,
            timezone: 'Asia/Kolkata',
            position: 0,
            createdAt: DateTime.utc(2026, 8, 11),
            updatedAt: DateTime.utc(2026, 8, 11),
          ),
        ],
      ),
    );

    final comingUp = tester.getRect(find.text('Coming up'));
    // Visible within the phone viewport (nav chrome lives outside this screen).
    expect(comingUp.top, lessThan(844));
    expect(comingUp.top, greaterThan(0));
  });

  testWidgets('Today navigates to reminders, journal day, and Kin', (
    tester,
  ) async {
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
    ];
    final upcoming = [
      HomeEntry(
        person: people[0],
        nextBirthday: DateTime(2027, 3, 8),
        daysUntil: 209,
        turningAge: null,
      ),
    ];

    await tester.binding.setSurfaceSize(const Size(390, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const TodayScreen(),
        ),
        GoRoute(
          path: '/reminders',
          builder: (context, state) => const Text('Reminders route'),
        ),
        GoRoute(
          path: '/journal/:date',
          name: 'journalDay',
          builder: (context, state) =>
              Text('Journal ${state.pathParameters['date']}'),
        ),
        GoRoute(
          path: '/kin',
          name: 'kin',
          builder: (context, state) => const Text('Kin route'),
        ),
        GoRoute(
          path: '/person/:id',
          name: 'person',
          builder: (context, state) =>
              Text('Person ${state.pathParameters['id']}'),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: baseOverrides(
          people: people,
          upcoming: upcoming,
          entries: [
            JournalEntry(
              id: 'e1',
              localDate: today,
              title: 'Morning light',
              body: '',
              position: 0,
              createdAt: DateTime.utc(2026, 8, 11),
              updatedAt: DateTime.utc(2026, 8, 11),
            ),
          ],
          reminders: [
            PersonalReminder(
              id: 'r1',
              text: 'Call home',
              localDate: today,
              localTime: const LocalClockTime(hour: 20, minute: 0),
              dayPart: ReminderDayPart.morning,
              timezone: 'Asia/Kolkata',
              position: 0,
              createdAt: DateTime.utc(2026, 8, 11),
              updatedAt: DateTime.utc(2026, 8, 11),
            ),
          ],
        ),
        child: MaterialApp.router(
          theme: buildMaterialShim(const QuietTheme.light()),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open reminders'));
    await tester.pumpAndSettle();
    expect(find.text('Reminders route'), findsOneWidget);

    router.go('/');
    await tester.pumpAndSettle();

    await tester.tap(find.text("Open today's journal"));
    await tester.pumpAndSettle();
    expect(find.text('Journal 2026-08-11'), findsOneWidget);

    router.go('/');
    await tester.pumpAndSettle();

    await tester.tap(find.text('See all birthdays'));
    await tester.pumpAndSettle();
    expect(find.text('Kin route'), findsOneWidget);

    router.go('/');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kavin'));
    await tester.pumpAndSettle();
    expect(find.text('Person p1'), findsOneWidget);
  });
}

class _FixedClock extends Clock {
  const _FixedClock();

  @override
  DateTime now() => DateTime.utc(2026, 8, 11, 12);
}
