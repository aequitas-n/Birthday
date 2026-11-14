import 'package:flutter/widgets.dart';
import 'package:kin/design/components/surfaces/q_illustrated_surface.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// The primary presentation surface.
///
/// Kin has no dialogs. Sheets replace dialogs, menus and pickers, because a
/// sheet arrives from somewhere and can be dismissed by the same gesture that
/// summoned it — a dialog just appears in the middle of the screen and demands
/// an answer.
///
/// Vintage Diary: warm parchment pulled up from the dark desk — not a dark
/// brown slab that merges into vintage-bg.
///
/// See docs/08-components.md §4.
class QSheet extends StatelessWidget {
  const QSheet({
    required this.child,
    this.title,
    this.bottom,
    this.showGrabber = true,
    super.key,
  });

  final Widget child;
  final String? title;

  /// Pinned actions. At most two, right-aligned.
  final Widget? bottom;

  final bool showGrabber;

  static const double grabberWidth = 36;
  static const double grabberHeight = 4;
  static const double maxHeightFraction = 0.92;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final i = q.interactive;
    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom;
    // Home-indicator inset only — never the keyboard. The keyboard is handled
    // by the outer pad below so the Save bar rides above it instead of
    // growing a hollow band between content and keys.
    final safeBottom = media.viewPadding.bottom;

    final sheet = Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: media.size.height * maxHeightFraction,
          ),
          child: _SheetSurface(
            child: DefaultTextStyle(
              style: q.text.body.tinted(i.ink),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showGrabber) ...[
                    SizedBox(height: q.space.sm),
                    Center(
                      child: Container(
                        width: grabberWidth,
                        height: grabberHeight,
                        decoration: BoxDecoration(
                          color: i.inkMuted.withValues(alpha: 0.55),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(grabberHeight / 2),
                          ),
                        ),
                      ),
                    ),
                  ],
                  Flexible(
                    child: ClipRect(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          q.space.xxl,
                          q.space.lg,
                          q.space.xxl,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (title != null) ...[
                              Text(
                                title!,
                                textAlign: TextAlign.start,
                                textScaler: context.nameTextScaler,
                                style: q.text.sectionTitle.tinted(i.ink),
                              ),
                              SizedBox(height: q.space.lg),
                            ],
                            Flexible(child: child),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (bottom != null) bottom!,
                  SizedBox(
                    height: keyboard > 0 ? q.space.sm : safeBottom + q.space.sm,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return QuietControlSurfaceScope(
      surface: QuietControlSurface.parchment,
      child: sheet,
    );
  }
}

/// Pinned actions at the foot of a sheet or editor. Wraps on small screens.
///
/// Not a persistent bar. The top hairline appears only when content is
/// scrolling beneath it.
class QBottomActions extends StatelessWidget {
  const QBottomActions({
    required this.children,
    this.showDivider = false,
    super.key,
  });

  /// Up to three: dismissal/destructive, optional secondary, then primary.
  final List<Widget> children;

  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    assert(children.length <= 3, 'A sheet offers at most three actions.');
    final q = context.quiet;
    final i = q.interactive;
    final onParchment = context.isParchmentControls;

    return AnimatedContainer(
      duration: q.motion.quick,
      curve: q.motion.standard,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: showDivider
                ? (onParchment ? i.sheetBorder : q.color.hairline)
                : (onParchment ? i.sheet : q.color.canvas),
            width: context.hairlineWidth,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        q.space.xxl,
        q.space.sm,
        q.space.xxl,
        q.space.sm,
      ),
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: q.space.md,
        runSpacing: q.space.sm,
        children: children,
      ),
    );
  }
}

/// Carries the same paper identity as cards, calendars, and profile plates.
class _SheetSurface extends StatelessWidget {
  const _SheetSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    if (context.appTheme.art != null) {
      return QIllustratedSurface(child: child);
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: q.interactive.sheet,
        borderRadius: BorderRadius.vertical(top: Radius.circular(q.radius.xl)),
        boxShadow: q.elevation.overlay,
        border: Border(
          top: BorderSide(
            color: q.interactive.sheetBorder,
            width: context.hairlineWidth,
          ),
        ),
      ),
      child: child,
    );
  }
}
