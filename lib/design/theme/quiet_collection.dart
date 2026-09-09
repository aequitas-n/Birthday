import 'dart:ui';

import 'package:kin/design/tokens/color_tokens.dart';

/// The sole product atmosphere: Vintage Diary.
///
/// Previous superficial colour collections (Ember, Ocean, etc.) are retired.
/// The app wears one visual identity — an old personal journal brought into
/// a modern interface.
enum QuietCollection {
  vintageDiary('Vintage Diary', QuietNeutralFamily.warm)
  ;

  const QuietCollection(this.label, this.neutrals);

  /// Shown in Settings when relevant. Never an identifier, never uppercased.
  final String label;

  final QuietNeutralFamily neutrals;

  /// Faded burgundy accent on the dark diary background.
  Color accent({required bool dark}) =>
      dark ? ColorTokens.vdTerracottaSoft : ColorTokens.vdBurgundy;

  /// Accent while pressed.
  Color accentPressed({required bool dark}) =>
      dark ? ColorTokens.vdTerracotta : ColorTokens.vdBurgundyMuted;
}

/// Neutral family retained for internal resolution — Vintage Diary is warm.
enum QuietNeutralFamily { warm, cool, verdant }

/// Which presentation adaptation of Vintage Diary is active.
///
/// All three share the same visual identity; they differ only in contrast
/// intensity for accessibility and display type.
enum QuietBrightness { light, dark, amoled }

/// Neutrals for the Vintage Diary dark atmosphere.
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
    // Vintage Diary always resolves to the dark parchment atmosphere.
    // [dark] toggles contrast intensity, not a separate visual identity.
    return dark ? _highContrast : _standard;
  }

  /// Standard Vintage Diary — cream ink on aged dark paper.
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

  /// Slightly brighter cream for reduced-glare / high-contrast conditions.
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
