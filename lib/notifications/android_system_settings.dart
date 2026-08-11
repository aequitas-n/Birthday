import 'package:flutter/services.dart';

class AndroidSystemSettings {
  AndroidSystemSettings({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_channelName);

  static const _channelName = 'kin/android_settings';

  final MethodChannel _channel;

  Future<void> openNotificationSettings() async {
    await _channel.invokeMethod<void>('openNotificationSettings');
  }

  Future<void> openExactAlarmSettings() async {
    await _channel.invokeMethod<void>('openExactAlarmSettings');
  }
}
