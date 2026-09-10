import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/design/theme/app_theme_definition.dart';
import 'package:kin/design/theme/product_theme_id.dart';
import 'package:kin/design/theme/product_themes.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/domain/models/settings.dart';

/// Session appearance — selected [ProductThemeId] resolved to a definition.
@immutable
class ThemePreference {
  const ThemePreference({
    this.productThemeId = ProductThemeId.quietDefault,
  });

  factory ThemePreference.fromSettings(AppSettings settings) {
    return ThemePreference(productThemeId: settings.productThemeId);
  }

  final ProductThemeId productThemeId;

  AppThemeDefinition get definition => ProductThemes.resolve(productThemeId);

  QuietTheme resolve([Brightness? _]) => definition.quiet;

  ThemePreference copyWith({ProductThemeId? productThemeId}) {
    return ThemePreference(
      productThemeId: productThemeId ?? this.productThemeId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ThemePreference && other.productThemeId == productThemeId;
  }

  @override
  int get hashCode => productThemeId.hashCode;
}

class ThemePreferenceNotifier extends Notifier<ThemePreference> {
  @override
  ThemePreference build() {
    final initial = ref.watch(initialThemePreferenceProvider);
    final async = ref.watch(appSettingsProvider);
    return async.maybeWhen(
      data: ThemePreference.fromSettings,
      orElse: () => initial,
    );
  }

  Future<void> setProductTheme(ProductThemeId id) async {
    final repo = ref.read(settingsRepositoryProvider);
    final current = await repo.readSettings();
    if (current.productThemeId == id) return;
    await repo.saveSettings(current.copyWith(productThemeId: id));
  }
}

final initialThemePreferenceProvider = Provider<ThemePreference>((ref) {
  return const ThemePreference();
});

final themePreferenceProvider =
    NotifierProvider<ThemePreferenceNotifier, ThemePreference>(
      ThemePreferenceNotifier.new,
    );
