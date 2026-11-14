import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/app/theme_controller.dart';
import 'package:kin/design/theme/product_theme_id.dart';
import 'package:kin/design/theme/product_themes.dart';
import 'package:kin/design/theme/quiet_collection.dart';
import 'package:kin/design/theme/quiet_colors.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/design/tokens/type_tokens.dart';

import '../support/quiet_test_app.dart';

void main() {
  group('QuietTheme lookup', () {
    testWidgets('context.quiet resolves the extension', (tester) async {
      late QuietTheme resolved;
      await tester.pumpQuiet(
        Builder(
          builder: (context) {
            resolved = context.quiet;
            return const SizedBox.shrink();
          },
        ),
        theme: const QuietTheme.dark(),
      );

      expect(resolved.mode, QuietBrightness.dark);
    });

    testWidgets('is keyed by its runtime type', (tester) async {
      late BuildContext ctx;
      await tester.pumpQuiet(
        Builder(
          builder: (context) {
            ctx = context;
            return const SizedBox.shrink();
          },
        ),
      );

      expect(Theme.of(ctx).extension<QuietTheme>(), isNotNull);
    });
  });

  group('QuietTheme.lerp', () {
    test('interpolates colour and holds metrics steady', () {
      const light = QuietTheme.light();
      const dark = QuietTheme.dark();

      final mid = light.lerp(dark, 0.5);

      expect(mid.color.canvas, isNot(light.color.canvas));
      expect(mid.color.canvas, isNot(dark.color.canvas));
      expect(mid.space.base, light.space.base);
      expect(mid.radius.xl, light.radius.xl);
      expect(mid.motion.base, light.motion.base);
    });

    test('reaches the endpoints exactly', () {
      const light = QuietTheme.light();
      const amoled = QuietTheme.amoled();

      expect(light.lerp(amoled, 0).color.canvas, light.color.canvas);
      expect(light.lerp(amoled, 1).color.canvas, amoled.color.canvas);
    });

    test('returns itself when the other side is null', () {
      const light = QuietTheme.light();
      expect(light.lerp(null, 0.5), same(light));
    });
  });

  group('product collections', () {
    test('exposes Default, Vintage Diary, and Neon Arcade', () {
      expect(QuietCollection.values, [
        QuietCollection.quietDefault,
        QuietCollection.vintageDiary,
        QuietCollection.neonArcade,
      ]);
    });

    test('Vintage uses dark parchment canvas with cream ink', () {
      const colors = QuietColors.light();
      expect(colors.collection, QuietCollection.vintageDiary);
      expect(colors.brightness, Brightness.dark);
      expect(colors.textPrimary.computeLuminance(), greaterThan(0.7));
      expect(colors.canvas.computeLuminance(), lessThan(0.15));
    });

    test('Default uses warm paper with dark ink', () {
      const colors = QuietColors.neutral();
      expect(colors.collection, QuietCollection.quietDefault);
      expect(colors.brightness, Brightness.light);
      expect(colors.canvas.computeLuminance(), greaterThan(0.8));
      expect(colors.textPrimary.computeLuminance(), lessThan(0.2));
    });

    test('Neon Arcade uses cool cream canvas with magenta accent', () {
      const colors = QuietColors.neonArcade();
      expect(colors.collection, QuietCollection.neonArcade);
      expect(colors.brightness, Brightness.light);
      expect(colors.canvas.computeLuminance(), greaterThan(0.8));
      expect(colors.textPrimary.computeLuminance(), lessThan(0.2));
      expect(colors.accent.computeLuminance(), lessThan(0.5));
    });

    test('AMOLED is deepest black-brown, not pure black', () {
      const amoled = QuietColors.amoled();
      expect(amoled.canvas.toARGB32(), 0xFF0A0806);
      expect(amoled.surface, isNot(amoled.canvas));
    });

    test('text is never pure white, to reduce halation', () {
      const dark = QuietColors.dark();
      expect(dark.textPrimary.toARGB32(), isNot(0xFFFFFFFF));
    });

    test('Vintage primary accent is faded burgundy', () {
      const colors = QuietColors.light();
      expect(colors.accent.toARGB32(), 0xFF713D3A);
    });

    test('Default primary accent is ember', () {
      const colors = QuietColors.neutral();
      expect(colors.accent.toARGB32(), 0xFFBF6039);
    });
  });

  group('monogram tints', () {
    test('are deterministic for a given seed', () {
      const c = QuietColors.light();
      expect(c.monogramTintFor('person-a'), c.monogramTintFor('person-a'));
    });

    test('spread across the available tints', () {
      const c = QuietColors.light();
      final seen = <Color>{};
      for (var i = 0; i < 60; i++) {
        seen.add(c.monogramTintFor('person-$i'));
      }
      expect(seen.length, greaterThan(1));
    });
  });

  group('ThemePreference', () {
    test('defaults to Default product theme', () {
      const pref = ThemePreference();
      expect(pref.productThemeId, ProductThemeId.quietDefault);
      expect(pref.resolve().collection, QuietCollection.quietDefault);
      expect(
        pref.resolve().text.expression.primaryFamily,
        'CourierPrime',
      );
      expect(
        pref.resolve().text.expression.secondaryFamily,
        'Fraunces',
      );
      expect(pref.resolve().text.journalWriting.fontFamily, isNot('Caveat'));
    });

    test('resolves Vintage Diary when selected', () {
      const pref = ThemePreference(
        productThemeId: ProductThemeId.vintageDiary,
      );
      expect(pref.resolve().collection, QuietCollection.vintageDiary);
      expect(pref.definition.assets.backgrounds.app, isNotNull);
      expect(
        pref.resolve().text.expression.primaryFamily,
        'Caveat',
      );
    });
  });

  group('ProductThemes registry', () {
    test('Default has null decorative assets', () {
      final assets = ProductThemes.quietDefault.assets;
      expect(assets.backgrounds.app, isNull);
      expect(assets.backgrounds.journalCard, isNull);
      expect(assets.chrome.navStrip, isNull);
      expect(assets.mood.emptyInvite, isNull);
    });

    for (final theme in [
      ProductThemes.vintageDiary,
      ProductThemes.neonArcade,
    ]) {
      test(
        '${theme.label} uses generated backdrops and live drawn surfaces',
        () {
          final assets = theme.assets;
          expect(theme.art, isNotNull);
          expect(assets.backgrounds.app, theme.art!.background);
          expect(assets.backgrounds.journalCard, isNull);
          expect(assets.chrome.navStrip, isNull);
          expect(assets.mood.emptyInvite, theme.art!.atlas);
          expect(assets.mood.illustration('joyful'), theme.art!.atlas);
        },
      );
    }
  });

  group('Default typography', () {
    test('uses CourierPrime for personal voice and Fraunces for editorial', () {
      const type = QuietTypography.quietDefault();
      expect(type.expression.primaryFamily, 'CourierPrime');
      expect(type.expression.secondaryFamily, 'Fraunces');
      expect(type.journalWriting.fontFamily, 'CourierPrime');
      expect(type.journalPrompt.fontFamily, 'CourierPrime');
      expect(type.pageTitle.fontFamily, 'Fraunces');
      expect(type.sectionTitle.fontFamily, 'Fraunces');
      expect(type.uiMetadata.fontFamily, 'CourierPrime');
    });
  });

  group('Neon typography', () {
    test(
      'uses CourierPrime for primary and secondary — never Caveat/Fraunces',
      () {
        const type = QuietTypography.neonArcade();
        expect(type.expression.primaryFamily, 'CourierPrime');
        expect(type.expression.secondaryFamily, 'CourierPrime');
        expect(type.journalWriting.fontFamily, 'CourierPrime');
        expect(type.pageTitle.fontFamily, 'CourierPrime');
        expect(type.expression.primaryFamily, isNot('Caveat'));
        expect(type.expression.secondaryFamily, isNot('Fraunces'));
      },
    );
  });
}
