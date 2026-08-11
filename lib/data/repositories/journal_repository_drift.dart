import 'package:drift/drift.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/core/id.dart';
import 'package:kin/data/local/database/kin_database.dart';
import 'package:kin/data/local/files/audio_store.dart';
import 'package:kin/domain/models/journal_day.dart';
import 'package:kin/domain/models/journal_entry.dart';
import 'package:kin/domain/models/journal_entry_photo.dart';
import 'package:kin/domain/models/journal_fragment.dart';
import 'package:kin/domain/models/journal_fragment_ops.dart';
import 'package:kin/domain/models/journal_mood.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/domain/repositories/journal_repository.dart';

class DriftJournalRepository implements JournalRepository {
  DriftJournalRepository(
    this._database,
    this._ids,
    this._clock, {
    AudioStore audioStore = const LocalAudioStore(),
  }) : _audioStore = audioStore;

  final KinDatabase _database;
  final IdGenerator _ids;
  final Clock _clock;
  final AudioStore _audioStore;

  @override
  Stream<JournalDay?> watchDay(LocalCalendarDate date) {
    final query = _database.select(_database.journalDays)
      ..where(
        (tbl) => tbl.localDate.equals(date.storageKey) & tbl.deletedAt.isNull(),
      );
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapDay(row),
    );
  }

  @override
  Stream<List<JournalDayMarker>> watchMonthMarkers({
    required int year,
    required int month,
  }) {
    final prefix =
        '${year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}-';
    final dayQuery = _database.select(_database.journalDays)
      ..where(
        (tbl) => tbl.localDate.like('$prefix%') & tbl.deletedAt.isNull(),
      );
    final entryQuery = _database.select(_database.journalEntries)
      ..where(
        (tbl) => tbl.localDate.like('$prefix%') & tbl.deletedAt.isNull(),
      );

    return entryQuery.watch().asyncMap((entryRows) async {
      final dayRows = await dayQuery.get();
      return _buildMonthMarkers(dayRows, entryRows);
    });
  }

  List<JournalDayMarker> _buildMonthMarkers(
    List<JournalDayRow> dayRows,
    List<JournalEntryRow> entryRows,
  ) {
    final moodByDate = {
      for (final row in dayRows)
        row.localDate: JournalMood.fromStorage(row.mood),
    };
    final counts = <String, int>{};
    for (final row in entryRows) {
      counts[row.localDate] = (counts[row.localDate] ?? 0) + 1;
    }
    final allDates = {...moodByDate.keys, ...counts.keys};
    final markers = <JournalDayMarker>[];
    for (final key in allDates) {
      final date = LocalCalendarDate.parseStorage(key);
      final count = counts[key] ?? 0;
      markers.add(
        JournalDayMarker(
          localDate: date,
          entryCount: count,
          hasEntries: count > 0,
          dayMood: moodByDate[key],
        ),
      );
    }
    markers.sort((a, b) => a.localDate.compareTo(b.localDate));
    return markers;
  }

  @override
  Future<JournalDay> upsertDay(JournalDay day) async {
    final now = _clock.now();
    final existing =
        await (_database.select(
              _database.journalDays,
            )..where((tbl) => tbl.localDate.equals(day.localDate.storageKey)))
            .getSingleOrNull();

    final createdAt = existing == null
        ? day.createdAt
        : _fromMillis(existing.createdAt);
    final companion = JournalDaysCompanion.insert(
      localDate: day.localDate.storageKey,
      mood: Value(day.mood?.storageValue),
      createdAt: _toMillis(createdAt),
      updatedAt: _toMillis(now),
      deletedAt: const Value(null),
    );
    await _database
        .into(_database.journalDays)
        .insertOnConflictUpdate(companion);
    final saved =
        await (_database.select(
              _database.journalDays,
            )..where((tbl) => tbl.localDate.equals(day.localDate.storageKey)))
            .getSingle();
    return _mapDay(saved);
  }

  @override
  Stream<List<JournalEntry>> watchEntriesForDay(LocalCalendarDate date) {
    final query = _database.select(_database.journalEntries)
      ..where(
        (tbl) => tbl.localDate.equals(date.storageKey) & tbl.deletedAt.isNull(),
      )
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.position)]);
    return query.watch().map(
      (rows) => rows.map(_mapEntry).toList(growable: false),
    );
  }

  @override
  Stream<JournalEntry?> watchEntry(String id) {
    final query = _database.select(_database.journalEntries)
      ..where((tbl) => tbl.id.equals(id) & tbl.deletedAt.isNull());
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapEntry(row),
    );
  }

  @override
  Future<JournalEntry> saveEntry(JournalEntry entry) async {
    final now = _clock.now();
    await _ensureDayExists(entry.localDate, now);
    final existing = entry.id.isEmpty
        ? null
        : await (_database.select(
            _database.journalEntries,
          )..where((tbl) => tbl.id.equals(entry.id))).getSingleOrNull();
    final id = existing?.id ?? (entry.id.isEmpty ? _ids.next() : entry.id);
    final createdAt = existing == null
        ? entry.createdAt
        : _fromMillis(existing.createdAt);

    // body is a preview cache: if fragments already exist, regenerate it.
    var body = entry.body.trim();
    if (existing != null) {
      final liveFragments = await _liveFragments(id);
      if (liveFragments.isNotEmpty) {
        body = JournalFragment.previewBodyFrom(liveFragments);
      }
    }

    final companion = JournalEntriesCompanion.insert(
      id: id,
      localDate: entry.localDate.storageKey,
      title: entry.title.trim(),
      body: body,
      mood: Value(entry.mood?.storageValue),
      position: entry.position,
      createdAt: _toMillis(createdAt),
      updatedAt: _toMillis(now),
      deletedAt: const Value(null),
    );
    await _database
        .into(_database.journalEntries)
        .insertOnConflictUpdate(companion);
    final saved = await (_database.select(
      _database.journalEntries,
    )..where((tbl) => tbl.id.equals(id))).getSingle();
    return _mapEntry(saved);
  }

  @override
  Future<void> softDeleteEntry(String id) async {
    final now = _clock.now();
    final audioPaths = await _audioPathsForEntry(id);
    await (_database.update(
      _database.journalEntries,
    )..where((tbl) => tbl.id.equals(id))).write(
      JournalEntriesCompanion(
        deletedAt: Value(_toMillis(now)),
        updatedAt: Value(_toMillis(now)),
      ),
    );
    await (_database.update(
      _database.journalEntryFragments,
    )..where((tbl) => tbl.entryId.equals(id) & tbl.deletedAt.isNull())).write(
      JournalEntryFragmentsCompanion(
        deletedAt: Value(_toMillis(now)),
        updatedAt: Value(_toMillis(now)),
      ),
    );
    await (_database.update(
      _database.journalEntryPhotos,
    )..where((tbl) => tbl.entryId.equals(id) & tbl.deletedAt.isNull())).write(
      JournalEntryPhotosCompanion(
        deletedAt: Value(_toMillis(now)),
        updatedAt: Value(_toMillis(now)),
      ),
    );
    await _purgeAudioPaths(audioPaths);
  }

  @override
  Stream<List<JournalEntryPhoto>> watchPhotosForEntry(String entryId) {
    final query = _database.select(_database.journalEntryPhotos)
      ..where(
        (tbl) => tbl.entryId.equals(entryId) & tbl.deletedAt.isNull(),
      )
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.position)]);
    return query.watch().map(
      (rows) => rows.map(_mapPhoto).toList(growable: false),
    );
  }

  @override
  Future<JournalEntryPhoto> saveEntryPhoto(JournalEntryPhoto photo) async {
    final now = _clock.now();
    final existing = photo.id.isEmpty
        ? null
        : await (_database.select(
            _database.journalEntryPhotos,
          )..where((tbl) => tbl.id.equals(photo.id))).getSingleOrNull();
    final id = existing?.id ?? (photo.id.isEmpty ? _ids.next() : photo.id);
    final createdAt = existing == null
        ? photo.createdAt
        : _fromMillis(existing.createdAt);
    final companion = JournalEntryPhotosCompanion.insert(
      id: id,
      entryId: photo.entryId,
      photoId: photo.photoId,
      caption: Value(_cleanText(photo.caption)),
      position: photo.position,
      createdAt: _toMillis(createdAt),
      updatedAt: _toMillis(now),
      deletedAt: const Value(null),
    );
    await _database
        .into(_database.journalEntryPhotos)
        .insertOnConflictUpdate(companion);
    final saved = await (_database.select(
      _database.journalEntryPhotos,
    )..where((tbl) => tbl.id.equals(id))).getSingle();
    return _mapPhoto(saved);
  }

  @override
  Future<void> softDeleteEntryPhoto(String id) async {
    final now = _clock.now();
    await (_database.update(
      _database.journalEntryPhotos,
    )..where((tbl) => tbl.id.equals(id))).write(
      JournalEntryPhotosCompanion(
        deletedAt: Value(_toMillis(now)),
        updatedAt: Value(_toMillis(now)),
      ),
    );
  }

  @override
  Stream<List<JournalFragment>> watchFragmentsForEntry(String entryId) {
    final query = _database.select(_database.journalEntryFragments)
      ..where(
        (tbl) => tbl.entryId.equals(entryId) & tbl.deletedAt.isNull(),
      )
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.position)]);
    return query.watch().map(
      (rows) => rows.map(_mapFragment).toList(growable: false),
    );
  }

  @override
  Future<JournalFragment> saveFragment(JournalFragment fragment) async {
    final now = _clock.now();
    final existing = fragment.id.isEmpty
        ? null
        : await (_database.select(
            _database.journalEntryFragments,
          )..where((tbl) => tbl.id.equals(fragment.id))).getSingleOrNull();
    final id =
        existing?.id ?? (fragment.id.isEmpty ? _ids.next() : fragment.id);
    final createdAt = existing == null
        ? fragment.createdAt
        : _fromMillis(existing.createdAt);
    final companion = JournalEntryFragmentsCompanion.insert(
      id: id,
      entryId: fragment.entryId,
      kind: fragment.kind.storageValue,
      position: fragment.position,
      textBody: Value(_cleanText(fragment.textBody)),
      photoId: Value(_cleanText(fragment.photoId)),
      caption: Value(_cleanText(fragment.caption)),
      audioRelPath: Value(_cleanText(fragment.audioRelPath)),
      audioDurationMs: Value(fragment.audioDurationMs),
      createdAt: _toMillis(createdAt),
      updatedAt: _toMillis(now),
      deletedAt: const Value(null),
    );
    await _database
        .into(_database.journalEntryFragments)
        .insertOnConflictUpdate(companion);
    final saved = await (_database.select(
      _database.journalEntryFragments,
    )..where((tbl) => tbl.id.equals(id))).getSingle();
    return _mapFragment(saved);
  }

  @override
  Future<void> softDeleteFragment(String id) async {
    final now = _clock.now();
    final row = await (_database.select(
      _database.journalEntryFragments,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    if (row == null || row.deletedAt != null) return;

    final entryId = row.entryId;
    final audioPath = row.kind == JournalFragmentKind.audio.storageValue
        ? row.audioRelPath
        : null;

    await (_database.update(
      _database.journalEntryFragments,
    )..where((tbl) => tbl.id.equals(id))).write(
      JournalEntryFragmentsCompanion(
        deletedAt: Value(_toMillis(now)),
        updatedAt: Value(_toMillis(now)),
      ),
    );

    if (audioPath != null && audioPath.isNotEmpty) {
      await _purgeAudioPaths({audioPath});
    }

    final remaining = await _liveFragments(entryId);
    final ordered = JournalFragmentOps.normalizePositions(remaining);
    for (final fragment in ordered) {
      await saveFragment(fragment);
    }
    await _syncLegacyPhotos(entryId, ordered);
    await _refreshEntryBody(entryId, ordered);
  }

  @override
  Future<JournalEntry> saveMemory({
    required JournalEntry entry,
    required List<JournalFragment> fragments,
  }) {
    return _database.transaction(() async {
      final ordered = JournalFragmentOps.normalizePositions(fragments);
      final preview = JournalFragment.previewBodyFrom(ordered);

      // Write shell with derived body first (may create the entry id).
      final savedEntry = await _writeEntryShell(
        entry.copyWith(body: preview),
        forceBody: preview,
      );

      final existing = await _liveFragmentRows(savedEntry.id);
      final keptIds = <String>{};
      final removedAudio = <String>{};

      for (final fragment in ordered) {
        final withEntry = fragment.copyWith(entryId: savedEntry.id);
        final saved = await saveFragment(withEntry);
        keptIds.add(saved.id);
      }

      for (final row in existing) {
        if (keptIds.contains(row.id)) continue;
        if (row.kind == JournalFragmentKind.audio.storageValue &&
            row.audioRelPath != null &&
            row.audioRelPath!.isNotEmpty) {
          removedAudio.add(row.audioRelPath!);
        }
        await (_database.update(
          _database.journalEntryFragments,
        )..where((tbl) => tbl.id.equals(row.id))).write(
          JournalEntryFragmentsCompanion(
            deletedAt: Value(_toMillis(_clock.now())),
            updatedAt: Value(_toMillis(_clock.now())),
          ),
        );
      }

      await _syncLegacyPhotos(savedEntry.id, ordered);
      await _purgeAudioPaths(removedAudio);
      return savedEntry;
    });
  }

  @override
  Future<JournalEntry> moveFragment({
    required String entryId,
    required int fromIndex,
    required int toIndex,
  }) {
    return _database.transaction(() async {
      final live = await _liveFragments(entryId);
      final ordered = JournalFragmentOps.moveTo(live, fromIndex, toIndex);
      for (final fragment in ordered) {
        await saveFragment(fragment);
      }
      await _syncLegacyPhotos(entryId, ordered);
      return _refreshEntryBody(entryId, ordered);
    });
  }

  Future<JournalEntry> _writeEntryShell(
    JournalEntry entry, {
    required String forceBody,
  }) async {
    final now = _clock.now();
    await _ensureDayExists(entry.localDate, now);
    final existing = entry.id.isEmpty
        ? null
        : await (_database.select(
            _database.journalEntries,
          )..where((tbl) => tbl.id.equals(entry.id))).getSingleOrNull();
    final id = existing?.id ?? (entry.id.isEmpty ? _ids.next() : entry.id);
    final createdAt = existing == null
        ? entry.createdAt
        : _fromMillis(existing.createdAt);
    final companion = JournalEntriesCompanion.insert(
      id: id,
      localDate: entry.localDate.storageKey,
      title: entry.title.trim(),
      body: forceBody,
      mood: Value(entry.mood?.storageValue),
      position: entry.position,
      createdAt: _toMillis(createdAt),
      updatedAt: _toMillis(now),
      deletedAt: const Value(null),
    );
    await _database
        .into(_database.journalEntries)
        .insertOnConflictUpdate(companion);
    final saved = await (_database.select(
      _database.journalEntries,
    )..where((tbl) => tbl.id.equals(id))).getSingle();
    return _mapEntry(saved);
  }

  Future<JournalEntry> _refreshEntryBody(
    String entryId,
    List<JournalFragment> fragments,
  ) async {
    final now = _clock.now();
    final preview = JournalFragment.previewBodyFrom(fragments);
    await (_database.update(
      _database.journalEntries,
    )..where((tbl) => tbl.id.equals(entryId))).write(
      JournalEntriesCompanion(
        body: Value(preview),
        updatedAt: Value(_toMillis(now)),
      ),
    );
    final saved = await (_database.select(
      _database.journalEntries,
    )..where((tbl) => tbl.id.equals(entryId))).getSingle();
    return _mapEntry(saved);
  }

  Future<List<JournalFragment>> _liveFragments(String entryId) async {
    final rows = await _liveFragmentRows(entryId);
    return rows.map(_mapFragment).toList(growable: false);
  }

  Future<List<JournalEntryFragmentRow>> _liveFragmentRows(
    String entryId,
  ) async {
    final query = _database.select(_database.journalEntryFragments)
      ..where(
        (tbl) => tbl.entryId.equals(entryId) & tbl.deletedAt.isNull(),
      )
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.position)]);
    return query.get();
  }

  Future<Set<String>> _audioPathsForEntry(String entryId) async {
    final rows = await _liveFragmentRows(entryId);
    return {
      for (final row in rows)
        if (row.kind == JournalFragmentKind.audio.storageValue &&
            row.audioRelPath != null &&
            row.audioRelPath!.isNotEmpty)
          row.audioRelPath!,
    };
  }

  Future<void> _purgeAudioPaths(Set<String> paths) async {
    for (final path in paths) {
      try {
        await _audioStore.delete(path);
      } on Object {
        // Missing file is fine — soft-deleted metadata already owns the state.
      }
    }
  }

  Future<void> _syncLegacyPhotos(
    String entryId,
    List<JournalFragment> fragments,
  ) async {
    final now = _clock.now();
    final photoFragments = [
      for (final fragment in fragments)
        if (fragment.kind == JournalFragmentKind.photograph &&
            fragment.photoId != null &&
            fragment.photoId!.isNotEmpty)
          fragment,
    ];
    final existing =
        await (_database.select(
              _database.journalEntryPhotos,
            )..where(
              (tbl) => tbl.entryId.equals(entryId) & tbl.deletedAt.isNull(),
            ))
            .get();
    final kept = <String>{};

    for (var i = 0; i < photoFragments.length; i++) {
      final fragment = photoFragments[i];
      JournalEntryPhotoRow? match;
      for (final row in existing) {
        if (row.photoId == fragment.photoId) {
          match = row;
          break;
        }
      }
      final saved = await saveEntryPhoto(
        JournalEntryPhoto(
          id: match?.id ?? '',
          entryId: entryId,
          photoId: fragment.photoId!,
          caption: fragment.caption,
          position: i,
          createdAt: match == null ? now : _fromMillis(match.createdAt),
          updatedAt: now,
        ),
      );
      kept.add(saved.id);
    }

    for (final row in existing) {
      if (!kept.contains(row.id)) {
        await softDeleteEntryPhoto(row.id);
      }
    }
  }

  Future<void> _ensureDayExists(LocalCalendarDate date, DateTime now) async {
    final existing = await (_database.select(
      _database.journalDays,
    )..where((tbl) => tbl.localDate.equals(date.storageKey))).getSingleOrNull();
    if (existing != null) return;
    await _database
        .into(_database.journalDays)
        .insert(
          JournalDaysCompanion.insert(
            localDate: date.storageKey,
            createdAt: _toMillis(now),
            updatedAt: _toMillis(now),
          ),
        );
  }

  JournalDay _mapDay(JournalDayRow row) {
    return JournalDay(
      localDate: LocalCalendarDate.parseStorage(row.localDate),
      mood: JournalMood.fromStorage(row.mood),
      createdAt: _fromMillis(row.createdAt),
      updatedAt: _fromMillis(row.updatedAt),
      deletedAt: row.deletedAt == null ? null : _fromMillis(row.deletedAt!),
    );
  }

  JournalEntry _mapEntry(JournalEntryRow row) {
    return JournalEntry(
      id: row.id,
      localDate: LocalCalendarDate.parseStorage(row.localDate),
      title: row.title,
      body: row.body,
      mood: JournalMood.fromStorage(row.mood),
      position: row.position,
      createdAt: _fromMillis(row.createdAt),
      updatedAt: _fromMillis(row.updatedAt),
      deletedAt: row.deletedAt == null ? null : _fromMillis(row.deletedAt!),
    );
  }

  JournalEntryPhoto _mapPhoto(JournalEntryPhotoRow row) {
    return JournalEntryPhoto(
      id: row.id,
      entryId: row.entryId,
      photoId: row.photoId,
      caption: row.caption,
      position: row.position,
      createdAt: _fromMillis(row.createdAt),
      updatedAt: _fromMillis(row.updatedAt),
      deletedAt: row.deletedAt == null ? null : _fromMillis(row.deletedAt!),
    );
  }

  JournalFragment _mapFragment(JournalEntryFragmentRow row) {
    return JournalFragment(
      id: row.id,
      entryId: row.entryId,
      kind: JournalFragmentKind.fromStorage(row.kind),
      position: row.position,
      textBody: row.textBody,
      photoId: row.photoId,
      caption: row.caption,
      audioRelPath: row.audioRelPath,
      audioDurationMs: row.audioDurationMs,
      createdAt: _fromMillis(row.createdAt),
      updatedAt: _fromMillis(row.updatedAt),
      deletedAt: row.deletedAt == null ? null : _fromMillis(row.deletedAt!),
    );
  }

  String? _cleanText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  int _toMillis(DateTime value) => value.toUtc().millisecondsSinceEpoch;

  DateTime _fromMillis(int value) =>
      DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
}
