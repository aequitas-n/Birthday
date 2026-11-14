import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/design/components/journal/q_animated_illustration.dart';
import 'package:kin/design/components/journal/q_mood_illustration.dart';
import 'package:kin/design/components/navigation/q_diary_chrome_strip.dart';
import 'package:kin/design/components/surfaces/q_theme_surfaces.dart';
import 'package:kin/design/theme/app_theme_definition.dart';
import 'package:kin/design/theme/product_themes.dart';
import 'package:kin/design/theme/quiet_theme.dart';

import '../support/quiet_test_app.dart';

/// Phase 3 image-pipeline probes (display-size decode + Neon mood sizing).
void main() {
  setUpAll(loadQuietFonts);

  tearDown(() {
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
  });

  testWidgets('PHASE3: Vintage shell uses display-sized decode', (
    tester,
  ) async {
    await _pumpShell(tester, ProductThemes.vintageDiary);

    final cache = PaintingBinding.instance.imageCache;
    // ignore: avoid_print — Phase 3 evidence
    print(
      'PHASE3_VINTAGE_SHELL '
      'images=${cache.currentSize} '
      'bytes=${cache.currentSizeBytes}',
    );

    final bg = _firstAssetImage(
      tester,
      ProductThemes.vintageDiary.assets.backgrounds.app!,
    );
    expect(bg.image, isA<ResizeImage>());
    expect((bg.image as ResizeImage).height, 844);
    expect(cache.currentSizeBytes, lessThan(6 * 1024 * 1024));
  });

  testWidgets('Neon moods share one bounded atlas decode', (tester) async {
    const moodId = 'joyful';
    final neonPath = ProductThemes.neonArcade.assets.mood.illustration(moodId)!;

    await tester.binding.setSurfaceSize(const Size(390, 844));
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 3;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
      tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      QuietTestApp(
        theme: const QuietTheme.neonArcade(),
        appTheme: ProductThemes.neonArcade,
        devicePixelRatio: 3,
        child: const Center(
          child: QMoodIllustration(
            moodId: moodId,
            size: MoodIllustrationSize.todayPreview,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpQuietImages();

    final sprite = tester.widget<QAnimatedIllustration>(
      find.byType(QAnimatedIllustration),
    );
    expect(sprite.asset, neonPath);
    final status = await AssetImage(
      neonPath,
    ).obtainCacheStatus(configuration: ImageConfiguration.empty);
    expect(status?.keepAlive, isTrue);
    // Four-frame loops share one atlas, rather than decoding a large image for
    // every mood or scheduling an always-running GIF decoder.
    expect(
      PaintingBinding.instance.imageCache.currentSizeBytes,
      lessThan(8 * 1024 * 1024),
    );
    expect(find.byType(Image), findsNothing);
  });
}

Future<void> _pumpShell(
  WidgetTester tester,
  AppThemeDefinition definition,
) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(() {
    tester.view
      ..resetPhysicalSize()
      ..resetDevicePixelRatio();
    tester.binding.setSurfaceSize(null);
  });

  await tester.pumpWidget(
    QuietTestApp(
      theme: definition.quiet,
      appTheme: definition,
      child: const Stack(
        fit: StackFit.expand,
        children: [
          QuietThemeBackdrop(),
          Align(
            alignment: Alignment.bottomCenter,
            child: QDiaryChromeStrip(
              child: SizedBox(height: 56, width: double.infinity),
            ),
          ),
        ],
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pumpQuietImages();
}

Image _firstAssetImage(WidgetTester tester, String assetPath) {
  final images = tester.widgetList<Image>(find.byType(Image)).where((image) {
    var provider = image.image;
    while (provider is ResizeImage) {
      provider = provider.imageProvider;
    }
    return provider is AssetImage && provider.assetName == assetPath;
  });
  expect(images, isNotEmpty, reason: 'expected Image for $assetPath');
  return images.first;
}
