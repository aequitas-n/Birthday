import 'package:flutter/widgets.dart';
import 'package:kin/design/components/surfaces/q_surface.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// The primary presentation surface.
///
/// Kin has no dialogs. Sheets replace dialogs, menus and pickers, because a
/// sheet arrives from somewhere and can be dismissed by the same gesture that
/// summoned it — a dialog just appears in the middle of the screen and demands
/// an answer.
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
    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom;
    // Home-indicator inset only — never the keyboard. The keyboard is handled
    // by the outer pad below so the Save bar rides above it instead of
    // growing a hollow band between content and keys.
    final safeBottom = media.viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: media.size.height * maxHeightFraction,
          ),
          child: QSurface(
            level: QuietLevel.raised,
            elevation: QuietElevationLevel.overlay,
            radius: q.radius.xl,
            topCornersOnly: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showGrabber) ...[
                  SizedBox(height: q.space.sm),
                  Container(
                    width: grabberWidth,
                    height: grabberHeight,
                    decoration: BoxDecoration(
                      color: q.color.hairlineStrong,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(grabberHeight / 2),
                      ),
                    ),
                  ),
                ],
                Flexible(
                  child: ClipRect(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        q.space.xxl,
                        q.space.xl,
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
                              style: q.text.title.tinted(q.color.textPrimary),
                            ),
                            SizedBox(height: q.space.xl),
                          ],
                          Flexible(child: child),
                        ],
                      ),
                    ),
                  ),
                ),
                if (bottom != null) bottom!,
                // When the keyboard is up the outer pad already clears it, so
                // only a hair of breathing room is needed under the actions.
                SizedBox(
                  height: keyboard > 0 ? q.space.sm : safeBottom + q.space.sm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pinned actions at the foot of a sheet or editor.
///
/// Not a persistent bar. The top hairline appears only when content is
/// scrolling beneath it.
class QBottomActions extends StatelessWidget {
  const QBottomActions({
    required this.children,
    this.showDivider = false,
    super.key,
  });

  /// At most two, right-aligned: tertiary then primary.
  final List<Widget> children;

  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    assert(children.length <= 2, 'A sheet offers at most two actions.');
    final q = context.quiet;

    return AnimatedContainer(
      duration: q.motion.quick,
      curve: q.motion.standard,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: showDivider ? q.color.hairline : q.color.canvas,
            width: context.hairlineWidth,
          ),
        ),
      ),
      // Tight on purpose: a tall action strip reads as wasted chrome sitting
      // on top of the keyboard.
      padding: EdgeInsets.fromLTRB(
        q.space.xxl,
        q.space.sm,
        q.space.xxl,
        q.space.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0) SizedBox(width: q.space.md),
            child,
          ],
        ],
      ),
    );
  }
}
