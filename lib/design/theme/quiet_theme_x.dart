import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';
import 'package:kin/design/theme/quiet_theme.dart';

/// The single access point for the design language.
///
/// ```dart
/// final q = context.quiet;
/// Text('Priya', style: q.text.voiceLg.tinted(q.color.textPrimary));
/// ```
extension QuietThemeX on BuildContext {
  /// The active [QuietTheme].
  QuietTheme get quiet {
    final theme = Theme.of(this).extension<QuietTheme>();
    assert(
      theme != null,
      'QuietTheme is missing. Wrap the app in KinApp, or use pumpQuiet() in '
      'tests.',
    );
    return theme ?? const QuietTheme.light();
  }

  /// A true hairline: one physical pixel, not one logical pixel.
  ///
  /// docs/03-design-philosophy.md — "hairlines that are actually hairlines".
  double get hairlineWidth => 1 / MediaQuery.devicePixelRatioOf(this);

  /// Whether the expanded breakpoint applies.
  bool get isExpanded =>
      MediaQuery.sizeOf(this).width >= quiet.layout.expandedBreakpoint;

  /// Horizontal screen gutter for the current breakpoint.
  double get gutter =>
      isExpanded ? quiet.layout.gutterExpanded : quiet.layout.gutter;

  /// Whether the platform has asked for reduced motion.
  bool get prefersReducedMotion => MediaQuery.disableAnimationsOf(this);

  /// The user's text scale, clamped for structural chrome so labels never
  /// outgrow the content they describe.
  TextScaler get structuralTextScaler => MediaQuery.textScalerOf(
    this,
  ).clamp(maxScaleFactor: quiet.text.structuralScaleCap);

  /// The user's text scale, clamped for names.
  TextScaler get nameTextScaler => MediaQuery.textScalerOf(
    this,
  ).clamp(maxScaleFactor: quiet.text.nameScaleCap);

  /// The user's text scale, clamped for type embedded in a hero photograph.
  TextScaler get heroTextScaler => MediaQuery.textScalerOf(
    this,
  ).clamp(maxScaleFactor: quiet.text.heroScaleCap);

  /// Height of a hero photograph on this viewport.
  ///
  /// A fraction of the viewport rather than a fixed height, bounded at both
  /// ends: a hero that scales without limit stops being a portrait and starts
  /// being a wallpaper.
  double get heroHeight {
    final q = quiet;
    final height = MediaQuery.sizeOf(this).height;
    return (height * q.layout.heroHeightFraction).clamp(
      q.layout.heroMinHeight,
      q.layout.heroMaxHeight,
    );
  }

  /// Applies photographic ink and a legibility shadow to a typography token.
  ///
  /// Type over an image cannot use a theme colour: the image is the one
  /// surface the app does not own, so its ink is fixed and carries its own
  /// shadow instead of relying on the scrim alone.
  TextStyle onImage(TextStyle style, {bool secondary = false}) {
    final q = quiet;
    return q.text
        .overImage(style, q.photo.onImageShadow)
        .tinted(
          secondary ? q.photo.onImageSecondary : q.photo.onImagePrimary,
        );
  }

  /// Whether the person row should restack rather than keep its single-line
  /// layout.
  bool get restacksRows =>
      MediaQuery.textScalerOf(this).scale(15) / 15 >
      quiet.layout.textScaleRestackThreshold;
}

/// Applies a semantic colour role to a typography token.
///
/// Typography tokens are deliberately colourless so a style can never smuggle
/// a hardcoded colour past the theme. This lives beside [QuietThemeX] rather
/// than with the tokens so components never need to import the raw token
/// files — see the ARCH-04 rule in `tool/check_architecture.dart`.
extension QuietTextStyleX on TextStyle {
  TextStyle tinted(Color color) => copyWith(color: color);
}
