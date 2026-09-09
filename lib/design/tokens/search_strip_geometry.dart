/// Measured geometry of `search.png` (Vintage Diary search parchment).
///
/// Values are normalized to the PNG canvas (0–1). Asset is **2090×341** —
/// the paper band alone (no hanging-chain canvas), so the full frame is the
/// strip.
abstract final class SearchStripGeometry {
  static const double canvasWidth = 2090;
  static const double canvasHeight = 341;

  /// Width / height of the PNG canvas.
  static const double aspectRatio = canvasWidth / canvasHeight;

  // ── Safe text band (avoids grommets / botanicals / stains) ─────────────

  /// Just right of the twin grommets + left plant sprig.
  static const double contentLeft = 0.118;

  /// Inside the right botanical / coffee-ring cluster.
  static const double contentRight = 0.905;

  /// Vertical inset as a fraction of canvas height (deckled edges).
  static const double contentPadY = 0.22;

  static double renderedHeightForWidth(double width) => width / aspectRatio;
}
