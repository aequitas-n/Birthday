import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/domain/models/local_clock_time.dart';
import 'package:kin/domain/models/personal_reminder.dart';
import 'package:kin/domain/models/reminder_day_part.dart';
import 'package:kin/domain/models/settings.dart';
import 'package:kin/features/reminders/application/reminder_providers.dart';
import 'package:kin/features/reminders/presentation/reminder_planner_screen.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

import '../../../support/quiet_test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    loadQuietFonts();
    tzdata.initializeTimeZones();
  });

  const today = LocalCalendarDate(year: 2026, month: 1, day: 14);
  const clock = _FixedClock();
  const settings = AppSettings(reminderTimezone: 'Asia/Kolkata');

  Future<void> pumpPlanner(
    WidgetTester tester, {
    required QuietTheme theme,
    required List<PersonalReminder> reminders,
    Size size = const Size(390, 844),
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpQuiet(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(clock),
          initialAppSettingsProvider.overrideWithValue(settings),
          reminderTodayProvider.overrideWithValue(today),
          remindersForDateProvider.overrideWith(
            (ref, key) => Stream.value(reminders),
          ),
        ],
        child: const ReminderPlannerScreen(),
      ),
      theme: theme,
      surfaceSize: size,
    );
    await tester.pumpAndSettle();
    await tester.pumpQuietImages();
  }

  for (final theme in quietThemes.entries) {
    testWidgets(
      'reminder planner empty ${theme.key}',
      (tester) async {
        await pumpPlanner(
          tester,
          theme: theme.value,
          reminders: const [],
        );

        await expectLater(
          find.byType(ReminderPlannerScreen),
          matchesGoldenFile('_goldens/reminder_empty.${theme.key}.png'),
        );
      },
      tags: 'golden',
    );

    testWidgets(
      'reminder planner populated ${theme.key}',
      (tester) async {
        await pumpPlanner(
          tester,
          theme: theme.value,
          reminders: [
            PersonalReminder(
              id: 'r1',
              localDate: today,
              localTime: const LocalClockTime(hour: 8, minute: 0),
              dayPart: ReminderDayPart.morning,
              text: 'Call Mom',
              timezone: 'Asia/Kolkata',
              position: 0,
              createdAt: DateTime.utc(2026),
              updatedAt: DateTime.utc(2026),
            ),
            PersonalReminder(
              id: 'r2',
              localDate: today,
              localTime: const LocalClockTime(hour: 19, minute: 30),
              dayPart: ReminderDayPart.evening,
              text: 'Review notes',
              timezone: 'Asia/Kolkata',
              position: 0,
              createdAt: DateTime.utc(2026),
              updatedAt: DateTime.utc(2026),
            ),
            PersonalReminder(
              id: 'r3',
              localDate: today,
              localTime: const LocalClockTime(hour: 15, minute: 30),
              dayPart: ReminderDayPart.afternoon,
              text: 'Submit the assignment',
              timezone: 'Asia/Kolkata',
              position: 0,
              createdAt: DateTime.utc(2026),
              updatedAt: DateTime.utc(2026),
            ),
          ],
        );

        await expectLater(
          find.byType(ReminderPlannerScreen),
          matchesGoldenFile('_goldens/reminder_populated.${theme.key}.png'),
        );
      },
      tags: 'golden',
    );

    testWidgets(
      'reminder planner completed collapsed ${theme.key}',
      (tester) async {
        await pumpPlanner(
          tester,
          theme: theme.value,
          reminders: [
            PersonalReminder(
              id: 'r1',
              localDate: today,
              localTime: const LocalClockTime(hour: 7, minute: 0),
              dayPart: ReminderDayPart.anytime,
              text: 'Did you wake up?',
              timezone: 'Asia/Kolkata',
              position: 0,
              createdAt: DateTime.utc(2026),
              updatedAt: DateTime.utc(2026),
            ),
            PersonalReminder(
              id: 'r2',
              localDate: today,
              localTime: const LocalClockTime(hour: 20, minute: 0),
              dayPart: ReminderDayPart.evening,
              text: 'Watch a movie',
              timezone: 'Asia/Kolkata',
              position: 1,
              createdAt: DateTime.utc(2026),
              updatedAt: DateTime.utc(2026),
            ),
          ],
        );

        await expectLater(
          find.byType(ReminderPlannerScreen),
          matchesGoldenFile(
            '_goldens/reminder_completed_collapsed.${theme.key}.png',
          ),
        );
      },
      tags: 'golden',
    );
  }
}

class _FixedClock extends Clock {
  const _FixedClock();

  @override
  DateTime now() => DateTime.utc(2026, 1, 14, 12);
}
