import 'package:flutter/widgets.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Full-screen app canvas from the active product theme.
///
/// When [AppThemeAssets.backgrounds.app] is null, renders a solid canvas.
/// When set, draws the texture over the theme canvas colour.
class QThemeCanvas extends StatelessWidget {
  const QThemeCanvas({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final asset = context.appTheme.assets.backgrounds.app;

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: q.color.canvas),
        if (asset != null) ...[
          DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(asset),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Soft edge darkening so light type stays legible over busy corners.
          DecoratedBox(
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
        ],
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
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final j = q.journal;
    final asset = context.appTheme.assets.backgrounds.journalCard;
    final resolvedPadding =
        padding ??
        EdgeInsets.fromLTRB(q.space.xl, q.space.lg, q.space.xl, q.space.xl);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: j.paper,
        borderRadius: BorderRadius.circular(q.radius.lg),
        border: asset == null
            ? Border.all(color: j.edge, width: context.hairlineWidth)
            : null,
        boxShadow: [
          BoxShadow(
            color: j.shadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        image: asset == null
            ? null
            : DecorationImage(
                image: AssetImage(asset),
                fit: BoxFit.cover,
              ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(q.radius.lg),
        child: QuietControlSurfaceScope(
          surface: QuietControlSurface.parchment,
          child: Padding(padding: resolvedPadding, child: child),
        ),
      ),
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
    final asset = context.appTheme.assets.backgrounds.calendar;
    final resolvedPadding =
        padding ??
        EdgeInsets.fromLTRB(q.space.sm, q.space.md, q.space.sm, q.space.md);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: j.paper,
        borderRadius: BorderRadius.circular(q.radius.md),
        border: Border.all(color: j.edge, width: context.hairlineWidth),
        boxShadow: [
          BoxShadow(
            color: j.shadow,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
        image: asset == null
            ? null
            : DecorationImage(
                image: AssetImage(asset),
                fit: BoxFit.cover,
              ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(q.radius.md),
        child: QuietControlSurfaceScope(
          surface: QuietControlSurface.parchment,
          child: Padding(padding: resolvedPadding, child: child),
        ),
      ),
    );
  }
}
