@Tags(['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/core/clock.dart';
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
import 'package:timezone/data/latest_all.dart' as tzdata;

import '../../../support/quiet_test_app.dart';

/// Product-surface goldens for Universal Home (Phase 4).
void main() {
  setUpAll(() {
    loadQuietFonts();
    tzdata.initializeTimeZones();
  });

  const today = LocalCalendarDate(year: 2026, month: 8, day: 11);
  const clock = _FixedClock();
  const settings = AppSettings(reminderTimezone: 'Asia/Kolkata');
  final now = DateTime(2026, 8, 11);

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
    Person(
      id: 'p3',
      displayName: 'Ganesh',
      birthday: const PartialDate(month: 8, day: 7),
      sortKey: 'ganesh',
      location: const LocationModel(label: 'Chennai'),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
  ];

  final birthdayTodayPeople = [
    Person(
      id: 'p0',
      displayName: 'Kavin',
      birthday: const PartialDate(month: 8, day: 11, year: 1998),
      sortKey: 'kavin',
      location: const LocationModel(label: 'Chennai'),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
    ...people.skip(1),
  ];

  final journalEntries = [
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
      body: 'Quiet streets after midnight.',
      position: 1,
      createdAt: DateTime.utc(2026, 8, 11, 18),
      updatedAt: DateTime.utc(2026, 8, 11, 18),
    ),
  ];

  final specimens = <String, Widget>{
    'empty': _TodaySpecimen(
      people: const [],
      entries: const [],
      now: now,
    ),
    'journal-empty-birthdays': _TodaySpecimen(
      people: people,
      entries: const [],
      now: now,
    ),
    'journal-populated-birthdays': _TodaySpecimen(
      people: people,
      entries: journalEntries,
      now: now,
    ),
    'with-reminders': _TodaySpecimen(
      people: people.take(2).toList(growable: false),
      entries: journalEntries.take(1).toList(growable: false),
      reminders: [
        PersonalReminder(
          id: 'r1',
          text: 'Finish project',
          localDate: today,
          localTime: const LocalClockTime(hour: 20, minute: 0),
          dayPart: ReminderDayPart.evening,
          timezone: 'Asia/Kolkata',
          position: 0,
          createdAt: DateTime.utc(2026, 8, 11),
          updatedAt: DateTime.utc(2026, 8, 11),
        ),
        PersonalReminder(
          id: 'r2',
          text: 'Watch movie',
          localDate: today,
          localTime: const LocalClockTime(hour: 21, minute: 0),
          dayPart: ReminderDayPart.evening,
          timezone: 'Asia/Kolkata',
          position: 1,
          createdAt: DateTime.utc(2026, 8, 11),
          updatedAt: DateTime.utc(2026, 8, 11),
        ),
      ],
      now: now,
    ),
    'birthday-today': _TodaySpecimen(
      people: birthdayTodayPeople,
      entries: const [],
      now: now,
    ),
    'multiple-upcoming': _TodaySpecimen(
      people: people,
      entries: journalEntries,
      now: now,
    ),
  };

  for (final themeEntry in quietThemes.entries) {
    for (final specimen in specimens.entries) {
      testWidgets(
        'today-${specimen.key}-${themeEntry.key}',
        (tester) async {
          await tester.pumpQuiet(
            ProviderScope(
              overrides: [
                clockProvider.overrideWithValue(clock),
                journalTodayProvider.overrideWithValue(today),
                initialAppSettingsProvider.overrideWithValue(settings),
              ],
              child: specimen.value,
            ),
            theme: themeEntry.value,
          );
          await tester.pumpAndSettle();
          await tester.pumpQuietImages();

          await expectLater(
            find.byType(TodayScreen),
            matchesGoldenFile(
              'goldens/today-${specimen.key}-${themeEntry.key}.png',
            ),
          );
        },
      );
    }
  }
}

class _TodaySpecimen extends StatelessWidget {
  const _TodaySpecimen({
    required this.people,
    required this.entries,
    required this.now,
    this.reminders = const [],
  });

  final List<Person> people;
  final List<JournalEntry> entries;
  final List<PersonalReminder> reminders;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final upcoming = _entriesFor(people, now).take(3).toList(growable: false);
    final birthdaysToday = upcoming
        .where((entry) => entry.daysUntil == 0)
        .toList(growable: false);

    return ProviderScope(
      overrides: [
        journalEntriesProvider.overrideWith(
          (ref, key) => Stream.value(entries),
        ),
        remindersForDateProvider.overrideWith(
          (ref, key) => Stream.value(reminders),
        ),
        initialAppSettingsProvider.overrideWithValue(
          const AppSettings(reminderTimezone: 'Asia/Kolkata'),
        ),
        appSettingsProvider.overrideWith(
          (ref) => Stream.value(
            const AppSettings(reminderTimezone: 'Asia/Kolkata'),
          ),
        ),
        todayActiveRemindersProvider.overrideWith((ref) {
          return filterActivePersonalReminders(
            reminders: reminders,
            nowUtc: ref.watch(clockProvider).now(),
            reminderTimeZone: watchReminderIanaSync(ref),
          );
        }),
        peopleStreamProvider.overrideWith((ref) => Stream.value(people)),
        profilesStreamProvider.overrideWith((ref) => Stream.value(const [])),
        todayUpcomingProvider.overrideWithValue(upcoming),
        todayBirthdayProvider.overrideWithValue(birthdaysToday),
      ],
      child: const TodayScreen(),
    );
  }
}

List<HomeEntry> _entriesFor(List<Person> people, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final entries = <HomeEntry>[];
  for (final person in people) {
    final next = _nextOccurrence(person.birthday, today);
    final daysUntil = next.difference(today).inDays;
    entries.add(
      HomeEntry(
        person: person,
        nextBirthday: next,
        daysUntil: daysUntil,
        turningAge: person.birthday.year == null
            ? null
            : (next.year - person.birthday.year!),
      ),
    );
  }
  entries.sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
  return entries;
}

DateTime _nextOccurrence(PartialDate birthday, DateTime today) {
  final thisYear = DateTime(today.year, birthday.month, birthday.day);
  if (!thisYear.isBefore(today)) return thisYear;
  return DateTime(today.year + 1, birthday.month, birthday.day);
}

class _FixedClock extends Clock {
  const _FixedClock();

  @override
  DateTime now() => DateTime.utc(2026, 8, 11, 12);
}
