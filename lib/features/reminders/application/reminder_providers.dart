// Riverpod family providers — explicit types omitted per project convention.
// ignore_for_file: specify_nonobvious_property_types

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/domain/models/personal_reminder.dart';
import 'package:kin/domain/services/personal_reminder_temporal.dart';
import 'package:kin/domain/services/reminder_timezone.dart';
import 'package:kin/notifications/application/notification_coordinator.dart';

export 'package:kin/domain/services/personal_reminder_temporal.dart'
    show ClassifiedPersonalReminders, calendarDateInReminderTimeZone;
export 'package:kin/domain/services/reminder_timezone.dart'
    show resolveReminderIana;

/// Resolves the configured reminder IANA zone synchronously for UI classification.
///
/// Uses reminder timezone from settings, then device cache, then UTC.
String watchReminderIanaSync(Ref ref) {
  final settings = ref
      .watch(appSettingsProvider)
      .maybeWhen(
        data: (value) => value,
        orElse: () => ref.watch(initialAppSettingsProvider),
      );
  return resolveReminderIana(
    settings: settings,
    deviceIana: settings.deviceTimezoneCache ?? 'UTC',
  );
}

/// Calendar "today" in the configured reminder timezone.
final reminderTodayProvider = Provider<LocalCalendarDate>((ref) {
  final nowUtc = ref.watch(clockProvider).now();
  final iana = watchReminderIanaSync(ref);
  return calendarDateInReminderTimeZone(
    nowUtc: nowUtc,
    reminderTimeZone: iana,
  );
});

/// Live reminders for a `YYYY-MM-DD` date key.
final remindersForDateProvider =
    StreamProvider.family<List<PersonalReminder>, String>((ref, dateKey) {
      final date = LocalCalendarDate.parseStorage(dateKey);
      return ref.watch(personalReminderRepositoryProvider).watchForDate(date);
    });

/// All persisted reminders for today — includes completed/past rows.
final todayRemindersProvider = Provider<AsyncValue<List<PersonalReminder>>>((
  ref,
) {
  final today = ref.watch(reminderTodayProvider);
  return ref.watch(remindersForDateProvider(today.storageKey));
});

/// Active + upcoming reminders for the Universal Today preview.
final todayActiveRemindersProvider = Provider<List<PersonalReminder>>((ref) {
  final today = ref.watch(reminderTodayProvider);
  final remindersAsync = ref.watch(remindersForDateProvider(today.storageKey));
  final nowUtc = ref.watch(clockProvider).now();
  final iana = watchReminderIanaSync(ref);
  return remindersAsync.maybeWhen(
    data: (reminders) => filterActivePersonalReminders(
      reminders: reminders,
      nowUtc: nowUtc,
      reminderTimeZone: iana,
    ),
    orElse: () => const <PersonalReminder>[],
  );
});

/// Active vs completed reminders for a planner date key.
final classifiedRemindersForDateProvider =
    Provider.family<AsyncValue<ClassifiedPersonalReminders>, String>((
      ref,
      dateKey,
    ) {
      final remindersAsync = ref.watch(remindersForDateProvider(dateKey));
      final nowUtc = ref.watch(clockProvider).now();
      final iana = watchReminderIanaSync(ref);

      return remindersAsync.when(
        loading: () => const AsyncLoading(),
        error: AsyncError.new,
        data: (reminders) => AsyncData(
          classifyPersonalReminders(
            reminders: reminders,
            nowUtc: nowUtc,
            reminderTimeZone: iana,
          ),
        ),
      );
    });

/// IANA zone used when scheduling personal reminders.
final reminderTimezoneProvider = FutureProvider<String>((ref) async {
  final settings = ref
      .watch(appSettingsProvider)
      .maybeWhen(
        data: (value) => value,
        orElse: () => ref.watch(initialAppSettingsProvider),
      );
  return resolveReminderIana(
    settings: settings,
    deviceIana: await ref.watch(deviceTimezoneSourceProvider).currentIanaName(),
  );
});
