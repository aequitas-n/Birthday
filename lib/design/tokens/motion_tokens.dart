import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// Duration and easing tokens.
///
/// Every animation in Kin must answer one of three questions: where did this
/// come from, where did it go, or did that work. Nothing here exists to
/// decorate.
///
/// The cubic control points reference the Material 3 easing specification,
/// used purely as a well-researched source of curve mathematics — not as a
/// visual style.
///
/// Specified in docs/07-motion.md §1 and §2.
@immutable
final class QuietMotionTokens {
  const QuietMotionTokens();

  // ── Durations ─────────────────────────────────────────────────────────

  /// Press and release, selection ticks, colour-only changes.
  Duration get instant => const Duration(milliseconds: 90);

  /// Fades, small reveals, focus rings, hover.
  Duration get quick => const Duration(milliseconds: 160);

  /// Standard transitions, theme change, list reorder.
  Duration get base => const Duration(milliseconds: 240);

  /// Sheets, page pushes, shared-element morphs.
  Duration get slow => const Duration(milliseconds: 360);

  /// The birthday moment, and nothing else.
  Duration get deliberate => const Duration(milliseconds: 520);

  // ── Curves ────────────────────────────────────────────────────────────

  /// Default for anything changing in place.
  Curve get standard => const Cubic(0.2, 0, 0, 1);

  /// Elements arriving. Decelerates into rest.
  Curve get enter => const Cubic(0, 0, 0, 1);

  /// Elements leaving. Accelerates away. Leaving is always faster than
  /// arriving.
  Curve get exit => const Cubic(0.3, 0, 1, 1);

  /// Shared-element morphs and sheets.
  Curve get emphasized => Curves.easeInOutCubicEmphasized;

  /// Anything the finger is currently holding.
  SpringDescription get spring =>
      const SpringDescription(mass: 1, stiffness: 380, damping: 30);

  // ── Choreography ──────────────────────────────────────────────────────

  /// Delay between consecutive items in a staggered entrance.
  Duration get stagger => const Duration(milliseconds: 24);

  /// Longer staggers make the last item feel broken. Items beyond this index
  /// share the timing of the last staggered item.
  int get staggerCap => 6;

  /// Beyond this, the app stops feeling responsive.
  Duration get maxDelay => const Duration(milliseconds: 120);

  /// A spinner that appears sooner than this flashes on fast operations,
  /// which is worse than showing nothing.
  Duration get loadingIndicatorDelay => const Duration(milliseconds: 120);

  /// How long an undo affordance survives.
  Duration get undoLifetime => const Duration(seconds: 6);

  /// Press feedback scale, anchored at the touch point rather than the
  /// widget centre.
  double get pressScale => 0.97;

  /// How far the page recedes behind a presented sheet.
  double get sheetRecedeScale => 0.985;
}
