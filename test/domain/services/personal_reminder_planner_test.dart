import 'package:flutter_test/flutter_test.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/domain/models/local_clock_time.dart';
import 'package:kin/domain/models/notification_plan.dart';
import 'package:kin/domain/models/personal_reminder.dart';
import 'package:kin/domain/models/reminder_day_part.dart';
import 'package:kin/domain/services/personal_reminder_planner.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

void main() {
  setUpAll(tzdata.initializeTimeZones);

  group('LocalClockTime', () {
    test('parses and formats storage and display', () {
      final time = LocalClockTime.parseStorage('19:30');
      expect(time.storageValue, '19:30');
      expect(time.displayLabel, '7:30 PM');
    });

    test('handles midnight and noon', () {
      expect(LocalClockTime.parseStorage('00:00').displayLabel, '12:00 AM');
      expect(LocalClockTime.parseStorage('12:00').displayLabel, '12:00 PM');
    });
  });

  group('PersonalReminderPlanner', () {
    const planner = PersonalReminderPlanner();

    PersonalReminder reminder({
      required String id,
      required LocalCalendarDate date,
      required LocalClockTime time,
    }) {
      return PersonalReminder(
        id: id,
        localDate: date,
        localTime: time,
        dayPart: ReminderDayPart.evening,
        text: 'Call Mom',
        timezone: 'Asia/Kolkata',
        position: 0,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );
    }

    test('schedules future reminders in the configured IANA zone', () {
      final plans = planner.planAll(
        reminders: [
          reminder(
            id: 'r1',
            date: const LocalCalendarDate(year: 2026, month: 8, day: 12),
            time: const LocalClockTime(hour: 19, minute: 30),
          ),
        ],
        reminderTimeZone: 'Asia/Kolkata',
        notificationsEnabled: true,
        nowUtc: DateTime.utc(2026, 8, 12, 10),
      );

      expect(plans, hasLength(1));
      expect(plans.single.source, NotificationPlanSource.personal);
      expect(plans.single.kind, NotificationPlanKind.personalReminder);
      expect(plans.single.reminderId, 'r1');
      expect(plans.single.body, 'Call Mom');
      expect(plans.single.targetLocalInstant.timeZone, 'Asia/Kolkata');
      expect(plans.single.targetLocalInstant.hour, 19);
      expect(plans.single.targetLocalInstant.minute, 30);
    });

    test('does not schedule past reminders', () {
      final plans = planner.planAll(
        reminders: [
          reminder(
            id: 'r1',
            date: const LocalCalendarDate(year: 2026, month: 8, day: 10),
            time: const LocalClockTime(hour: 19, minute: 30),
          ),
        ],
        reminderTimeZone: 'Asia/Kolkata',
        notificationsEnabled: true,
        nowUtc: DateTime.utc(2026, 8, 12, 10),
      );
      expect(plans, isEmpty);
    });

    test('keeps local clock when timezone preference changes', () {
      final item = reminder(
        id: 'r1',
        date: const LocalCalendarDate(year: 2026, month: 8, day: 12),
        time: const LocalClockTime(hour: 19, minute: 30),
      );
      final kolkata = planner.planOne(
        reminder: item,
        reminderTimeZone: 'Asia/Kolkata',
        nowUtc: DateTime.utc(2026, 8),
      )!;
      final newYork = planner.planOne(
        reminder: item,
        reminderTimeZone: 'America/New_York',
        nowUtc: DateTime.utc(2026, 8),
      )!;

      expect(kolkata.targetLocalInstant.hour, 19);
      expect(newYork.targetLocalInstant.hour, 19);
      expect(kolkata.fireAtUtc, isNot(newYork.fireAtUtc));
    });

    test('stable ids are deterministic and distinct from birthday seeds', () {
      final a = PersonalReminderPlanner.stablePersonalNotificationId(
        reminderId: 'r1',
        localDateKey: '2026-08-12',
      );
      final b = PersonalReminderPlanner.stablePersonalNotificationId(
        reminderId: 'r1',
        localDateKey: '2026-08-12',
      );
      final c = PersonalReminderPlanner.stablePersonalNotificationId(
        reminderId: 'r2',
        localDateKey: '2026-08-12',
      );
      expect(a, b);
      expect(a, isNot(c));
    });
  });
}
