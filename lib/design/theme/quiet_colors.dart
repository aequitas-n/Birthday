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
  });

  /// Warm paper. Autumn Ember, resolved light.
  const QuietColors.light()
    : brightness = Brightness.light,
      collection = QuietCollection.ember,
      heroTint = ColorTokens.ember700,
      canvas = ColorTokens.paperCanvas,
      surface = ColorTokens.paperSurface,
      raised = ColorTokens.paperSurface,
      sunken = ColorTokens.paperSunken,
      hairline = ColorTokens.paperHairline,
      hairlineStrong = ColorTokens.paperHairlineStrong,
      textPrimary = ColorTokens.paperInkPrimary,
      textSecondary = ColorTokens.paperInkSecondary,
      textTertiary = ColorTokens.paperInkTertiary,
      textInverse = ColorTokens.paperCanvas,
      accent = ColorTokens.ember500,
      accentPressed = ColorTokens.ember600,
      accentWash = ColorTokens.ember50,
      danger = ColorTokens.dangerLight,
      dangerWash = ColorTokens.dangerWashLight,
      scrim = ColorTokens.scrimLight,
      selection = ColorTokens.selectionLight,
      monogramTints = ColorTokens.monogramLight;

  /// Warm charcoal. Autumn Ember, resolved dark.
  const QuietColors.dark()
    : brightness = Brightness.dark,
      collection = QuietCollection.ember,
      heroTint = ColorTokens.ember700,
      canvas = ColorTokens.charcoalCanvas,
      surface = ColorTokens.charcoalSurface,
      raised = ColorTokens.charcoalRaised,
      sunken = ColorTokens.charcoalSunken,
      hairline = ColorTokens.charcoalHairline,
      hairlineStrong = ColorTokens.charcoalHairlineStrong,
      textPrimary = ColorTokens.charcoalInkPrimary,
      textSecondary = ColorTokens.charcoalInkSecondary,
      textTertiary = ColorTokens.charcoalInkTertiary,
      textInverse = ColorTokens.charcoalCanvas,
      accent = ColorTokens.ember300,
      accentPressed = ColorTokens.ember400,
      accentWash = ColorTokens.accentWashDark,
      danger = ColorTokens.dangerDark,
      dangerWash = ColorTokens.dangerWashDark,
      scrim = ColorTokens.scrimDark,
      selection = ColorTokens.selectionDark,
      monogramTints = ColorTokens.monogramDark;

  /// True black. Canvas and surface are identical, so hairlines carry the
  /// entire visual structure of every screen.
  const QuietColors.amoled()
    : brightness = Brightness.dark,
      collection = QuietCollection.ember,
      heroTint = ColorTokens.ember700,
      canvas = ColorTokens.voidCanvas,
      surface = ColorTokens.voidCanvas,
      raised = ColorTokens.voidRaised,
      sunken = ColorTokens.voidCanvas,
      hairline = ColorTokens.voidHairline,
      hairlineStrong = ColorTokens.voidHairlineStrong,
      textPrimary = ColorTokens.voidInkPrimary,
      textSecondary = ColorTokens.voidInkSecondary,
      textTertiary = ColorTokens.voidInkTertiary,
      textInverse = ColorTokens.voidCanvas,
      accent = ColorTokens.ember300,
      accentPressed = ColorTokens.ember400,
      accentWash = ColorTokens.accentWashVoid,
      danger = ColorTokens.dangerDark,
      dangerWash = ColorTokens.dangerWashDark,
      scrim = ColorTokens.scrimVoid,
      selection = ColorTokens.selectionDark,
      monogramTints = ColorTokens.monogramDark;

  /// Resolves a [QuietCollection] against a brightness.
  ///
  /// Only four values per collection are authored — the accent and its pressed
  /// state, at each brightness. Washes, selection, focus, hero tints and
  /// monogram stock are computed here, which is the whole reason a new
  /// collection costs a single enum row instead of forty hex codes.
  ///
  /// Autumn Ember short-circuits to the const instances above: it is the
  /// default, it is built on every frame before the user has chosen anything,
  /// and hand-authored values should never drift from derived ones.
  factory QuietColors.of(
    QuietCollection collection, {
    required bool dark,
    bool amoled = false,
  }) {
    if (collection == QuietCollection.ember) {
      if (!dark) return const QuietColors.light();
      return amoled ? const QuietColors.amoled() : const QuietColors.dark();
    }

    final neutrals = amoled
        ? const QuietNeutrals.pureBlack()
        : QuietNeutrals.of(collection.neutrals, dark: dark);
    final accent = collection.accent(dark: dark);

    return QuietColors(
      brightness: dark ? Brightness.dark : Brightness.light,
      collection: collection,
      // A hero gradient tinted with the raw accent reads as a colour filter
      // over someone's face. Pulled most of the way to black, it reads as
      // evening light instead.
      heroTint: Color.lerp(accent, ColorTokens.voidCanvas, 0.55)!,
      canvas: neutrals.canvas,
      surface: neutrals.surface,
      raised: neutrals.raised,
      sunken: neutrals.sunken,
      hairline: neutrals.hairline,
      hairlineStrong: neutrals.hairlineStrong,
      textPrimary: neutrals.inkPrimary,
      textSecondary: neutrals.inkSecondary,
      textTertiary: neutrals.inkTertiary,
      textInverse: neutrals.canvas,
      accent: accent,
      accentPressed: collection.accentPressed(dark: dark),
      // Dark surfaces need more accent to register as tinted at all.
      accentWash: Color.lerp(neutrals.surface, accent, dark ? 0.18 : 0.1)!,
      danger: dark ? ColorTokens.dangerDark : ColorTokens.dangerLight,
      dangerWash: dark
          ? ColorTokens.dangerWashDark
          : ColorTokens.dangerWashLight,
      scrim: amoled
          ? ColorTokens.scrimVoid
          : (dark ? ColorTokens.scrimDark : ColorTokens.scrimLight),
      selection: accent.withValues(alpha: 0.2),
      monogramTints: _monogramFamily(neutrals: neutrals, accent: accent),
    );
  }

  /// Six tints for people without a photo, in the collection's own family.
  ///
  /// Stepped between the sunken and hairline neutrals and tinted 4% toward the
  /// accent — enough that two adjacent avatars are distinguishable, far too
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

  /// Six tints for people without a photo, in the collection's own family.
  ///
  /// Stepped between the sunken and hairline neutrals and tinted 4% toward the
  /// accent — enough that two adjacent avatars are distinguishable, far too
  /// little to read as colour-coding.
  static List<Color> _monogramFamily({
    required QuietNeutrals neutrals,
    required Color accent,
  }) {
    const steps = <double>[0, 0.18, 0.36, 0.54, 0.72, 0.9];
    return <Color>[
      for (final step in steps)
        Color.lerp(
          Color.lerp(neutrals.sunken, neutrals.hairlineStrong, step),
          accent,
          0.04,
        )!,
    ];
  }

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
