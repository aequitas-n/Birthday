import 'package:drift/drift.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/core/id.dart';
import 'package:kin/data/local/database/kin_database.dart';
import 'package:kin/domain/models/profile.dart';
import 'package:kin/domain/repositories/profile_repository.dart';

class DriftProfileRepository implements ProfileRepository {
  DriftProfileRepository(this._database, this._ids, this._clock);

  final KinDatabase _database;
  final IdGenerator _ids;
  final Clock _clock;

  @override
  Stream<List<RelationshipProfile>> watchAll() {
    final query = _database.select(_database.profiles)
      ..where((tbl) => tbl.deletedAt.isNull());
    return query.watch().map(
      (rows) => rows.map(_mapProfile).toList(growable: false),
    );
  }

  @override
  Stream<RelationshipProfile?> watchForPerson(String personId) {
    final query = _database.select(_database.profiles)
      ..where((tbl) => tbl.personId.equals(personId) & tbl.deletedAt.isNull());
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapProfile(row),
    );
  }

  @override
  Future<RelationshipProfile?> readForPerson(String personId) async {
    final row =
        await (_database.select(_database.profiles)..where(
              (tbl) => tbl.personId.equals(personId) & tbl.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    return row == null ? null : _mapProfile(row);
  }

  @override
  Future<RelationshipProfile> save(RelationshipProfile profile) async {
    final now = _clock.now();
    final existingById = profile.id.isEmpty
        ? null
        : await (_database.select(
            _database.profiles,
          )..where((tbl) => tbl.id.equals(profile.id))).getSingleOrNull();
    final existingByPerson = existingById == null
        ? await (_database.select(_database.profiles)
                ..where((tbl) => tbl.personId.equals(profile.personId)))
              .getSingleOrNull()
        : null;
    final existing = existingById ?? existingByPerson;
    final id = existing?.id ?? (profile.id.isEmpty ? _ids.next() : profile.id);
    final createdAt = existing == null
        ? profile.createdAt
        : _fromMillis(existing.createdAt);
    final companion = ProfilesCompanion.insert(
      id: id,
      personId: profile.personId,
      nickname: Value(_cleanText(profile.nickname)),
      relationship: Value(profile.relationship?.name),
      relationshipLabel: Value(_cleanText(profile.relationshipLabel)),
      photoId: Value(_cleanText(profile.photoId)),
      isPinned: Value(profile.isPinned),
      createdAt: _toMillis(createdAt),
      updatedAt: _toMillis(now),
      deletedAt: const Value(null),
      syncRev: Value((existing?.syncRev ?? profile.syncRev) + 1),
    );
    await _database.into(_database.profiles).insertOnConflictUpdate(companion);
    final saved = await (_database.select(
      _database.profiles,
    )..where((tbl) => tbl.id.equals(id))).getSingle();
    return _mapProfile(saved);
  }

  @override
  Future<void> softDelete(String id) async {
    final now = _toMillis(_clock.now());
    await (_database.update(_database.profiles)
          ..where((tbl) => tbl.id.equals(id)))
        .write(ProfilesCompanion(deletedAt: Value(now), updatedAt: Value(now)));
  }

  RelationshipProfile _mapProfile(Profile row) {
    return RelationshipProfile(
      id: row.id,
      personId: row.personId,
      nickname: row.nickname,
      relationship: RelationshipKind.fromStorage(row.relationship),
      relationshipLabel: row.relationshipLabel,
      photoId: row.photoId,
      isPinned: row.isPinned,
      createdAt: _fromMillis(row.createdAt),
      updatedAt: _fromMillis(row.updatedAt),
      deletedAt: row.deletedAt == null ? null : _fromMillis(row.deletedAt!),
      syncRev: row.syncRev,
    );
  }

  static String? _cleanText(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static DateTime _fromMillis(int value) =>
      DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);

  static int _toMillis(DateTime value) => value.toUtc().millisecondsSinceEpoch;
}
