import 'package:flutter/widgets.dart';
import 'package:kin/design/components/surfaces/q_illustrated_surface.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Bordered content well whose ink/border come from the active theme surface.
///
/// On [QuietSurfaceKind.canvas]: transparent fill, cream border, cream type
/// via [DefaultTextStyle]. On [QuietSurfaceKind.paper]: cream fill, paper edge,
/// brown ink.
class QDiaryWell extends StatelessWidget {
  const QDiaryWell({
    required this.child,
    this.surface = QuietSurfaceKind.canvas,
    this.padding,
    this.focused = false,
    super.key,
  });

  final Widget child;
  final QuietSurfaceKind surface;
  final EdgeInsetsGeometry? padding;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final ink = q.on(surface);
    final pad = padding ?? EdgeInsets.all(q.space.md);
    final borderColor = focused && surface == QuietSurfaceKind.canvas
        ? ink.primary
        : ink.border;

    if (context.appTheme.art != null) {
      return DefaultTextStyle(
        style: q.text.journalWriting.copyWith(color: ink.primary),
        child: QIllustratedSurface(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.appTheme.art!.corner),
              border: focused
                  ? Border.all(color: q.color.accent, width: 1.5)
                  : null,
            ),
            child: Padding(
              padding: pad.add(const EdgeInsets.symmetric(horizontal: 6)),
              child: child,
            ),
          ),
        ),
      );
    }

    return DefaultTextStyle(
      style: q.text.journalWriting.copyWith(color: ink.primary),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ink.fill,
          borderRadius: BorderRadius.circular(q.radius.sm),
          border: Border.all(
            color: borderColor,
            width: focused ? 1.25 : context.hairlineWidth,
          ),
        ),
        child: Padding(padding: pad, child: child),
      ),
    );
  }
}
