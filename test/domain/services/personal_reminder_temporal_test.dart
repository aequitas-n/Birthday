import 'package:flutter_test/flutter_test.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/domain/models/local_clock_time.dart';
import 'package:kin/domain/models/personal_reminder.dart';
import 'package:kin/domain/models/reminder_day_part.dart';
import 'package:kin/domain/services/personal_reminder_temporal.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

void main() {
  setUpAll(tzdata.initializeTimeZones);

  PersonalReminder reminder({
    required String id,
    required LocalCalendarDate date,
    required LocalClockTime time,
    ReminderDayPart dayPart = ReminderDayPart.morning,
  }) {
    return PersonalReminder(
      id: id,
      localDate: date,
      localTime: time,
      dayPart: dayPart,
      text: 'Reminder $id',
      timezone: 'Asia/Kolkata',
      position: 0,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
  }

  const date = LocalCalendarDate(year: 2026, month: 8, day: 12);
  const zone = 'Asia/Kolkata';

  group('isPersonalReminderPast', () {
    test('marks reminders before now as past in configured zone', () {
      final item = reminder(
        id: 'r1',
        date: date,
        time: const LocalClockTime(hour: 7, minute: 0),
      );
      expect(
        isPersonalReminderPast(
          reminder: item,
          nowUtc: DateTime.utc(2026, 8, 12, 4, 30),
          reminderTimeZone: zone,
        ),
        isTrue,
      );
    });

    test('keeps future reminders active in configured zone', () {
      final item = reminder(
        id: 'r1',
        date: date,
        time: const LocalClockTime(hour: 15, minute: 0),
      );
      expect(
        isPersonalReminderActive(
          reminder: item,
          nowUtc: DateTime.utc(2026, 8, 12, 4, 30),
          reminderTimeZone: zone,
        ),
        isTrue,
      );
    });

    test('uses reminder timezone rather than device offset', () {
      final item = reminder(
        id: 'r1',
        date: date,
        time: const LocalClockTime(hour: 8, minute: 0),
      );
      // 02:30 UTC = 08:00 Asia/Kolkata on Aug 12 — exactly at fire time → past.
      expect(
        isPersonalReminderPast(
          reminder: item,
          nowUtc: DateTime.utc(2026, 8, 12, 2, 30),
          reminderTimeZone: zone,
        ),
        isTrue,
      );
      // Same UTC instant is still morning in New York — would be active there.
      expect(
        isPersonalReminderActive(
          reminder: item,
          nowUtc: DateTime.utc(2026, 8, 12, 2, 30),
          reminderTimeZone: 'America/New_York',
        ),
        isTrue,
      );
    });
  });

  group('classifyPersonalReminders', () {
    test('splits active and completed without mutating order buckets', () {
      final past = reminder(
        id: 'past',
        date: date,
        time: const LocalClockTime(hour: 7, minute: 0),
        dayPart: ReminderDayPart.anytime,
      );
      final future = reminder(
        id: 'future',
        date: date,
        time: const LocalClockTime(hour: 20, minute: 0),
        dayPart: ReminderDayPart.evening,
      );

      final classified = classifyPersonalReminders(
        reminders: [past, future],
        nowUtc: DateTime.utc(2026, 8, 12, 10),
        reminderTimeZone: zone,
      );

      expect(classified.active, [future]);
      expect(classified.completed, [past]);
      expect(
        classified.forDayPart(ReminderDayPart.anytime).completed,
        [past],
      );
      expect(classified.forDayPart(ReminderDayPart.evening).active, [future]);
    });
  });

  group('filterActivePersonalReminders', () {
    test('matches Today preview scenario', () {
      const date = LocalCalendarDate(year: 2026, month: 8, day: 11);
      final reminders = [
        reminder(
          id: 'past1',
          date: date,
          time: const LocalClockTime(hour: 4, minute: 10),
        ),
        reminder(
          id: 'past2',
          date: date,
          time: const LocalClockTime(hour: 7, minute: 0),
        ),
        reminder(
          id: 'past3',
          date: date,
          time: const LocalClockTime(hour: 15, minute: 0),
        ),
        reminder(
          id: 'active',
          date: date,
          time: const LocalClockTime(hour: 20, minute: 0),
        ),
      ];

      final active = filterActivePersonalReminders(
        reminders: reminders,
        nowUtc: DateTime.utc(2026, 8, 11, 12),
        reminderTimeZone: zone,
      );

      expect(active.map((r) => r.id), ['active']);
    });
  });
}
