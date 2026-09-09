import 'package:kin/domain/models/settings.dart';

/// Resolves the IANA zone used to schedule personal reminders.
///
/// Prefers [AppSettings.reminderTimezone], then device cache, then [deviceIana].
String resolveReminderIana({
  required AppSettings settings,
  required String deviceIana,
}) {
  final preferred = settings.reminderTimezone?.trim();
  if (preferred != null && preferred.isNotEmpty) return preferred;
  final cached = settings.deviceTimezoneCache?.trim();
  if (cached != null && cached.isNotEmpty) return cached;
  return deviceIana;
}
