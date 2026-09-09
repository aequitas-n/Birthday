import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/domain/models/personal_reminder.dart';

abstract interface class PersonalReminderRepository {
  Stream<List<PersonalReminder>> watchForDate(LocalCalendarDate date);

  Future<List<PersonalReminder>> readForDate(LocalCalendarDate date);

  Future<List<PersonalReminder>> readLiveFutureAndToday({
    required LocalCalendarDate today,
  });

  Future<PersonalReminder?> readById(String id);

  Future<PersonalReminder> upsert(PersonalReminder reminder);

  Future<void> softDelete(String id);

  Future<void> updateTimezoneForAllLive(String ianaTimezone);
}
