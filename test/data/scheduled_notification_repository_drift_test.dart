import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/data/local/database/kin_database.dart';
import 'package:kin/data/repositories/scheduled_notification_repository_drift.dart';
import 'package:kin/domain/models/notification_plan.dart';
import 'package:kin/domain/models/reminder_rule.dart';
import 'package:kin/domain/models/scheduled_notification_record.dart';

void main() {
  group('DriftScheduledNotificationRepository', () {
    late KinDatabase database;
    late DriftScheduledNotificationRepository repository;

    setUp(() {
      database = KinDatabase(NativeDatabase.memory());
      repository = DriftScheduledNotificationRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    NotificationPlan samplePlan({required int stableId}) {
      return NotificationPlan(
        stableId: stableId,
        personId: 'person-1',
        ruleId: 'default-days-7',
        occurrenceYear: 2026,
        fireAtUtc: DateTime.utc(2026, 7, 21, 8),
        targetLocalInstant: const LocalScheduledMoment(
          timeZone: 'Europe/London',
          year: 2026,
          month: 7,
          day: 21,
          hour: 9,
          minute: 0,
        ),
        kind: NotificationPlanKind.birthdayUpcoming,
        payload: const NotificationPayload(
          version: 1,
          personId: 'person-1',
          ruleKind: ReminderRuleKind.daysBefore,
          occurrenceYear: 2026,
        ),
        title: 'Emma turns 24 soon.',
        body: 'A little time to think ahead.',
        hidesSensitivePreview: false,
      );
    }

    test('persists and restores active plans from snapshot json', () async {
      await database
          .into(database.people)
          .insertOnConflictUpdate(
            PeopleCompanion.insert(
              id: 'person-1',
              displayName: 'Emma Stone',
              birthMonth: 7,
              birthDay: 28,
              birthYear: const Value(2002),
              sortKey: 'emma stone',
              createdAt: 0,
              updatedAt: 0,
            ),
          );

      final plan = samplePlan(stableId: 707);
      await repository.upsertRegistered(
        plan: plan,
        deviceTimeZone: 'Europe/London',
        createdAt: DateTime.utc(2026),
      );

      final active = await repository.readActivePlans(
        nowUtc: DateTime.utc(2026),
      );

      expect(active.single, plan);
      expect(
        (await repository.readAllRegistered()).single.state,
        ScheduledNotificationState.registered,
      );
    });

    test('markStale updates persisted state', () async {
      await database
          .into(database.people)
          .insertOnConflictUpdate(
            PeopleCompanion.insert(
              id: 'person-1',
              displayName: 'Emma Stone',
              birthMonth: 7,
              birthDay: 28,
              birthYear: const Value(2002),
              sortKey: 'emma stone',
              createdAt: 0,
              updatedAt: 0,
            ),
          );

      await repository.upsertRegistered(
        plan: samplePlan(stableId: 808),
        deviceTimeZone: 'Europe/London',
        createdAt: DateTime.utc(2026),
      );
      await repository.markStale(808);

      expect(
        (await repository.readByOsId(808))?.state,
        ScheduledNotificationState.stale,
      );
      expect(
        await repository.readActivePlans(nowUtc: DateTime.utc(2026)),
        isEmpty,
      );
    });
  });
}
