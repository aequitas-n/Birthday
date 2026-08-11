import 'package:kin/domain/models/notification_plan.dart';
import 'package:kin/domain/models/scheduled_notification_record.dart';

abstract interface class ScheduledNotificationRepository {
  Future<List<ScheduledNotificationRecord>> readAllRegistered();

  Future<List<ScheduledNotificationRecord>> readRegisteredFuture({
    required DateTime nowUtc,
  });

  Future<List<NotificationPlan>> readActivePlans({required DateTime nowUtc});

  Future<void> upsertRegistered({
    required NotificationPlan plan,
    required String deviceTimeZone,
    required DateTime createdAt,
  });

  Future<void> markStale(int osId);

  Future<void> markStaleAll(Iterable<int> osIds);

  Future<ScheduledNotificationRecord?> readByOsId(int osId);
}
