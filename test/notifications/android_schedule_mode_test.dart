import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/notifications/android_schedule_mode.dart';
import 'package:kin/notifications/notification_service.dart';

void main() {
  group('androidScheduleModeFor', () {
    test('uses alarmClock when exact alarms are available', () {
      expect(
        androidScheduleModeFor(AndroidCapabilityState.granted),
        AndroidScheduleMode.alarmClock,
      );
      expect(
        androidScheduleModeFor(AndroidCapabilityState.notRequired),
        AndroidScheduleMode.alarmClock,
      );
    });

    test('falls back to inexact when exact alarms are denied', () {
      expect(
        androidScheduleModeFor(AndroidCapabilityState.denied),
        AndroidScheduleMode.inexactAllowWhileIdle,
      );
    });
  });
}
