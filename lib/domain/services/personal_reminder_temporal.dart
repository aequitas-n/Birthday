import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/domain/models/personal_reminder.dart';
import 'package:kin/domain/models/reminder_day_part.dart';
import 'package:timezone/timezone.dart' as tz;

/// Temporal visibility for personal reminders — derived, never persisted.
class ClassifiedPersonalReminders {
  const ClassifiedPersonalReminders({
    required this.active,
    required this.completed,
  });

  final List<PersonalReminder> active;
  final List<PersonalReminder> completed;

  ClassifiedPersonalReminders forDayPart(ReminderDayPart dayPart) {
    return ClassifiedPersonalReminders(
      active: [
        for (final reminder in active)
          if (reminder.dayPart == dayPart) reminder,
      ],
      completed: [
        for (final reminder in completed)
          if (reminder.dayPart == dayPart) reminder,
      ],
    );
  }
}

/// Calendar date for [nowUtc] in the configured reminder IANA zone.
LocalCalendarDate calendarDateInReminderTimeZone({
  required DateTime nowUtc,
  required String reminderTimeZone,
}) {
  final location = _locationOrNull(reminderTimeZone);
  if (location == null) {
    final local = nowUtc.toLocal();
    return LocalCalendarDate.fromLocalDateTime(local);
  }
  final zoned = tz.TZDateTime.from(nowUtc, location);
  return LocalCalendarDate(
    year: zoned.year,
    month: zoned.month,
    day: zoned.day,
  );
}

/// UTC instant when [reminder] fires in [reminderTimeZone], or null if unresolvable.
DateTime? personalReminderFireAtUtc({
  required PersonalReminder reminder,
  required String reminderTimeZone,
}) {
  final location = _locationOrNull(reminderTimeZone);
  if (location == null) return null;

  return tz.TZDateTime(
    location,
    reminder.localDate.year,
    reminder.localDate.month,
    reminder.localDate.day,
    reminder.localTime.hour,
    reminder.localTime.minute,
  ).toUtc();
}

/// True when the reminder's scheduled local instant is not after [nowUtc].
bool isPersonalReminderPast({
  required PersonalReminder reminder,
  required DateTime nowUtc,
  required String reminderTimeZone,
}) {
  final fireAtUtc = personalReminderFireAtUtc(
    reminder: reminder,
    reminderTimeZone: reminderTimeZone,
  );
  if (fireAtUtc == null) return false;
  return !fireAtUtc.isAfter(nowUtc);
}

bool isPersonalReminderActive({
  required PersonalReminder reminder,
  required DateTime nowUtc,
  required String reminderTimeZone,
}) {
  return !isPersonalReminderPast(
    reminder: reminder,
    nowUtc: nowUtc,
    reminderTimeZone: reminderTimeZone,
  );
}

List<PersonalReminder> filterActivePersonalReminders({
  required List<PersonalReminder> reminders,
  required DateTime nowUtc,
  required String reminderTimeZone,
}) {
  return [
    for (final reminder in reminders)
      if (isPersonalReminderActive(
        reminder: reminder,
        nowUtc: nowUtc,
        reminderTimeZone: reminderTimeZone,
      ))
        reminder,
  ];
}

ClassifiedPersonalReminders classifyPersonalReminders({
  required List<PersonalReminder> reminders,
  required DateTime nowUtc,
  required String reminderTimeZone,
}) {
  final active = <PersonalReminder>[];
  final completed = <PersonalReminder>[];
  for (final reminder in reminders) {
    if (isPersonalReminderPast(
      reminder: reminder,
      nowUtc: nowUtc,
      reminderTimeZone: reminderTimeZone,
    )) {
      completed.add(reminder);
    } else {
      active.add(reminder);
    }
  }
  return ClassifiedPersonalReminders(active: active, completed: completed);
}

tz.Location? _locationOrNull(String iana) {
  try {
    return tz.getLocation(iana);
  } on Object {
    return null;
  }
}
