import 'package:kin/domain/models/notification_plan.dart';
import 'package:kin/domain/models/personal_reminder.dart';
import 'package:kin/domain/services/personal_reminder_temporal.dart';
import 'package:timezone/timezone.dart' as tz;

/// Builds NotificationPlans for app-owned personal reminders.
///
/// Birthday planning stays in ReminderPlanner. Both feed the shared
/// reconcile + PlatformScheduler path.
class PersonalReminderPlanner {
  const PersonalReminderPlanner();

  List<NotificationPlan> planAll({
    required List<PersonalReminder> reminders,
    required String reminderTimeZone,
    required bool notificationsEnabled,
    required DateTime nowUtc,
  }) {
    if (!notificationsEnabled) return const [];

    final plans = <NotificationPlan>[];
    for (final reminder in reminders) {
      if (reminder.isDeleted) continue;
      final text = reminder.text.trim();
      if (text.isEmpty) continue;

      final plan = planOne(
        reminder: reminder,
        reminderTimeZone: reminderTimeZone,
        nowUtc: nowUtc,
      );
      if (plan != null) {
        plans.add(plan);
      }
    }
    plans.sort((a, b) => a.fireAtUtc.compareTo(b.fireAtUtc));
    return plans;
  }

  NotificationPlan? planOne({
    required PersonalReminder reminder,
    required String reminderTimeZone,
    required DateTime nowUtc,
  }) {
    final fireAtUtc = personalReminderFireAtUtc(
      reminder: reminder,
      reminderTimeZone: reminderTimeZone,
    );
    if (fireAtUtc == null || !fireAtUtc.isAfter(nowUtc)) {
      return null;
    }

    final location = _locationOrNull(reminderTimeZone);
    if (location == null) return null;

    final stableId = stablePersonalNotificationId(
      reminderId: reminder.id,
      localDateKey: reminder.localDate.storageKey,
    );

    return NotificationPlan(
      stableId: stableId,
      source: NotificationPlanSource.personal,
      reminderId: reminder.id,
      occurrenceYear: reminder.localDate.year,
      fireAtUtc: fireAtUtc,
      targetLocalInstant: LocalScheduledMoment(
        timeZone: reminderTimeZone,
        year: reminder.localDate.year,
        month: reminder.localDate.month,
        day: reminder.localDate.day,
        hour: reminder.localTime.hour,
        minute: reminder.localTime.minute,
      ),
      kind: NotificationPlanKind.personalReminder,
      payload: NotificationPayload.personal(
        reminderId: reminder.id,
        occurrenceYear: reminder.localDate.year,
      ),
      title: 'Kin',
      body: reminder.text.trim(),
      hidesSensitivePreview: false,
    );
  }

  /// Deterministic OS id — distinct seed from birthday plans.
  static int stablePersonalNotificationId({
    required String reminderId,
    required String localDateKey,
  }) {
    final seed = 'personal|$reminderId|$localDateKey';
    var hash = 2166136261;
    for (final unit in seed.codeUnits) {
      hash ^= unit;
      hash = (hash * 16777619) & 0x7fffffff;
    }
    return hash == 0 ? 1 : hash;
  }

  tz.Location? _locationOrNull(String iana) {
    try {
      return tz.getLocation(iana);
    } on Object {
      return null;
    }
  }
}
