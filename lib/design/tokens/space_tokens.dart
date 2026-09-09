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

  // ── Editorial page rhythm (Today and peers) ─────────────────────────────
  // Named roles over the grid so screens share intentional air — not random
  // paddings, and not [chapter]/[scene] gaps that stretch a diary page.

  /// Top inset under the safe area on an editorial page.
  double get pageTop => base;

  /// Bottom scroll clearance so last content sits above chrome / nav.
  double get pageBottom => xxl;

  /// Within an identity block (title → date → weekday).
  double get identity => xs;

  /// Section heading → first content line or card.
  double get sectionLead => sm;

  /// Between peer sections (journal → reminders → coming up).
  double get sectionGap => xl;

  /// After a physical card before the next section heading.
  double get cardToSection => xl;

  /// Compact list rows (reminders, stacked metadata).
  double get listItem => xs;
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

  /// Profile card uses the full gallery viewport width. Screen gutter lives in
  /// [_HomePane]; do not apply a second fractional width here.
  double get galleryCardWidthFraction => 1.0;

  /// PageView page width fraction. Full width so neighbours stay off-screen
  /// at rest; the card itself is sized by [galleryCardWidthFraction].
  double get galleryViewportFraction => 1.0;

  /// Fraction of viewport height a gallery card may occupy when height-bound.
  double get galleryCardHeightFraction => 0.76;

  /// A gallery card never grows past this.
  double get galleryCardMaxHeight => 540;

  // ── Journal of the Day ────────────────────────────────────────────────

  /// Target memory-card height as a fraction of the screen height.
  /// Caps the deck so leftover vertical space is breathing room, not stretch.
  double get journalDayCardHeightFraction => 0.52;

  /// Absolute bounds for the day memory card (logical pixels).
  double get journalDayCardMinHeight => 300;
  double get journalDayCardMaxHeight => 560;

  /// Fraction of viewport height the empty state is lifted by, because true
  /// centre reads low.
  double get emptyStateOpticalLift => 0.08;
}
