import 'package:flutter/widgets.dart';
import 'package:kin/app/app_shell.dart' show AppShell;
import 'package:kin/design/components/surfaces/q_illustrated_surface.dart';
import 'package:kin/design/media/quiet_display_image.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Marks that a full-bleed [QuietThemeBackdrop] is already painted by an
/// ancestor (e.g. [AppShell]). Nested [QThemeCanvas] must not paint another
/// cover-fitted copy — that restarts the artwork at the body/nav seam.
class QuietShellBackdropScope extends InheritedWidget {
  const QuietShellBackdropScope({required super.child, super.key});

  static bool activeOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<QuietShellBackdropScope>() !=
        null;
  }

  @override
  bool updateShouldNotify(covariant QuietShellBackdropScope oldWidget) => false;
}

/// Full-bleed product-theme backdrop (canvas colour + optional app background).
///
/// Used by [QThemeCanvas] and [AppShell] so decorative themes can continue the
/// same artwork behind bottom navigation without a second solid slab.
class QuietThemeBackdrop extends StatelessWidget {
  const QuietThemeBackdrop({
    this.includeScrim = true,
    super.key,
  });

  /// Soft radial darkening over busy corner art (legibility for light type).
  final bool includeScrim;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final art = context.appTheme.art;
    final asset = art?.background ?? context.appTheme.assets.backgrounds.app;
    final viewport = MediaQuery.sizeOf(context);
    final cache = QuietDisplayImage.cacheSize(context, viewport);

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: q.color.canvas),
        if (asset != null) ...[
          Positioned.fill(
            child: Image.asset(
              asset,
              fit: BoxFit.cover,
              cacheWidth: cache.$1,
              cacheHeight: cache.$2,
              gaplessPlayback: true,
              excludeFromSemantics: true,
            ),
          ),
          if (includeScrim && art == null)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 1.15,
                    colors: [
                      q.color.transparent,
                      q.color.scrim.withValues(alpha: 0.35),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

/// Full-screen app canvas from the active product theme.
///
/// When `AppThemeAssets.backgrounds.app` is null, renders a solid canvas.
/// When set, draws the texture over the theme canvas colour — unless an
/// ancestor [QuietShellBackdropScope] already owns the full-bleed art.
class QThemeCanvas extends StatelessWidget {
  const QThemeCanvas({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (QuietShellBackdropScope.activeOf(context)) {
      // Shell already painted one continuous backdrop behind body + nav.
      return child;
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        const QuietThemeBackdrop(),
        child,
      ],
    );
  }
}

/// Journal memory card paper — image when the theme provides one, else solid.
class QJournalCardSurface extends StatelessWidget {
  const QJournalCardSurface({
    required this.child,
    this.padding,
    this.scaleContentToFit,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  /// When true, shrinks [child] uniformly if it exceeds the safe content box.
  /// Defaults to true whenever theme `journalCardContent` is set (CRT frames).
  /// Memory cards that use [Expanded] must pass false.
  final bool? scaleContentToFit;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final j = q.journal;
    if (context.appTheme.art != null) {
      return QIllustratedSurface(
        padding: padding ?? const EdgeInsets.fromLTRB(24, 24, 24, 26),
        child: QuietControlSurfaceScope(
          surface: QuietControlSurface.parchment,
          child: child,
        ),
      );
    }
    final asset = context.appTheme.assets.backgrounds.journalCard;
    final layout = context.appTheme.assets.layout;
    final contentRect = layout.journalCardContent;
    final artAspect = layout.journalCardAspectRatio;
    final hasArt = asset != null;

    Widget paperShell({
      required EdgeInsetsGeometry resolvedPadding,
      required BorderRadius radius,
      required bool expand,
      required Widget content,
    }) {
      final padded = QuietControlSurfaceScope(
        surface: QuietControlSurface.parchment,
        child: Padding(padding: resolvedPadding, child: content),
      );

      return DecoratedBox(
        decoration: BoxDecoration(
          color: hasArt ? q.color.transparent : j.paper,
          borderRadius: radius,
          border: hasArt
              ? null
              : Border.all(color: j.edge, width: context.hairlineWidth),
          boxShadow: hasArt
              ? const []
              : [
                  BoxShadow(
                    color: j.shadow,
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: expand ? SizedBox.expand(child: padded) : padded,
        ),
      );
    }

    Widget buildArtSurface(BoxConstraints constraints) {
      final logicalW = constraints.maxWidth.isFinite && constraints.maxWidth > 0
          ? constraints.maxWidth
          : MediaQuery.sizeOf(context).width;
      final logicalH =
          constraints.maxHeight.isFinite && constraints.maxHeight > 0
          ? constraints.maxHeight
          : artAspect != null && artAspect > 0
          ? logicalW / artAspect
          : logicalW * 1.25;
      final size = Size(logicalW, logicalH);
      final cache = QuietDisplayImage.cacheSize(context, size);

      final resolvedPadding =
          padding ??
          (contentRect != null
              ? contentRect.toPadding(size)
              : EdgeInsets.fromLTRB(
                  q.space.xl,
                  q.space.lg,
                  q.space.xl,
                  q.space.xl,
                ));

      final corner = layout.journalCardCornerRadius ?? 0.0;
      final radius = BorderRadius.circular(corner);

      return DecoratedBox(
        decoration: BoxDecoration(
          color: q.color.transparent,
          borderRadius: radius,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Image.asset(
                  asset!,
                  fit: BoxFit.cover,
                  cacheWidth: cache.$1,
                  cacheHeight: cache.$2,
                  gaplessPlayback: true,
                  excludeFromSemantics: true,
                ),
              ),
              Positioned.fill(
                child: QuietControlSurfaceScope(
                  surface: QuietControlSurface.parchment,
                  child: Padding(
                    padding: resolvedPadding,
                    child: (scaleContentToFit ?? contentRect != null)
                        ? FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width:
                                  size.width -
                                  resolvedPadding
                                      .resolve(TextDirection.ltr)
                                      .horizontal,
                              child: child,
                            ),
                          )
                        : child,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final heightBounded =
            constraints.maxHeight.isFinite && constraints.maxHeight > 0;
        final corner =
            layout.journalCardCornerRadius ?? (hasArt ? 0.0 : q.radius.lg);
        final radius = BorderRadius.circular(corner);

        // Default solid paper: size to the child when height is unbound
        // (Today). An expand-only Stack collapses to 0 and piles sections.
        if (!hasArt) {
          final resolvedPadding =
              padding ??
              EdgeInsets.fromLTRB(
                q.space.xl,
                q.space.lg,
                q.space.xl,
                q.space.xl,
              );
          return paperShell(
            resolvedPadding: resolvedPadding,
            radius: radius,
            expand: heightBounded,
            content: child,
          );
        }

        if (artAspect != null && artAspect > 0 && !heightBounded) {
          return AspectRatio(
            aspectRatio: artAspect,
            child: LayoutBuilder(
              builder: (context, inner) => buildArtSurface(inner),
            ),
          );
        }
        return buildArtSurface(constraints);
      },
    );
  }
}

/// Journal month calendar surface — image when provided, else solid paper.
class QCalendarSurface extends StatelessWidget {
  const QCalendarSurface({
    required this.child,
    this.padding,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final j = q.journal;
    if (context.appTheme.art != null) {
      return QIllustratedSurface(
        kind: IllustratedSurfaceKind.calendar,
        padding: padding ?? const EdgeInsets.fromLTRB(12, 20, 12, 18),
        child: QuietControlSurfaceScope(
          surface: QuietControlSurface.parchment,
          child: child,
        ),
      );
    }
    final asset = context.appTheme.assets.backgrounds.calendar;
    final resolvedPadding =
        padding ??
        EdgeInsets.fromLTRB(q.space.sm, q.space.md, q.space.sm, q.space.md);

    return LayoutBuilder(
      builder: (context, constraints) {
        final logicalW =
            constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final logicalH =
            constraints.maxHeight.isFinite && constraints.maxHeight > 0
            ? constraints.maxHeight
            : logicalW;
        final cache = QuietDisplayImage.cacheSize(
          context,
          Size(logicalW, logicalH),
        );
        final hasArt = asset != null;
        // Minimal radius on every theme (art + solid) so calendar plates
        // don't read as hard-cut rectangles.
        final radius = BorderRadius.circular(q.radius.xs);

        return DecoratedBox(
          decoration: BoxDecoration(
            color: hasArt ? q.color.transparent : j.paper,
            borderRadius: radius,
            border: hasArt
                ? null
                : Border.all(color: j.edge, width: context.hairlineWidth),
            boxShadow: [
              BoxShadow(
                color: j.shadow,
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              children: [
                if (hasArt)
                  Positioned.fill(
                    child: Image.asset(
                      asset,
                      fit: BoxFit.cover,
                      cacheWidth: cache.$1,
                      cacheHeight: cache.$2,
                      gaplessPlayback: true,
                      excludeFromSemantics: true,
                    ),
                  ),
                QuietControlSurfaceScope(
                  surface: QuietControlSurface.parchment,
                  child: Padding(padding: resolvedPadding, child: child),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
