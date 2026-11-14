import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:kin/design/theme/quiet_collection.dart';
import 'package:kin/design/tokens/color_tokens.dart';

/// Semantic surfaces for the Journal archive experience.
///
/// Vintage Diary: cream parchment cards with brown-black ink, sitting on the
/// dark aged diary background.
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

  /// Vintage Diary — cream paper card on dark desk.
  const QuietJournal.light()
    : desk = ColorTokens.vdDiaryCanvas,
      paper = ColorTokens.vdPaperWarm,
      paperSunken = ColorTokens.vdPaperParchment,
      ink = ColorTokens.vdInkPrimary,
      inkMuted = ColorTokens.vdInkSecondary,
      edge = ColorTokens.vdPaperAged,
      rule = ColorTokens.vdJournalRule,
      tape = ColorTokens.vdTerracottaPale,
      clip = ColorTokens.vdInkTertiary,
      photoMat = ColorTokens.vdPaperHighlight,
      shadow = ColorTokens.vdJournalShadow,
      washStrength = 0.48;

  const QuietJournal.dark()
    : desk = ColorTokens.vdCanvasDark,
      paper = ColorTokens.vdPaperWarm,
      paperSunken = ColorTokens.vdPaperParchment,
      ink = ColorTokens.vdInkPrimary,
      inkMuted = ColorTokens.vdInkSecondary,
      edge = ColorTokens.vdPaperAged,
      rule = ColorTokens.vdJournalRuleDark,
      tape = ColorTokens.vdTerracottaSoft,
      clip = ColorTokens.vdInkTertiary,
      photoMat = ColorTokens.vdPaperHighlight,
      shadow = ColorTokens.vdJournalShadowDark,
      washStrength = 0.44;

  const QuietJournal.amoled()
    : desk = ColorTokens.vdCanvasAmoled,
      paper = ColorTokens.vdPaperParchment,
      paperSunken = ColorTokens.vdPaperAged,
      ink = ColorTokens.vdInkPrimary,
      inkMuted = ColorTokens.vdInkSecondary,
      edge = ColorTokens.vdJournalEdgeAmoled,
      rule = ColorTokens.vdJournalRuleAmoled,
      tape = ColorTokens.vdTerracottaPale,
      clip = ColorTokens.vdInkTertiary,
      photoMat = ColorTokens.vdPaperWarm,
      shadow = ColorTokens.vdJournalShadowAmoled,
      washStrength = 0.4;

  /// Original Quiet Default — warm paper archive, no parchment texture.
  ///
  /// Secondary ink is a warm brown-grey (not cool taupe) so supporting copy
  /// on `journalPaperLight` stays legible without competing with primary ink.
  const QuietJournal.neutral()
    : desk = ColorTokens.paperCanvas,
      paper = ColorTokens.journalPaperLight,
      paperSunken = ColorTokens.paperSunken,
      ink = ColorTokens.paperInkPrimary,
      inkMuted = ColorTokens.paperInkOnPaperSecondary,
      edge = ColorTokens.journalPaperEdgeLight,
      rule = ColorTokens.paperHairlineStrong,
      tape = ColorTokens.journalTapeLight,
      clip = ColorTokens.paperInkSecondary,
      photoMat = ColorTokens.journalPhotoMatLight,
      shadow = ColorTokens.journalShadowLight,
      washStrength = 0.42;

  /// Neon Arcade — dark CRT panels (journal / calendar art) on cream desk.
  const QuietJournal.neonArcade()
    : desk = ColorTokens.naCanvas,
      paper = ColorTokens.naCard,
      paperSunken = ColorTokens.naCardSunken,
      ink = ColorTokens.naCardInk,
      inkMuted = ColorTokens.naCardInkMuted,
      edge = ColorTokens.naCardEdge,
      rule = ColorTokens.naCardRule,
      tape = ColorTokens.naMagenta,
      clip = ColorTokens.naCyanMuted,
      photoMat = ColorTokens.naCardRaised,
      shadow = ColorTokens.naCardShadow,
      washStrength = 0.36;

  /// Resolves journal atmosphere for the active collection.
  factory QuietJournal.of(
    QuietCollection collection, {
    required QuietBrightness mode,
  }) {
    if (collection == QuietCollection.quietDefault) {
      return const QuietJournal.neutral();
    }
    if (collection == QuietCollection.neonArcade) {
      return const QuietJournal.neonArcade();
    }
    return switch (mode) {
      QuietBrightness.amoled => const QuietJournal.amoled(),
      QuietBrightness.dark => const QuietJournal.dark(),
      QuietBrightness.light => const QuietJournal.light(),
    };
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
