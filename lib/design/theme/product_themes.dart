import 'package:kin/design/theme/app_theme_assets.dart';
import 'package:kin/design/theme/app_theme_definition.dart';
import 'package:kin/design/theme/product_theme_id.dart';
import 'package:kin/design/theme/quiet_theme.dart';
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
        searchStrip: VintageDiaryAssets.search,
        birthdayStrip: VintageDiaryAssets.userStrip,
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
    ),
  );

  static List<AppThemeDefinition> get all => [
    quietDefault,
    vintageDiary,
  ];

  static AppThemeDefinition resolve(ProductThemeId id) => switch (id) {
    ProductThemeId.quietDefault => quietDefault,
    ProductThemeId.vintageDiary => vintageDiary,
  };

  /// Fallback for tests that only supply a [QuietTheme].
  static AppThemeDefinition matchingQuiet(QuietTheme quiet) {
    if (quiet.collection == quietDefault.quiet.collection) {
      return quietDefault;
    }
    return vintageDiary.copyWith(quiet: quiet);
  }
}
