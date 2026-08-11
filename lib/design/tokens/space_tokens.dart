import 'package:flutter/foundation.dart';

/// The 4pt spacing grid.
///
/// Raw numbers in layout code are an architecture violation. If a gap you
/// need is not on this scale, the scale is wrong — not the layout.
///
/// Specified in docs/04-design-system.md §1.
@immutable
final class QuietSpace {
  const QuietSpace();

  /// Optical nudges and icon-to-text kerning.
  double get hair => 2;

  /// Inside chips, between stacked labels.
  double get xs => 4;

  /// Icon gaps, tight pairs.
  double get sm => 8;

  /// Input inner padding, list row internals.
  double get md => 12;

  /// Default gap between related elements.
  double get base => 16;

  /// Screen horizontal gutter on phones.
  double get lg => 20;

  /// Gap between unrelated elements.
  double get xl => 24;

  /// Sheet inner padding, block separation.
  double get xxl => 32;

  /// Between sections on a screen.
  double get section => 40;

  /// Between major regions.
  double get chapter => 56;

  /// Between one scene and the next: the gap that tells the reader a subject
  /// has changed, not merely a topic.
  double get scene => 72;

  /// Beneath a hero, and above the first line that follows it.
  ///
  /// Larger than any other gap in the product. The hero needs room to finish
  /// speaking before the page starts explaining.
  double get hero => 96;

  /// Above and below empty-state content.
  double get emptiness => 96;
}

/// Fixed layout measurements.
///
/// Specified in docs/04-design-system.md §1 and §12.
@immutable
final class QuietLayout {
  const QuietLayout();

  /// Horizontal screen gutter, compact breakpoint.
  double get gutter => 20;

  /// Horizontal screen gutter, expanded breakpoint.
  double get gutterExpanded => 24;

  /// Reading measure cap. Content centres beyond this width.
  double get contentMaxWidth => 560;

  /// Sheets become centred panels at this width on large screens.
  double get panelWidth => 480;

  /// The compact/expanded breakpoint.
  double get expandedBreakpoint => 600;

  /// Home list row height at 1.0x text scale.
  ///
  /// Dense enough that five or six people fit without scrolling on a modern
  /// phone, and tall enough that the name never feels trapped by its bounds.
  double get personRowHeight => 60;

  /// Home list row height once text scale exceeds [textScaleRestackThreshold].
  double get personRowHeightStacked => 76;

  /// Settings row height.
  double get settingRowHeight => 52;

  /// Above this text scale the person row restacks rather than truncating.
  double get textScaleRestackThreshold => 1.3;

  /// Minimum touch target on every axis, regardless of visual size.
  double get minTouchTarget => 44;

  /// Empty-state content is capped here and optically raised.
  double get emptyStateMaxWidth => 280;

  // ── Hero photography ──────────────────────────────────────────────────

  /// Fraction of the viewport a hero image occupies.
  ///
  /// Enough that the photograph is the page rather than an illustration on
  /// it, and little enough that the first line of context is visible without
  /// scrolling — the reader should know there is more below.
  double get heroHeightFraction => 0.44;

  /// A hero never collapses below this, however short the viewport.
  double get heroMinHeight => 320;

  /// A hero never grows past this, however tall the viewport. On a tablet, a
  /// portrait that keeps scaling stops being intimate.
  double get heroMaxHeight => 520;

  /// How far the hero image drifts against the scroll, as a fraction of the
  /// distance scrolled. Small on purpose: parallax should be felt rather than
  /// seen.
  double get heroParallaxFactor => 0.24;

  // ── Portrait gallery ──────────────────────────────────────────────────

  /// Fraction of the viewport width one gallery card occupies, leaving its
  /// neighbours visible at the edges.
  double get galleryViewportFraction => 0.78;

  /// Fraction of viewport height a gallery card occupies.
  double get galleryCardHeightFraction => 0.62;

  /// A gallery card never grows past this.
  double get galleryCardMaxHeight => 560;

  /// How much a neighbouring card shrinks, which is what reads as depth.
  double get galleryNeighbourScale => 0.9;

  /// How far a neighbouring card sinks, in points.
  double get galleryNeighbourDrop => 18;

  /// How far a neighbouring card fades.
  double get galleryNeighbourFade => 0.32;

  /// Fraction of viewport height the empty state is lifted by, because true
  /// centre reads low.
  double get emptyStateOpticalLift => 0.08;
}
