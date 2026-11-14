import 'package:flutter/material.dart';
import 'package:kin/design/theme/app_theme_definition.dart';
import 'package:kin/design/theme/product_themes.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/design/tokens/color_tokens.dart';

/// A deliberately minimal [ThemeData].
///
/// Kin does not use Material components. This exists only so framework
/// internals that require a Material ancestor — text selection handles,
/// overlays, the default text style behind stray [Text] widgets — do not look
/// wrong. Nothing here should ever be read by a Kin widget.
ThemeData buildMaterialShim(
  QuietTheme quiet, {
  AppThemeDefinition? appTheme,
}) {
  final c = quiet.color;
  final t = quiet.text;
  final product = appTheme ?? ProductThemes.matchingQuiet(quiet);

  return ThemeData(
    useMaterial3: true,
    brightness: c.brightness,

    // Kin draws its own press feedback, anchored to the touch point.
    splashFactory: NoSplash.splashFactory,
    highlightColor: ColorTokens.transparent,
    splashColor: ColorTokens.transparent,
    hoverColor: ColorTokens.transparent,

    scaffoldBackgroundColor: c.canvas,
    canvasColor: c.canvas,
    dividerColor: c.hairline,
    shadowColor: ColorTokens.transparent,

    // Hand-built rather than seeded, so no tonal palette is generated.
    colorScheme: ColorScheme(
      brightness: c.brightness,
      primary: c.accent,
      onPrimary: c.textInverse,
      secondary: c.accent,
      onSecondary: c.textInverse,
      error: c.danger,
      onError: c.textInverse,
      surface: c.surface,
      onSurface: c.textPrimary,
    ),

    textSelectionTheme: TextSelectionThemeData(
      cursorColor: c.accent,
      selectionColor: c.selection,
      selectionHandleColor: c.accent,
    ),

    // Escape hatch for stray Text — product universal archive face, never
    // a fourth theme personality.
    fontFamily: t.uiFamily,
    textTheme: TextTheme(
      displayLarge: t.voiceXl,
      displayMedium: t.voiceLg,
      displaySmall: t.voiceMd,
      headlineMedium: t.title,
      titleMedium: t.title,
      bodyLarge: t.bodyLg,
      bodyMedium: t.body,
      bodySmall: t.caption,
      labelLarge: t.label,
      labelMedium: t.label,
      labelSmall: t.eyebrow,
    ).apply(bodyColor: c.textPrimary, displayColor: c.textPrimary),

    extensions: <ThemeExtension<dynamic>>[quiet, product],
  );
}
