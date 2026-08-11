import 'package:kin/domain/models/settings.dart';

abstract interface class SettingsRepository {
  Stream<AppSettings> watchSettings();
  Future<AppSettings> readSettings();
  Future<void> saveAppearance({
    required StoredThemeMode mode,
    required bool amoled,
  });
  Future<void> saveSettings(AppSettings settings);
}
