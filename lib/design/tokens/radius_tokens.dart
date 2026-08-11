import 'package:flutter/widgets.dart';

/// Corner geometry.
///
/// Radii at or above [superellipseThreshold] use a rounded superellipse — the
/// Apple-style squircle — because at those sizes the curvature discontinuity
/// of an ordinary rounded rectangle is visible and reads as cheap. Below the
/// threshold the difference is imperceptible and the cheaper clip wins.
///
/// Specified in docs/04-design-system.md §2.
@immutable
final class QuietRadius {
  const QuietRadius();

  /// Tags, inline badges.
  double get xs => 6;

  /// Inputs, small buttons, note pills.
  double get sm => 10;

  /// List row press surfaces, tiles.
  double get md => 14;

  /// Panels, photo frames, action sheets.
  double get lg => 20;

  /// Bottom sheets — top corners only.
  double get xl => 28;

  /// The bottom corners of a hero image, and portrait gallery cards.
  ///
  /// Large enough that the curve itself is a visible piece of the
  /// composition rather than a softened corner.
  double get xxl => 36;

  /// Avatars, pills.
  double get full => 999;

  /// At or above this value, use a superellipse rather than a circular arc.
  double get superellipseThreshold => 14;

  bool prefersSuperellipse(double radius) => radius >= superellipseThreshold;

  BorderRadius all(double radius) => BorderRadius.all(Radius.circular(radius));

  BorderRadius top(double radius) =>
      BorderRadius.vertical(top: Radius.circular(radius));

  /// Concentric corners: an inner radius equals the outer radius minus the
  /// padding between them, floored at [xs]. Concentric or nothing.
  double nested({required double outer, required double padding}) {
    final inner = outer - padding;
    return inner < xs ? xs : inner;
  }
}
