import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:kin/design/theme/quiet_collection.dart';
import 'package:kin/design/tokens/color_tokens.dart';

/// App-level bottom navigation strip roles.
@immutable
final class QuietNavigation {
  const QuietNavigation({
    required this.surface,
    required this.border,
    required this.inkActive,
    required this.inkInactive,
    required this.indicator,
  });

  /// Vintage Diary — ink on parchment chrome. Surface is transparent so the
  /// shell theme backdrop (vintage-bg) continues through the strip's torn
  /// alpha margins — never a separate cream slab under the bar.
  const QuietNavigation.light()
    : surface = ColorTokens.transparent,
      border = ColorTokens.vdPaperAged,
      inkActive = ColorTokens.vdInkPrimary,
      inkInactive = ColorTokens.vdInkSecondary,
      indicator = ColorTokens.vdBurgundy;

  const QuietNavigation.dark()
    : surface = ColorTokens.transparent,
      border = ColorTokens.vdPaperAged,
      inkActive = ColorTokens.vdInkPrimary,
      inkInactive = ColorTokens.vdInkSecondary,
      indicator = ColorTokens.vdBurgundyMuted;

  const QuietNavigation.amoled()
    : surface = ColorTokens.transparent,
      border = ColorTokens.vdPaperAged,
      inkActive = ColorTokens.vdInkPrimary,
      inkInactive = ColorTokens.vdInkSecondary,
      indicator = ColorTokens.vdBurgundy;

  /// Original Quiet Default — solid paper bar, ember indicator.
  const QuietNavigation.neutral()
    : surface = ColorTokens.paperSurface,
      border = ColorTokens.paperHairline,
      inkActive = ColorTokens.paperInkPrimary,
      inkInactive = ColorTokens.paperInkSecondary,
      indicator = ColorTokens.ember500;

  /// Neon Arcade — dark HUD bar under bottom-navbar.webp; cyan active, magenta
  /// indicator. Surface is transparent so the shell theme backdrop (arcade-bg)
  /// continues through the strip's alpha margins — never a separate black slab.
  const QuietNavigation.neonArcade()
    : surface = ColorTokens.transparent,
      border = ColorTokens.naNavBorder,
      inkActive = ColorTokens.naCyan,
      inkInactive = ColorTokens.naCardInkMuted,
      indicator = ColorTokens.naMagenta;

  factory QuietNavigation.of({
    required QuietCollection collection,
    required bool dark,
    bool amoled = false,
  }) {
    if (collection == QuietCollection.quietDefault) {
      return const QuietNavigation.neutral();
    }
    if (collection == QuietCollection.neonArcade) {
      return const QuietNavigation.neonArcade();
    }
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

  /// Solid fill under an optional chrome strip image (or alone when null).
  final Color surface;
  final Color border;

  /// Active destination — brown ink on cream.
  final Color inkActive;

  /// Inactive destinations — softer brown ink.
  final Color inkInactive;

  /// Underline / selection mark — restrained burgundy.
  final Color indicator;
}
