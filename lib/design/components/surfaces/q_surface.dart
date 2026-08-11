import 'package:flutter/widgets.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// The four surface levels. There is no fifth.
///
/// A screen shows at most two at rest; [QuietLevel.raised] exists only while a
/// sheet or menu is open. See docs/04-design-system.md §3.
enum QuietLevel { canvas, surface, raised, sunken }

/// Elevation recipes, chosen by meaning rather than by depth in points.
enum QuietElevationLevel {
  /// Flat against the page.
  flat,

  /// A hairline border and nothing else.
  hairline,

  /// Resting just above the page: an undo bar, a selected segment.
  lift,

  /// A card the user can throw sideways: a portrait in the gallery.
  float,

  /// Sheets and menus.
  overlay,
}

/// A rectangle of a given surface level, with Kin's corner geometry.
///
/// Radii at or above the superellipse threshold are drawn as rounded
/// superellipses. At those sizes the curvature discontinuity of an ordinary
/// rounded rectangle is visible and reads as cheap.
class QSurface extends StatelessWidget {
  const QSurface({
    required this.child,
    this.level = QuietLevel.surface,
    this.elevation = QuietElevationLevel.flat,
    this.radius = 0,
    this.topCornersOnly = false,
    this.padding,
    this.width,
    this.height,
    this.borderColor,
    this.borderWidth,
    super.key,
  });

  final Widget child;
  final QuietLevel level;
  final QuietElevationLevel elevation;
  final double radius;
  final bool topCornersOnly;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  /// Overrides the hairline colour, used for focus and error states.
  final Color? borderColor;

  /// Overrides the hairline width.
  ///
  /// A border contributes to the shape's dimensions, so a component that
  /// changes border width between states must set this to a constant and vary
  /// only the colour — otherwise the surface grows and the layout shifts.
  final double? borderWidth;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final c = q.color;

    final fill = switch (level) {
      QuietLevel.canvas => c.canvas,
      QuietLevel.surface => c.surface,
      QuietLevel.raised => c.raised,
      QuietLevel.sunken => c.sunken,
    };

    final shadows = switch (elevation) {
      QuietElevationLevel.flat => const <BoxShadow>[],
      QuietElevationLevel.hairline => const <BoxShadow>[],
      QuietElevationLevel.lift => q.elevation.lift,
      QuietElevationLevel.float => q.elevation.float,
      QuietElevationLevel.overlay => q.elevation.overlay,
    };

    final wantsBorder =
        borderColor != null ||
        elevation == QuietElevationLevel.hairline ||
        elevation == QuietElevationLevel.lift;

    final side = wantsBorder
        ? BorderSide(
            color: borderColor ?? c.hairline,
            width: borderWidth ?? context.hairlineWidth,
          )
        : BorderSide.none;

    final borderRadius = topCornersOnly
        ? BorderRadius.vertical(top: Radius.circular(radius))
        : BorderRadius.all(Radius.circular(radius));

    final shape = q.radius.prefersSuperellipse(radius)
        ? RoundedSuperellipseBorder(side: side, borderRadius: borderRadius)
        : RoundedRectangleBorder(side: side, borderRadius: borderRadius);

    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: ShapeDecoration(color: fill, shape: shape, shadows: shadows),
      child: child,
    );
  }
}

/// Clips a child to Kin's corner geometry without painting a surface.
///
/// Used for photographs, which are the only colour the app does not control
/// and are therefore always clipped and always isolated on the canvas.
class QClip extends StatelessWidget {
  const QClip({
    required this.radius,
    required this.child,
    this.topCornersOnly = false,
    this.bottomCornersOnly = false,
    super.key,
  }) : assert(
         !(topCornersOnly && bottomCornersOnly),
         'Rounding both ends is just an ordinary rounded rectangle.',
       );

  final double radius;
  final bool topCornersOnly;

  /// Used by hero images, which meet the top edge of the screen square and
  /// curve away from the content below.
  final bool bottomCornersOnly;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final borderRadius = switch ((topCornersOnly, bottomCornersOnly)) {
      (true, _) => BorderRadius.vertical(top: Radius.circular(radius)),
      (_, true) => BorderRadius.vertical(bottom: Radius.circular(radius)),
      _ => BorderRadius.all(Radius.circular(radius)),
    };

    if (!context.quiet.radius.prefersSuperellipse(radius)) {
      return ClipRRect(borderRadius: borderRadius, child: child);
    }

    return ClipPath(
      clipper: ShapeBorderClipper(
        shape: RoundedSuperellipseBorder(borderRadius: borderRadius),
      ),
      child: child,
    );
  }
}
