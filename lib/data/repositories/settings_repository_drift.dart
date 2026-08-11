import 'package:drift/drift.dart';
import 'package:kin/data/local/database/kin_database.dart';
import 'package:kin/domain/models/settings.dart';
import 'package:kin/domain/repositories/settings_repository.dart';

class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._database);

  final KinDatabase _database;

  @override
  Stream<AppSettings> watchSettings() {
    final query = _database.select(_database.settings)
      ..where((tbl) => tbl.id.equals(0));
    return query.watchSingle().map(_mapSettings);
  }

  @override
  Future<AppSettings> readSettings() async {
    final row = await (_database.select(
      _database.settings,
    )..where((tbl) => tbl.id.equals(0))).getSingle();
    return _mapSettings(row);
  }

  @override
  Future<void> saveAppearance({
    required StoredThemeMode mode,
    required bool amoled,
  }) async {
    await (_database.update(
      _database.settings,
    )..where((tbl) => tbl.id.equals(0))).write(
      SettingsCompanion(themeMode: Value(mode.name), amoled: Value(amoled)),
    );
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await _database
        .into(_database.settings)
        .insertOnConflictUpdate(
          SettingsCompanion(
            id: const Value(0),
            themeMode: Value(settings.themeMode.name),
            amoled: Value(settings.amoled),
            showDetailsOnLockScreen: Value(settings.showDetailsOnLockScreen),
            notificationsEnabled: Value(settings.notificationsEnabled),
            onboardingCompletedAt: Value(
              _toMillis(settings.onboardingCompletedAt),
            ),
            deviceTimezoneCache: Value(settings.deviceTimezoneCache),
            lastReconciledAt: Value(_toMillis(settings.lastReconciledAt)),
          ),
        );
  }

  AppSettings _mapSettings(Setting row) {
    return AppSettings(
      themeMode: StoredThemeMode.fromStorage(row.themeMode),
      amoled: row.amoled,
      showDetailsOnLockScreen: row.showDetailsOnLockScreen,
      notificationsEnabled: row.notificationsEnabled,
      onboardingCompletedAt: _fromMillis(row.onboardingCompletedAt),
      deviceTimezoneCache: row.deviceTimezoneCache,
      lastReconciledAt: _fromMillis(row.lastReconciledAt),
    );
  }

  static DateTime? _fromMillis(int? value) {
    if (value == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }

  static int? _toMillis(DateTime? value) =>
      value?.toUtc().millisecondsSinceEpoch;
}
