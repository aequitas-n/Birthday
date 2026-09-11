import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/design/components/navigation/q_diary_chrome_strip.dart';
import 'package:kin/design/components/navigation/q_primary_nav.dart';
import 'package:kin/design/theme/app_theme_definition.dart';
import 'package:kin/design/theme/product_themes.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/design/tokens/color_tokens.dart';
import 'package:kin/design/tokens/neon_arcade_tokens.dart';
import 'package:kin/design/tokens/vintage_diary_tokens.dart';

import '../support/quiet_test_app.dart';

void main() {
  setUpAll(loadQuietFonts);

  const viewPadding = EdgeInsets.only(bottom: 34);

  Future<Size> pumpNav(
    WidgetTester tester, {
    required QuietTheme theme,
    required AppThemeDefinition appTheme,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      QuietTestApp(
        theme: theme,
        appTheme: appTheme,
        child: MediaQuery(
          data: const MediaQueryData(
            size: Size(390, 844),
            padding: viewPadding,
            viewPadding: viewPadding,
          ),
          child: const ColoredBox(
            color: Color(0xFF000000),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: QPrimaryNav(
                selected: PrimaryDestination.today,
                onSelected: _noop,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return tester.getSize(find.byType(QPrimaryNav));
  }

  double opaqueBandHeight(double width, double aspect, double opaque) =>
      width / aspect * opaque;

  group('QPrimaryNav theme-surface geometry', () {
    testWidgets('Default stays compact; themed chrome contains opaque band', (
      tester,
    ) async {
      final defaultSize = await pumpNav(
        tester,
        theme: const QuietTheme.quietDefault(),
        appTheme: ProductThemes.quietDefault,
      );
      final vintageSize = await pumpNav(
        tester,
        theme: const QuietTheme.light(),
        appTheme: ProductThemes.vintageDiary,
      );
      final neonSize = await pumpNav(
        tester,
        theme: const QuietTheme.neonArcade(),
        appTheme: ProductThemes.neonArcade,
      );

      expect(defaultSize.width, 390);
      expect(defaultSize.height, greaterThan(48));
      expect(defaultSize.height, lessThan(120));

      final vintageOpaque = opaqueBandHeight(
        390,
        VintageDiaryAssets.chromeStripAspectRatio,
        VintageDiaryAssets.chromeStripOpaqueFraction,
      );
      final neonOpaque = opaqueBandHeight(
        390,
        NeonArcadeAssets.chromeStripAspectRatio,
        NeonArcadeAssets.chromeStripOpaqueFraction,
      );

      // Opaque-band floor — not the full transparent asset frame (~130px).
      expect(vintageSize.height, greaterThanOrEqualTo(vintageOpaque - 0.5));
      expect(neonSize.height, greaterThanOrEqualTo(neonOpaque - 0.5));
      expect(vintageSize.height, lessThan(120));
      expect(neonSize.height, lessThan(120));
      expect(
        ProductThemes.vintageDiary.quiet.navigation.surface,
        ColorTokens.transparent,
      );
    });

    testWidgets('Default paints solid surface — no navStrip asset', (tester) async {
      await pumpNav(
        tester,
        theme: const QuietTheme.quietDefault(),
        appTheme: ProductThemes.quietDefault,
      );

      final paths = collectAssetImagePaths(tester);
      expect(paths, isNot(contains(VintageDiaryAssets.chromeStrip)));
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('Themed strip cover-zooms opaque band (no bottom-gap pin)', (
      tester,
    ) async {
      await pumpNav(
        tester,
        theme: const QuietTheme.light(),
        appTheme: ProductThemes.vintageDiary,
      );

      final paths = collectAssetImagePaths(tester);
      expect(paths, contains(VintageDiaryAssets.chromeStrip));

      final strip = tester.getSize(find.byType(QDiaryChromeStrip));
      final nav = tester.getSize(find.byType(QPrimaryNav));
      expect(strip, nav);

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.fit, BoxFit.cover);
      expect(image.alignment, Alignment.center);
    });

    testWidgets('nav labels stay hittable across Default and Vintage', (
      tester,
    ) async {
      await pumpNav(
        tester,
        theme: const QuietTheme.quietDefault(),
        appTheme: ProductThemes.quietDefault,
      );
      final defaultRects = [
        for (final label in ['Today', 'Kin', 'Journal'])
          tester.getRect(find.text(label)),
      ];

      await pumpNav(
        tester,
        theme: const QuietTheme.light(),
        appTheme: ProductThemes.vintageDiary,
      );
      final vintageRects = [
        for (final label in ['Today', 'Kin', 'Journal'])
          tester.getRect(find.text(label)),
      ];

      expect(vintageRects.length, defaultRects.length);
      for (var i = 0; i < defaultRects.length; i++) {
        expect(vintageRects[i], defaultRects[i]);
      }
    });
  });
}

void _noop(PrimaryDestination _) {}
