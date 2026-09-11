import 'package:flutter_test/flutter_test.dart';
import 'package:kin/design/theme/app_theme_assets.dart';
import 'package:kin/design/theme/product_theme_id.dart';
import 'package:kin/design/theme/product_themes.dart';
import 'package:kin/design/tokens/color_tokens.dart';
import 'package:kin/design/tokens/neon_arcade_tokens.dart';
import 'package:kin/design/tokens/type_tokens.dart';
import 'package:kin/design/tokens/vintage_diary_tokens.dart';
import 'package:kin/domain/models/settings.dart';

void main() {
  group('ProductThemeId', () {
    test('storage keys are stable', () {
      expect(ProductThemeId.quietDefault.storageKey, 'default');
      expect(ProductThemeId.vintageDiary.storageKey, 'vintage_diary');
      expect(ProductThemeId.neonArcade.storageKey, 'neon_arcade');
    });

    test('fromStorage defaults missing/unknown to Default', () {
      expect(ProductThemeId.fromStorage(null), ProductThemeId.quietDefault);
      expect(ProductThemeId.fromStorage(''), ProductThemeId.quietDefault);
      expect(ProductThemeId.fromStorage('nope'), ProductThemeId.quietDefault);
    });

    test('fromStorage resolves known keys', () {
      expect(
        ProductThemeId.fromStorage('default'),
        ProductThemeId.quietDefault,
      );
      expect(
        ProductThemeId.fromStorage('vintage_diary'),
        ProductThemeId.vintageDiary,
      );
      expect(
        ProductThemeId.fromStorage('neon_arcade'),
        ProductThemeId.neonArcade,
      );
    });
  });

  group('AppThemeAssets null semantics', () {
    test('none() leaves every audited slot null', () {
      const assets = AppThemeAssets.none();
      expect(assets.backgrounds.app, isNull);
      expect(assets.backgrounds.journalCard, isNull);
      expect(assets.backgrounds.calendar, isNull);
      expect(assets.chrome.navStrip, isNull);
      expect(assets.chrome.searchStrip, isNull);
      expect(assets.chrome.birthdayStrip, isNull);
      expect(assets.chrome.profileCard, isNull);
      expect(assets.mood.emptyInvite, isNull);
      expect(assets.mood.illustration('joyful'), isNull);
    });
  });

  group('product theme definitions', () {
    test('Default is asset-free with Courier personal voice + Fraunces editorial', () {
      final theme = ProductThemes.quietDefault;
      expect(theme.id, ProductThemeId.quietDefault);
      expect(theme.assets.backgrounds.app, isNull);
      expect(theme.quiet.text.expression.primaryFamily, 'CourierPrime');
      expect(theme.quiet.text.expression.secondaryFamily, 'Fraunces');
      expect(
        theme.quiet.text.expression.primaryFamily,
        QuietTypography.quietDefault().expression.primaryFamily,
      );
      expect(theme.quiet.text.journalWriting.fontFamily, 'CourierPrime');
      expect(theme.quiet.text.journalPrompt.fontFamily, 'CourierPrime');
      expect(theme.quiet.text.pageTitle.fontFamily, 'Fraunces');
      expect(theme.quiet.text.expression.primaryFamily, isNot('Caveat'));
    });

    test('Vintage preserves current asset paths', () {
      final theme = ProductThemes.vintageDiary;
      expect(theme.id, ProductThemeId.vintageDiary);
      expect(theme.assets.backgrounds.app, VintageDiaryAssets.background);
      expect(theme.assets.backgrounds.journalCard, VintageDiaryAssets.journalCard);
      expect(theme.assets.chrome.navStrip, VintageDiaryAssets.chromeStrip);
      expect(theme.assets.chrome.navStripRevealBackdrop, isTrue);
      expect(theme.quiet.navigation.surface, ColorTokens.transparent);
      expect(theme.assets.mood.emptyInvite, VintageDiaryAssets.excitedHome);
      expect(
        theme.assets.layout.journalCardAspectRatio,
        closeTo(VintageDiaryAssets.journalCardAspectRatio, 0.001),
      );
      expect(
        theme.assets.layout.journalCardCornerRadius,
        VintageDiaryAssets.journalCardCornerRadius,
      );
      expect(theme.assets.layout.profileCard?.clipPlateCorners, isTrue);
      expect(theme.assets.layout.profileCard?.cornerRadius, 6);
      expect(
        theme.assets.layout.galleryCardWidthFraction,
        VintageDiaryAssets.galleryCardWidthFraction,
      );
      expect(
        theme.assets.layout.galleryCardMaxWidth,
        VintageDiaryAssets.galleryCardMaxWidth,
      );
      expect(theme.quiet.text.expression.primaryFamily, 'Caveat');
      expect(theme.quiet.text.expression.secondaryFamily, 'Fraunces');
      expect(theme.quiet.text.journalWriting.fontFamily, 'Caveat');
    });

    test('Neon Arcade maps HUD assets; search stays Default; birthday strip set', () {
      final theme = ProductThemes.neonArcade;
      expect(theme.id, ProductThemeId.neonArcade);
      expect(theme.assets.backgrounds.app, NeonArcadeAssets.background);
      expect(theme.assets.backgrounds.journalCard, NeonArcadeAssets.journalCard);
      expect(theme.assets.chrome.navStrip, NeonArcadeAssets.chromeStrip);
      expect(theme.assets.chrome.profileCard, NeonArcadeAssets.profileCard);
      expect(theme.assets.chrome.searchStrip, isNull);
      expect(theme.assets.chrome.birthdayStrip, NeonArcadeAssets.userStrip);
      expect(theme.assets.chrome.navStripRevealBackdrop, isTrue);
      expect(theme.assets.mood.emptyInvite, NeonArcadeAssets.excitedHome);
      expect(theme.assets.layout.journalCardContent, isNotNull);
      expect(theme.assets.layout.journalCardAspectRatio, closeTo(1402 / 1122, 0.001));
      expect(
        theme.assets.layout.journalCardCornerRadius,
        NeonArcadeAssets.journalCardCornerRadius,
      );
      expect(theme.assets.layout.profileCard?.aspectRatio, closeTo(941 / 1672, 0.001));
      expect(theme.assets.layout.galleryCardWidthFraction, 1.0);
      expect(theme.assets.layout.galleryCardHeightFraction, 1.0);
      expect(theme.assets.layout.galleryCardMaxHeight, 900.0);
      expect(theme.quiet.navigation.surface, ColorTokens.transparent);
      expect(theme.quiet.text.expression.primaryFamily, 'CourierPrime');
      expect(theme.quiet.text.expression.secondaryFamily, 'CourierPrime');
      expect(theme.quiet.text.expression.primaryFamily, isNot('Caveat'));
      expect(theme.assets.backgrounds.app, isNot(contains('Vintage')));
    });

    test('switching themes isolates Decorative assets', () {
      final def = ProductThemes.quietDefault.assets;
      final vin = ProductThemes.vintageDiary.assets;
      final neon = ProductThemes.neonArcade.assets;
      expect(def.backgrounds.app, isNot(vin.backgrounds.app));
      expect(def.chrome.profileCard, isNull);
      expect(vin.chrome.profileCard, isNotNull);
      expect(neon.chrome.profileCard, isNotNull);
      expect(neon.chrome.searchStrip, isNull);
      expect(vin.chrome.searchStrip, isNotNull);
      expect(ProductThemes.all.length, 3);
    });
  });

  group('AppSettings product theme', () {
    test('fresh AppSettings default to Default theme', () {
      expect(
        const AppSettings().productThemeId,
        ProductThemeId.quietDefault,
      );
    });

    test('copyWith can select Vintage without touching other fields', () {
      const base = AppSettings(notificationsEnabled: true);
      final next = base.copyWith(productThemeId: ProductThemeId.vintageDiary);
      expect(next.productThemeId, ProductThemeId.vintageDiary);
      expect(next.notificationsEnabled, isTrue);
    });
  });
}
