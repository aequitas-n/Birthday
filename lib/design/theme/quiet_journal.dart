import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:kin/design/theme/quiet_collection.dart';
import 'package:kin/design/theme/quiet_colors.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/design/tokens/color_tokens.dart';

/// Semantic surfaces for the Journal archive experience.
///
/// Same diary, different atmosphere: paper/ink track the active
/// [QuietCollection] neutrals rather than forcing one global beige.
@immutable
final class QuietJournal {
  const QuietJournal({
    required this.desk,
    required this.paper,
    required this.paperSunken,
    required this.ink,
    required this.inkMuted,
    required this.edge,
    required this.rule,
    required this.tape,
    required this.clip,
    required this.photoMat,
    required this.shadow,
    required this.washStrength,
  });

  /// Ember / warm light — aged archival paper on warm canvas.
  const QuietJournal.light()
    : desk = ColorTokens.paperCanvas,
      paper = ColorTokens.journalPaperLight,
      paperSunken = ColorTokens.paperSunken,
      ink = ColorTokens.paperInkPrimary,
      inkMuted = ColorTokens.paperInkSecondary,
      edge = ColorTokens.journalPaperEdgeLight,
      rule = ColorTokens.paperHairline,
      tape = ColorTokens.journalTapeLight,
      clip = ColorTokens.journalClipLight,
      photoMat = ColorTokens.journalPhotoMatLight,
      shadow = ColorTokens.journalShadowLight,
      washStrength = 0.42;

  const QuietJournal.dark()
    : desk = ColorTokens.charcoalCanvas,
      paper = ColorTokens.journalPaperDark,
      paperSunken = ColorTokens.charcoalSunken,
      ink = ColorTokens.charcoalInkPrimary,
      inkMuted = ColorTokens.charcoalInkSecondary,
      edge = ColorTokens.journalPaperEdgeDark,
      rule = ColorTokens.charcoalHairline,
      tape = ColorTokens.journalTapeDark,
      clip = ColorTokens.journalClipDark,
      photoMat = ColorTokens.journalPhotoMatDark,
      shadow = ColorTokens.journalShadowDark,
      washStrength = 0.38;

  const QuietJournal.amoled()
    : desk = ColorTokens.voidCanvas,
      paper = ColorTokens.journalPaperVoid,
      paperSunken = ColorTokens.voidRaised,
      ink = ColorTokens.voidInkPrimary,
      inkMuted = ColorTokens.voidInkSecondary,
      edge = ColorTokens.journalPaperEdgeVoid,
      rule = ColorTokens.voidHairline,
      tape = ColorTokens.journalTapeVoid,
      clip = ColorTokens.journalClipVoid,
      photoMat = ColorTokens.journalPhotoMatVoid,
      shadow = ColorTokens.journalShadowVoid,
      washStrength = 0.32;

  /// Resolves journal atmosphere from collection neutrals + brightness.
  factory QuietJournal.of(
    QuietCollection collection, {
    required QuietBrightness mode,
  }) {
    if (mode == QuietBrightness.amoled) {
      return const QuietJournal.amoled();
    }
    final dark = mode == QuietBrightness.dark;
    final neutrals = QuietNeutrals.of(collection.neutrals, dark: dark);
    final accentWash = QuietColors.of(
      collection,
      dark: dark,
    ).accentWash;

    // Slightly aged paper relative to the collection surface — same diary,
    // room lighting changes with the collection.
    final paper = Color.lerp(neutrals.surface, accentWash, dark ? 0.06 : 0.1)!;
    final photoMat = Color.lerp(
      neutrals.surface,
      neutrals.sunken,
      dark ? 0.35 : 0.55,
    )!;
    final tape = Color.lerp(
      accentWash,
      neutrals.hairlineStrong,
      dark ? 0.45 : 0.35,
    )!;

    return QuietJournal(
      desk: neutrals.canvas,
      paper: paper,
      paperSunken: neutrals.sunken,
      ink: neutrals.inkPrimary,
      inkMuted: neutrals.inkSecondary,
      edge: neutrals.hairlineStrong,
      rule: neutrals.hairline,
      tape: tape,
      clip: neutrals.inkTertiary,
      photoMat: photoMat,
      shadow: dark
          ? ColorTokens.journalShadowDark
          : ColorTokens.journalShadowLight,
      washStrength: dark ? 0.36 : 0.42,
    );
  }

  /// Page / desk behind artifacts (collection canvas).
  final Color desk;

  /// Primary writing / fragment paper.
  final Color paper;

  /// Recessed paper well (writing surface).
  final Color paperSunken;

  /// Primary archive ink.
  final Color ink;

  /// Metadata / captions.
  final Color inkMuted;

  /// Thin paper edge.
  final Color edge;

  /// Quiet rule / separator.
  final Color rule;

  /// Washi / archival tape.
  final Color tape;

  /// Metal clip accent.
  final Color clip;

  /// Photograph mat / border stock.
  final Color photoMat;

  /// Restrained fragment shadow.
  final Color shadow;

  /// Alpha scale for mood ink washes on calendar / day headers.
  final double washStrength;

  QuietJournal lerp(QuietJournal other, double t) {
    return QuietJournal(
      desk: Color.lerp(desk, other.desk, t)!,
      paper: Color.lerp(paper, other.paper, t)!,
      paperSunken: Color.lerp(paperSunken, other.paperSunken, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      edge: Color.lerp(edge, other.edge, t)!,
      rule: Color.lerp(rule, other.rule, t)!,
      tape: Color.lerp(tape, other.tape, t)!,
      clip: Color.lerp(clip, other.clip, t)!,
      photoMat: Color.lerp(photoMat, other.photoMat, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      washStrength: washStrength + (other.washStrength - washStrength) * t,
    );
  }
}
