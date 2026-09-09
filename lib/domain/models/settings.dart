import 'package:meta/meta.dart';

enum StoredThemeMode {
  system,
  light,
  dark
  ;

  static StoredThemeMode fromStorage(String value) {
    return values.firstWhere(
      (entry) => entry.name == value,
      orElse: () => StoredThemeMode.light,
    );
  }
}

@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = StoredThemeMode.light,
    this.amoled = false,
    this.showDetailsOnLockScreen = true,
    this.notificationsEnabled = false,
    this.onboardingCompletedAt,
    this.deviceTimezoneCache,
    this.reminderTimezone,
    this.lastReconciledAt,
  });

  final StoredThemeMode themeMode;
  final bool amoled;
  final bool showDetailsOnLockScreen;
  final bool notificationsEnabled;
  final DateTime? onboardingCompletedAt;
  final String? deviceTimezoneCache;

  /// IANA zone for personal reminder scheduling. Null → use device zone.
  final String? reminderTimezone;
  final DateTime? lastReconciledAt;

  AppSettings copyWith({
    StoredThemeMode? themeMode,
    bool? amoled,
    bool? showDetailsOnLockScreen,
    bool? notificationsEnabled,
    Object? onboardingCompletedAt = _sentinel,
    Object? deviceTimezoneCache = _sentinel,
    Object? reminderTimezone = _sentinel,
    Object? lastReconciledAt = _sentinel,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      amoled: amoled ?? this.amoled,
      showDetailsOnLockScreen:
          showDetailsOnLockScreen ?? this.showDetailsOnLockScreen,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      onboardingCompletedAt: onboardingCompletedAt == _sentinel
          ? this.onboardingCompletedAt
          : onboardingCompletedAt as DateTime?,
      deviceTimezoneCache: deviceTimezoneCache == _sentinel
          ? this.deviceTimezoneCache
          : deviceTimezoneCache as String?,
      reminderTimezone: reminderTimezone == _sentinel
          ? this.reminderTimezone
          : reminderTimezone as String?,
      lastReconciledAt: lastReconciledAt == _sentinel
          ? this.lastReconciledAt
          : lastReconciledAt as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppSettings &&
        other.themeMode == themeMode &&
        other.amoled == amoled &&
        other.showDetailsOnLockScreen == showDetailsOnLockScreen &&
        other.notificationsEnabled == notificationsEnabled &&
        other.onboardingCompletedAt == onboardingCompletedAt &&
        other.deviceTimezoneCache == deviceTimezoneCache &&
        other.reminderTimezone == reminderTimezone &&
        other.lastReconciledAt == lastReconciledAt;
  }

  @override
  int get hashCode => Object.hash(
    themeMode,
    amoled,
    showDetailsOnLockScreen,
    notificationsEnabled,
    onboardingCompletedAt,
    deviceTimezoneCache,
    reminderTimezone,
    lastReconciledAt,
  );
}

const _sentinel = Object();
