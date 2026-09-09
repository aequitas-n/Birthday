import 'package:flutter/widgets.dart';

/// Immediate surface behind interactive controls.
///
/// Controls read this from [QuietControlSurfaceScope] so the same button
/// can be cream-on-desk on vintage-bg and burgundy-on-parchment inside sheets
/// and journal cards — without feature widgets inventing colours.
enum QuietControlSurface {
  /// Dark vintage desk (`vintage-bg`). Cream parchment CTAs, cream chrome ink.
  desk,

  /// Light aged paper — bottom sheets, journal cards, calendars.
  /// Burgundy CTAs, brown ink.
  parchment,
}

/// Publishes the ambient control surface for descendants.
class QuietControlSurfaceScope extends InheritedWidget {
  const QuietControlSurfaceScope({
    required this.surface,
    required super.child,
    super.key,
  });

  final QuietControlSurface surface;

  static QuietControlSurface of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<QuietControlSurfaceScope>()
            ?.surface ??
        QuietControlSurface.desk;
  }

  static QuietControlSurface? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<QuietControlSurfaceScope>()
        ?.surface;
  }

  @override
  bool updateShouldNotify(QuietControlSurfaceScope oldWidget) =>
      surface != oldWidget.surface;
}

/// Convenience for the ambient control surface.
extension QuietControlSurfaceX on BuildContext {
  QuietControlSurface get controlSurface => QuietControlSurfaceScope.of(this);

  bool get isParchmentControls =>
      controlSurface == QuietControlSurface.parchment;
}
