import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/design/media/quiet_display_image.dart';

void main() {
  group('QuietDisplayImage', () {
    testWidgets('px multiplies logical extent by devicePixelRatio', (
      tester,
    ) async {
      late int pixels;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(390, 844),
            devicePixelRatio: 2.5,
          ),
          child: Builder(
            builder: (context) {
              pixels = QuietDisplayImage.px(context, 44);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(pixels, 110);
    });

    testWidgets('at preserves aspect by sizing the longer edge only', (
      tester,
    ) async {
      late ImageProvider resized;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(390, 844),
            devicePixelRatio: 2,
          ),
          child: Builder(
            builder: (context) {
              resized = QuietDisplayImage.at(
                const AssetImage('assets/themes/Vintage-Diary/vintage-bg.webp'),
                context: context,
                logicalWidth: 390,
                logicalHeight: 844,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resized, isA<ResizeImage>());
      final resize = resized as ResizeImage;
      // Portrait box → height only (aspect preserved for BoxFit.cover).
      expect(resize.width, isNull);
      expect(resize.height, 1688);
    });

    testWidgets('maybeAt is a no-op for unbounded constraints', (tester) async {
      const original = AssetImage('assets/themes/Vintage-Diary/search.webp');
      late ImageProvider result;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(devicePixelRatio: 3),
          child: Builder(
            builder: (context) {
              result = QuietDisplayImage.maybeAt(
                original,
                context: context,
                constraints: const BoxConstraints(),
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(identical(result, original), isTrue);
    });

    testWidgets('cacheSize cover uses longer edge; fill uses both', (
      tester,
    ) async {
      late (int?, int?) cover;
      late (int?, int?) fill;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(devicePixelRatio: 2),
          child: Builder(
            builder: (context) {
              cover = QuietDisplayImage.cacheSize(
                context,
                const Size(390, 80),
                scale: 1.25,
              );
              fill = QuietDisplayImage.cacheSize(
                context,
                const Size(390, 80),
                fit: BoxFit.fill,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      // Landscape strip → width only when covering.
      expect(cover.$1, 975);
      expect(cover.$2, isNull);
      expect(fill.$1, 780);
      expect(fill.$2, 160);
    });
  });
}
