import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kin/notifications/notification_service.dart';

/// Chooses the Android schedule mode for a timed Kin notification.
///
/// Personal reminders and birthday alerts are user-visible clock times.
/// Prefer [AndroidScheduleMode.alarmClock] (`AlarmManager.setAlarmClock`) —
/// it fires at the exact local minute and is not batched into Doze windows.
///
/// When exact alarms are denied, Android only allows inexact delivery, which
/// routinely drifts by a few minutes early or late.
AndroidScheduleMode androidScheduleModeFor(
  AndroidCapabilityState exactAlarmState,
) {
  return switch (exactAlarmState) {
    AndroidCapabilityState.denied => AndroidScheduleMode.inexactAllowWhileIdle,
    AndroidCapabilityState.granted ||
    AndroidCapabilityState.notRequired => AndroidScheduleMode.alarmClock,
  };
}
