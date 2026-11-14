import 'package:flutter_test/flutter_test.dart';
import 'package:kin/design/theme/app_theme_assets.dart';
import 'package:kin/design/theme/product_theme_id.dart';
import 'package:kin/design/theme/product_themes.dart';
import 'package:kin/design/tokens/type_tokens.dart';
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
    test(
      'Default is asset-free with Courier personal voice + Fraunces editorial',
      () {
        const theme = ProductThemes.quietDefault;
        expect(theme.id, ProductThemeId.quietDefault);
        expect(theme.assets.backgrounds.app, isNull);
        expect(theme.quiet.text.expression.primaryFamily, 'CourierPrime');
        expect(theme.quiet.text.expression.secondaryFamily, 'Fraunces');
        expect(
          theme.quiet.text.expression.primaryFamily,
          const QuietTypography.quietDefault().expression.primaryFamily,
        );
        expect(theme.quiet.text.journalWriting.fontFamily, 'CourierPrime');
        expect(theme.quiet.text.journalPrompt.fontFamily, 'CourierPrime');
        expect(theme.quiet.text.pageTitle.fontFamily, 'Fraunces');
        expect(theme.quiet.text.expression.primaryFamily, isNot('Caveat'));
      },
    );

    for (final theme in ProductThemes.all.where((theme) => theme.art != null)) {
      test('${theme.label} owns artwork, natural surfaces, and typography', () {
        final art = theme.art!;
        expect(theme.assets.backgrounds.app, art.background);
        expect(theme.assets.mood.emptyInvite, art.atlas);
        expect(theme.assets.mood.illustration('joyful'), art.atlas);
        expect(theme.assets.backgrounds.journalCard, isNull);
        expect(theme.assets.chrome.navStrip, isNull);
        expect(theme.assets.layout.journalCardAspectRatio, isNull);
        expect(theme.quiet.navigation.surface, art.paper);
      });
    }

    test('switching themes isolates the artwork and keeps saved keys', () {
      expect(ProductThemes.all.length, 8);
      expect(
        ProductThemes.all
            .map((theme) => theme.assets.backgrounds.app)
            .toSet()
            .length,
        8,
      );
      expect(
        ProductThemes.vintageDiary.quiet.text.journalWriting.fontFamily,
        'Caveat',
      );
      expect(
        ProductThemes.vintageDiary.quiet.text.pageTitle.fontFamily,
        'CormorantGaramond',
      );
      expect(
        ProductThemes.neonArcade.quiet.text.pageTitle.fontFamily,
        'ChakraPetch',
      );
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
