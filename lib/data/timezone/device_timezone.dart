import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class DeviceTimezoneSource {
  const DeviceTimezoneSource({this.fixedIanaName});

  /// When set, skips the platform channel. Used by widget tests and any host
  /// that already knows the zone.
  final String? fixedIanaName;

  Future<String> currentIanaName() async {
    final fixed = fixedIanaName;
    if (fixed != null && fixed.isNotEmpty) {
      return fixed;
    }

    // Platform channels that never complete hang widget tests forever —
    // Future.timeout does not help unless the test pumps real time.
    if (_isTestBinding) {
      return 'UTC';
    }

    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      return timezone.identifier;
    } on MissingPluginException {
      return 'UTC';
    } on Object {
      return 'UTC';
    }
  }

  static bool get _isTestBinding {
    final name = WidgetsBinding.instance.runtimeType.toString();
    return name.contains('TestWidgetsFlutterBinding');
  }
}
