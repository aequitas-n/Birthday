import 'package:drift/drift.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/core/id.dart';
import 'package:kin/data/local/database/kin_database.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/domain/models/local_clock_time.dart';
import 'package:kin/domain/models/personal_reminder.dart';
import 'package:kin/domain/models/reminder_day_part.dart';
import 'package:kin/domain/repositories/personal_reminder_repository.dart';

class DriftPersonalReminderRepository implements PersonalReminderRepository {
  DriftPersonalReminderRepository(
    this._database,
    this._ids,
    this._clock,
  );

  final KinDatabase _database;
  final IdGenerator _ids;
  final Clock _clock;

  @override
  Stream<List<PersonalReminder>> watchForDate(LocalCalendarDate date) {
    final query = _database.select(_database.personalReminders)
      ..where(
        (tbl) => tbl.localDate.equals(date.storageKey) & tbl.deletedAt.isNull(),
      )
      ..orderBy([
        (tbl) => OrderingTerm.asc(tbl.position),
        (tbl) => OrderingTerm.asc(tbl.localTime),
      ]);
    return query.watch().map(
      (rows) => rows.map(_map).toList(growable: false),
    );
  }

  @override
  Future<List<PersonalReminder>> readForDate(LocalCalendarDate date) async {
    final rows =
        await (_database.select(_database.personalReminders)
              ..where(
                (tbl) =>
                    tbl.localDate.equals(date.storageKey) &
                    tbl.deletedAt.isNull(),
              )
              ..orderBy([
                (tbl) => OrderingTerm.asc(tbl.position),
                (tbl) => OrderingTerm.asc(tbl.localTime),
              ]))
            .get();
    return rows.map(_map).toList(growable: false);
  }

  @override
  Future<List<PersonalReminder>> readLiveFutureAndToday({
    required LocalCalendarDate today,
  }) async {
    final rows =
        await (_database.select(_database.personalReminders)
              ..where((tbl) => tbl.deletedAt.isNull())
              ..orderBy([
                (tbl) => OrderingTerm.asc(tbl.localDate),
                (tbl) => OrderingTerm.asc(tbl.localTime),
              ]))
            .get();
    return [
      for (final row in rows)
        if (LocalCalendarDate.parseStorage(row.localDate).compareTo(today) >= 0)
          _map(row),
    ];
  }

  @override
  Future<PersonalReminder?> readById(String id) async {
    final row = await (_database.select(
      _database.personalReminders,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    return row == null ? null : _map(row);
  }

  @override
  Future<PersonalReminder> upsert(PersonalReminder reminder) async {
    final now = _clock.now();
    final id = reminder.id.isEmpty ? _ids.next() : reminder.id;
    final existing = await readById(id);
    final createdAt = existing?.createdAt ?? now;
    final position =
        existing?.position ??
        await _nextPosition(reminder.localDate, reminder.dayPart);

    final saved = reminder.copyWith(
      id: id,
      position: position,
      createdAt: createdAt,
      updatedAt: now,
      deletedAt: null,
    );

    await _database
        .into(_database.personalReminders)
        .insertOnConflictUpdate(
          PersonalRemindersCompanion.insert(
            id: saved.id,
            localDate: saved.localDate.storageKey,
            localTime: saved.localTime.storageValue,
            dayPart: saved.dayPart.storageValue,
            body: saved.text.trim(),
            timezone: saved.timezone,
            position: saved.position,
            createdAt: saved.createdAt.toUtc().millisecondsSinceEpoch,
            updatedAt: saved.updatedAt.toUtc().millisecondsSinceEpoch,
            deletedAt: const Value(null),
          ),
        );
    return saved;
  }

  @override
  Future<void> softDelete(String id) async {
    final now = _clock.now().toUtc().millisecondsSinceEpoch;
    await (_database.update(
      _database.personalReminders,
    )..where((tbl) => tbl.id.equals(id))).write(
      PersonalRemindersCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> updateTimezoneForAllLive(String ianaTimezone) async {
    final now = _clock.now().toUtc().millisecondsSinceEpoch;
    await (_database.update(
      _database.personalReminders,
    )..where((tbl) => tbl.deletedAt.isNull())).write(
      PersonalRemindersCompanion(
        timezone: Value(ianaTimezone),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> _nextPosition(
    LocalCalendarDate date,
    ReminderDayPart dayPart,
  ) async {
    final rows =
        await (_database.select(_database.personalReminders)..where(
              (tbl) =>
                  tbl.localDate.equals(date.storageKey) &
                  tbl.dayPart.equals(dayPart.storageValue) &
                  tbl.deletedAt.isNull(),
            ))
            .get();
    var max = -1;
    for (final row in rows) {
      if (row.position > max) max = row.position;
    }
    return max + 1;
  }

  PersonalReminder _map(PersonalReminderRow row) {
    return PersonalReminder(
      id: row.id,
      localDate: LocalCalendarDate.parseStorage(row.localDate),
      localTime: LocalClockTime.parseStorage(row.localTime),
      dayPart: ReminderDayPart.fromStorage(row.dayPart),
      text: row.body,
      timezone: row.timezone,
      position: row.position,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row.createdAt,
        isUtc: true,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        row.updatedAt,
        isUtc: true,
      ),
      deletedAt: row.deletedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row.deletedAt!, isUtc: true),
    );
  }
}
