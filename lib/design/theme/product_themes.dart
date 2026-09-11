import 'package:kin/design/theme/app_theme_assets.dart';
import 'package:kin/design/theme/app_theme_definition.dart';
import 'package:kin/design/theme/product_theme_id.dart';
import 'package:kin/design/theme/quiet_collection.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/design/tokens/neon_arcade_tokens.dart';
import 'package:kin/design/tokens/user_strip_geometry.dart';
import 'package:kin/design/tokens/vintage_diary_tokens.dart';

/// Registry of first-class product themes.
///
/// Screens never branch on theme identity — they consume [AppThemeDefinition]
/// via `context.appTheme`.
abstract final class ProductThemes {
  static const AppThemeDefinition quietDefault = AppThemeDefinition(
    id: ProductThemeId.quietDefault,
    label: 'Default',
    quiet: QuietTheme.quietDefault(),
    assets: AppThemeAssets.none(),
  );

  static final AppThemeDefinition vintageDiary = AppThemeDefinition(
    id: ProductThemeId.vintageDiary,
    label: 'Vintage Diary',
    quiet: const QuietTheme.light(),
    assets: AppThemeAssets(
      backgrounds: AppThemeBackgrounds(
        app: VintageDiaryAssets.background,
        journalCard: VintageDiaryAssets.journalCard,
        calendar: VintageDiaryAssets.calendar,
      ),
      chrome: AppThemeChrome(
        navStrip: VintageDiaryAssets.chromeStrip,
        navStripOpaqueFraction: VintageDiaryAssets.chromeStripOpaqueFraction,
        navStripAspectRatio: VintageDiaryAssets.chromeStripAspectRatio,
        navStripRevealBackdrop: true,
        searchStrip: VintageDiaryAssets.search,
        birthdayStrip: VintageDiaryAssets.userStrip,
        birthdayStripLayout: UserStripGeometry.vintage,
        profileCard: VintageDiaryAssets.profileCard,
      ),
      mood: AppThemeMoodAssets(
        illustrations: {
          for (final id in const [
            'joyful',
            'calm',
            'sad',
            'affection',
            'anxious',
            'frustrated',
            'surprised',
            'neutral',
          ])
            if (VintageDiaryAssets.moodIllustration(id) != null)
              id: VintageDiaryAssets.moodIllustration(id)!,
        },
        emptyInvite: VintageDiaryAssets.excitedHome,
      ),
      layout: AppThemeSurfaceLayout(
        journalCardAspectRatio: VintageDiaryAssets.journalCardAspectRatio,
        journalCardCornerRadius: VintageDiaryAssets.journalCardCornerRadius,
        profileCard: VintageDiaryAssets.profileLayout,
        galleryCardWidthFraction: VintageDiaryAssets.galleryCardWidthFraction,
        galleryCardHeightFraction: VintageDiaryAssets.galleryCardHeightFraction,
        galleryCardMaxHeight: VintageDiaryAssets.galleryCardMaxHeight,
        galleryCardMaxWidth: VintageDiaryAssets.galleryCardMaxWidth,
      ),
    ),
  );

  /// Neon Arcade — HUD chrome + CRT cards. Search strip stays null so that
  /// component keeps the intentional Default simple fallback. Birthday strip
  /// uses the Neon hanging tag asset.
  static final AppThemeDefinition neonArcade = AppThemeDefinition(
    id: ProductThemeId.neonArcade,
    label: 'Neon Arcade',
    quiet: const QuietTheme.neonArcade(),
    assets: AppThemeAssets(
      backgrounds: AppThemeBackgrounds(
        app: NeonArcadeAssets.background,
        journalCard: NeonArcadeAssets.journalCard,
        calendar: NeonArcadeAssets.calendar,
      ),
      chrome: AppThemeChrome(
        navStrip: NeonArcadeAssets.chromeStrip,
        navStripOpaqueFraction: NeonArcadeAssets.chromeStripOpaqueFraction,
        navStripAspectRatio: NeonArcadeAssets.chromeStripAspectRatio,
        navStripRevealBackdrop: true,
        // searchStrip intentionally omitted (Default fallback).
        birthdayStrip: NeonArcadeAssets.userStrip,
        birthdayStripLayout: UserStripGeometry.neon,
        profileCard: NeonArcadeAssets.profileCard,
      ),
      mood: AppThemeMoodAssets(
        illustrations: {
          for (final id in const [
            'joyful',
            'calm',
            'sad',
            'affection',
            'anxious',
            'frustrated',
            'surprised',
            'neutral',
          ])
            if (NeonArcadeAssets.moodIllustration(id) != null)
              id: NeonArcadeAssets.moodIllustration(id)!,
        },
        emptyInvite: NeonArcadeAssets.excitedHome,
      ),
      layout: AppThemeSurfaceLayout(
        journalCardContent: NeonArcadeAssets.journalCardContent,
        journalCardAspectRatio: NeonArcadeAssets.journalCardAspectRatio,
        journalCardCornerRadius: NeonArcadeAssets.journalCardCornerRadius,
        profileCard: NeonArcadeAssets.profileLayout,
        galleryCardWidthFraction: NeonArcadeAssets.galleryCardWidthFraction,
        galleryCardHeightFraction: NeonArcadeAssets.galleryCardHeightFraction,
        galleryCardMaxHeight: NeonArcadeAssets.galleryCardMaxHeight,
      ),
    ),
  );

  static List<AppThemeDefinition> get all => [
    quietDefault,
    vintageDiary,
    neonArcade,
  ];

  static AppThemeDefinition resolve(ProductThemeId id) => switch (id) {
    ProductThemeId.quietDefault => quietDefault,
    ProductThemeId.vintageDiary => vintageDiary,
    ProductThemeId.neonArcade => neonArcade,
  };

  /// Fallback for tests that only supply a [QuietTheme].
  static AppThemeDefinition matchingQuiet(QuietTheme quiet) {
    return switch (quiet.collection) {
      QuietCollection.quietDefault => quietDefault,
      QuietCollection.neonArcade => neonArcade.copyWith(quiet: quiet),
      QuietCollection.vintageDiary => vintageDiary.copyWith(quiet: quiet),
    };
  }
}
