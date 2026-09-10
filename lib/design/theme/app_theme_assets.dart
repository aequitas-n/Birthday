import 'package:flutter/foundation.dart';

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
  });

  /// Fully asset-free theme (Default).
  const AppThemeAssets.none()
    : backgrounds = const AppThemeBackgrounds.none(),
      chrome = const AppThemeChrome.none(),
      mood = const AppThemeMoodAssets.none();

  final AppThemeBackgrounds backgrounds;
  final AppThemeChrome chrome;
  final AppThemeMoodAssets mood;
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
    this.searchStrip,
    this.birthdayStrip,
    this.profileCard,
  });

  const AppThemeChrome.none()
    : navStrip = null,
      searchStrip = null,
      birthdayStrip = null,
      profileCard = null;

  final String? navStrip;
  final String? searchStrip;
  final String? birthdayStrip;
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
