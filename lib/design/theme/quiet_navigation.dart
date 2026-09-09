import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:kin/design/tokens/color_tokens.dart';

/// App-level bottom navigation — cream parchment strip on the dark desk.
///
/// Same contrast language as toggles and desk CTAs: warm paper against
/// vintage-bg, with brown ink labels and a burgundy selection mark.
@immutable
final class QuietNavigation {
  const QuietNavigation({
    required this.surface,
    required this.border,
    required this.inkActive,
    required this.inkInactive,
    required this.indicator,
  });

  const QuietNavigation.light()
    : surface = ColorTokens.vdJournalCardCream,
      border = ColorTokens.vdPaperAged,
      inkActive = ColorTokens.vdInkPrimary,
      inkInactive = ColorTokens.vdInkSecondary,
      indicator = ColorTokens.vdBurgundy;

  const QuietNavigation.dark()
    : surface = ColorTokens.vdJournalCardCream,
      border = ColorTokens.vdPaperAged,
      inkActive = ColorTokens.vdInkPrimary,
      inkInactive = ColorTokens.vdInkSecondary,
      indicator = ColorTokens.vdBurgundyMuted;

  const QuietNavigation.amoled()
    : surface = ColorTokens.vdJournalCardCream,
      border = ColorTokens.vdPaperAged,
      inkActive = ColorTokens.vdInkPrimary,
      inkInactive = ColorTokens.vdInkSecondary,
      indicator = ColorTokens.vdBurgundy;

  factory QuietNavigation.of({required bool dark, bool amoled = false}) {
    if (amoled) return const QuietNavigation.amoled();
    if (dark) return const QuietNavigation.dark();
    return const QuietNavigation.light();
  }

  factory QuietNavigation.lerp(QuietNavigation a, QuietNavigation b, double t) {
    if (identical(a, b)) return a;
    return QuietNavigation(
      surface: Color.lerp(a.surface, b.surface, t)!,
      border: Color.lerp(a.border, b.border, t)!,
      inkActive: Color.lerp(a.inkActive, b.inkActive, t)!,
      inkInactive: Color.lerp(a.inkInactive, b.inkInactive, t)!,
      indicator: Color.lerp(a.indicator, b.indicator, t)!,
    );
  }

  /// Cream parchment fallback under [VintageDiaryAssets.chromeStrip].
  final Color surface;
  final Color border;

  /// Active destination — brown ink on cream.
  final Color inkActive;

  /// Inactive destinations — softer brown ink.
  final Color inkInactive;

  /// Underline / selection mark — restrained burgundy.
  final Color indicator;
}
