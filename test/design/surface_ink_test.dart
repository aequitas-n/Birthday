import 'package:flutter_test/flutter_test.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/design/tokens/color_tokens.dart';

void main() {
  group('QuietSurfaceInk', () {
    const theme = QuietTheme.light();

    test('canvas ink is cream on dark diary', () {
      final ink = theme.canvas;
      expect(ink.kind, QuietSurfaceKind.canvas);
      expect(ink.primary, ColorTokens.vdCreamPrimary);
      expect(ink.secondary, ColorTokens.vdCreamSecondary);
      expect(ink.tertiary, ColorTokens.vdCreamTertiary);
      expect(ink.fill, isNull);
      expect(
        theme.inked(theme.text.pageTitle).color,
        ColorTokens.vdCreamPrimary,
      );
      expect(
        theme.inked(theme.text.uiDate, tone: QuietInkTone.secondary).color,
        ColorTokens.vdCreamSecondary,
      );
    });

    test('paper ink is brown on cream card/calendar', () {
      final ink = theme.paper;
      expect(ink.kind, QuietSurfaceKind.paper);
      expect(ink.primary, ColorTokens.vdInkPrimary);
      expect(ink.secondary, ColorTokens.vdInkSecondary);
      expect(ink.fill, ColorTokens.vdPaperWarm);
      expect(
        theme
            .inked(
              theme.text.journalWriting,
              surface: QuietSurfaceKind.paper,
            )
            .color,
        ColorTokens.vdInkPrimary,
      );
    });
  });
}
