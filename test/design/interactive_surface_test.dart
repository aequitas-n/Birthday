import 'package:flutter_test/flutter_test.dart';
import 'package:kin/design/theme/quiet_control_surface.dart';
import 'package:kin/design/theme/quiet_interactive.dart';
import 'package:kin/design/theme/quiet_navigation.dart';
import 'package:kin/design/tokens/color_tokens.dart';

void main() {
  group('QuietInteractive', () {
    const interactive = QuietInteractive.light();

    test('desk primary CTA is cream parchment with brown ink', () {
      expect(
        interactive.actionFill(QuietControlSurface.desk),
        ColorTokens.vdPaperHighlight,
      );
      expect(
        interactive.actionInk(
          QuietControlSurface.desk,
          ColorTokens.vdCreamPrimary,
        ),
        ColorTokens.vdInkPrimary,
      );
    });

    test('parchment host keeps burgundy CTA for card/sheet contrast', () {
      expect(
        interactive.actionFill(QuietControlSurface.parchment),
        ColorTokens.vdBurgundy,
      );
    });

    test('sheet surface is warm parchment, not diary raised brown', () {
      expect(interactive.sheet, ColorTokens.vdPaperWarm);
      expect(interactive.sheet, isNot(ColorTokens.vdDiaryRaised));
    });
  });

  group('QuietNavigation', () {
    const nav = QuietNavigation.light();

    test('nav surface matches Journal-Card cream', () {
      expect(nav.surface, ColorTokens.vdJournalCardCream);
      expect(nav.surface, isNot(ColorTokens.vdDiaryCanvas));
      expect(nav.inkActive, ColorTokens.vdInkPrimary);
      expect(nav.indicator, ColorTokens.vdBurgundy);
    });
  });
}
