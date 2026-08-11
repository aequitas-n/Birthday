import 'dart:ui';

import 'package:kin/design/tokens/color_tokens.dart';

/// The neutral family a collection is built on.
///
/// Neutrals are the atmosphere. An accent swap alone produces the familiar
/// "same app, different hue" result, because the 98% of the screen that is
/// paper and ink never moves. Changing the neutral family is what makes
/// Ocean Mist feel like a different morning rather than a different button.
enum QuietNeutralFamily { warm, cool, verdant }

/// A theme collection: an entire atmosphere, not a colour.
///
/// Kin has no light/dark toggle at the top level. It has collections, each of
/// which resolves against the platform brightness — so Ocean Mist is Ocean
/// Mist at breakfast and at midnight, and the user's choice survives the
/// system flipping underneath them.
///
/// Adding one is four accent values and a row in this enum. Everything else —
/// washes, selection, focus, hero gradients, monogram tints, pressed states —
/// is derived in `QuietColors`, which is why no screen ever needs to know
/// which collection is active.
enum QuietCollection {
  /// Terracotta on warm paper. The original Quiet, and the default.
  ember('Autumn Ember', QuietNeutralFamily.warm),

  /// Soft rose on warm paper.
  dawn('Spring Dawn', QuietNeutralFamily.warm),

  /// Deep rose on warm paper.
  rosewood('Rosewood', QuietNeutralFamily.warm),

  /// Teal on cool paper.
  ocean('Ocean Mist', QuietNeutralFamily.cool),

  /// Steel on cool paper.
  frost('Winter Frost', QuietNeutralFamily.cool),

  /// Indigo on cool paper.
  midnight('Midnight Blue', QuietNeutralFamily.cool),

  /// Violet-slate on cool paper.
  night('Quiet Night', QuietNeutralFamily.cool),

  /// Moss green on verdant paper.
  moss('Forest Moss', QuietNeutralFamily.verdant)
  ;

  const QuietCollection(this.label, this.neutrals);

  /// Shown in Settings. Never an identifier, never uppercased.
  final String label;

  final QuietNeutralFamily neutrals;

  /// The accent, at the given brightness.
  Color accent({required bool dark}) => switch (this) {
    QuietCollection.ember => dark ? ColorTokens.ember300 : ColorTokens.ember500,
    QuietCollection.dawn => dark ? ColorTokens.dawnDark : ColorTokens.dawnLight,
    QuietCollection.rosewood =>
      dark ? ColorTokens.rosewoodDark : ColorTokens.rosewoodLight,
    QuietCollection.ocean =>
      dark ? ColorTokens.oceanDark : ColorTokens.oceanLight,
    QuietCollection.frost =>
      dark ? ColorTokens.frostDark : ColorTokens.frostLight,
    QuietCollection.midnight =>
      dark ? ColorTokens.midnightDark : ColorTokens.midnightLight,
    QuietCollection.night =>
      dark ? ColorTokens.nightDark : ColorTokens.nightLight,
    QuietCollection.moss => dark ? ColorTokens.mossDark : ColorTokens.mossLight,
  };

  /// The accent while a finger is on it.
  Color accentPressed({required bool dark}) => switch (this) {
    QuietCollection.ember => dark ? ColorTokens.ember400 : ColorTokens.ember600,
    QuietCollection.dawn =>
      dark ? ColorTokens.dawnDarkPressed : ColorTokens.dawnLightPressed,
    QuietCollection.rosewood =>
      dark ? ColorTokens.rosewoodDarkPressed : ColorTokens.rosewoodLightPressed,
    QuietCollection.ocean =>
      dark ? ColorTokens.oceanDarkPressed : ColorTokens.oceanLightPressed,
    QuietCollection.frost =>
      dark ? ColorTokens.frostDarkPressed : ColorTokens.frostLightPressed,
    QuietCollection.midnight =>
      dark ? ColorTokens.midnightDarkPressed : ColorTokens.midnightLightPressed,
    QuietCollection.night =>
      dark ? ColorTokens.nightDarkPressed : ColorTokens.nightLightPressed,
    QuietCollection.moss =>
      dark ? ColorTokens.mossDarkPressed : ColorTokens.mossLightPressed,
  };
}

/// The nine neutrals a collection paints its pages with.
///
/// Internal to `design/theme/`. Nothing outside it constructs one.
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

  factory QuietNeutrals.of(QuietNeutralFamily family, {required bool dark}) {
    return switch ((family, dark)) {
      (QuietNeutralFamily.warm, false) => const QuietNeutrals(
        canvas: ColorTokens.paperCanvas,
        surface: ColorTokens.paperSurface,
        raised: ColorTokens.paperSurface,
        sunken: ColorTokens.paperSunken,
        hairline: ColorTokens.paperHairline,
        hairlineStrong: ColorTokens.paperHairlineStrong,
        inkPrimary: ColorTokens.paperInkPrimary,
        inkSecondary: ColorTokens.paperInkSecondary,
        inkTertiary: ColorTokens.paperInkTertiary,
      ),
      (QuietNeutralFamily.warm, true) => const QuietNeutrals(
        canvas: ColorTokens.charcoalCanvas,
        surface: ColorTokens.charcoalSurface,
        raised: ColorTokens.charcoalRaised,
        sunken: ColorTokens.charcoalSunken,
        hairline: ColorTokens.charcoalHairline,
        hairlineStrong: ColorTokens.charcoalHairlineStrong,
        inkPrimary: ColorTokens.charcoalInkPrimary,
        inkSecondary: ColorTokens.charcoalInkSecondary,
        inkTertiary: ColorTokens.charcoalInkTertiary,
      ),
      (QuietNeutralFamily.cool, false) => const QuietNeutrals(
        canvas: ColorTokens.mistCanvas,
        surface: ColorTokens.mistSurface,
        raised: ColorTokens.mistSurface,
        sunken: ColorTokens.mistSunken,
        hairline: ColorTokens.mistHairline,
        hairlineStrong: ColorTokens.mistHairlineStrong,
        inkPrimary: ColorTokens.mistInkPrimary,
        inkSecondary: ColorTokens.mistInkSecondary,
        inkTertiary: ColorTokens.mistInkTertiary,
      ),
      (QuietNeutralFamily.cool, true) => const QuietNeutrals(
        canvas: ColorTokens.slateCanvas,
        surface: ColorTokens.slateSurface,
        raised: ColorTokens.slateRaised,
        sunken: ColorTokens.slateSunken,
        hairline: ColorTokens.slateHairline,
        hairlineStrong: ColorTokens.slateHairlineStrong,
        inkPrimary: ColorTokens.slateInkPrimary,
        inkSecondary: ColorTokens.slateInkSecondary,
        inkTertiary: ColorTokens.slateInkTertiary,
      ),
      (QuietNeutralFamily.verdant, false) => const QuietNeutrals(
        canvas: ColorTokens.fieldCanvas,
        surface: ColorTokens.fieldSurface,
        raised: ColorTokens.fieldSurface,
        sunken: ColorTokens.fieldSunken,
        hairline: ColorTokens.fieldHairline,
        hairlineStrong: ColorTokens.fieldHairlineStrong,
        inkPrimary: ColorTokens.fieldInkPrimary,
        inkSecondary: ColorTokens.fieldInkSecondary,
        inkTertiary: ColorTokens.fieldInkTertiary,
      ),
      (QuietNeutralFamily.verdant, true) => const QuietNeutrals(
        canvas: ColorTokens.pineCanvas,
        surface: ColorTokens.pineSurface,
        raised: ColorTokens.pineRaised,
        sunken: ColorTokens.pineSunken,
        hairline: ColorTokens.pineHairline,
        hairlineStrong: ColorTokens.pineHairlineStrong,
        inkPrimary: ColorTokens.pineInkPrimary,
        inkSecondary: ColorTokens.pineInkSecondary,
        inkTertiary: ColorTokens.pineInkTertiary,
      ),
    };
  }

  /// True black. Canvas, surface and sunken collapse to one value, so
  /// hairlines carry the entire structure of every screen — which is why they
  /// are stronger here than in any other neutral set.
  const QuietNeutrals.pureBlack()
    : canvas = ColorTokens.voidCanvas,
      surface = ColorTokens.voidCanvas,
      raised = ColorTokens.voidRaised,
      sunken = ColorTokens.voidCanvas,
      hairline = ColorTokens.voidHairline,
      hairlineStrong = ColorTokens.voidHairlineStrong,
      inkPrimary = ColorTokens.voidInkPrimary,
      inkSecondary = ColorTokens.voidInkSecondary,
      inkTertiary = ColorTokens.voidInkTertiary;

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
