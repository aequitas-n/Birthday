import 'package:kin/design/theme/app_theme_assets.dart';
import 'package:kin/design/theme/app_theme_definition.dart';
import 'package:kin/design/theme/birthday_strip_geometry.dart';
import 'package:kin/design/theme/illustrated_theme.dart';
import 'package:kin/design/theme/product_theme_id.dart';
import 'package:kin/design/theme/quiet_collection.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/design/tokens/neon_arcade_tokens.dart';
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

  static final AppThemeDefinition _legacyVintageDiary = AppThemeDefinition(
    id: ProductThemeId.vintageDiary,
    label: 'Vintage Diary',
    quiet: const QuietTheme.light(),
    assets: AppThemeAssets(
      backgrounds: const AppThemeBackgrounds(
        app: VintageDiaryAssets.background,
        journalCard: VintageDiaryAssets.journalCard,
        calendar: VintageDiaryAssets.calendar,
      ),
      chrome: const AppThemeChrome(
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
      layout: const AppThemeSurfaceLayout(
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
  static final AppThemeDefinition _legacyNeonArcade = AppThemeDefinition(
    id: ProductThemeId.neonArcade,
    label: 'Neon Arcade',
    quiet: const QuietTheme.neonArcade(),
    assets: AppThemeAssets(
      backgrounds: const AppThemeBackgrounds(
        app: NeonArcadeAssets.background,
        journalCard: NeonArcadeAssets.journalCard,
        calendar: NeonArcadeAssets.calendar,
      ),
      chrome: const AppThemeChrome(
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
      layout: const AppThemeSurfaceLayout(
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

  static AppThemeDefinition _illustrated(
    ProductThemeId id,
    IllustratedTheme art, {
    QuietCollection collection = QuietCollection.quietDefault,
  }) => AppThemeDefinition(
    id: id,
    label: id.label,
    quiet: art.buildQuiet(collection: collection),
    art: art,
    assets: AppThemeAssets(
      backgrounds: AppThemeBackgrounds(app: art.background),
      chrome: const AppThemeChrome.none(),
      mood: AppThemeMoodAssets(
        illustrations: {
          for (final mood in const [
            'joyful',
            'calm',
            'sad',
            'affection',
            'anxious',
            'frustrated',
            'surprised',
            'neutral',
          ])
            mood: art.atlas,
        },
        emptyInvite: art.atlas,
      ),
    ),
  );

  static final AppThemeDefinition vintageDiary = _illustrated(
    ProductThemeId.vintageDiary,
    IllustratedTheme.vintage,
    collection: QuietCollection.vintageDiary,
  );
  static final AppThemeDefinition neonArcade = _illustrated(
    ProductThemeId.neonArcade,
    IllustratedTheme.arcade,
    collection: QuietCollection.neonArcade,
  );

  static final AppThemeDefinition retroPostcard = _illustrated(
    ProductThemeId.retroPostcard,
    IllustratedTheme.postcard,
  );
  static final AppThemeDefinition sundayComics = _illustrated(
    ProductThemeId.sundayComics,
    IllustratedTheme.comic,
  );
  static final AppThemeDefinition botanicalSketchbook = _illustrated(
    ProductThemeId.botanicalSketchbook,
    IllustratedTheme.botanical,
  );
  static final AppThemeDefinition seasideWatercolor = _illustrated(
    ProductThemeId.seasideWatercolor,
    IllustratedTheme.seaside,
  );
  static final AppThemeDefinition midnightStorybook = _illustrated(
    ProductThemeId.midnightStorybook,
    IllustratedTheme.storybook,
  );

  static List<AppThemeDefinition> get all => [
    quietDefault,
    vintageDiary,
    neonArcade,
    retroPostcard,
    sundayComics,
    botanicalSketchbook,
    seasideWatercolor,
    midnightStorybook,
  ];

  static AppThemeDefinition resolve(ProductThemeId id) => switch (id) {
    ProductThemeId.quietDefault => quietDefault,
    ProductThemeId.vintageDiary => vintageDiary,
    ProductThemeId.neonArcade => neonArcade,
    ProductThemeId.retroPostcard => retroPostcard,
    ProductThemeId.sundayComics => sundayComics,
    ProductThemeId.botanicalSketchbook => botanicalSketchbook,
    ProductThemeId.seasideWatercolor => seasideWatercolor,
    ProductThemeId.midnightStorybook => midnightStorybook,
  };

  /// Legacy callers supplying only a QuietTheme keep the matching original
  /// artwork and contrast. Product runtime always supplies its full definition.
  static AppThemeDefinition matchingQuiet(QuietTheme quiet) {
    return switch (quiet.collection) {
      QuietCollection.quietDefault => quietDefault.copyWith(quiet: quiet),
      QuietCollection.neonArcade => _legacyNeonArcade.copyWith(quiet: quiet),
      QuietCollection.vintageDiary => _legacyVintageDiary.copyWith(
        quiet: quiet,
      ),
    };
  }
}
