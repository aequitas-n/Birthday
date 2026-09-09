import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:kin/design/theme/quiet_control_surface.dart';
import 'package:kin/design/tokens/color_tokens.dart';

/// Theme-owned interactive surfaces — paper controls on the dark desk,
/// ink controls on parchment sheets/cards.
///
/// Widgets consume these roles. They never hardcode cream/burgundy fills.
///
/// Hierarchy:
/// ```text
/// DARK VINTAGE DESK
///        ↓
/// cream / parchment interactive surfaces
///        ↓
/// brown ink  ·  burgundy accent
/// ```
@immutable
final class QuietInteractive {
  const QuietInteractive({
    required this.primaryAction,
    required this.primaryActionPressed,
    required this.primaryActionInk,
    required this.secondaryAction,
    required this.secondaryActionBorder,
    required this.secondaryActionInk,
    required this.sheet,
    required this.sheetElevated,
    required this.sheetBorder,
    required this.sheetGrabber,
    required this.ink,
    required this.inkSecondary,
    required this.inkMuted,
    required this.inkDisabled,
    required this.accent,
    required this.selectedSurface,
    required this.selectedInk,
    required this.input,
    required this.inputFocused,
    required this.inputBorder,
    required this.toggleTrackOff,
    required this.toggleTrackOn,
    required this.toggleThumbOff,
    required this.toggleThumbOn,
    required this.disabledSurface,
  });

  /// Vintage Diary — cream CTAs on desk; parchment sheets; leather-adjacent
  /// accents stay on [accent] for selection indicators.
  const QuietInteractive.light()
    : primaryAction = ColorTokens.vdPaperHighlight,
      primaryActionPressed = ColorTokens.vdPaperAged,
      primaryActionInk = ColorTokens.vdInkPrimary,
      secondaryAction = ColorTokens.vdPaperParchment,
      secondaryActionBorder = ColorTokens.vdPaperAged,
      secondaryActionInk = ColorTokens.vdCreamPrimary,
      sheet = ColorTokens.vdPaperWarm,
      sheetElevated = ColorTokens.vdPaperHighlight,
      sheetBorder = ColorTokens.vdPaperAged,
      sheetGrabber = ColorTokens.vdInkTertiary,
      ink = ColorTokens.vdInkPrimary,
      inkSecondary = ColorTokens.vdInkSecondary,
      inkMuted = ColorTokens.vdInkTertiary,
      inkDisabled = ColorTokens.vdInkTertiary,
      accent = ColorTokens.vdBurgundy,
      selectedSurface = ColorTokens.vdPaperAged,
      selectedInk = ColorTokens.vdInkPrimary,
      input = ColorTokens.vdPaperParchment,
      inputFocused = ColorTokens.vdPaperHighlight,
      inputBorder = ColorTokens.vdPaperAged,
      toggleTrackOff = ColorTokens.vdPaperAged,
      toggleTrackOn = ColorTokens.vdPaperHighlight,
      toggleThumbOff = ColorTokens.vdInkSecondary,
      toggleThumbOn = ColorTokens.vdBurgundy,
      disabledSurface = ColorTokens.vdPaperParchment;

  const QuietInteractive.dark()
    : primaryAction = ColorTokens.vdPaperHighlight,
      primaryActionPressed = ColorTokens.vdPaperAged,
      primaryActionInk = ColorTokens.vdInkPrimary,
      secondaryAction = ColorTokens.vdPaperParchment,
      secondaryActionBorder = ColorTokens.vdPaperAged,
      secondaryActionInk = ColorTokens.vdTextPrimaryDark,
      sheet = ColorTokens.vdPaperWarm,
      sheetElevated = ColorTokens.vdPaperHighlight,
      sheetBorder = ColorTokens.vdPaperAged,
      sheetGrabber = ColorTokens.vdInkTertiary,
      ink = ColorTokens.vdInkPrimary,
      inkSecondary = ColorTokens.vdInkSecondary,
      inkMuted = ColorTokens.vdInkTertiary,
      inkDisabled = ColorTokens.vdInkTertiary,
      accent = ColorTokens.vdTerracotta,
      selectedSurface = ColorTokens.vdPaperAged,
      selectedInk = ColorTokens.vdInkPrimary,
      input = ColorTokens.vdPaperParchment,
      inputFocused = ColorTokens.vdPaperHighlight,
      inputBorder = ColorTokens.vdPaperAged,
      toggleTrackOff = ColorTokens.vdPaperAged,
      toggleTrackOn = ColorTokens.vdPaperHighlight,
      toggleThumbOff = ColorTokens.vdInkSecondary,
      toggleThumbOn = ColorTokens.vdBurgundyMuted,
      disabledSurface = ColorTokens.vdPaperParchment;

  const QuietInteractive.amoled()
    : primaryAction = ColorTokens.vdPaperHighlight,
      primaryActionPressed = ColorTokens.vdPaperAged,
      primaryActionInk = ColorTokens.vdInkPrimary,
      secondaryAction = ColorTokens.vdPaperParchment,
      secondaryActionBorder = ColorTokens.vdPaperAged,
      secondaryActionInk = ColorTokens.vdTextPrimaryDark,
      sheet = ColorTokens.vdPaperWarm,
      sheetElevated = ColorTokens.vdPaperHighlight,
      sheetBorder = ColorTokens.vdPaperAged,
      sheetGrabber = ColorTokens.vdInkTertiary,
      ink = ColorTokens.vdInkPrimary,
      inkSecondary = ColorTokens.vdInkSecondary,
      inkMuted = ColorTokens.vdInkTertiary,
      inkDisabled = ColorTokens.vdInkTertiary,
      accent = ColorTokens.vdTerracotta,
      selectedSurface = ColorTokens.vdPaperAged,
      selectedInk = ColorTokens.vdInkPrimary,
      input = ColorTokens.vdPaperParchment,
      inputFocused = ColorTokens.vdPaperHighlight,
      inputBorder = ColorTokens.vdPaperAged,
      toggleTrackOff = ColorTokens.vdPaperAged,
      toggleTrackOn = ColorTokens.vdPaperHighlight,
      toggleThumbOff = ColorTokens.vdInkSecondary,
      toggleThumbOn = ColorTokens.vdBurgundy,
      disabledSurface = ColorTokens.vdPaperParchment;

  factory QuietInteractive.of({required bool dark, bool amoled = false}) {
    if (amoled) return const QuietInteractive.amoled();
    if (dark) return const QuietInteractive.dark();
    return const QuietInteractive.light();
  }

  factory QuietInteractive.lerp(
    QuietInteractive a,
    QuietInteractive b,
    double t,
  ) {
    if (identical(a, b)) return a;
    Color mix(Color x, Color y) => Color.lerp(x, y, t)!;
    return QuietInteractive(
      primaryAction: mix(a.primaryAction, b.primaryAction),
      primaryActionPressed: mix(a.primaryActionPressed, b.primaryActionPressed),
      primaryActionInk: mix(a.primaryActionInk, b.primaryActionInk),
      secondaryAction: mix(a.secondaryAction, b.secondaryAction),
      secondaryActionBorder: mix(
        a.secondaryActionBorder,
        b.secondaryActionBorder,
      ),
      secondaryActionInk: mix(a.secondaryActionInk, b.secondaryActionInk),
      sheet: mix(a.sheet, b.sheet),
      sheetElevated: mix(a.sheetElevated, b.sheetElevated),
      sheetBorder: mix(a.sheetBorder, b.sheetBorder),
      sheetGrabber: mix(a.sheetGrabber, b.sheetGrabber),
      ink: mix(a.ink, b.ink),
      inkSecondary: mix(a.inkSecondary, b.inkSecondary),
      inkMuted: mix(a.inkMuted, b.inkMuted),
      inkDisabled: mix(a.inkDisabled, b.inkDisabled),
      accent: mix(a.accent, b.accent),
      selectedSurface: mix(a.selectedSurface, b.selectedSurface),
      selectedInk: mix(a.selectedInk, b.selectedInk),
      input: mix(a.input, b.input),
      inputFocused: mix(a.inputFocused, b.inputFocused),
      inputBorder: mix(a.inputBorder, b.inputBorder),
      toggleTrackOff: mix(a.toggleTrackOff, b.toggleTrackOff),
      toggleTrackOn: mix(a.toggleTrackOn, b.toggleTrackOn),
      toggleThumbOff: mix(a.toggleThumbOff, b.toggleThumbOff),
      toggleThumbOn: mix(a.toggleThumbOn, b.toggleThumbOn),
      disabledSurface: mix(a.disabledSurface, b.disabledSurface),
    );
  }

  /// Cream parchment fill for primary CTAs on the dark desk.
  final Color primaryAction;
  final Color primaryActionPressed;

  /// Deep brown ink on [primaryAction].
  final Color primaryActionInk;

  /// Soft parchment secondary fill (desk chrome).
  final Color secondaryAction;
  final Color secondaryActionBorder;
  final Color secondaryActionInk;

  /// Bottom sheet / modal parchment surface.
  final Color sheet;
  final Color sheetElevated;
  final Color sheetBorder;
  final Color sheetGrabber;

  /// Brown ink for content on parchment sheets.
  final Color ink;
  final Color inkSecondary;
  final Color inkMuted;
  final Color inkDisabled;

  /// Burgundy / terracotta — selection accents, not default CTA fills on desk.
  final Color accent;

  final Color selectedSurface;
  final Color selectedInk;

  /// Input wells on parchment sheets.
  final Color input;
  final Color inputFocused;
  final Color inputBorder;

  final Color toggleTrackOff;
  final Color toggleTrackOn;
  final Color toggleThumbOff;
  final Color toggleThumbOn;

  final Color disabledSurface;

  /// Primary CTA fill for the ambient [surface].
  ///
  /// Desk → cream parchment. Parchment host (sheet/card) → accent burgundy.
  Color actionFill(QuietControlSurface surface) => switch (surface) {
    QuietControlSurface.desk => primaryAction,
    QuietControlSurface.parchment => accent,
  };

  Color actionPressed(QuietControlSurface surface, Color accentPressed) =>
      switch (surface) {
        QuietControlSurface.desk => primaryActionPressed,
        QuietControlSurface.parchment => accentPressed,
      };

  Color actionInk(QuietControlSurface surface, Color creamOnAccent) =>
      switch (surface) {
        QuietControlSurface.desk => primaryActionInk,
        QuietControlSurface.parchment => creamOnAccent,
      };

  /// Body / label ink for the ambient control surface.
  Color chromeInk(
    QuietControlSurface surface, {
    required Color deskInk,
  }) => switch (surface) {
    QuietControlSurface.desk => deskInk,
    QuietControlSurface.parchment => ink,
  };

  Color chromeInkSecondary(
    QuietControlSurface surface, {
    required Color deskInk,
  }) => switch (surface) {
    QuietControlSurface.desk => deskInk,
    QuietControlSurface.parchment => inkSecondary,
  };

  Color chromeInkMuted(
    QuietControlSurface surface, {
    required Color deskInk,
  }) => switch (surface) {
    QuietControlSurface.desk => deskInk,
    QuietControlSurface.parchment => inkMuted,
  };
}
