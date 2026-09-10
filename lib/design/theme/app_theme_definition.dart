import 'package:flutter/material.dart' show ThemeExtension;
import 'package:flutter/widgets.dart';
import 'package:kin/design/theme/app_theme_assets.dart';
import 'package:kin/design/theme/product_theme_id.dart';
import 'package:kin/design/theme/quiet_theme.dart';

/// Immutable product theme: Quiet roles + optional decorative assets.
@immutable
final class AppThemeDefinition extends ThemeExtension<AppThemeDefinition> {
  const AppThemeDefinition({
    required this.id,
    required this.label,
    required this.quiet,
    required this.assets,
  });

  final ProductThemeId id;
  final String label;
  final QuietTheme quiet;
  final AppThemeAssets assets;

  bool get hasDecorativeAssets =>
      assets.backgrounds.app != null ||
      assets.chrome.navStrip != null ||
      assets.chrome.profileCard != null;

  @override
  AppThemeDefinition copyWith({
    ProductThemeId? id,
    String? label,
    QuietTheme? quiet,
    AppThemeAssets? assets,
  }) {
    return AppThemeDefinition(
      id: id ?? this.id,
      label: label ?? this.label,
      quiet: quiet ?? this.quiet,
      assets: assets ?? this.assets,
    );
  }

  @override
  AppThemeDefinition lerp(covariant AppThemeDefinition? other, double t) {
    if (other == null) return this;
    // Asset paths snap; QuietTheme lerps for colour animation.
    return AppThemeDefinition(
      id: t < 0.5 ? id : other.id,
      label: t < 0.5 ? label : other.label,
      quiet: quiet.lerp(other.quiet, t),
      assets: t < 0.5 ? assets : other.assets,
    );
  }
}
