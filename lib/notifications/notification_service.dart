import 'package:kin/domain/models/notification_plan.dart';

enum AndroidCapabilityState { granted, denied, notRequired }

class NotificationLaunchRequest {
  const NotificationLaunchRequest({
    required this.personId,
    required this.notificationId,
    required this.ruleKind,
    required this.occurrenceYear,
  });

  final String personId;
  final int? notificationId;
  final String ruleKind;
  final int occurrenceYear;
}

class PendingPlatformNotification {
  const PendingPlatformNotification({
    required this.id,
    this.title,
    this.body,
    this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

class NoopNotificationService implements NotificationService {
  const NoopNotificationService();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> schedule(NotificationPlan plan) async {}

  @override
  Future<void> cancel(int notificationId) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<Set<int>> pendingNotificationIds() async {
    return const <int>{};
  }

  @override
  Future<List<PendingPlatformNotification>> pendingNotifications() async {
    return const <PendingPlatformNotification>[];
  }

  @override
  Future<AndroidCapabilityState> notificationsPermissionState() async {
    return AndroidCapabilityState.notRequired;
  }

  @override
  Future<AndroidCapabilityState> requestNotificationsPermission() async {
    return AndroidCapabilityState.notRequired;
  }

  @override
  Future<AndroidCapabilityState> exactAlarmState() async {
    return AndroidCapabilityState.notRequired;
  }

  @override
  Future<AndroidCapabilityState> requestExactAlarmPermission() async {
    return AndroidCapabilityState.notRequired;
  }

  @override
  Future<void> openNotificationSettings() async {}

  @override
  Future<void> openExactAlarmSettings() async {}

  @override
  Future<NotificationLaunchRequest?> consumeLaunchRequest() async {
    return null;
  }

  @override
  Stream<NotificationLaunchRequest> get launchRequests =>
      const Stream<NotificationLaunchRequest>.empty();
}

abstract interface class NotificationService {
  Future<void> initialize();

  Future<void> schedule(NotificationPlan plan);

  Future<void> cancel(int notificationId);

  Future<void> cancelAll();

  Future<Set<int>> pendingNotificationIds();

  Future<List<PendingPlatformNotification>> pendingNotifications();

  Future<AndroidCapabilityState> notificationsPermissionState();

  Future<AndroidCapabilityState> requestNotificationsPermission();

  Future<AndroidCapabilityState> exactAlarmState();

  Future<AndroidCapabilityState> requestExactAlarmPermission();

  Future<void> openNotificationSettings();

  Future<void> openExactAlarmSettings();

  Future<NotificationLaunchRequest?> consumeLaunchRequest();

  Stream<NotificationLaunchRequest> get launchRequests;
}
