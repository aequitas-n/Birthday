import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kin/domain/models/notification_plan.dart';

const birthdayTodayChannelId = 'birthday_today';
const birthdayUpcomingChannelId = 'birthday_upcoming';

const birthdayTodayChannel = AndroidNotificationChannel(
  birthdayTodayChannelId,
  'Birthday today',
  description: 'The day itself.',
  importance: Importance.high,
);

const birthdayUpcomingChannel = AndroidNotificationChannel(
  birthdayUpcomingChannelId,
  'Birthday upcoming',
  description: 'Heads-up reminders before a birthday.',
);

String channelIdFor(NotificationPlanKind kind) {
  return switch (kind) {
    NotificationPlanKind.birthdayToday => birthdayTodayChannelId,
    NotificationPlanKind.birthdayUpcoming => birthdayUpcomingChannelId,
  };
}

NotificationDetails notificationDetailsFor(NotificationPlan plan) {
  final channelId = channelIdFor(plan.kind);
  final visibility = plan.hidesSensitivePreview
      ? NotificationVisibility.private
      : NotificationVisibility.public;

  return NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      switch (plan.kind) {
        NotificationPlanKind.birthdayToday => birthdayTodayChannel.name,
        NotificationPlanKind.birthdayUpcoming => birthdayUpcomingChannel.name,
      },
      channelDescription: switch (plan.kind) {
        NotificationPlanKind.birthdayToday => birthdayTodayChannel.description,
        NotificationPlanKind.birthdayUpcoming =>
          birthdayUpcomingChannel.description,
      },
      importance: switch (plan.kind) {
        NotificationPlanKind.birthdayToday => Importance.high,
        NotificationPlanKind.birthdayUpcoming => Importance.defaultImportance,
      },
      priority: switch (plan.kind) {
        NotificationPlanKind.birthdayToday => Priority.high,
        NotificationPlanKind.birthdayUpcoming => Priority.defaultPriority,
      },
      visibility: visibility,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: plan.kind == NotificationPlanKind.birthdayToday
          ? InterruptionLevel.timeSensitive
          : InterruptionLevel.active,
    ),
  );
}
