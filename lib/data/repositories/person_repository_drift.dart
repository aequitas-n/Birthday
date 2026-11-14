import 'package:drift/drift.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/core/id.dart';
import 'package:kin/data/local/database/kin_database.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/domain/repositories/person_repository.dart';

class DriftPersonRepository implements PersonRepository {
  DriftPersonRepository(this._database, this._ids, this._clock);

  final KinDatabase _database;
  final IdGenerator _ids;
  final Clock _clock;

  @override
  Stream<List<Person>> watchAll() {
    final query = _database.select(_database.people)
      ..where((tbl) => tbl.deletedAt.isNull())
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortKey)]);
    return query.watch().map(
      (rows) => rows.map(_mapPerson).toList(growable: false),
    );
  }

  @override
  Stream<Person?> watchById(String id) {
    final query = _database.select(_database.people)
      ..where((tbl) => tbl.id.equals(id) & tbl.deletedAt.isNull());
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapPerson(row),
    );
  }

  @override
  Future<Person> save(Person person) async {
    final now = _clock.now();
    final existing = person.id.isEmpty
        ? null
        : await (_database.select(
            _database.people,
          )..where((tbl) => tbl.id.equals(person.id))).getSingleOrNull();
    final id = existing?.id ?? (person.id.isEmpty ? _ids.next() : person.id);
    final createdAt = existing == null
        ? person.createdAt
        : _fromMillis(existing.createdAt);
    final companion = PeopleCompanion.insert(
      id: id,
      displayName: person.displayName.trim(),
      birthMonth: person.birthday.month,
      birthDay: person.birthday.day,
      birthYear: Value(person.birthday.year),
      placeLabel: Value(_cleanText(person.location?.label)),
      ianaTimezone: Value(person.location?.timezone?.ianaName),
      sortKey: _normalizeSortKey(person.displayName),
      createdAt: _toMillis(
        existing == null ? createdAt : _fromMillis(existing.createdAt),
      ),
      updatedAt: _toMillis(now),
      deletedAt: const Value(null),
      syncRev: Value((existing?.syncRev ?? person.syncRev) + 1),
    );
    await _database.into(_database.people).insertOnConflictUpdate(companion);
    final saved = await (_database.select(
      _database.people,
    )..where((tbl) => tbl.id.equals(id))).getSingle();
    return _mapPerson(saved);
  }

  @override
  Future<void> softDelete(String id) async {
    final now = _toMillis(_clock.now());
    final profileRows = await (_database.select(
      _database.profiles,
    )..where((tbl) => tbl.personId.equals(id))).get();
    final profileIds = profileRows.map((row) => row.id).toList(growable: false);

    if (profileIds.isNotEmpty) {
      await (_database.update(
        _database.notes,
      )..where((tbl) => tbl.profileId.isIn(profileIds))).write(
        NotesCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    }

    await (_database.update(
      _database.profiles,
    )..where((tbl) => tbl.personId.equals(id))).write(
      ProfilesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    await (_database.update(_database.people)
          ..where((tbl) => tbl.id.equals(id)))
        .write(PeopleCompanion(deletedAt: Value(now), updatedAt: Value(now)));
  }

  @override
  Future<void> restore(String id) async {
    final now = _toMillis(_clock.now());
    await (_database.update(
      _database.people,
    )..where((tbl) => tbl.id.equals(id))).write(
      PeopleCompanion(deletedAt: const Value(null), updatedAt: Value(now)),
    );
  }

  @override
  Future<List<Person>> search(String query) async {
    final normalized = _normalizeSortKey(query);
    if (normalized.isEmpty) return const [];
    final rows =
        await (_database.select(_database.people)
              ..where((tbl) => tbl.deletedAt.isNull())
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortKey)]))
            .get();
    return rows
        .where(
          (row) =>
              row.sortKey.contains(normalized) ||
              (row.placeLabel?.toLowerCase().contains(normalized) ?? false),
        )
        .map(_mapPerson)
        .toList(growable: false);
  }

  Person _mapPerson(PeopleData row) {
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

  static String _normalizeSortKey(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String? _cleanText(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static DateTime _fromMillis(int value) =>
      DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);

  static int _toMillis(DateTime value) => value.toUtc().millisecondsSinceEpoch;
}
