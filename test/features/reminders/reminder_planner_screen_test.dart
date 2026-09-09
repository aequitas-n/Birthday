import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/design/theme/material_shim.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/domain/models/local_clock_time.dart';
import 'package:kin/domain/models/personal_reminder.dart';
import 'package:kin/domain/models/reminder_day_part.dart';
import 'package:kin/domain/models/settings.dart';
import 'package:kin/features/reminders/application/reminder_providers.dart';
import 'package:kin/features/reminders/presentation/reminder_planner_screen.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

import '../../support/quiet_test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    loadQuietFonts();
    tzdata.initializeTimeZones();
  });

  const today = LocalCalendarDate(year: 2026, month: 8, day: 12);
  const clock = _FixedClock();
  const settings = AppSettings(reminderTimezone: 'Asia/Kolkata');

  Future<void> pumpPlanner(
    WidgetTester tester, {
    required List<PersonalReminder> reminders,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(clock),
          initialAppSettingsProvider.overrideWithValue(settings),
          reminderTodayProvider.overrideWithValue(today),
          remindersForDateProvider.overrideWith(
            (ref, key) => Stream.value(reminders),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildMaterialShim(const QuietTheme.light()),
          home: Builder(
            builder: (context) => ColoredBox(
              color: context.quiet.color.canvas,
              child: const ReminderPlannerScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  PersonalReminder reminder({
    required String id,
    required String text,
    required LocalClockTime time,
    required ReminderDayPart dayPart,
    int position = 0,
  }) {
    return PersonalReminder(
      id: id,
      text: text,
      localDate: today,
      localTime: time,
      dayPart: dayPart,
      timezone: 'Asia/Kolkata',
      position: position,
      createdAt: DateTime.utc(2026, 8, 12),
      updatedAt: DateTime.utc(2026, 8, 12),
    );
  }

  testWidgets('shows one chronological list across day-parts', (tester) async {
    await pumpPlanner(
      tester,
      reminders: [
        reminder(
          id: 'evening',
          text: 'Call Mom',
          time: const LocalClockTime(hour: 20, minute: 0),
          dayPart: ReminderDayPart.evening,
        ),
        reminder(
          id: 'afternoon',
          text: 'Submit assignment',
          time: const LocalClockTime(hour: 16, minute: 30),
          dayPart: ReminderDayPart.afternoon,
        ),
        reminder(
          id: 'laterAfternoon',
          text: 'Wake stretch',
          time: const LocalClockTime(hour: 17, minute: 0),
          dayPart: ReminderDayPart.anytime,
        ),
      ],
    );

    expect(find.text('Reminders'), findsOneWidget);
    expect(find.text('Add reminder'), findsOneWidget);
    expect(find.text('Morning'), findsNothing);
    expect(find.text('Afternoon'), findsNothing);
    expect(find.text('Evening'), findsNothing);
    expect(find.text('Anytime'), findsNothing);

    final assignment = tester.getTopLeft(find.text('Submit assignment'));
    final stretch = tester.getTopLeft(find.text('Wake stretch'));
    final call = tester.getTopLeft(find.text('Call Mom'));
    expect(assignment.dy, lessThan(stretch.dy));
    expect(stretch.dy, lessThan(call.dy));
  });

  testWidgets('same-time reminders preserve position order', (tester) async {
    await pumpPlanner(
      tester,
      reminders: [
        reminder(
          id: 'b',
          text: 'Second at six',
          time: const LocalClockTime(hour: 18, minute: 0),
          dayPart: ReminderDayPart.evening,
          position: 1,
        ),
        reminder(
          id: 'a',
          text: 'First at six',
          time: const LocalClockTime(hour: 18, minute: 0),
          dayPart: ReminderDayPart.anytime,
        ),
      ],
    );

    final first = tester.getTopLeft(find.text('First at six'));
    final second = tester.getTopLeft(find.text('Second at six'));
    expect(first.dy, lessThan(second.dy));
  });

  testWidgets('empty day shows one empty state and one add action', (
    tester,
  ) async {
    await pumpPlanner(tester, reminders: const []);

    expect(find.text('Nothing planned yet.'), findsOneWidget);
    expect(find.text('Add reminder'), findsOneWidget);
    expect(find.text('Morning'), findsNothing);
    expect(find.text("What's on your morning list?"), findsNothing);
    expect(find.text('Completed · 0'), findsNothing);
  });

  testWidgets('hides past reminders by default and reveals completed rows', (
    tester,
  ) async {
    await pumpPlanner(
      tester,
      reminders: [
        reminder(
          id: 'past',
          text: 'Did you wake up?',
          time: const LocalClockTime(hour: 7, minute: 0),
          dayPart: ReminderDayPart.anytime,
        ),
        reminder(
          id: 'future',
          text: 'Finish project',
          time: const LocalClockTime(hour: 20, minute: 0),
          dayPart: ReminderDayPart.evening,
        ),
      ],
    );

    expect(find.text('Finish project'), findsOneWidget);
    expect(find.text('Did you wake up?'), findsNothing);
    expect(find.text('Completed · 1'), findsOneWidget);
    expect(find.text('1'), findsWidgets);

    await tester.tap(find.text('Completed · 1'));
    await tester.pumpAndSettle();

    expect(find.text('Did you wake up?'), findsOneWidget);
    expect(find.text('Finish project'), findsOneWidget);
  });

  testWidgets('completed disclosure orders past reminders chronologically', (
    tester,
  ) async {
    await pumpPlanner(
      tester,
      reminders: [
        reminder(
          id: 'later',
          text: 'Drink water',
          time: const LocalClockTime(hour: 9, minute: 0),
          dayPart: ReminderDayPart.morning,
        ),
        reminder(
          id: 'earlier',
          text: 'Go and sleep dude',
          time: const LocalClockTime(hour: 4, minute: 10),
          dayPart: ReminderDayPart.anytime,
        ),
      ],
    );

    expect(find.text('Completed · 2'), findsOneWidget);
    await tester.tap(find.text('Completed · 2'));
    await tester.pumpAndSettle();

    final sleep = tester.getTopLeft(find.text('Go and sleep dude'));
    final water = tester.getTopLeft(find.text('Drink water'));
    expect(sleep.dy, lessThan(water.dy));
  });
}

class _FixedClock extends Clock {
  const _FixedClock();

  @override
  DateTime now() => DateTime.utc(2026, 8, 12, 10);
}
