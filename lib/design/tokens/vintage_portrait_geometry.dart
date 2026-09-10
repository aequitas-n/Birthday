import 'dart:ui' show Size;

/// Layout geometry for the People profile card container.
///
/// The **container** owns size. `profile_card.webp` is artwork that fills the
/// container with cover fit — its pixel aspect ratio does **not** drive layout.
abstract final class ProfileCardGeometry {
  /// `profile_card.webp` canvas metadata — for reference only.
  static const double assetCanvasWidth = 842;
  static const double assetCanvasHeight = 1867;
  static const double assetAspectRatio = assetCanvasWidth / assetCanvasHeight;

  /// Visible card width / height — wider than the tall source PNG so cover
  /// zooms and crops rather than shrinking the whole plate.
  static const double aspectRatio = 0.68;

  /// Horizontal inset for the mounted photograph window (of card width).
  static const double photoLeft = 0.14;
  static const double photoRight = 0.86;

  /// Top of the photograph window (of card height).
  static const double photoTop = 0.11;

  /// Bottom of the photograph window (normalized from top, 0–1).
  static const double photoBottom = 0.66;

  /// Lower text band as a fraction of card height (ink sits on parchment).
  static const double textBandFraction = 0.18;

  /// Insets for text within the profile card parchment.
  static const double textLeft = 0.10;
  static const double textRight = 0.90;
  static const double textBottom = 0.055;
}

/// Portrait composition helpers for the People gallery card.
abstract final class VintagePortraitLayout {
  static double heightForWidth(double width) =>
      width / ProfileCardGeometry.aspectRatio;

  static double widthForHeight(double height) =>
      height * ProfileCardGeometry.aspectRatio;

  static double textHeightForWidth(double width) =>
      heightForWidth(width) * ProfileCardGeometry.textBandFraction;

  /// Fit a profile card into [maxWidth] × [maxHeight].
  ///
  /// [widthFraction] insets the plate inside the gallery content width so the
  /// card sits narrower than the search strip (Default and Vintage).
  static Size fitIn({
    required double maxWidth,
    required double maxHeight,
    double widthFraction = 1.0,
  }) {
    final w = maxWidth * widthFraction;
    final idealH = heightForWidth(w);
    final h = idealH <= maxHeight ? idealH : maxHeight;
    return Size(w, h);
  }

  /// Photograph bottom edge (normalized from top).
  static double photoBottomNorm(double width) => ProfileCardGeometry.photoBottom;
}
