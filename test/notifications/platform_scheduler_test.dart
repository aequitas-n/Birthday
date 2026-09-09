import 'package:flutter_test/flutter_test.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/domain/models/notification_plan.dart';
import 'package:kin/domain/models/reminder_rule.dart';
import 'package:kin/domain/models/scheduled_notification_record.dart';
import 'package:kin/domain/repositories/scheduled_notification_repository.dart';
import 'package:kin/domain/services/reminder_planner.dart';
import 'package:kin/notifications/scheduler/platform_scheduler.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

import 'fake_notification_service.dart';

class _FixedClock extends Clock {
  const _FixedClock(this.fixedNow);

  final DateTime fixedNow;

  @override
  DateTime now() => fixedNow;
}

class _MemoryScheduledNotificationRepository
    implements ScheduledNotificationRepository {
  final _records = <int, ScheduledNotificationRecord>{};

  @override
  Future<List<ScheduledNotificationRecord>> readAllRegistered() async {
    return _records.values
        .where(
          (record) => record.state == ScheduledNotificationState.registered,
        )
        .toList(growable: false);
  }

  @override
  Future<List<ScheduledNotificationRecord>> readRegisteredFuture({
    required DateTime nowUtc,
  }) async {
    return _records.values
        .where(
          (record) =>
              record.state == ScheduledNotificationState.registered &&
              record.fireAtUtc.isAfter(nowUtc.toUtc()),
        )
        .toList(growable: false);
  }

  @override
  Future<List<NotificationPlan>> readActivePlans({
    required DateTime nowUtc,
  }) async {
    final records = await readRegisteredFuture(nowUtc: nowUtc);
    return records.map((record) => record.toPlan()).toList(growable: false);
  }

  @override
  Future<void> upsertRegistered({
    required NotificationPlan plan,
    required String deviceTimeZone,
    required DateTime createdAt,
  }) async {
    _records[plan.stableId] = ScheduledNotificationRecord.fromPlan(
      plan: plan,
      deviceTimeZone: deviceTimeZone,
      createdAt: createdAt,
    );
  }

  @override
  Future<void> markStale(int osId) async {
    final record = _records[osId];
    if (record == null) return;
    _records[osId] = record.copyWith(state: ScheduledNotificationState.stale);
  }

  @override
  Future<void> markStaleAll(Iterable<int> osIds) async {
    for (final osId in osIds) {
      await markStale(osId);
    }
  }

  @override
  Future<ScheduledNotificationRecord?> readByOsId(int osId) async {
    return _records[osId];
  }
}

void main() {
  setUpAll(tzdata.initializeTimeZones);

  group('PlatformScheduler', () {
    const planner = ReminderPlanner();
    const deviceTimeZone = 'Europe/London';
    final nowUtc = DateTime.utc(2026);

    late FakeNotificationService notificationService;
    late _MemoryScheduledNotificationRepository repository;
    late PlatformScheduler scheduler;

    NotificationPlan plan({
      required int stableId,
      required String personId,
      required String ruleId,
      required DateTime fireAtUtc,
    }) {
      return NotificationPlan(
        stableId: stableId,
        source: NotificationPlanSource.birthday,
        personId: personId,
        ruleId: ruleId,
        occurrenceYear: 2026,
        fireAtUtc: fireAtUtc,
        targetLocalInstant: const LocalScheduledMoment(
          timeZone: 'Europe/London',
          year: 2026,
          month: 7,
          day: 28,
          hour: 9,
          minute: 0,
        ),
        kind: NotificationPlanKind.birthdayUpcoming,
        payload: NotificationPayload.birthday(
          personId: personId,
          ruleKind: ReminderRuleKind.daysBefore,
          occurrenceYear: 2026,
        ),
        title: 'Emma turns 24 soon.',
        body: 'A little time to think ahead.',
        hidesSensitivePreview: false,
      );
    }

    setUp(() {
      notificationService = FakeNotificationService();
      repository = _MemoryScheduledNotificationRepository();
      scheduler = PlatformScheduler(
        notificationService: notificationService,
        repository: repository,
        clock: _FixedClock(nowUtc),
      );
    });

    test('schedules additions from reconciliation', () async {
      final desired = [
        plan(
          stableId: 101,
          personId: 'person-1',
          ruleId: 'days-7',
          fireAtUtc: DateTime.utc(2026, 7, 21, 8),
        ),
      ];

      final reconciliation = planner.reconcile(
        current: const [],
        desired: desired,
      );
      final result = await scheduler.synchronize(
        reconciliation: reconciliation,
        deviceTimeZone: deviceTimeZone,
      );

      expect(result.added, 1);
      expect(notificationService.scheduledPlans, contains(101));
      expect(
        (await repository.readActivePlans(nowUtc: nowUtc)).single.stableId,
        101,
      );
    });

    test('updates changed plans by rescheduling the same stable id', () async {
      final original = plan(
        stableId: 202,
        personId: 'person-2',
        ruleId: 'days-1',
        fireAtUtc: DateTime.utc(2026, 7, 27, 8),
      );
      final updated = original.copyWith(body: 'Updated copy');

      await scheduler.synchronize(
        reconciliation: planner.reconcile(
          current: const [],
          desired: [original],
        ),
        deviceTimeZone: deviceTimeZone,
      );
      notificationService.scheduleCalls.clear();
      notificationService.cancelCalls.clear();

      final reconciliation = planner.reconcile(
        current: [original],
        desired: [updated],
      );
      final result = await scheduler.synchronize(
        reconciliation: reconciliation,
        deviceTimeZone: deviceTimeZone,
      );

      expect(result.updated, 1);
      expect(notificationService.cancelCalls, [202]);
      expect(notificationService.scheduleCalls.single.body, 'Updated copy');
    });

    test('cancels removed plans and marks them stale', () async {
      final existing = plan(
        stableId: 303,
        personId: 'person-3',
        ruleId: 'midnight',
        fireAtUtc: DateTime.utc(2026, 7, 28, 5),
      );

      await scheduler.synchronize(
        reconciliation: planner.reconcile(
          current: const [],
          desired: [existing],
        ),
        deviceTimeZone: deviceTimeZone,
      );
      notificationService.cancelCalls.clear();

      final reconciliation = planner.reconcile(
        current: [existing],
        desired: const [],
      );
      final result = await scheduler.synchronize(
        reconciliation: reconciliation,
        deviceTimeZone: deviceTimeZone,
      );

      expect(result.removed, 1);
      expect(notificationService.cancelCalls, [303]);
      expect(notificationService.scheduledPlans, isEmpty);
      expect(
        (await repository.readByOsId(303))?.state,
        ScheduledNotificationState.stale,
      );
    });

    test(
      'second synchronization with unchanged reconciliation is a no-op',
      () async {
        final desired = [
          plan(
            stableId: 404,
            personId: 'person-4',
            ruleId: 'days-7',
            fireAtUtc: DateTime.utc(2026, 7, 21, 8),
          ),
        ];

        await scheduler.synchronize(
          reconciliation: planner.reconcile(
            current: const [],
            desired: desired,
          ),
          deviceTimeZone: deviceTimeZone,
        );
        final mutationsAfterFirst = notificationService.totalMutations;

        final unchangedReconciliation = planner.reconcile(
          current: desired,
          desired: desired,
        );
        final result = await scheduler.synchronize(
          reconciliation: unchangedReconciliation,
          deviceTimeZone: deviceTimeZone,
        );

        expect(result.added, 0);
        expect(result.updated, 0);
        expect(result.removed, 0);
        expect(result.unchanged, 1);
        expect(notificationService.totalMutations, mutationsAfterFirst);
      },
    );

    test(
      'duplicate execution of the same add reconciliation is tolerated',
      () async {
        final desired = [
          plan(
            stableId: 505,
            personId: 'person-5',
            ruleId: 'days-1',
            fireAtUtc: DateTime.utc(2026, 7, 27, 8),
          ),
        ];
        final reconciliation = planner.reconcile(
          current: const [],
          desired: desired,
        );

        await scheduler.synchronize(
          reconciliation: reconciliation,
          deviceTimeZone: deviceTimeZone,
        );
        final scheduleCallsAfterFirst =
            notificationService.scheduleCalls.length;

        await scheduler.synchronize(
          reconciliation: reconciliation,
          deviceTimeZone: deviceTimeZone,
        );

        expect(
          notificationService.scheduleCalls.length,
          scheduleCallsAfterFirst,
        );
        expect(notificationService.scheduledPlans, contains(505));
      },
    );

    test(
      'restoreAfterReboot reschedules missing platform notifications',
      () async {
        final desired = [
          plan(
            stableId: 606,
            personId: 'person-6',
            ruleId: 'midnight',
            fireAtUtc: DateTime.utc(2026, 7, 28, 5),
          ),
        ];

        await scheduler.synchronize(
          reconciliation: planner.reconcile(
            current: const [],
            desired: desired,
          ),
          deviceTimeZone: deviceTimeZone,
        );

        notificationService.pendingOverride = const {};
        notificationService.scheduledPlans.clear();
        notificationService.scheduleCalls.clear();

        final result = await scheduler.restoreAfterReboot(
          deviceTimeZone: deviceTimeZone,
        );

        expect(result.restored, 1);
        expect(notificationService.scheduleCalls, hasLength(1));
        expect(notificationService.scheduleCalls.single.stableId, 606);
      },
    );
  });
}
