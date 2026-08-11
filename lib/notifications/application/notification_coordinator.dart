import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/data/local/database/kin_database.dart' as db;
import 'package:kin/data/timezone/device_timezone.dart';
import 'package:kin/domain/models/birthday_occurrence.dart';
import 'package:kin/domain/models/note.dart';
import 'package:kin/domain/models/notification_plan.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/domain/models/reminder_rule.dart';
import 'package:kin/domain/models/scheduled_notification_record.dart';
import 'package:kin/domain/models/settings.dart';
import 'package:kin/domain/repositories/scheduled_notification_repository.dart';
import 'package:kin/domain/repositories/settings_repository.dart';
import 'package:kin/domain/services/occurrence_calculator.dart';
import 'package:kin/domain/services/reminder_planner.dart';
import 'package:kin/notifications/notification_service.dart';
import 'package:kin/notifications/scheduler/platform_scheduler.dart';

final deviceTimezoneSourceProvider = Provider<DeviceTimezoneSource>((ref) {
  return const DeviceTimezoneSource();
});

final occurrenceCalculatorProvider = Provider<OccurrenceCalculator>((ref) {
  return const OccurrenceCalculator();
});

final reminderPlannerProvider = Provider<ReminderPlanner>((ref) {
  return const ReminderPlanner();
});

final platformSchedulerProvider = Provider<PlatformScheduler>((ref) {
  return PlatformScheduler(
    notificationService: ref.watch(notificationServiceProvider),
    repository: ref.watch(scheduledNotificationRepositoryProvider),
    clock: ref.watch(clockProvider),
  );
});

final notificationCoordinatorProvider = Provider<NotificationCoordinator>((
  ref,
) {
  return NotificationCoordinator(
    database: ref.watch(kinDatabaseProvider),
    clock: ref.watch(clockProvider),
    deviceTimezoneSource: ref.watch(deviceTimezoneSourceProvider),
    notificationService: ref.watch(notificationServiceProvider),
    occurrenceCalculator: ref.watch(occurrenceCalculatorProvider),
    reminderPlanner: ref.watch(reminderPlannerProvider),
    scheduledRepository: ref.watch(scheduledNotificationRepositoryProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
    scheduler: ref.watch(platformSchedulerProvider),
  );
});

final notificationStatusProvider = FutureProvider<NotificationRuntimeStatus>((
  ref,
) {
  return ref.watch(notificationCoordinatorProvider).status();
});

final notificationDebugSnapshotProvider =
    FutureProvider<NotificationDebugSnapshot>((ref) {
      return ref.watch(notificationCoordinatorProvider).debugSnapshot();
    });

class NotificationCoordinator {
  NotificationCoordinator({
    required db.KinDatabase database,
    required Clock clock,
    required DeviceTimezoneSource deviceTimezoneSource,
    required NotificationService notificationService,
    required OccurrenceCalculator occurrenceCalculator,
    required ReminderPlanner reminderPlanner,
    required ScheduledNotificationRepository scheduledRepository,
    required SettingsRepository settingsRepository,
    required PlatformScheduler scheduler,
  }) : _database = database,
       _clock = clock,
       _deviceTimezoneSource = deviceTimezoneSource,
       _notificationService = notificationService,
       _occurrenceCalculator = occurrenceCalculator,
       _reminderPlanner = reminderPlanner,
       _scheduledRepository = scheduledRepository,
       _settingsRepository = settingsRepository,
       _scheduler = scheduler;

  final db.KinDatabase _database;
  final Clock _clock;
  final DeviceTimezoneSource _deviceTimezoneSource;
  final NotificationService _notificationService;
  final OccurrenceCalculator _occurrenceCalculator;
  final ReminderPlanner _reminderPlanner;
  final ScheduledNotificationRepository _scheduledRepository;
  final SettingsRepository _settingsRepository;
  final PlatformScheduler _scheduler;

  Future<void> initialize() {
    return _notificationService.initialize();
  }

  Future<NotificationRuntimeStatus> status() async {
    await initialize();
    final settings = await _settingsRepository.readSettings();
    final deviceTimeZone = await _deviceTimezoneSource.currentIanaName();
    final pending = await _notificationService.pendingNotifications();
    final currentPlans = await _scheduledRepository.readActivePlans(
      nowUtc: _clock.now(),
    );
    return NotificationRuntimeStatus(
      notificationsEnabled: settings.notificationsEnabled,
      notificationPermission: await _notificationService
          .notificationsPermissionState(),
      exactAlarmPermission: await _notificationService.exactAlarmState(),
      deviceTimeZone: deviceTimeZone,
      pendingCount: pending.length,
      plannedCount: currentPlans.length,
      lastReconciledAt: settings.lastReconciledAt,
    );
  }

  Future<AndroidCapabilityState> requestNotificationPermission() async {
    final result = await _notificationService.requestNotificationsPermission();
    return result;
  }

  Future<AndroidCapabilityState> requestExactAlarmPermission() async {
    final result = await _notificationService.requestExactAlarmPermission();
    return result;
  }

  Future<void> openNotificationSettings() {
    return _notificationService.openNotificationSettings();
  }

  Future<void> openExactAlarmSettings() {
    return _notificationService.openExactAlarmSettings();
  }

  Future<void> setNotificationsEnabled({required bool value}) async {
    final settings = await _settingsRepository.readSettings();
    await _settingsRepository.saveSettings(
      settings.copyWith(notificationsEnabled: value),
    );
  }

  Future<PlatformSyncResult> synchronizeStartup() async {
    await initialize();
    final deviceTimeZone = await _deviceTimezoneSource.currentIanaName();
    final restored = await _scheduler.restoreAfterReboot(
      deviceTimeZone: deviceTimeZone,
    );
    final synchronized = await synchronize();
    return PlatformSyncResult(
      added: synchronized.added,
      updated: synchronized.updated,
      removed: synchronized.removed,
      unchanged: synchronized.unchanged,
      restored: restored.restored,
    );
  }

  Future<PlatformSyncResult> synchronize() async {
    await initialize();
    if (_notificationService is NoopNotificationService) {
      return const PlatformSyncResult(
        added: 0,
        updated: 0,
        removed: 0,
        unchanged: 0,
        restored: 0,
      );
    }
    final settings = await _settingsRepository.readSettings();
    final deviceTimeZone = await _deviceTimezoneSource.currentIanaName();
    final desired = await _desiredPlans(
      settings: settings,
      deviceTimeZone: deviceTimeZone,
      nowUtc: _clock.now(),
    );
    final current = await _scheduledRepository.readActivePlans(
      nowUtc: _clock.now(),
    );
    final reconciliation = _reminderPlanner.reconcile(
      current: current,
      desired: desired,
    );
    final result = await _scheduler.synchronize(
      reconciliation: reconciliation,
      deviceTimeZone: deviceTimeZone,
    );
    await _settingsRepository.saveSettings(
      settings.copyWith(
        deviceTimezoneCache: deviceTimeZone,
        lastReconciledAt: _clock.now(),
      ),
    );
    return result;
  }

  Future<NotificationLaunchRequest?> consumeLaunchRequest() {
    return _notificationService.consumeLaunchRequest();
  }

  Stream<NotificationLaunchRequest> get launchRequests =>
      _notificationService.launchRequests;

  Future<NotificationDebugSnapshot> debugSnapshot() async {
    final settings = await _settingsRepository.readSettings();
    final status = await this.status();
    final peopleRows = await (_database.select(
      _database.people,
    )..where((tbl) => tbl.deletedAt.isNull())).get();
    final noteRows = await (_database.select(
      _database.notes,
    )..where((tbl) => tbl.deletedAt.isNull())).get();
    final ruleRows = await (_database.select(
      _database.reminderRules,
    )..where((tbl) => tbl.deletedAt.isNull())).get();
    final desired = await _desiredPlans(
      settings: settings,
      deviceTimeZone: status.deviceTimeZone,
      nowUtc: _clock.now(),
    );
    final pending = await _notificationService.pendingNotifications();
    final scheduled = await _scheduledRepository.readAllRegistered();

    final profileRows = await (_database.select(
      _database.profiles,
    )..where((tbl) => tbl.deletedAt.isNull())).get();
    final personIdByProfileId = <String, String>{
      for (final profile in profileRows) profile.id: profile.personId,
    };
    final notesByPerson = <String, List<Note>>{};
    for (final row in noteRows) {
      final personId = personIdByProfileId[row.profileId];
      if (personId == null) continue;
      notesByPerson.putIfAbsent(personId, () => []).add(_mapNote(row));
    }

    final ruleModels = ruleRows.map(_mapReminderRule).toList(growable: false);
    final peopleDebug = <NotificationDebugPerson>[];
    for (final row in peopleRows) {
      final person = _mapPerson(row);
      final occurrence = _safeOccurrence(
        person: person,
        deviceTimeZone: status.deviceTimeZone,
        nowUtc: _clock.now(),
      );
      if (occurrence == null) {
        continue;
      }
      final personRules = _rulesForPerson(ruleModels, person.id);
      final plans = _reminderPlanner.planForPerson(
        person: person,
        occurrence: occurrence,
        rules: personRules,
        notes: notesByPerson[person.id] ?? const <Note>[],
        notificationsEnabled: settings.notificationsEnabled,
        showDetailsOnLockScreen: settings.showDetailsOnLockScreen,
        nowUtc: _clock.now(),
      );
      peopleDebug.add(
        NotificationDebugPerson(
          personId: person.id,
          displayName: person.displayName,
          occurrence: occurrence,
          plans: plans,
        ),
      );
    }

    peopleDebug.sort(
      (a, b) => a.occurrence.anchorUtc.compareTo(b.occurrence.anchorUtc),
    );

    return NotificationDebugSnapshot(
      status: status,
      pending: pending,
      scheduled: scheduled,
      desiredPlans: desired,
      people: peopleDebug,
    );
  }

  Future<List<NotificationPlan>> _desiredPlans({
    required AppSettings settings,
    required String deviceTimeZone,
    required DateTime nowUtc,
  }) async {
    final peopleRows = await (_database.select(
      _database.people,
    )..where((tbl) => tbl.deletedAt.isNull())).get();
    final noteRows = await (_database.select(
      _database.notes,
    )..where((tbl) => tbl.deletedAt.isNull())).get();
    final ruleRows = await (_database.select(
      _database.reminderRules,
    )..where((tbl) => tbl.deletedAt.isNull())).get();

    final profileRows = await (_database.select(
      _database.profiles,
    )..where((tbl) => tbl.deletedAt.isNull())).get();
    final personIdByProfileId = <String, String>{
      for (final profile in profileRows) profile.id: profile.personId,
    };
    final notesByPerson = <String, List<Note>>{};
    for (final row in noteRows) {
      final personId = personIdByProfileId[row.profileId];
      if (personId == null) continue;
      notesByPerson.putIfAbsent(personId, () => []).add(_mapNote(row));
    }
    final ruleModels = ruleRows.map(_mapReminderRule).toList(growable: false);

    final allPlans = <NotificationPlan>[];
    for (final row in peopleRows) {
      final person = _mapPerson(row);
      final occurrence = _safeOccurrence(
        person: person,
        deviceTimeZone: deviceTimeZone,
        nowUtc: nowUtc,
      );
      if (occurrence == null) {
        continue;
      }
      allPlans.addAll(
        _reminderPlanner.planForPerson(
          person: person,
          occurrence: occurrence,
          rules: _rulesForPerson(ruleModels, person.id),
          notes: notesByPerson[person.id] ?? const <Note>[],
          notificationsEnabled: settings.notificationsEnabled,
          showDetailsOnLockScreen: settings.showDetailsOnLockScreen,
          nowUtc: nowUtc,
        ),
      );
    }
    allPlans.sort((a, b) => a.fireAtUtc.compareTo(b.fireAtUtc));
    return allPlans;
  }

  List<ReminderRule> _rulesForPerson(
    List<ReminderRule> rules,
    String personId,
  ) {
    return rules
        .where((rule) => rule.personId == null || rule.personId == personId)
        .toList(growable: false);
  }

  BirthdayOccurrence? _safeOccurrence({
    required Person person,
    required String deviceTimeZone,
    required DateTime nowUtc,
  }) {
    try {
      return _occurrenceCalculator.next(
        date: person.birthday,
        personTimeZone: person.location?.timezone?.ianaName,
        nowUtc: nowUtc,
        deviceTimeZone: deviceTimeZone,
      );
    } on Object catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Skipping invalid occurrence for ${person.id}: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      return null;
    }
  }

  Person _mapPerson(db.PeopleData row) {
    final location = row.placeLabel == null && row.ianaTimezone == null
        ? null
        : LocationModel(
            label: row.placeLabel ?? '',
            timezone: row.ianaTimezone == null
                ? null
                : TimezoneModel(row.ianaTimezone!),
          );
    return Person(
      id: row.id,
      displayName: row.displayName,
      birthday: PartialDate(
        month: row.birthMonth,
        day: row.birthDay,
        year: row.birthYear,
      ),
      location: location,
      sortKey: row.sortKey,
      createdAt: _fromMillis(row.createdAt),
      updatedAt: _fromMillis(row.updatedAt),
      deletedAt: row.deletedAt == null ? null : _fromMillis(row.deletedAt!),
      syncRev: row.syncRev,
    );
  }

  Note _mapNote(db.Note row) {
    return Note(
      id: row.id,
      profileId: row.profileId,
      kind: NoteKind.fromStorage(row.kind),
      label: row.kindLabel,
      value: row.value,
      isRetired: row.isRetired,
      position: row.position,
      createdAt: _fromMillis(row.createdAt),
      updatedAt: _fromMillis(row.updatedAt),
      deletedAt: row.deletedAt == null ? null : _fromMillis(row.deletedAt!),
      syncRev: row.syncRev,
    );
  }

  ReminderRule _mapReminderRule(db.ReminderRule row) {
    return ReminderRule(
      id: row.id,
      personId: row.personId,
      kind: ReminderRuleKind.fromStorage(row.kind),
      offsetDays: row.offsetDays,
      localTime: row.localTime,
      enabled: row.enabled,
      updatedAt: _fromMillis(row.updatedAt),
      deletedAt: row.deletedAt == null ? null : _fromMillis(row.deletedAt!),
      syncRev: row.syncRev,
    );
  }

  DateTime _fromMillis(int value) {
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }
}

@immutable
class NotificationRuntimeStatus {
  const NotificationRuntimeStatus({
    required this.notificationsEnabled,
    required this.notificationPermission,
    required this.exactAlarmPermission,
    required this.deviceTimeZone,
    required this.pendingCount,
    required this.plannedCount,
    required this.lastReconciledAt,
  });

  final bool notificationsEnabled;
  final AndroidCapabilityState notificationPermission;
  final AndroidCapabilityState exactAlarmPermission;
  final String deviceTimeZone;
  final int pendingCount;
  final int plannedCount;
  final DateTime? lastReconciledAt;
}

@immutable
class NotificationDebugSnapshot {
  const NotificationDebugSnapshot({
    required this.status,
    required this.pending,
    required this.scheduled,
    required this.desiredPlans,
    required this.people,
  });

  final NotificationRuntimeStatus status;
  final List<PendingPlatformNotification> pending;
  final List<ScheduledNotificationRecord> scheduled;
  final List<NotificationPlan> desiredPlans;
  final List<NotificationDebugPerson> people;
}

@immutable
class NotificationDebugPerson {
  const NotificationDebugPerson({
    required this.personId,
    required this.displayName,
    required this.occurrence,
    required this.plans,
  });

  final String personId;
  final String displayName;
  final BirthdayOccurrence occurrence;
  final List<NotificationPlan> plans;
}
