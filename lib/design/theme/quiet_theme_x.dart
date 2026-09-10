import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';
import 'package:kin/design/theme/app_theme_definition.dart';
import 'package:kin/design/theme/product_themes.dart';
import 'package:kin/design/theme/quiet_control_surface.dart';
import 'package:kin/design/theme/quiet_surface_ink.dart';
import 'package:kin/design/theme/quiet_theme.dart';

export 'package:kin/design/theme/quiet_control_surface.dart';
export 'package:kin/design/theme/quiet_surface_ink.dart';

/// The single access point for the design language.
///
/// ```dart
/// final q = context.quiet;
/// final theme = context.appTheme;
/// // Surface-aware type (preferred):
/// Text('Priya', style: q.inked(q.text.pageTitle));
/// Text(date, style: q.inked(q.text.uiDate, tone: QuietInkTone.secondary));
/// // On cream paper / calendar:
/// Text(note, style: q.inked(q.text.diaryNote, surface: QuietSurfaceKind.paper));
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

  /// The active product theme (Quiet roles + semantic assets).
  AppThemeDefinition get appTheme {
    final theme = Theme.of(this).extension<AppThemeDefinition>();
    assert(
      theme != null,
      'AppThemeDefinition is missing. Wrap the app in KinApp, or use '
      'pumpQuiet() in tests.',
    );
    return theme ?? ProductThemes.matchingQuiet(quiet);
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
  double get heroHeight {
    final q = quiet;
    final height = MediaQuery.sizeOf(this).height;
    return (height * q.layout.heroHeightFraction).clamp(
      q.layout.heroMinHeight,
      q.layout.heroMaxHeight,
    );
  }

  /// Applies photographic ink and a legibility shadow to a typography token.
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

  /// Primary readable ink for the ambient control surface (desk cream or
  /// parchment brown).
  Color get controlInk {
    final q = quiet;
    return q.interactive.chromeInk(
      controlSurface,
      deskInk: q.color.textPrimary,
    );
  }

  Color get controlInkSecondary {
    final q = quiet;
    return q.interactive.chromeInkSecondary(
      controlSurface,
      deskInk: q.color.textSecondary,
    );
  }

  Color get controlInkMuted {
    final q = quiet;
    return q.interactive.chromeInkMuted(
      controlSurface,
      deskInk: q.color.textTertiary,
    );
  }
}

/// Theme helpers for surface-aware ink (canvas vs paper).
extension QuietThemeSurfaceX on QuietTheme {
  /// Ink block for [kind] — cream on diary canvas, brown on paper/calendar.
  QuietSurfaceInk on(QuietSurfaceKind kind) => QuietSurfaceInk.fromTheme(
    kind: kind,
    color: color,
    journal: journal,
  );

  /// Cream-on-dark diary chrome.
  QuietSurfaceInk get canvas => on(QuietSurfaceKind.canvas);

  /// Brown-on-cream paper / calendar / card chrome.
  QuietSurfaceInk get paper => on(QuietSurfaceKind.paper);

  /// Typography role + surface ink in one call.
  ///
  /// Defaults to [QuietSurfaceKind.canvas] (most screens sit on vintage-bg).
  TextStyle inked(
    TextStyle role, {
    QuietSurfaceKind surface = QuietSurfaceKind.canvas,
    QuietInkTone tone = QuietInkTone.primary,
  }) => on(surface).inked(role, tone: tone);
}

/// Applies a semantic colour role to a typography token.
extension QuietTextStyleX on TextStyle {
  TextStyle tinted(Color color) => copyWith(color: color);
}
