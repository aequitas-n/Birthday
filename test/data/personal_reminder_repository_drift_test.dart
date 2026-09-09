import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/core/id.dart';
import 'package:kin/data/local/database/kin_database.dart';
import 'package:kin/data/repositories/personal_reminder_repository_drift.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/domain/models/local_clock_time.dart';
import 'package:kin/domain/models/personal_reminder.dart';
import 'package:kin/domain/models/reminder_day_part.dart';

void main() {
  group('DriftPersonalReminderRepository', () {
    late KinDatabase database;
    late DriftPersonalReminderRepository repository;

    setUp(() {
      database = KinDatabase(NativeDatabase.memory());
      repository = DriftPersonalReminderRepository(
        database,
        const IdGenerator(),
        const Clock(),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('creates, reads, updates, and soft-deletes reminders', () async {
      const date = LocalCalendarDate(year: 2026, month: 8, day: 12);
      final created = await repository.upsert(
        PersonalReminder(
          id: '',
          localDate: date,
          localTime: const LocalClockTime(hour: 7, minute: 30),
          dayPart: ReminderDayPart.morning,
          text: 'Call Mom',
          timezone: 'Asia/Kolkata',
          position: 0,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
      );

      expect(created.id, isNotEmpty);
      final loaded = await repository.readForDate(date);
      expect(loaded, hasLength(1));
      expect(loaded.single.id, created.id);
      expect(loaded.single.text, 'Call Mom');

      final updated = await repository.upsert(
        created.copyWith(
          localTime: const LocalClockTime(hour: 8, minute: 0),
          text: 'Call Mom again',
        ),
      );
      expect(updated.localTime.hour, 8);
      expect(
        (await repository.readForDate(date)).single.text,
        'Call Mom again',
      );

      await repository.softDelete(created.id);
      expect(await repository.readForDate(date), isEmpty);
    });

    test(
      'orders multiple reminders and updates timezone for live rows',
      () async {
        const date = LocalCalendarDate(year: 2026, month: 8, day: 12);
        await repository.upsert(
          PersonalReminder(
            id: 'a',
            localDate: date,
            localTime: const LocalClockTime(hour: 9, minute: 0),
            dayPart: ReminderDayPart.morning,
            text: 'First',
            timezone: 'Asia/Kolkata',
            position: 0,
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        );
        await repository.upsert(
          PersonalReminder(
            id: 'b',
            localDate: date,
            localTime: const LocalClockTime(hour: 19, minute: 0),
            dayPart: ReminderDayPart.evening,
            text: 'Second',
            timezone: 'Asia/Kolkata',
            position: 0,
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        );

        final day = await repository.readForDate(date);
        expect(day.map((r) => r.id), ['a', 'b']);

        await repository.updateTimezoneForAllLive('America/New_York');
        final refreshed = await repository.readForDate(date);
        expect(
          refreshed.every((r) => r.timezone == 'America/New_York'),
          isTrue,
        );
      },
    );
  });
}
