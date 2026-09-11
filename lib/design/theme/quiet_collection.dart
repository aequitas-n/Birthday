import 'dart:ui';

import 'package:kin/design/tokens/color_tokens.dart';

/// Neutral family a collection is built on.
enum QuietNeutralFamily { warm, cool, verdant }

/// Visual atmosphere within QuietTheme colour resolution.
///
/// Product themes ([ProductThemeId]) select which collection QuietTheme uses.
/// Prefer product-theme APIs at the app boundary; collections stay an internal
/// colour-atmosphere concept.
enum QuietCollection {
  /// Original Quiet — warm paper, terracotta accent, black ink.
  quietDefault('Default', QuietNeutralFamily.warm),

  /// Vintage Diary — cream parchment on dark desk.
  vintageDiary('Vintage Diary', QuietNeutralFamily.warm),

  /// Neon Arcade — cool cream canvas, magenta/cyan HUD, dark CRT cards.
  neonArcade('Neon Arcade', QuietNeutralFamily.cool);

  const QuietCollection(this.label, this.neutrals);

  final String label;
  final QuietNeutralFamily neutrals;

  Color accent({required bool dark}) => switch (this) {
    QuietCollection.quietDefault =>
      dark ? ColorTokens.ember300 : ColorTokens.ember500,
    QuietCollection.vintageDiary =>
      dark ? ColorTokens.vdTerracottaSoft : ColorTokens.vdBurgundy,
    QuietCollection.neonArcade => ColorTokens.naMagenta,
  };

  Color accentPressed({required bool dark}) => switch (this) {
    QuietCollection.quietDefault =>
      dark ? ColorTokens.ember400 : ColorTokens.ember600,
    QuietCollection.vintageDiary =>
      dark ? ColorTokens.vdTerracotta : ColorTokens.vdBurgundyMuted,
    QuietCollection.neonArcade => ColorTokens.naMagentaPressed,
  };
}

/// Contrast adaptation — orthogonal to product theme identity.
enum QuietBrightness { light, dark, amoled }

/// Neutrals helper retained for Vintage contrast variants.
class QuietNeutrals {
  const QuietNeutrals({
    required this.canvas,
    required this.surface,
    required this.raised,
    required this.sunken,
    required this.hairline,
    required this.hairlineStrong,
    required this.inkPrimary,
    required this.inkSecondary,
    required this.inkTertiary,
  });

  const QuietNeutrals.pureBlack()
    : canvas = ColorTokens.vdCanvasAmoled,
      surface = ColorTokens.vdSurfaceAmoled,
      raised = ColorTokens.vdRaisedAmoled,
      sunken = ColorTokens.vdSunkenAmoled,
      hairline = ColorTokens.vdHairlineAmoled,
      hairlineStrong = ColorTokens.vdHairlineStrongAmoled,
      inkPrimary = ColorTokens.vdTextPrimaryDark,
      inkSecondary = ColorTokens.vdCreamSecondary,
      inkTertiary = ColorTokens.vdCreamTertiary;

  factory QuietNeutrals.of(QuietNeutralFamily _, {required bool dark}) {
    return dark ? _highContrast : _standard;
  }

  static const _standard = QuietNeutrals(
    canvas: ColorTokens.vdDiaryCanvas,
    surface: ColorTokens.vdDiarySurface,
    raised: ColorTokens.vdDiaryRaised,
    sunken: ColorTokens.vdDiarySunken,
    hairline: ColorTokens.vdDiaryHairline,
    hairlineStrong: ColorTokens.vdDiaryHairlineStrong,
    inkPrimary: ColorTokens.vdCreamPrimary,
    inkSecondary: ColorTokens.vdCreamSecondary,
    inkTertiary: ColorTokens.vdCreamTertiary,
  );

  static const _highContrast = QuietNeutrals(
    canvas: ColorTokens.vdCanvasDark,
    surface: ColorTokens.vdSurfaceDark,
    raised: ColorTokens.vdRaisedDark,
    sunken: ColorTokens.vdSunkenDark,
    hairline: ColorTokens.vdHairlineDark,
    hairlineStrong: ColorTokens.vdHairlineStrongDark,
    inkPrimary: ColorTokens.vdTextPrimaryDark,
    inkSecondary: ColorTokens.vdTextSecondaryDark,
    inkTertiary: ColorTokens.vdTextTertiaryDark,
  );

  final Color canvas;
  final Color surface;
  final Color raised;
  final Color sunken;
  final Color hairline;
  final Color hairlineStrong;
  final Color inkPrimary;
  final Color inkSecondary;
  final Color inkTertiary;
}
