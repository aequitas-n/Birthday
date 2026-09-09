import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/domain/models/settings.dart';

/// Session appearance for Kin.
///
/// Vintage Diary is the sole product theme — an old personal journal brought
/// into a modern interface.
@immutable
class ThemePreference {
  const ThemePreference();

  factory ThemePreference.fromSettings(AppSettings _) {
    return const ThemePreference();
  }

  /// Always resolves the Vintage Diary theme.
  QuietTheme resolve([Brightness? _]) {
    return const QuietTheme.light();
  }
}

class ThemePreferenceNotifier extends Notifier<ThemePreference> {
  @override
  ThemePreference build() => ref.watch(initialThemePreferenceProvider);
}

final initialThemePreferenceProvider = Provider<ThemePreference>((ref) {
  return const ThemePreference();
});

final themePreferenceProvider =
    NotifierProvider<ThemePreferenceNotifier, ThemePreference>(
      ThemePreferenceNotifier.new,
    );
