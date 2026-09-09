/// Measured geometry of `user-strip.png` (Vintage Diary hanging tag).
///
/// Values are normalized to the PNG canvas (0–1), derived from alpha / metal
/// sampling of the 2172×724 asset — not device pixels.
///
/// The PNG is a **composite**: hanging chain + two grommets + paper strip on
/// a transparent canvas. Layout must use [strip*] / [topHole*] / [bottomHole*]
/// rather than treating the full canvas as the paper tag.
abstract final class UserStripGeometry {
  static const double canvasWidth = 2172;
  static const double canvasHeight = 724;

  /// Width / height of the full PNG canvas.
  static const double aspectRatio = canvasWidth / canvasHeight;

  // ── Visible paper strip (opaque band) ─────────────────────────────────

  static const double stripLeft = 0.022;
  static const double stripTop = 0.320;
  static const double stripRight = 0.982;
  static const double stripBottom = 0.782;

  // ── Grommets (shared X) ───────────────────────────────────────────────

  static const double holeX = 0.061;

  /// Center of the upper grommet (chain terminates here).
  static const double topHoleY = 0.420;

  /// Center of the lower grommet (empty in the asset — next strip's chain
  /// attaches here when strips are stacked).
  static const double bottomHoleY = 0.693;

  /// First opaque chain pixel from the top of the canvas.
  static const double chainTopY = 0.037;

  // ── Safe content band inside the paper (avoids holes / botanicals) ────

  /// Just right of the grommets + left plant sprig.
  static const double contentLeft = 0.145;

  /// Near the paper's right edge — countdown anchors here; floral can sit under.
  static const double contentRight = 0.935;

  /// Vertical inset inside the paper band as a fraction of strip height.
  static const double contentPadY = 0.14;

  /// Gap between photo and name as a fraction of strip width.
  static const double contentGap = 0.012;

  /// Gap between name column and countdown as a fraction of strip width.
  static const double countdownGap = 0.008;

  /// Vertical step between consecutive PNG tops so the next strip's chain
  /// head meets the previous strip's bottom-hole center.
  static double chainAdvance(double renderedHeight) =>
      renderedHeight * (bottomHoleY - chainTopY);

  static double renderedHeightForWidth(double width) => width / aspectRatio;
}
