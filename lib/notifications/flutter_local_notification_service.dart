import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kin/domain/models/notification_plan.dart';
import 'package:kin/notifications/android_schedule_mode.dart';
import 'package:kin/notifications/android_system_settings.dart';
import 'package:kin/notifications/channels.dart';
import 'package:kin/notifications/notification_service.dart';
import 'package:kin/notifications/payload.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class FlutterLocalNotificationService implements NotificationService {
  FlutterLocalNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    AndroidSystemSettings? androidSystemSettings,
    bool initializeTimeZones = true,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _androidSystemSettings =
           androidSystemSettings ?? AndroidSystemSettings(),
       _initializeTimeZones = initializeTimeZones;

  final FlutterLocalNotificationsPlugin _plugin;
  final AndroidSystemSettings _androidSystemSettings;
  final bool _initializeTimeZones;
  final _launchRequests =
      StreamController<NotificationLaunchRequest>.broadcast();
  var _initialized = false;
  NotificationLaunchRequest? _pendingLaunchRequest;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    if (_initializeTimeZones) {
      tzdata.initializeTimeZones();
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(birthdayTodayChannel);
      await androidPlugin.createNotificationChannel(birthdayUpcomingChannel);
      await androidPlugin.createNotificationChannel(personalReminderChannel);
    }

    _initialized = true;
  }

  @override
  Future<void> schedule(NotificationPlan plan) async {
    await initialize();

    final location = tz.getLocation(plan.targetLocalInstant.timeZone);
    final scheduledDate = tz.TZDateTime(
      location,
      plan.targetLocalInstant.year,
      plan.targetLocalInstant.month,
      plan.targetLocalInstant.day,
      plan.targetLocalInstant.hour,
      plan.targetLocalInstant.minute,
      plan.targetLocalInstant.second,
    );

    final exactState = await exactAlarmState();
    final scheduleMode = androidScheduleModeFor(exactState);

    await _plugin.zonedSchedule(
      id: plan.stableId,
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetailsFor(plan),
      androidScheduleMode: scheduleMode,
      title: plan.title,
      body: plan.body,
      payload: encodeNotificationPayload(plan.payload),
    );
  }

  @override
  Future<void> cancel(int notificationId) async {
    await initialize();
    await _plugin.cancel(id: notificationId);
  }

  @override
  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }

  @override
  Future<Set<int>> pendingNotificationIds() async {
    final pending = await pendingNotifications();
    return pending.map((request) => request.id).toSet();
  }

  @override
  Future<List<PendingPlatformNotification>> pendingNotifications() async {
    await initialize();
    final pending = await _plugin.pendingNotificationRequests();
    return pending
        .map(
          (request) => PendingPlatformNotification(
            id: request.id,
            title: request.title,
            body: request.body,
            payload: request.payload,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<AndroidCapabilityState> notificationsPermissionState() async {
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final enabled = await android?.areNotificationsEnabled();
    return _mapCapability(enabled);
  }

  @override
  Future<AndroidCapabilityState> requestNotificationsPermission() async {
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted = await android?.requestNotificationsPermission();
    return _mapCapability(granted);
  }

  @override
  Future<AndroidCapabilityState> exactAlarmState() async {
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final canSchedule = await android?.canScheduleExactNotifications();
    return _mapCapability(canSchedule);
  }

  @override
  Future<AndroidCapabilityState> requestExactAlarmPermission() async {
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted = await android?.requestExactAlarmsPermission();
    return _mapCapability(granted);
  }

  @override
  Future<void> openNotificationSettings() {
    return _androidSystemSettings.openNotificationSettings();
  }

  @override
  Future<void> openExactAlarmSettings() {
    return _androidSystemSettings.openExactAlarmSettings();
  }

  @override
  Future<NotificationLaunchRequest?> consumeLaunchRequest() async {
    await initialize();
    final fromLaunch = _pendingLaunchRequest;
    if (fromLaunch != null) {
      _pendingLaunchRequest = null;
      return fromLaunch;
    }

    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) {
      return null;
    }
    return _parseLaunchRequest(details?.notificationResponse);
  }

  @override
  Stream<NotificationLaunchRequest> get launchRequests =>
      _launchRequests.stream;

  void _handleNotificationResponse(NotificationResponse response) {
    final request = _parseLaunchRequest(response);
    if (request != null) {
      _launchRequests.add(request);
    }
  }

  NotificationLaunchRequest? _parseLaunchRequest(
    NotificationResponse? response,
  ) {
    final payload = response?.payload;
    if (payload == null || payload.isEmpty) {
      return null;
    }
    final decoded = decodeNotificationPayload(payload);
    return NotificationLaunchRequest(
      source: decoded.source,
      personId: decoded.personId,
      reminderId: decoded.reminderId,
      notificationId: response?.id,
      ruleKind: decoded.ruleKind?.storageValue,
      occurrenceYear: decoded.occurrenceYear,
    );
  }

  AndroidCapabilityState _mapCapability(bool? value) {
    return switch (value) {
      true => AndroidCapabilityState.granted,
      false => AndroidCapabilityState.denied,
      null => AndroidCapabilityState.notRequired,
    };
  }
}
