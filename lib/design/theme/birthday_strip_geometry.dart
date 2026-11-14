import 'package:meta/meta.dart';

/// Measured geometry for theme hanging / HUD birthday strips.
///
/// Values are normalized to the asset canvas (0–1). Vintage includes chain +
/// grommets on a tall transparent canvas; Neon is a short opaque HUD plate.
@immutable
final class UserStripLayout {
  const UserStripLayout({
    required this.canvasWidth,
    required this.canvasHeight,
    required this.stripLeft,
    required this.stripTop,
    required this.stripRight,
    required this.stripBottom,
    required this.contentLeft,
    required this.contentRight,
    this.contentPadY = 0.14,
    this.contentGap = 0.012,
    this.countdownGap = 0.008,
    this.holeX = 0.061,
    this.topHoleY = 0.420,
    this.bottomHoleY = 0.693,
    this.chainTopY = 0.037,
    this.chainStack = true,
  });

  final double canvasWidth;
  final double canvasHeight;

  final double stripLeft;
  final double stripTop;
  final double stripRight;
  final double stripBottom;

  final double contentLeft;
  final double contentRight;
  final double contentPadY;
  final double contentGap;
  final double countdownGap;

  final double holeX;
  final double topHoleY;
  final double bottomHoleY;
  final double chainTopY;

  /// When true, stacked strips overlap so chains link (Vintage).
  /// Neon HUD bars stack with a plain gap instead.
  final bool chainStack;

  double get aspectRatio => canvasWidth / canvasHeight;

  double chainAdvance(double renderedHeight) =>
      renderedHeight * (bottomHoleY - chainTopY);

  double renderedHeightForWidth(double width) => width / aspectRatio;
}

/// Shared defaults — Vintage Diary hanging tag (2172×724).
abstract final class UserStripGeometry {
  static const UserStripLayout vintage = UserStripLayout(
    canvasWidth: 2172,
    canvasHeight: 724,
    stripLeft: 0.022,
    stripTop: 0.320,
    stripRight: 0.982,
    stripBottom: 0.782,
    contentLeft: 0.145,
    contentRight: 0.935,
  );

  /// Neon Arcade HUD bar (2095×358).
  ///
  /// Content sits in the dark plate inset from neon tubes (measured): roughly
  /// 4.5%–95.7% × 17%–87% of the canvas.
  static const UserStripLayout neon = UserStripLayout(
    canvasWidth: 2095,
    canvasHeight: 358,
    stripLeft: 0.045,
    stripTop: 0.169,
    stripRight: 0.957,
    stripBottom: 0.870,
    // Content fills the dark plate; padY is breathing room inside the tubes.
    contentLeft: 0.058,
    contentRight: 0.942,
    contentPadY: 0.02,
    contentGap: 0.020,
    countdownGap: 0.014,
    chainStack: false,
  );

  // ── Back-compat aliases used by older call sites ───────────────────────

  static const double canvasWidth = 2172;
  static const double canvasHeight = 724;
  static const double aspectRatio = canvasWidth / canvasHeight;
  static const double stripLeft = 0.022;
  static const double stripTop = 0.320;
  static const double stripRight = 0.982;
  static const double stripBottom = 0.782;
  static const double holeX = 0.061;
  static const double topHoleY = 0.420;
  static const double bottomHoleY = 0.693;
  static const double chainTopY = 0.037;
  static const double contentLeft = 0.145;
  static const double contentRight = 0.935;
  static const double contentPadY = 0.14;
  static const double contentGap = 0.012;
  static const double countdownGap = 0.008;

  static double chainAdvance(double renderedHeight) =>
      vintage.chainAdvance(renderedHeight);

  static double renderedHeightForWidth(double width) =>
      vintage.renderedHeightForWidth(width);
}
