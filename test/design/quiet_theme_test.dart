import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/app/theme_controller.dart';
import 'package:kin/design/theme/quiet_collection.dart';
import 'package:kin/design/theme/quiet_colors.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

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

    // QuietTheme's typography field is named `text` rather than `type`
    // precisely because ThemeExtension.type is the map key ThemeData uses.
    // If that ever regresses, this fails.
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

  group('the three themes', () {
    test('AMOLED is true black with canvas and surface identical', () {
      const amoled = QuietColors.amoled();
      expect(amoled.canvas.toARGB32(), 0xFF000000);
      expect(amoled.surface, amoled.canvas);
    });

    test('AMOLED hairlines are stronger than dark, since they carry the '
        'entire structure', () {
      const dark = QuietColors.dark();
      const amoled = QuietColors.amoled();
      expect(
        amoled.hairline.computeLuminance(),
        greaterThan(dark.canvas.computeLuminance()),
      );
    });

    test('light canvas is warm, never pure white', () {
      const light = QuietColors.light();
      expect(light.canvas.toARGB32(), isNot(0xFFFFFFFF));
      expect(light.canvas.r, greaterThan(light.canvas.b));
    });

    test('dark text is never pure white, to reduce halation', () {
      const dark = QuietColors.dark();
      expect(dark.textPrimary.toARGB32(), isNot(0xFFFFFFFF));
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

    test('are low chroma, so they read as paper rather than colour-coding', () {
      for (final tint in const QuietColors.light().monogramTints) {
        final channels = [tint.r, tint.g, tint.b];
        final spread =
            channels.reduce((a, b) => a > b ? a : b) -
            channels.reduce((a, b) => a < b ? a : b);
        expect(spread, lessThan(0.06));
      }
    });
  });

  group('collections', () {
    test('ember resolves to the hand-authored themes, not derived ones', () {
      expect(
        QuietColors.of(QuietCollection.ember, dark: false).canvas,
        const QuietColors.light().canvas,
      );
      expect(
        QuietColors.of(QuietCollection.ember, dark: true).canvas,
        const QuietColors.dark().canvas,
      );
    });

    test('a collection changes the paper, not only the accent', () {
      final warm = QuietColors.of(QuietCollection.ember, dark: false);
      final cool = QuietColors.of(QuietCollection.ocean, dark: false);

      expect(cool.accent, isNot(warm.accent));
      // The point of the whole architecture: swapping an accent alone leaves
      // the 98% of the screen that is paper untouched, and the app feels
      // identical.
      expect(cool.canvas, isNot(warm.canvas));
      expect(cool.surface, isNot(warm.surface));
      expect(cool.textPrimary, isNot(warm.textPrimary));
    });

    test('every collection is legible in both brightnesses', () {
      for (final collection in QuietCollection.values) {
        for (final dark in [false, true]) {
          final colors = QuietColors.of(collection, dark: dark);
          final contrast =
              (colors.textPrimary.computeLuminance() -
                      colors.canvas.computeLuminance())
                  .abs();
          expect(
            contrast,
            greaterThan(0.4),
            reason: '${collection.name} (dark: $dark) has weak ink on paper',
          );
        }
      }
    });

    test(
      'pure black overrides the collection neutrals but keeps its accent',
      () {
        final amoled = QuietColors.of(
          QuietCollection.moss,
          dark: true,
          amoled: true,
        );
        expect(amoled.canvas.toARGB32(), 0xFF000000);
        expect(amoled.accent, QuietCollection.moss.accent(dark: true));
      },
    );

    test('a theme carries its collection so lerp can reach the other one', () {
      final ocean = QuietTheme.of(QuietCollection.ocean, dark: false);
      final moss = QuietTheme.of(QuietCollection.moss, dark: false);

      expect(ocean.collection, QuietCollection.ocean);
      expect(ocean.lerp(moss, 1).collection, QuietCollection.moss);
      expect(ocean.lerp(moss, 0).collection, QuietCollection.ocean);
    });
  });

  group('ThemePreference', () {
    test('a collection resolves against either brightness', () {
      const pref = ThemePreference(collection: QuietCollection.ocean);
      expect(
        pref.resolve(Brightness.light).collection,
        QuietCollection.ocean,
      );
      expect(pref.resolve(Brightness.dark).collection, QuietCollection.ocean);
      expect(pref.resolve(Brightness.dark).mode, QuietBrightness.dark);
    });

    test('system follows the platform', () {
      const pref = ThemePreference();
      expect(pref.resolve(Brightness.light).mode, QuietBrightness.light);
      expect(pref.resolve(Brightness.dark).mode, QuietBrightness.dark);
    });

    test('AMOLED refines dark rather than replacing it', () {
      const pref = ThemePreference(choice: ThemeChoice.dark, amoled: true);
      expect(pref.resolve(Brightness.light).mode, QuietBrightness.amoled);
    });

    test('AMOLED has no effect while light', () {
      const pref = ThemePreference(choice: ThemeChoice.light, amoled: true);
      expect(pref.resolve(Brightness.dark).mode, QuietBrightness.light);
    });
  });
}
