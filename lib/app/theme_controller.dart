import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/design/theme/quiet_collection.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/domain/models/settings.dart';

/// How the user has chosen to resolve appearance.
///
/// AMOLED is deliberately not a fourth top-level mode. Users think in
/// light/dark, and pure black is a refinement of dark — it appears as a
/// single switch nested beneath it. See docs/06-color.md §4.
enum ThemeChoice { system, light, dark }

@immutable
class ThemePreference {
  const ThemePreference({
    this.choice = ThemeChoice.system,
    this.amoled = false,
    this.collection = QuietCollection.ember,
  });

  factory ThemePreference.fromSettings(AppSettings settings) {
    return ThemePreference(
      choice: switch (settings.themeMode) {
        StoredThemeMode.system => ThemeChoice.system,
        StoredThemeMode.light => ThemeChoice.light,
        StoredThemeMode.dark => ThemeChoice.dark,
      },
      amoled: settings.amoled,
    );
  }

  final ThemeChoice choice;
  final bool amoled;

  /// Which atmosphere the app wears.
  ///
  /// Orthogonal to [choice]: a collection resolves against whichever
  /// brightness is in force, so Ocean Mist is Ocean Mist in both.
  final QuietCollection collection;

  ThemePreference copyWith({
    ThemeChoice? choice,
    bool? amoled,
    QuietCollection? collection,
  }) => ThemePreference(
    choice: choice ?? this.choice,
    amoled: amoled ?? this.amoled,
    collection: collection ?? this.collection,
  );

  /// Resolves the preference against the platform brightness.
  QuietTheme resolve(Brightness platformBrightness) {
    final wantsDark = switch (choice) {
      ThemeChoice.system => platformBrightness == Brightness.dark,
      ThemeChoice.light => false,
      ThemeChoice.dark => true,
    };
    return QuietTheme.of(collection, dark: wantsDark, amoled: amoled);
  }
}

class ThemePreferenceNotifier extends Notifier<ThemePreference> {
  @override
  ThemePreference build() => ref.watch(initialThemePreferenceProvider);

  void setChoice(ThemeChoice choice) {
    state = state.copyWith(choice: choice);
    unawaited(_persist());
  }

  void setAmoled({required bool enabled}) {
    state = state.copyWith(amoled: enabled);
    unawaited(_persist());
  }

  /// Changes the collection for this session.
  ///
  /// Not persisted. The settings table stores appearance as a mode and an
  /// AMOLED flag, and adding a column for the collection would mean a Drift
  /// migration — which this pass is explicitly not permitted to make. The
  /// selection is otherwise complete: it drives every screen through
  /// [QuietTheme] and animates on change like any other appearance switch.
  void setCollection(QuietCollection collection) {
    state = state.copyWith(collection: collection);
  }

  Future<void> _persist() {
    return ref
        .read(settingsRepositoryProvider)
        .saveAppearance(
          mode: switch (state.choice) {
            ThemeChoice.system => StoredThemeMode.system,
            ThemeChoice.light => StoredThemeMode.light,
            ThemeChoice.dark => StoredThemeMode.dark,
          },
          amoled: state.amoled,
        );
  }
}

final initialThemePreferenceProvider = Provider<ThemePreference>((ref) {
  return const ThemePreference();
});

final themePreferenceProvider =
    NotifierProvider<ThemePreferenceNotifier, ThemePreference>(
      ThemePreferenceNotifier.new,
    );
