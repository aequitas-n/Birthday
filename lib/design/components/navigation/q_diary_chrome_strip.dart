import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:kin/design/components/surfaces/q_illustrated_surface.dart';
import 'package:kin/design/media/quiet_display_image.dart';
import 'package:kin/design/theme/app_theme_assets.dart' show AppThemeChrome;
import 'package:kin/design/theme/quiet_navigation.dart' show QuietNavigation;
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Bottom navigation strip — textured when the theme provides
/// [AppThemeChrome.navStrip], otherwise a solid [QuietNavigation.surface].
///
/// **Geometry**
/// - Default (no asset): compact — labels + padding + safe-area.
/// - Themed chrome: at least tall enough to **contain the opaque band**
///   (`width / aspectRatio * opaqueFraction`). Never expand to the full
///   transparent asset frame — that created an invisible capsule that shrunk
///   screen content and floated the chrome above the bottom edge.
///
/// When [safeBottom] / [safeTop] is set, insets apply to the **labels** only.
/// The chrome fill still paints edge-to-edge — including the system gesture /
/// home-indicator band.
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
    final chrome = context.appTheme.assets.chrome;
    final asset = chrome.navStrip;
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
      // Prefer viewPadding so the bar still extends under the home indicator
      // when MediaQuery.padding.bottom has been consumed (edge-to-edge).
      content = SafeArea(
        top: safeTop,
        bottom: safeBottom,
        maintainBottomViewPadding: safeBottom,
        child: content,
      );
    }

    if (context.appTheme.art != null) {
      return QIllustratedSurface(
        kind: IllustratedSurfaceKind.navigation,
        child: content,
      );
    }

    // Size from labels (+ safe inset). Themed chrome may raise the floor so
    // the ornate frame is contained instead of clipped.
    final strip = ColoredBox(
      color: q.navigation.surface,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          if (asset != null)
            Positioned.fill(
              child: _NavStripCover(
                asset: asset,
                opaqueFraction: chrome.navStripOpaqueFraction,
                aspectRatio: chrome.navStripAspectRatio,
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

    final aspect = chrome.navStripAspectRatio;
    final opaqueFraction = chrome.navStripOpaqueFraction;
    if (asset != null &&
        aspect != null &&
        aspect > 0 &&
        opaqueFraction > 0 &&
        opaqueFraction < 1) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final opaqueBandHeight =
              constraints.maxWidth / aspect * opaqueFraction;
          return ConstrainedBox(
            constraints: BoxConstraints(minHeight: opaqueBandHeight),
            child: strip,
          );
        },
      );
    }

    return strip;
  }
}

/// Paints [asset] so the **opaque chrome band** fills the bar.
///
/// Transparent margins in the source WebP are cropped via cover-zoom — they
/// must not invent layout height (invisible capsule) or pin a hollow gap under
/// the ornate frame ([Alignment.bottomCenter] on the full frame).
class _NavStripCover extends StatelessWidget {
  const _NavStripCover({
    required this.asset,
    required this.opaqueFraction,
    required this.aspectRatio,
  });

  final String asset;
  final double opaqueFraction;
  final double? aspectRatio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final zoom = _coverZoom(
          barWidth: constraints.maxWidth,
          barHeight: constraints.maxHeight,
          opaqueFraction: opaqueFraction,
          aspectRatio: aspectRatio,
        );

        final cache = QuietDisplayImage.cacheSize(
          context,
          Size(constraints.maxWidth, constraints.maxHeight),
          scale: zoom,
        );

        Widget image = Image.asset(
          asset,
          fit: BoxFit.cover,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          cacheWidth: cache.$1,
          cacheHeight: cache.$2,
          gaplessPlayback: true,
          excludeFromSemantics: true,
        );

        if (zoom > 1) {
          image = Transform.scale(scale: zoom, child: image);
        }

        return ClipRect(child: image);
      },
    );
  }

  /// Extra scale on top of [BoxFit.cover] so the opaque band fills [barHeight].
  static double _coverZoom({
    required double barWidth,
    required double barHeight,
    required double opaqueFraction,
    required double? aspectRatio,
  }) {
    if (opaqueFraction >= 1 ||
        aspectRatio == null ||
        aspectRatio <= 0 ||
        barWidth <= 0 ||
        barHeight <= 0) {
      return 1;
    }

    final coverHeight = barWidth / aspectRatio;
    final opaqueHeight = coverHeight * opaqueFraction;
    if (opaqueHeight <= 0) return 1;

    return math.max(1, barHeight / opaqueHeight);
  }
}
