import 'package:flutter_test/flutter_test.dart';
import 'package:kin/design/theme/app_theme_assets.dart';
import 'package:kin/design/theme/product_theme_id.dart';
import 'package:kin/design/theme/product_themes.dart';
import 'package:kin/design/tokens/type_tokens.dart';
import 'package:kin/design/tokens/vintage_diary_tokens.dart';
import 'package:kin/domain/models/settings.dart';

void main() {
  group('ProductThemeId', () {
    test('storage keys are stable', () {
      expect(ProductThemeId.quietDefault.storageKey, 'default');
      expect(ProductThemeId.vintageDiary.storageKey, 'vintage_diary');
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
    test('Default is asset-free with Caveat handwriting + Fraunces editorial', () {
      final theme = ProductThemes.quietDefault;
      expect(theme.id, ProductThemeId.quietDefault);
      expect(theme.assets.backgrounds.app, isNull);
      expect(theme.quiet.text.expression.primaryFamily, 'Caveat');
      expect(theme.quiet.text.expression.secondaryFamily, 'Fraunces');
      expect(
        theme.quiet.text.expression.primaryFamily,
        QuietTypography.quietDefault().expression.primaryFamily,
      );
      expect(theme.quiet.text.journalWriting.fontFamily, 'Caveat');
      expect(theme.quiet.text.pageTitle.fontFamily, 'Fraunces');
    });

    test('Vintage preserves current asset paths', () {
      final theme = ProductThemes.vintageDiary;
      expect(theme.id, ProductThemeId.vintageDiary);
      expect(theme.assets.backgrounds.app, VintageDiaryAssets.background);
      expect(theme.assets.backgrounds.journalCard, VintageDiaryAssets.journalCard);
      expect(theme.assets.chrome.navStrip, VintageDiaryAssets.chromeStrip);
      expect(theme.assets.mood.emptyInvite, VintageDiaryAssets.excitedHome);
      expect(theme.quiet.text.expression.primaryFamily, 'Caveat');
      expect(theme.quiet.text.expression.secondaryFamily, 'Fraunces');
    });

    test('switching themes isolates Decorative assets', () {
      final def = ProductThemes.quietDefault.assets;
      final vin = ProductThemes.vintageDiary.assets;
      expect(def.backgrounds.app, isNot(vin.backgrounds.app));
      expect(def.chrome.profileCard, isNull);
      expect(vin.chrome.profileCard, isNotNull);
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
