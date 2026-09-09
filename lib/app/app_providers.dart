import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/core/id.dart';
import 'package:kin/data/local/database/kin_database.dart';
import 'package:kin/data/local/files/image_store.dart';
import 'package:kin/data/repositories/journal_repository_drift.dart';
import 'package:kin/data/repositories/note_repository_drift.dart';
import 'package:kin/data/repositories/person_repository_drift.dart';
import 'package:kin/data/repositories/personal_reminder_repository_drift.dart';
import 'package:kin/data/repositories/profile_repository_drift.dart';
import 'package:kin/data/repositories/scheduled_notification_repository_drift.dart';
import 'package:kin/data/repositories/settings_repository_drift.dart';
import 'package:kin/domain/models/settings.dart';
import 'package:kin/domain/repositories/journal_repository.dart';
import 'package:kin/domain/repositories/note_repository.dart';
import 'package:kin/domain/repositories/person_repository.dart';
import 'package:kin/domain/repositories/personal_reminder_repository.dart';
import 'package:kin/domain/repositories/profile_repository.dart';
import 'package:kin/domain/repositories/scheduled_notification_repository.dart';
import 'package:kin/domain/repositories/settings_repository.dart';
import 'package:kin/notifications/notification_service.dart';

final kinDatabaseProvider = Provider<KinDatabase>((ref) {
  throw UnimplementedError('bootstrap() must override kinDatabaseProvider.');
});

final imageStoreProvider = Provider<ImageStore>((ref) {
  throw UnimplementedError('bootstrap() must override imageStoreProvider.');
});

final initialAppSettingsProvider = Provider<AppSettings>((ref) {
  return const AppSettings();
});

final personRepositoryProvider = Provider<PersonRepository>((ref) {
  return DriftPersonRepository(
    ref.watch(kinDatabaseProvider),
    ref.watch(idGeneratorProvider),
    ref.watch(clockProvider),
  );
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return DriftProfileRepository(
    ref.watch(kinDatabaseProvider),
    ref.watch(idGeneratorProvider),
    ref.watch(clockProvider),
  );
});

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return DriftJournalRepository(
    ref.watch(kinDatabaseProvider),
    ref.watch(idGeneratorProvider),
    ref.watch(clockProvider),
  );
});

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return DriftNoteRepository(
    ref.watch(kinDatabaseProvider),
    ref.watch(idGeneratorProvider),
    ref.watch(clockProvider),
  );
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return DriftSettingsRepository(ref.watch(kinDatabaseProvider));
});

final personalReminderRepositoryProvider = Provider<PersonalReminderRepository>(
  (ref) {
    return DriftPersonalReminderRepository(
      ref.watch(kinDatabaseProvider),
      ref.watch(idGeneratorProvider),
      ref.watch(clockProvider),
    );
  },
);

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return const NoopNotificationService();
});

final scheduledNotificationRepositoryProvider =
    Provider<ScheduledNotificationRepository>((ref) {
      return DriftScheduledNotificationRepository(
        ref.watch(kinDatabaseProvider),
      );
    });

final appSettingsProvider = StreamProvider<AppSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).watchSettings();
});
