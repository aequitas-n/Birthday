import 'dart:ui' show Size;

import 'package:kin/design/theme/app_theme_assets.dart'
    show AppThemeProfileLayout;

import 'package:kin/design/theme/app_theme_surface_layout.dart'
    show AppThemeProfileLayout;

import 'package:kin/design/tokens/space_tokens.dart' show QuietLayout;

/// Layout geometry for the People profile card container.
///
/// The **container** owns size. `profile_card.webp` is artwork that fills the
/// container with cover fit — its pixel aspect ratio does **not** drive layout
/// unless a theme supplies [AppThemeProfileLayout.aspectRatio].
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

  /// Where note/moment peeks begin, as a fraction of **full card height**.
  static const double notesStartFraction = 0.40;

  /// Lower text band as a fraction of card height (ink sits on parchment).
  static const double textBandFraction = 0.18;

  /// Insets for text within the profile card parchment.
  static const double textLeft = 0.10;
  static const double textRight = 0.90;
  static const double textBottom = 0.055;
}

/// Portrait composition helpers for the People gallery card.
abstract final class VintagePortraitLayout {
  static double heightForWidth(
    double width, {
    double aspectRatio = ProfileCardGeometry.aspectRatio,
  }) => width / aspectRatio;

  static double widthForHeight(
    double height, {
    double aspectRatio = ProfileCardGeometry.aspectRatio,
  }) => height * aspectRatio;

  static double textHeightForWidth(
    double width, {
    double aspectRatio = ProfileCardGeometry.aspectRatio,
    double textBandFraction = ProfileCardGeometry.textBandFraction,
  }) => heightForWidth(width, aspectRatio: aspectRatio) * textBandFraction;

  /// Fit a profile card into [maxWidth] × [maxHeight].
  ///
  /// [widthFraction] insets the plate inside the gallery content width so the
  /// card sits narrower than the search strip (Default and Vintage).
  static Size fitIn({
    required double maxWidth,
    required double maxHeight,
    double widthFraction = 1.0,
    double aspectRatio = ProfileCardGeometry.aspectRatio,
  }) {
    final maxW = maxWidth * widthFraction;
    final idealH = heightForWidth(maxW, aspectRatio: aspectRatio);
    if (idealH <= maxHeight) return Size(maxW, idealH);
    // Height-bound: shrink width so the plate aspect stays true (no stretch).
    final h = maxHeight;
    final w = widthForHeight(h, aspectRatio: aspectRatio);
    return Size(w <= maxW ? w : maxW, h);
  }

  /// Fit a People gallery plate into available space using theme layout when
  /// present, otherwise shared [QuietLayout] gallery constants.
  static Size fitGalleryCard({
    required double maxWidth,
    required double maxHeight,
    required double widthFraction,
    required double heightFraction,
    required double maxHeightCap,
    required double aspectRatio,
    double? maxWidthCap,
  }) {
    final paneW = maxWidthCap == null
        ? maxWidth
        : (maxWidth < maxWidthCap ? maxWidth : maxWidthCap);
    final cappedH = maxHeight * heightFraction;
    return fitIn(
      maxWidth: paneW,
      maxHeight: cappedH < maxHeightCap ? cappedH : maxHeightCap,
      widthFraction: widthFraction,
      aspectRatio: aspectRatio,
    );
  }

  /// Photograph bottom edge (normalized from top).
  static double photoBottomNorm(
    double width, {
    double photoBottom = ProfileCardGeometry.photoBottom,
  }) => photoBottom;
}
