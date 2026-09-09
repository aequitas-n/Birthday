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

  group('Vintage Diary theme', () {
    test('is the only collection', () {
      expect(QuietCollection.values, [QuietCollection.vintageDiary]);
    });

    test('uses dark parchment canvas with cream ink', () {
      const colors = QuietColors.light();
      expect(colors.collection, QuietCollection.vintageDiary);
      expect(colors.brightness, Brightness.dark);
      expect(colors.textPrimary.computeLuminance(), greaterThan(0.7));
      expect(colors.canvas.computeLuminance(), lessThan(0.15));
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

    test('primary accent is faded burgundy', () {
      const colors = QuietColors.light();
      expect(colors.accent.toARGB32(), 0xFF713D3A);
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
    test('always resolves Vintage Diary', () {
      const pref = ThemePreference();
      expect(pref.resolve().collection, QuietCollection.vintageDiary);
      expect(pref.resolve(Brightness.dark).mode, QuietBrightness.light);
    });
  });
}
