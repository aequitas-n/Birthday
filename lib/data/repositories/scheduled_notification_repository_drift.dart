import 'package:drift/drift.dart';
import 'package:kin/data/local/database/kin_database.dart';
import 'package:kin/data/repositories/scheduled_notification_snapshot.dart';
import 'package:kin/domain/models/notification_plan.dart';
import 'package:kin/domain/models/scheduled_notification_record.dart';
import 'package:kin/domain/repositories/scheduled_notification_repository.dart';

class DriftScheduledNotificationRepository
    implements ScheduledNotificationRepository {
  DriftScheduledNotificationRepository(this._database);

  final KinDatabase _database;

  @override
  Future<List<ScheduledNotificationRecord>> readAllRegistered() async {
    final rows =
        await (_database.select(_database.scheduledNotifications)..where(
              (tbl) => tbl.state.equals(
                ScheduledNotificationState.registered.storageValue,
              ),
            ))
            .get();
    return rows.map(_mapRecord).toList(growable: false);
  }

  @override
  Future<List<ScheduledNotificationRecord>> readRegisteredFuture({
    required DateTime nowUtc,
  }) async {
    final rows =
        await (_database.select(_database.scheduledNotifications)..where(
              (tbl) =>
                  tbl.state.equals(
                    ScheduledNotificationState.registered.storageValue,
                  ) &
                  tbl.fireAtUtc.isBiggerThanValue(
                    nowUtc.toUtc().millisecondsSinceEpoch,
                  ),
            ))
            .get();
    return rows.map(_mapRecord).toList(growable: false);
  }

  @override
  Future<List<NotificationPlan>> readActivePlans({
    required DateTime nowUtc,
  }) async {
    final records = await readRegisteredFuture(nowUtc: nowUtc);
    return records.map((record) => record.toPlan()).toList(growable: false);
  }

  @override
  Future<void> upsertRegistered({
    required NotificationPlan plan,
    required String deviceTimeZone,
    required DateTime createdAt,
  }) async {
    final snapshot = encodeScheduleSnapshot(plan);
    final deviceLocal = _deviceLocalMillis(plan.targetLocalInstant);

    await _database
        .into(_database.scheduledNotifications)
        .insertOnConflictUpdate(
          ScheduledNotificationsCompanion.insert(
            osId: Value(plan.stableId),
            source: Value(plan.source.storageValue),
            personId: Value(plan.personId),
            ruleId: Value(plan.ruleId),
            reminderId: Value(plan.reminderId),
            occurrenceYear: plan.occurrenceYear,
            fireAtUtc: plan.fireAtUtc.toUtc().millisecondsSinceEpoch,
            fireAtDeviceLocal: deviceLocal,
            deviceTz: deviceTimeZone,
            title: plan.title,
            body: plan.body,
            state: ScheduledNotificationState.registered.storageValue,
            createdAt: createdAt.toUtc().millisecondsSinceEpoch,
            snapshotJson: Value(snapshot),
          ),
        );
  }

  @override
  Future<void> markStale(int osId) async {
    await (_database.update(
      _database.scheduledNotifications,
    )..where((tbl) => tbl.osId.equals(osId))).write(
      ScheduledNotificationsCompanion(
        state: Value(ScheduledNotificationState.stale.storageValue),
      ),
    );
  }

  @override
  Future<void> markStaleAll(Iterable<int> osIds) async {
    final ids = osIds.toList(growable: false);
    if (ids.isEmpty) return;

    await (_database.update(
      _database.scheduledNotifications,
    )..where((tbl) => tbl.osId.isIn(ids))).write(
      ScheduledNotificationsCompanion(
        state: Value(ScheduledNotificationState.stale.storageValue),
      ),
    );
  }

  @override
  Future<ScheduledNotificationRecord?> readByOsId(int osId) async {
    final row = await (_database.select(
      _database.scheduledNotifications,
    )..where((tbl) => tbl.osId.equals(osId))).getSingleOrNull();
    return row == null ? null : _mapRecord(row);
  }

  ScheduledNotificationRecord _mapRecord(ScheduledNotification row) {
    final snapshot = decodeScheduleSnapshot(row.snapshotJson);
    final targetJson =
        snapshot['targetLocalInstant'] as Map<String, dynamic>? ?? {};
    final payloadJson = snapshot['payload'] as Map<String, dynamic>? ?? {};
    final source = NotificationPlanSource.fromStorage(
      row.source.isEmpty
          ? (snapshot['source'] as String? ?? 'birthday')
          : row.source,
    );

    return ScheduledNotificationRecord(
      osId: row.osId,
      source: source,
      personId: row.personId,
      ruleId: row.ruleId,
      reminderId: row.reminderId,
      occurrenceYear: row.occurrenceYear,
      fireAtUtc: DateTime.fromMillisecondsSinceEpoch(
        row.fireAtUtc,
        isUtc: true,
      ),
      targetLocalInstant: decodeTargetLocalInstant(targetJson),
      deviceTimeZone: row.deviceTz,
      kind: decodePlanKind(snapshot['kind'] as String? ?? ''),
      payload: decodePayloadMap(payloadJson),
      title: row.title,
      body: row.body,
      hidesSensitivePreview:
          snapshot['hidesSensitivePreview'] as bool? ?? false,
      state: ScheduledNotificationState.fromStorage(row.state),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row.createdAt,
        isUtc: true,
      ),
      noteIdUsed: row.noteIdUsed,
    );
  }

  int _deviceLocalMillis(LocalScheduledMoment moment) {
    return DateTime.utc(
      moment.year,
      moment.month,
      moment.day,
      moment.hour,
      moment.minute,
      moment.second,
    ).millisecondsSinceEpoch;
  }
}
