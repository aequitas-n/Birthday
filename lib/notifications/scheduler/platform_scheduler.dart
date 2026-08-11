import 'package:kin/core/clock.dart';
import 'package:kin/domain/models/notification_plan.dart';
import 'package:kin/domain/repositories/scheduled_notification_repository.dart';
import 'package:kin/notifications/notification_service.dart';
import 'package:meta/meta.dart';

@immutable
class PlatformSyncResult {
  const PlatformSyncResult({
    required this.added,
    required this.updated,
    required this.removed,
    required this.unchanged,
    required this.restored,
  });

  final int added;
  final int updated;
  final int removed;
  final int unchanged;
  final int restored;

  int get totalMutations => added + updated + removed + restored;
}

class PlatformScheduler {
  PlatformScheduler({
    required NotificationService notificationService,
    required ScheduledNotificationRepository repository,
    required Clock clock,
  }) : _notificationService = notificationService,
       _repository = repository,
       _clock = clock;

  final NotificationService _notificationService;
  final ScheduledNotificationRepository _repository;
  final Clock _clock;

  Future<PlatformSyncResult> synchronize({
    required NotificationPlanReconciliation reconciliation,
    required String deviceTimeZone,
  }) async {
    await _notificationService.initialize();

    var removed = 0;
    for (final plan in reconciliation.toRemove) {
      await _cancelSafely(plan.stableId);
      await _repository.markStale(plan.stableId);
      removed++;
    }

    var updated = 0;
    for (final plan in reconciliation.toUpdate) {
      await _cancelSafely(plan.stableId);
      await _scheduleSafely(plan);
      await _repository.upsertRegistered(
        plan: plan,
        deviceTimeZone: deviceTimeZone,
        createdAt: _clock.now(),
      );
      updated++;
    }

    var added = 0;
    for (final plan in reconciliation.toAdd) {
      await _scheduleSafely(plan);
      await _repository.upsertRegistered(
        plan: plan,
        deviceTimeZone: deviceTimeZone,
        createdAt: _clock.now(),
      );
      added++;
    }

    return PlatformSyncResult(
      added: added,
      updated: updated,
      removed: removed,
      unchanged: reconciliation.unchanged.length,
      restored: 0,
    );
  }

  Future<PlatformSyncResult> synchronizeAfterTimeZoneChange({
    required NotificationPlanReconciliation reconciliation,
    required String deviceTimeZone,
  }) {
    return synchronize(
      reconciliation: reconciliation,
      deviceTimeZone: deviceTimeZone,
    );
  }

  Future<PlatformSyncResult> restoreAfterReboot({
    required String deviceTimeZone,
  }) async {
    await _notificationService.initialize();

    final nowUtc = _clock.now();
    final registered = await _repository.readRegisteredFuture(nowUtc: nowUtc);
    final pending = await _notificationService.pendingNotificationIds();

    var restored = 0;
    for (final record in registered) {
      if (pending.contains(record.osId)) {
        continue;
      }

      await _scheduleSafely(record.toPlan());
      await _repository.upsertRegistered(
        plan: record.toPlan(),
        deviceTimeZone: deviceTimeZone,
        createdAt: record.createdAt,
      );
      restored++;
    }

    return PlatformSyncResult(
      added: 0,
      updated: 0,
      removed: 0,
      unchanged: registered.length - restored,
      restored: restored,
    );
  }

  Future<void> _scheduleSafely(NotificationPlan plan) async {
    final pending = await _notificationService.pendingNotificationIds();
    if (pending.contains(plan.stableId)) {
      return;
    }

    try {
      await _notificationService.schedule(plan);
    } on Object {
      final stillPending = await _notificationService.pendingNotificationIds();
      if (!stillPending.contains(plan.stableId)) {
        rethrow;
      }
    }
  }

  Future<void> _cancelSafely(int notificationId) async {
    try {
      await _notificationService.cancel(notificationId);
    } on Object {
      final pending = await _notificationService.pendingNotificationIds();
      if (pending.contains(notificationId)) {
        rethrow;
      }
    }
  }
}
