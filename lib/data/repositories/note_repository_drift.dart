import 'package:drift/drift.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/core/id.dart';
import 'package:kin/data/local/database/kin_database.dart';
import 'package:kin/domain/models/note.dart' as domain;
import 'package:kin/domain/repositories/note_repository.dart';

class DriftNoteRepository implements NoteRepository {
  DriftNoteRepository(this._database, this._ids, this._clock);

  final KinDatabase _database;
  final IdGenerator _ids;
  final Clock _clock;

  @override
  Stream<List<domain.Note>> watchForPerson(String personId) {
    final query =
        _database.select(_database.notes).join([
            innerJoin(
              _database.profiles,
              _database.profiles.id.equalsExp(_database.notes.profileId),
            ),
          ])
          ..where(
            _database.profiles.personId.equals(personId) &
                _database.notes.deletedAt.isNull() &
                _database.profiles.deletedAt.isNull(),
          )
          ..orderBy([OrderingTerm.asc(_database.notes.position)]);
    return query.watch().map(
      (rows) => rows
          .map((row) => _mapNote(row.readTable(_database.notes)))
          .toList(growable: false),
    );
  }

  @override
  Stream<List<domain.Note>> watchForProfile(String profileId) {
    final query = _database.select(_database.notes)
      ..where((tbl) => tbl.profileId.equals(profileId) & tbl.deletedAt.isNull())
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.position)]);
    return query.watch().map(
      (rows) => rows.map(_mapNote).toList(growable: false),
    );
  }

  @override
  Future<domain.Note> save(domain.Note note) async {
    final now = _clock.now();
    final existing = note.id.isEmpty
        ? null
        : await (_database.select(
            _database.notes,
          )..where((tbl) => tbl.id.equals(note.id))).getSingleOrNull();
    final id = existing?.id ?? (note.id.isEmpty ? _ids.next() : note.id);
    final createdAt = existing == null
        ? note.createdAt
        : _fromMillis(existing.createdAt);
    final companion = NotesCompanion.insert(
      id: id,
      profileId: note.profileId,
      kind: note.kind.storageValue,
      kindLabel: Value(_cleanText(note.label)),
      value: note.value.trim(),
      isRetired: Value(note.isRetired),
      position: note.position,
      createdAt: _toMillis(createdAt),
      updatedAt: _toMillis(now),
      deletedAt: const Value(null),
      syncRev: Value((existing?.syncRev ?? note.syncRev) + 1),
    );
    await _database.into(_database.notes).insertOnConflictUpdate(companion);
    final saved = await (_database.select(
      _database.notes,
    )..where((tbl) => tbl.id.equals(id))).getSingle();
    return _mapNote(saved);
  }

  @override
  Future<void> retire(String id, {required bool value}) async {
    await (_database.update(
      _database.notes,
    )..where((tbl) => tbl.id.equals(id))).write(
      NotesCompanion(
        isRetired: Value(value),
        updatedAt: Value(_toMillis(_clock.now())),
      ),
    );
  }

  @override
  Future<void> reorder({
    required String profileId,
    required List<String> noteIdsInOrder,
  }) async {
    final now = _toMillis(_clock.now());
    await _database.batch((batch) {
      for (var index = 0; index < noteIdsInOrder.length; index++) {
        batch.update(
          _database.notes,
          NotesCompanion(position: Value(index), updatedAt: Value(now)),
          where: (tbl) =>
              tbl.id.equals(noteIdsInOrder[index]) &
              tbl.profileId.equals(profileId),
        );
      }
    });
  }

  @override
  Future<void> softDelete(String id) async {
    final now = _toMillis(_clock.now());
    await (_database.update(_database.notes)..where((tbl) => tbl.id.equals(id)))
        .write(NotesCompanion(deletedAt: Value(now), updatedAt: Value(now)));
  }

  domain.Note _mapNote(Note row) {
    return domain.Note(
      id: row.id,
      profileId: row.profileId,
      kind: domain.NoteKind.fromStorage(row.kind),
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

  static DateTime _fromMillis(int value) =>
      DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);

  static int _toMillis(DateTime value) => value.toUtc().millisecondsSinceEpoch;

  static String? _cleanText(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
