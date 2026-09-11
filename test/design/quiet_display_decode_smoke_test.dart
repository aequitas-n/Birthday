import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/design/components/surfaces/q_screen.dart';
import 'package:kin/design/theme/product_themes.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/design/tokens/vintage_diary_tokens.dart';

import '../support/quiet_test_app.dart';

void main() {
  setUpAll(loadQuietFonts);

  testWidgets('Vintage canvas loads display-sized background asset', (tester) async {
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
        theme: const QuietTheme.light(),
        appTheme: ProductThemes.vintageDiary,
        child: const QScreen(child: SizedBox.expand()),
      ),
    );
    await tester.pumpAndSettle();

    final paths = collectAssetImagePaths(tester);
    expect(paths, contains(VintageDiaryAssets.background));

    final images = tester.widgetList<Image>(find.byType(Image)).where((image) {
      var provider = image.image;
      while (provider is ResizeImage) {
        provider = provider.imageProvider;
      }
      return provider is AssetImage &&
          provider.assetName == VintageDiaryAssets.background;
    });
    expect(images, isNotEmpty);
    final bg = images.first;
    expect(bg.fit, BoxFit.cover);
    // Image.asset with cache hints wraps ResizeImage — portrait viewport
    // sizes by height only so aspect ratio stays intrinsic.
    expect(bg.image, isA<ResizeImage>());
    expect((bg.image as ResizeImage).width, isNull);
    expect((bg.image as ResizeImage).height, 844);
  });
}
