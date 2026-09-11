import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Fractional content rects for theme surface artwork (normalized 0–1).
///
/// [left]/[top]/[right]/[bottom] are edges of the **safe content** rectangle
/// relative to the rendered surface size — not EdgeInsets. Convert with
/// [toPadding].
@immutable
final class AppThemeContentRect {
  const AppThemeContentRect({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final double left;
  final double top;
  final double right;
  final double bottom;

  EdgeInsets toPadding(Size size) {
    return EdgeInsets.fromLTRB(
      size.width * left,
      size.height * top,
      size.width * (1 - right),
      size.height * (1 - bottom),
    );
  }
}

/// Profile-card composition derived from a theme's profile plate artwork.
@immutable
final class AppThemeProfileLayout {
  const AppThemeProfileLayout({
    required this.aspectRatio,
    required this.photoLeft,
    required this.photoRight,
    required this.photoTop,
    required this.photoBottom,
    required this.textLeft,
    required this.textRight,
    required this.textBottom,
    this.textBandFraction = 0.18,
    this.clipPlateCorners = true,
    this.cornerRadius,
    this.avatarDiameterFraction,
    this.avatarInsetLeft = 0,
    this.avatarInsetTop = 0,
  });

  /// Card width / height. Prefer the plate asset's intrinsic ratio when the
  /// frame must stay uncropped.
  final double aspectRatio;

  final double photoLeft;
  final double photoRight;
  final double photoTop;
  final double photoBottom;

  final double textLeft;
  final double textRight;
  final double textBottom;
  final double textBandFraction;

  /// When false, the plate art owns its corners (no ClipRRect radius).
  final bool clipPlateCorners;

  /// Optional clip radius when [clipPlateCorners] is true.
  /// `null` → theme [QuietRadius.sm].
  final double? cornerRadius;

  /// Avatar diameter as a fraction of **card width**. `null` → [QAvatarSize.lg].
  final double? avatarDiameterFraction;

  /// Extra left inset for the avatar inside the photo window (of content width).
  final double avatarInsetLeft;

  /// Extra top inset for the avatar inside the photo window (of content height).
  final double avatarInsetTop;
}

/// Optional composition metrics for a product theme's decorative surfaces.
///
/// `null` fields mean “use the shared Default/Vintage layout constants”.
@immutable
final class AppThemeSurfaceLayout {
  const AppThemeSurfaceLayout({
    this.journalCardContent,
    this.journalCardAspectRatio,
    this.journalCardCornerRadius,
    this.profileCard,
    this.galleryCardWidthFraction,
    this.galleryCardHeightFraction,
    this.galleryCardMaxHeight,
    this.galleryCardMaxWidth,
  });

  const AppThemeSurfaceLayout.none()
    : journalCardContent = null,
      journalCardAspectRatio = null,
      journalCardCornerRadius = null,
      profileCard = null,
      galleryCardWidthFraction = null,
      galleryCardHeightFraction = null,
      galleryCardMaxHeight = null,
      galleryCardMaxWidth = null;

  /// Safe text/CTA region inside [AppThemeBackgrounds.journalCard].
  final AppThemeContentRect? journalCardContent;

  /// Intrinsic width / height of the journal-card artwork when present.
  final double? journalCardAspectRatio;

  /// Corner clip for journal-card artwork. `null` → 0 when art is present
  /// (Neon owns its frame), else [QuietRadius.lg] on solid Default paper.
  final double? journalCardCornerRadius;

  /// Photo + name geometry for [AppThemeChrome.profileCard].
  final AppThemeProfileLayout? profileCard;

  /// Overrides [QuietLayout.galleryCardWidthFraction] when set.
  final double? galleryCardWidthFraction;

  /// Overrides [QuietLayout.galleryCardHeightFraction] when set.
  final double? galleryCardHeightFraction;

  /// Overrides [QuietLayout.galleryCardMaxHeight] when set.
  final double? galleryCardMaxHeight;

  /// Hard cap on gallery plate width (tablet / wide panes). `null` → uncapped
  /// beyond [galleryCardWidthFraction] of the pane.
  final double? galleryCardMaxWidth;
}
