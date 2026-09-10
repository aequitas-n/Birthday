import 'package:flutter/widgets.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Bottom navigation strip — textured when the theme provides
/// [AppThemeChrome.navStrip], otherwise a solid [QuietNavigation.surface].
///
/// **Geometry is owned by this container**, never by the asset. The optional
/// [navStrip] image only paints the surface inside the same bounds Default
/// would use (full width × content + safe-area height).
///
/// When [safeBottom] / [safeTop] is set, insets apply to the **child** only.
/// The chrome fill still paints edge-to-edge — including the system gesture /
/// home-indicator band — so themes never shift navigation position.
class QDiaryChromeStrip extends StatelessWidget {
  const QDiaryChromeStrip({
    required this.child,
    this.height,
    this.padding,
    this.safeBottom = false,
    this.safeTop = false,
    super.key,
  });

  final Widget child;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool safeBottom;
  final bool safeTop;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final asset = context.appTheme.assets.chrome.navStrip;
    final resolvedPadding =
        padding ??
        EdgeInsets.symmetric(
          horizontal: q.space.md,
          vertical: q.space.xs,
        );

    Widget content = QuietControlSurfaceScope(
      surface: QuietControlSurface.parchment,
      child: Padding(padding: resolvedPadding, child: child),
    );

    if (height != null) {
      content = SizedBox(height: height, child: content);
    }

    if (safeBottom || safeTop) {
      content = SafeArea(
        top: safeTop,
        bottom: safeBottom,
        child: content,
      );
    }

    // Surface paints behind [content]; layout size comes only from [content].
    // Vintage `bottom-navbar.webp` is a tall transparent canvas with the
    // parchment band near the vertical center — cover + center crops the
    // empty margins so the strip fills this bar. topCenter would keep the
    // transparent head and visually float/misplace the parchment.
    return ColoredBox(
      color: q.navigation.surface,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          if (asset != null)
            Positioned.fill(
              child: Image.asset(
                asset,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                gaplessPlayback: true,
                filterQuality: FilterQuality.medium,
                excludeFromSemantics: true,
              ),
            )
          else
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ColoredBox(
                color: q.navigation.border,
                child: SizedBox(height: context.hairlineWidth),
              ),
            ),
          content,
        ],
      ),
    );
  }
}
