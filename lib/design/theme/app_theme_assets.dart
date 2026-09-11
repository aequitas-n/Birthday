import 'package:flutter/foundation.dart';
import 'package:kin/design/theme/app_theme_surface_layout.dart';
import 'package:kin/design/tokens/user_strip_geometry.dart';

export 'package:kin/design/theme/app_theme_surface_layout.dart';
export 'package:kin/design/tokens/user_strip_geometry.dart' show UserStripLayout;

/// Semantic image slots for a product theme.
///
/// A `null` path means the theme **intentionally** has no image for that
/// element — components must use a solid/simple fallback. It is not an error.
@immutable
final class AppThemeAssets {
  const AppThemeAssets({
    required this.backgrounds,
    required this.chrome,
    required this.mood,
    this.layout = const AppThemeSurfaceLayout.none(),
  });

  /// Fully asset-free theme (Default).
  const AppThemeAssets.none()
    : backgrounds = const AppThemeBackgrounds.none(),
      chrome = const AppThemeChrome.none(),
      mood = const AppThemeMoodAssets.none(),
      layout = const AppThemeSurfaceLayout.none();

  final AppThemeBackgrounds backgrounds;
  final AppThemeChrome chrome;
  final AppThemeMoodAssets mood;

  /// Composition metrics for decorative surfaces (optional per theme).
  final AppThemeSurfaceLayout layout;
}

@immutable
final class AppThemeBackgrounds {
  const AppThemeBackgrounds({
    this.app,
    this.journalCard,
    this.calendar,
  });

  const AppThemeBackgrounds.none()
    : app = null,
      journalCard = null,
      calendar = null;

  /// Full-screen app canvas texture (e.g. vintage-bg).
  final String? app;

  /// Journal memory card paper.
  final String? journalCard;

  /// Journal month calendar parchment.
  final String? calendar;
}

@immutable
final class AppThemeChrome {
  const AppThemeChrome({
    this.navStrip,
    this.navStripOpaqueFraction = 1,
    this.navStripAspectRatio,
    this.navStripRevealBackdrop = false,
    this.searchStrip,
    this.birthdayStrip,
    this.birthdayStripLayout,
    this.profileCard,
  });

  const AppThemeChrome.none()
    : navStrip = null,
      navStripOpaqueFraction = 1,
      navStripAspectRatio = null,
      navStripRevealBackdrop = false,
      searchStrip = null,
      birthdayStrip = null,
      birthdayStripLayout = null,
      profileCard = null;

  final String? navStrip;

  /// Fraction of [navStrip] height that is opaque art (`1` = full frame).
  ///
  /// Values below `1` mean the asset has transparent margins (e.g. a torn
  /// edge). Unless [navStripRevealBackdrop] is true, chrome cover zooms so
  /// this band fills the bar instead of leaving solid gutters behind the
  /// texture.
  final double navStripOpaqueFraction;

  /// Width / height of [navStrip]. Needed when [navStripOpaqueFraction] < 1.
  final double? navStripAspectRatio;

  /// When true, navigation.surface is transparent so the shell backdrop shows
  /// through outside the opaque chrome. Layout height still follows the opaque
  /// band only — transparent asset margins never inflate the bar.
  final bool navStripRevealBackdrop;

  final String? searchStrip;
  final String? birthdayStrip;

  /// Content / stack metrics for [birthdayStrip]. Defaults to Vintage hanging
  /// geometry when null and a strip asset is present.
  final UserStripLayout? birthdayStripLayout;

  final String? profileCard;
}

@immutable
final class AppThemeMoodAssets {
  const AppThemeMoodAssets({
    this.illustrations = const <String, String>{},
    this.emptyInvite,
  });

  const AppThemeMoodAssets.none()
    : illustrations = const <String, String>{},
      emptyInvite = null;

  /// moodId → asset path.
  final Map<String, String> illustrations;

  /// Today empty-journal invite character (Excited-home in Vintage).
  final String? emptyInvite;

  String? illustration(String moodId) => illustrations[moodId];
}
