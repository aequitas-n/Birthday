import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/data/local/database/kin_database.dart';
import 'package:kin/data/repositories/settings_repository_drift.dart';
import 'package:kin/design/theme/product_theme_id.dart';
import 'package:kin/domain/models/settings.dart';

void main() {
  group('product theme persistence', () {
    late KinDatabase database;
    late DriftSettingsRepository repository;

    setUp(() {
      database = KinDatabase(NativeDatabase.memory());
      repository = DriftSettingsRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('fresh install seeds Default product theme', () async {
      final settings = await repository.readSettings();
      expect(settings.productThemeId, ProductThemeId.quietDefault);

      final row = await database.select(database.settings).getSingle();
      expect(row.productTheme, 'default');
    });

    test('saveSettings persists Vintage and restores Default', () async {
      final base = await repository.readSettings();
      await repository.saveSettings(
        base.copyWith(productThemeId: ProductThemeId.vintageDiary),
      );
      expect(
        (await repository.readSettings()).productThemeId,
        ProductThemeId.vintageDiary,
      );

      await repository.saveSettings(
        base.copyWith(productThemeId: ProductThemeId.quietDefault),
      );
      expect(
        (await repository.readSettings()).productThemeId,
        ProductThemeId.quietDefault,
      );
    });

    test('watchSettings emits product theme changes', () async {
      final base = await repository.readSettings();
      final events = <ProductThemeId>[];
      final sub = repository.watchSettings().listen(
        (s) => events.add(s.productThemeId),
      );
      await Future<void>.delayed(Duration.zero);

      await repository.saveSettings(
        base.copyWith(productThemeId: ProductThemeId.vintageDiary),
      );
      await repository.saveSettings(
        base.copyWith(productThemeId: ProductThemeId.quietDefault),
      );
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(events, contains(ProductThemeId.quietDefault));
      expect(events, contains(ProductThemeId.vintageDiary));
    });

    test('product theme is the single authoritative preference field', () async {
      final base = await repository.readSettings();
      await repository.saveSettings(
        base.copyWith(
          productThemeId: ProductThemeId.vintageDiary,
          themeMode: StoredThemeMode.dark,
          amoled: true,
          notificationsEnabled: true,
        ),
      );
      final next = await repository.readSettings();
      expect(next.productThemeId, ProductThemeId.vintageDiary);
      // Unrelated appearance/privacy flags remain independently stored.
      expect(next.themeMode, StoredThemeMode.dark);
      expect(next.amoled, isTrue);
      expect(next.notificationsEnabled, isTrue);
    });
  });

  group('schema v8 → v9 migration', () {
    test('existing settings row is stamped vintage_diary', () async {
      final database = KinDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      // Preserve an "existing user" row, then strip product_theme to mimic v8.
      await (database.update(database.settings)
            ..where((tbl) => tbl.id.equals(0)))
          .write(
            const SettingsCompanion(
              notificationsEnabled: Value(true),
              showDetailsOnLockScreen: Value(false),
            ),
          );

      await database.customStatement('''
CREATE TABLE settings_v8 (
  id INTEGER NOT NULL PRIMARY KEY DEFAULT 0,
  theme_mode TEXT NOT NULL DEFAULT 'system',
  amoled INTEGER NOT NULL DEFAULT 0 CHECK (amoled IN (0, 1)),
  show_details_on_lock_screen INTEGER NOT NULL DEFAULT 1
    CHECK (show_details_on_lock_screen IN (0, 1)),
  notifications_enabled INTEGER NOT NULL DEFAULT 0
    CHECK (notifications_enabled IN (0, 1)),
  onboarding_completed_at INTEGER NULL,
  device_timezone_cache TEXT NULL,
  reminder_timezone TEXT NULL,
  last_reconciled_at INTEGER NULL
)
''');
      await database.customStatement('''
INSERT INTO settings_v8 (
  id, theme_mode, amoled, show_details_on_lock_screen, notifications_enabled,
  onboarding_completed_at, device_timezone_cache, reminder_timezone,
  last_reconciled_at
)
SELECT
  id, theme_mode, amoled, show_details_on_lock_screen, notifications_enabled,
  onboarding_completed_at, device_timezone_cache, reminder_timezone,
  last_reconciled_at
FROM settings
''');
      await database.customStatement('DROP TABLE settings');
      await database.customStatement(
        'ALTER TABLE settings_v8 RENAME TO settings',
      );

      // Exact steps from KinDatabase migration case 8.
      final migrator = Migrator(database);
      await migrator.addColumn(
        database.settings,
        database.settings.productTheme,
      );
      await database.customStatement(
        "UPDATE settings SET product_theme = 'vintage_diary'",
      );

      // beforeOpen seed must not clobber migrated theme.
      await database.customStatement('PRAGMA foreign_keys = ON');
      await database
          .into(database.settings)
          .insert(
            SettingsCompanion.insert(
              id: const Value(0),
              productTheme: const Value('default'),
            ),
            mode: InsertMode.insertOrIgnore,
          );

      final repo = DriftSettingsRepository(database);
      final settings = await repo.readSettings();
      expect(settings.productThemeId, ProductThemeId.vintageDiary);
      expect(settings.notificationsEnabled, isTrue);
      expect(settings.showDetailsOnLockScreen, isFalse);
    });
  });
}
