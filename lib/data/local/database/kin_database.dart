import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'kin_database.g.dart';

class People extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text().named('display_name')();
  IntColumn get birthMonth => integer().named('birth_month')();
  IntColumn get birthDay => integer().named('birth_day')();
  IntColumn get birthYear => integer().named('birth_year').nullable()();
  TextColumn get placeLabel => text().named('place_label').nullable()();
  TextColumn get ianaTimezone => text().named('iana_timezone').nullable()();
  TextColumn get sortKey => text().named('sort_key')();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  IntColumn get deletedAt => integer().named('deleted_at').nullable()();
  IntColumn get syncRev =>
      integer().named('sync_rev').withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Profiles extends Table {
  TextColumn get id => text()();
  TextColumn get personId =>
      text().named('person_id').unique().references(People, #id)();
  TextColumn get nickname => text().nullable()();
  TextColumn get relationship => text().nullable()();
  TextColumn get relationshipLabel =>
      text().named('relationship_label').nullable()();
  TextColumn get photoId => text().named('photo_id').nullable()();
  BoolColumn get isPinned =>
      boolean().named('is_pinned').withDefault(const Constant(false))();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  IntColumn get deletedAt => integer().named('deleted_at').nullable()();
  IntColumn get syncRev =>
      integer().named('sync_rev').withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get profileId =>
      text().named('profile_id').references(Profiles, #id)();
  TextColumn get kind => text()();
  TextColumn get kindLabel => text().named('kind_label').nullable()();
  TextColumn get value => text().withLength(min: 1, max: 280)();
  BoolColumn get isRetired =>
      boolean().named('is_retired').withDefault(const Constant(false))();
  IntColumn get position => integer()();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  IntColumn get deletedAt => integer().named('deleted_at').nullable()();
  IntColumn get syncRev =>
      integer().named('sync_rev').withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Photos extends Table {
  TextColumn get id => text()();
  TextColumn get personId =>
      text().named('person_id').nullable().references(People, #id)();
  TextColumn get relPath => text().named('rel_path')();
  IntColumn get width => integer()();
  IntColumn get height => integer()();
  IntColumn get bytes => integer()();
  TextColumn get remotePath => text().named('remote_path').nullable()();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get deletedAt => integer().named('deleted_at').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ReminderRules extends Table {
  TextColumn get id => text()();
  TextColumn get personId =>
      text().named('person_id').nullable().references(People, #id)();
  TextColumn get kind => text()();
  IntColumn get offsetDays => integer().named('offset_days').nullable()();
  TextColumn get localTime => text().named('local_time').nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  IntColumn get updatedAt => integer().named('updated_at')();
  IntColumn get deletedAt => integer().named('deleted_at').nullable()();
  IntColumn get syncRev =>
      integer().named('sync_rev').withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ScheduledNotifications extends Table {
  IntColumn get osId => integer().named('os_id')();
  TextColumn get personId =>
      text().named('person_id').references(People, #id)();
  TextColumn get ruleId =>
      text().named('rule_id').references(ReminderRules, #id)();
  IntColumn get occurrenceYear => integer().named('occurrence_year')();
  IntColumn get fireAtUtc => integer().named('fire_at_utc')();
  IntColumn get fireAtDeviceLocal => integer().named('fire_at_device_local')();
  TextColumn get deviceTz => text().named('device_tz')();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get noteIdUsed =>
      text().named('note_id_used').nullable().references(Notes, #id)();
  TextColumn get state => text()();
  TextColumn get snapshotJson =>
      text().named('snapshot_json').withDefault(const Constant('{}'))();
  IntColumn get createdAt => integer().named('created_at')();

  @override
  Set<Column<Object>> get primaryKey => {osId};
}

class Settings extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  TextColumn get themeMode =>
      text().named('theme_mode').withDefault(const Constant('system'))();
  BoolColumn get amoled => boolean().withDefault(const Constant(false))();
  BoolColumn get showDetailsOnLockScreen => boolean()
      .named('show_details_on_lock_screen')
      .withDefault(const Constant(true))();
  BoolColumn get notificationsEnabled => boolean()
      .named('notifications_enabled')
      .withDefault(const Constant(false))();
  IntColumn get onboardingCompletedAt =>
      integer().named('onboarding_completed_at').nullable()();
  TextColumn get deviceTimezoneCache =>
      text().named('device_timezone_cache').nullable()();
  IntColumn get lastReconciledAt =>
      integer().named('last_reconciled_at').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SyncState extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  TextColumn get deviceId => text().named('device_id')();
  TextColumn get accountId => text().named('account_id').nullable()();
  IntColumn get lastPulledAt => integer().named('last_pulled_at').nullable()();
  IntColumn get lastPushedAt => integer().named('last_pushed_at').nullable()();
  TextColumn get lastError => text().named('last_error').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('JournalDayRow')
class JournalDays extends Table {
  TextColumn get localDate => text().named('local_date')();
  TextColumn get mood => text().nullable()();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  IntColumn get deletedAt => integer().named('deleted_at').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {localDate};
}

@DataClassName('JournalEntryRow')
class JournalEntries extends Table {
  TextColumn get id => text()();
  TextColumn get localDate =>
      text().named('local_date').references(JournalDays, #localDate)();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get mood => text().nullable()();
  IntColumn get position => integer()();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  IntColumn get deletedAt => integer().named('deleted_at').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('JournalEntryPhotoRow')
class JournalEntryPhotos extends Table {
  TextColumn get id => text()();
  TextColumn get entryId =>
      text().named('entry_id').references(JournalEntries, #id)();
  TextColumn get photoId => text().named('photo_id').references(Photos, #id)();
  TextColumn get caption => text().nullable()();
  IntColumn get position => integer()();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  IntColumn get deletedAt => integer().named('deleted_at').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Ordered composition pieces inside a memory (writing / list / photo / audio).
@DataClassName('JournalEntryFragmentRow')
class JournalEntryFragments extends Table {
  TextColumn get id => text()();
  TextColumn get entryId =>
      text().named('entry_id').references(JournalEntries, #id)();
  TextColumn get kind => text()();
  IntColumn get position => integer()();
  TextColumn get textBody => text().named('text_body').nullable()();
  TextColumn get photoId =>
      text().named('photo_id').nullable().references(Photos, #id)();
  TextColumn get caption => text().nullable()();
  TextColumn get audioRelPath => text().named('audio_rel_path').nullable()();
  IntColumn get audioDurationMs =>
      integer().named('audio_duration_ms').nullable()();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  IntColumn get deletedAt => integer().named('deleted_at').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    People,
    Profiles,
    Notes,
    Photos,
    ReminderRules,
    ScheduledNotifications,
    Settings,
    SyncState,
    JournalDays,
    JournalEntries,
    JournalEntryPhotos,
    JournalEntryFragments,
  ],
)
class KinDatabase extends _$KinDatabase {
  KinDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createIndexes();
      await _seedDefaults();
    },
    onUpgrade: (m, from, to) async {
      for (var version = from; version < to; version++) {
        switch (version) {
          case 1:
            await m.addColumn(notes, notes.kindLabel);
          case 2:
            await m.addColumn(
              scheduledNotifications,
              scheduledNotifications.snapshotJson,
            );
          case 3:
            await _migrateToPersonProfileSplit(m);
          case 4:
            await m.addColumn(profiles, profiles.isPinned);
          case 5:
            await m.createTable(journalDays);
            await m.createTable(journalEntries);
            await m.createTable(journalEntryPhotos);
            await _createJournalIndexes();
          case 6:
            await m.createTable(journalEntryFragments);
            await _createJournalFragmentIndexes();
            await _migrateJournalBodiesToFragments();
        }
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      if (!details.wasCreated) {
        await _seedDefaults();
      }
    },
  );

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final directory = await getApplicationSupportDirectory();
      final file = File(p.join(directory.path, 'kin.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }

  Future<void> _migrateToPersonProfileSplit(Migrator m) async {
    await m.createTable(profiles);

    // Create a profile for every person that already carries profile fields
    // or notes. Birthday-only people remain without a profile.
    await customStatement('''
INSERT INTO profiles (
  id, person_id, nickname, relationship, relationship_label, photo_id,
  created_at, updated_at, deleted_at, sync_rev
)
SELECT
  'prf_' || id,
  id,
  nickname,
  relationship,
  relationship_label,
  photo_id,
  created_at,
  updated_at,
  deleted_at,
  sync_rev
FROM people
WHERE nickname IS NOT NULL
   OR relationship IS NOT NULL
   OR relationship_label IS NOT NULL
   OR photo_id IS NOT NULL
   OR id IN (SELECT DISTINCT person_id FROM notes)
''');

    await customStatement('PRAGMA foreign_keys = OFF');
    await customStatement('''
CREATE TABLE notes_new (
  id TEXT NOT NULL PRIMARY KEY,
  profile_id TEXT NOT NULL REFERENCES profiles(id),
  kind TEXT NOT NULL,
  kind_label TEXT NULL,
  value TEXT NOT NULL,
  is_retired INTEGER NOT NULL DEFAULT 0 CHECK (is_retired IN (0, 1)),
  position INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER NULL,
  sync_rev INTEGER NOT NULL DEFAULT 0
)
''');
    await customStatement('''
INSERT INTO notes_new (
  id, profile_id, kind, kind_label, value, is_retired, position,
  created_at, updated_at, deleted_at, sync_rev
)
SELECT
  n.id,
  p.id,
  n.kind,
  n.kind_label,
  n.value,
  n.is_retired,
  n.position,
  n.created_at,
  n.updated_at,
  n.deleted_at,
  n.sync_rev
FROM notes n
INNER JOIN profiles p ON p.person_id = n.person_id
''');
    await customStatement('DROP TABLE notes');
    await customStatement('ALTER TABLE notes_new RENAME TO notes');
    await customStatement('''
UPDATE people
SET nickname = NULL,
    relationship = NULL,
    relationship_label = NULL,
    photo_id = NULL
''');
    await customStatement('PRAGMA foreign_keys = ON');

    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_notes_profile_position '
      'ON notes (profile_id, deleted_at, position)',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_profiles_person '
      'ON profiles (person_id)',
    );
  }

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX idx_people_birthdays '
      'ON people (deleted_at, birth_month, birth_day)',
    );
    await customStatement(
      'CREATE INDEX idx_people_sort_key ON people (sort_key)',
    );
    await customStatement(
      'CREATE UNIQUE INDEX idx_profiles_person ON profiles (person_id)',
    );
    await customStatement(
      'CREATE INDEX idx_notes_profile_position '
      'ON notes (profile_id, deleted_at, position)',
    );
    await customStatement(
      'CREATE INDEX idx_scheduled_notifications_state_fire '
      'ON scheduled_notifications (state, fire_at_utc)',
    );
    await _createJournalIndexes();
  }

  Future<void> _createJournalIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_journal_entries_day_position '
      'ON journal_entries (local_date, deleted_at, position)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_journal_entry_photos_entry_position '
      'ON journal_entry_photos (entry_id, deleted_at, position)',
    );
    await _createJournalFragmentIndexes();
  }

  Future<void> _createJournalFragmentIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_journal_entry_fragments_entry_position '
      'ON journal_entry_fragments (entry_id, deleted_at, position)',
    );
  }

  /// v6 → v7: body → writing fragment; entry photos → photograph fragments.
  Future<void> _migrateJournalBodiesToFragments() async {
    final entries = await customSelect(
      'SELECT id, body, created_at, updated_at FROM journal_entries '
      'WHERE deleted_at IS NULL',
    ).get();

    for (final entry in entries) {
      final entryId = entry.read<String>('id');
      final body = entry.read<String>('body').trim();
      final createdAt = entry.read<int>('created_at');
      final updatedAt = entry.read<int>('updated_at');
      var position = 0;

      if (body.isNotEmpty) {
        await customStatement(
          'INSERT INTO journal_entry_fragments ( '
          'id, entry_id, kind, position, text_body, photo_id, caption, '
          'audio_rel_path, audio_duration_ms, created_at, updated_at, deleted_at '
          ') VALUES (?, ?, ?, ?, ?, NULL, NULL, NULL, NULL, ?, ?, NULL)',
          [
            'jfr_mig_${entryId}_w',
            entryId,
            'writing',
            position,
            body,
            createdAt,
            updatedAt,
          ],
        );
        position += 1;
      }

      final photos = await customSelect(
        'SELECT id, photo_id, caption, position, created_at, updated_at '
        'FROM journal_entry_photos '
        'WHERE entry_id = ? AND deleted_at IS NULL '
        'ORDER BY position ASC',
        variables: [Variable.withString(entryId)],
      ).get();

      for (final photo in photos) {
        final photoRowId = photo.read<String>('id');
        await customStatement(
          'INSERT INTO journal_entry_fragments ( '
          'id, entry_id, kind, position, text_body, photo_id, caption, '
          'audio_rel_path, audio_duration_ms, created_at, updated_at, deleted_at '
          ') VALUES (?, ?, ?, ?, NULL, ?, ?, NULL, NULL, ?, ?, NULL)',
          [
            'jfr_mig_$photoRowId',
            entryId,
            'photograph',
            position,
            photo.read<String>('photo_id'),
            photo.read<String?>('caption'),
            photo.read<int>('created_at'),
            photo.read<int>('updated_at'),
          ],
        );
        position += 1;
      }
    }
  }

  Future<void> _seedDefaults() async {
    await into(
      settings,
    ).insertOnConflictUpdate(SettingsCompanion.insert(id: const Value(0)));

    final existingDefaultRules = await (select(
      reminderRules,
    )..where((tbl) => tbl.personId.isNull() & tbl.deletedAt.isNull())).get();
    if (existingDefaultRules.isNotEmpty) return;

    await batch((batch) {
      batch.insertAll(reminderRules, [
        ReminderRulesCompanion.insert(
          id: 'default-days-7',
          kind: 'days_before',
          offsetDays: const Value(7),
          localTime: const Value('09:00'),
          enabled: const Value(true),
          updatedAt: 0,
        ),
        ReminderRulesCompanion.insert(
          id: 'default-days-1',
          kind: 'days_before',
          offsetDays: const Value(1),
          localTime: const Value('09:00'),
          enabled: const Value(true),
          updatedAt: 0,
        ),
        ReminderRulesCompanion.insert(
          id: 'default-at-midnight',
          kind: 'at_their_midnight',
          enabled: const Value(true),
          updatedAt: 0,
        ),
      ]);
    });
  }
}
