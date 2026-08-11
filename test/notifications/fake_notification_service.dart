import 'package:kin/domain/models/notification_plan.dart';
import 'package:kin/notifications/notification_service.dart';

class FakeNotificationService implements NotificationService {
  final Map<int, NotificationPlan> scheduledPlans = {};
  final List<NotificationPlan> scheduleCalls = [];
  final List<int> cancelCalls = [];
  final List<PendingPlatformNotification> pendingRequestSnapshots = [];
  int initializeCalls = 0;
  int cancelAllCalls = 0;
  AndroidCapabilityState notificationPermission =
      AndroidCapabilityState.granted;
  AndroidCapabilityState exactAlarmPermission = AndroidCapabilityState.granted;
  NotificationLaunchRequest? initialLaunchRequest;

  Set<int> pendingOverride = const {};

  int get totalMutations =>
      scheduleCalls.length + cancelCalls.length + cancelAllCalls;

  @override
  Future<void> initialize() async {
    initializeCalls++;
  }

  @override
  Future<void> schedule(NotificationPlan plan) async {
    scheduleCalls.add(plan);
    scheduledPlans[plan.stableId] = plan;
  }

  @override
  Future<void> cancel(int notificationId) async {
    cancelCalls.add(notificationId);
    scheduledPlans.remove(notificationId);
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCalls++;
    scheduledPlans.clear();
  }

  @override
  Future<Set<int>> pendingNotificationIds() async {
    if (pendingOverride.isNotEmpty) {
      return pendingOverride;
    }
    return scheduledPlans.keys.toSet();
  }

  @override
  Future<List<PendingPlatformNotification>> pendingNotifications() async {
    if (pendingRequestSnapshots.isNotEmpty) {
      return pendingRequestSnapshots;
    }
    return scheduledPlans.values
        .map(
          (plan) => PendingPlatformNotification(
            id: plan.stableId,
            title: plan.title,
            body: plan.body,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<AndroidCapabilityState> notificationsPermissionState() async {
    return notificationPermission;
  }

  @override
  Future<AndroidCapabilityState> requestNotificationsPermission() async {
    return notificationPermission;
  }

  @override
  Future<AndroidCapabilityState> exactAlarmState() async {
    return exactAlarmPermission;
  }

  @override
  Future<AndroidCapabilityState> requestExactAlarmPermission() async {
    return exactAlarmPermission;
  }

  @override
  Future<void> openNotificationSettings() async {}

  @override
  Future<void> openExactAlarmSettings() async {}

  @override
  Future<NotificationLaunchRequest?> consumeLaunchRequest() async {
    final request = initialLaunchRequest;
    initialLaunchRequest = null;
    return request;
  }

  @override
  Stream<NotificationLaunchRequest> get launchRequests => const Stream.empty();
}
