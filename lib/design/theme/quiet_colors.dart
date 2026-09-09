import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:kin/design/theme/quiet_collection.dart';
import 'package:kin/design/tokens/color_tokens.dart';

/// Semantic colour roles.
///
/// Widgets read these names. They never read [ColorTokens], and they never
/// invent a shade with `withOpacity` — if a shade is needed it becomes a
/// named role here.
///
/// Specified in docs/06-color.md §2.
@immutable
final class QuietColors {
  const QuietColors({
    required this.brightness,
    required this.collection,
    required this.heroTint,
    required this.canvas,
    required this.surface,
    required this.raised,
    required this.sunken,
    required this.hairline,
    required this.hairlineStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textInverse,
    required this.accent,
    required this.accentPressed,
    required this.accentWash,
    required this.danger,
    required this.dangerWash,
    required this.scrim,
    required this.selection,
    required this.monogramTints,
    required this.transparent,
  });

  /// Vintage Diary — standard contrast on the dark parchment background.
  const QuietColors.light()
    : brightness = Brightness.dark,
      collection = QuietCollection.vintageDiary,
      heroTint = ColorTokens.vdBurgundy,
      canvas = ColorTokens.vdDiaryCanvas,
      surface = ColorTokens.vdDiarySurface,
      raised = ColorTokens.vdDiaryRaised,
      sunken = ColorTokens.vdDiarySunken,
      hairline = ColorTokens.vdDiaryHairline,
      hairlineStrong = ColorTokens.vdDiaryHairlineStrong,
      textPrimary = ColorTokens.vdCreamPrimary,
      textSecondary = ColorTokens.vdCreamSecondary,
      textTertiary = ColorTokens.vdCreamTertiary,
      textInverse = ColorTokens.vdCreamPrimary,
      accent = ColorTokens.vdBurgundy,
      accentPressed = ColorTokens.vdBurgundyMuted,
      accentWash = ColorTokens.vdAccentWash,
      danger = ColorTokens.dangerDark,
      dangerWash = ColorTokens.dangerWashDark,
      scrim = ColorTokens.vdScrim,
      selection = ColorTokens.vdSelection,
      monogramTints = ColorTokens.monogramDark,
      transparent = ColorTokens.transparent;

  /// Vintage Diary — slightly brighter cream for reduced-glare reading.
  const QuietColors.dark()
    : brightness = Brightness.dark,
      collection = QuietCollection.vintageDiary,
      heroTint = ColorTokens.vdBurgundyMuted,
      canvas = ColorTokens.vdCanvasDark,
      surface = ColorTokens.vdSurfaceDark,
      raised = ColorTokens.vdRaisedDark,
      sunken = ColorTokens.vdSunkenDark,
      hairline = ColorTokens.vdHairlineDark,
      hairlineStrong = ColorTokens.vdHairlineStrongDark,
      textPrimary = ColorTokens.vdTextPrimaryDark,
      textSecondary = ColorTokens.vdTextSecondaryDark,
      textTertiary = ColorTokens.vdTextTertiaryDark,
      textInverse = ColorTokens.vdTextPrimaryDark,
      accent = ColorTokens.vdTerracottaSoft,
      accentPressed = ColorTokens.vdTerracotta,
      accentWash = ColorTokens.vdAccentWashDark,
      danger = ColorTokens.dangerDark,
      dangerWash = ColorTokens.dangerWashDark,
      scrim = ColorTokens.vdScrimDark,
      selection = ColorTokens.vdSelection,
      monogramTints = ColorTokens.monogramDark,
      transparent = ColorTokens.transparent;

  /// Vintage Diary — deepest black-brown for AMOLED, same identity.
  const QuietColors.amoled()
    : brightness = Brightness.dark,
      collection = QuietCollection.vintageDiary,
      heroTint = ColorTokens.vdBurgundy,
      canvas = ColorTokens.vdCanvasAmoled,
      surface = ColorTokens.vdSurfaceAmoled,
      raised = ColorTokens.vdRaisedAmoled,
      sunken = ColorTokens.vdSunkenAmoled,
      hairline = ColorTokens.vdHairlineAmoled,
      hairlineStrong = ColorTokens.vdHairlineStrongAmoled,
      textPrimary = ColorTokens.vdTextPrimaryDark,
      textSecondary = ColorTokens.vdCreamSecondary,
      textTertiary = ColorTokens.vdCreamTertiary,
      textInverse = ColorTokens.vdTextPrimaryDark,
      accent = ColorTokens.vdTerracottaSoft,
      accentPressed = ColorTokens.vdTerracotta,
      accentWash = ColorTokens.vdAccentWashAmoled,
      danger = ColorTokens.dangerDark,
      dangerWash = ColorTokens.dangerWashDark,
      scrim = ColorTokens.vdScrimAmoled,
      selection = ColorTokens.vdSelection,
      monogramTints = ColorTokens.monogramDark,
      transparent = ColorTokens.transparent;

  /// Resolves Vintage Diary at the requested contrast level.
  factory QuietColors.of(
    QuietCollection _, {
    required bool dark,
    bool amoled = false,
  }) {
    if (amoled) return const QuietColors.amoled();
    if (dark) return const QuietColors.dark();
    return const QuietColors.light();
  }

  /// Six tints for people without a photo, in the collection's own family.
  factory QuietColors.lerp(QuietColors a, QuietColors b, double t) {
    if (identical(a, b)) return a;
    return QuietColors(
      brightness: t < 0.5 ? a.brightness : b.brightness,
      collection: t < 0.5 ? a.collection : b.collection,
      heroTint: Color.lerp(a.heroTint, b.heroTint, t)!,
      canvas: Color.lerp(a.canvas, b.canvas, t)!,
      surface: Color.lerp(a.surface, b.surface, t)!,
      raised: Color.lerp(a.raised, b.raised, t)!,
      sunken: Color.lerp(a.sunken, b.sunken, t)!,
      hairline: Color.lerp(a.hairline, b.hairline, t)!,
      hairlineStrong: Color.lerp(a.hairlineStrong, b.hairlineStrong, t)!,
      textPrimary: Color.lerp(a.textPrimary, b.textPrimary, t)!,
      textSecondary: Color.lerp(a.textSecondary, b.textSecondary, t)!,
      textTertiary: Color.lerp(a.textTertiary, b.textTertiary, t)!,
      textInverse: Color.lerp(a.textInverse, b.textInverse, t)!,
      accent: Color.lerp(a.accent, b.accent, t)!,
      accentPressed: Color.lerp(a.accentPressed, b.accentPressed, t)!,
      accentWash: Color.lerp(a.accentWash, b.accentWash, t)!,
      danger: Color.lerp(a.danger, b.danger, t)!,
      dangerWash: Color.lerp(a.dangerWash, b.dangerWash, t)!,
      scrim: Color.lerp(a.scrim, b.scrim, t)!,
      selection: Color.lerp(a.selection, b.selection, t)!,
      monogramTints: t < 0.5 ? a.monogramTints : b.monogramTints,
      transparent: Color.lerp(a.transparent, b.transparent, t)!,
    );
  }

  final Brightness brightness;

  /// The collection these roles were resolved from.
  final QuietCollection collection;

  /// Deep accent used to tint hero gradients, so a photograph sits in the
  /// collection's light rather than under a neutral grey wash.
  final Color heroTint;

  /// Level 0. Most of the screen is this.
  final Color canvas;

  /// Level 1. A distinct region of content on the canvas.
  final Color surface;

  /// Level 2. Something temporarily above the page.
  final Color raised;

  /// Level −1. Input wells and recessed regions.
  final Color sunken;

  final Color hairline;
  final Color hairlineStrong;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  /// For text sitting on an accent fill.
  final Color textInverse;

  /// The single accent. Permitted on roughly 2% of any screen.
  final Color accent;
  final Color accentPressed;
  final Color accentWash;

  final Color danger;
  final Color dangerWash;

  final Color scrim;

  /// Text selection highlight.
  final Color selection;

  /// Six low-chroma tints for people without a photo. They should read as
  /// paper stock, not as colour-coding.
  final List<Color> monogramTints;

  /// Fully transparent — for overlays on the diary background.
  final Color transparent;

  /// Deterministic tint for a person, so an avatar never changes colour
  /// between launches.
  Color monogramTintFor(String seed) {
    var hash = 0;
    for (var i = 0; i < seed.length; i++) {
      hash = (hash * 31 + seed.codeUnitAt(i)) & 0x7fffffff;
    }
    return monogramTints[hash % monogramTints.length];
  }
}
