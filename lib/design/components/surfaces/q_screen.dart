import 'package:flutter/widgets.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/design/theme/vintage_diary_background.dart';

/// Kin's replacement for `Scaffold`.
///
/// There is no app bar, no toolbar, no bottom navigation. A screen is the
/// canvas, safe insets, and content. Titles are content — they scroll away
/// with everything else, because a persistent bar is furniture that competes
/// with the words that matter.
class QScreen extends StatelessWidget {
  const QScreen({
    required this.child,
    this.bottom,
    this.canvasColor,
    this.applyTopInset = true,
    this.applyBottomInset = true,
    super.key,
  });

  final Widget child;

  /// Pinned above the bottom safe inset. Used by sheets and editors only —
  /// never as a persistent app-wide bar.
  final Widget? bottom;

  /// Optional page colour. When set, replaces the Vintage Diary texture with a
  /// flat fill — reserved for rare overrides (e.g. full-screen photo viewers).
  final Color? canvasColor;

  final bool applyTopInset;
  final bool applyBottomInset;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final useTexture = canvasColor == null;

    final content = DefaultTextStyle(
      style: q.inked(q.text.body),
      child: SafeArea(
        top: applyTopInset,
        bottom: applyBottomInset && bottom == null,
        child: bottom == null
            ? child
            : Column(
                children: [
                  Expanded(child: child),
                  SafeArea(top: false, child: bottom!),
                ],
              ),
      ),
    );

    if (!useTexture) {
      return ColoredBox(color: canvasColor!, child: content);
    }

    return VintageDiaryCanvas(child: content);
  }
}

/// Constrains content to the reading measure and centres it once the viewport
/// is wider than that. There is no tablet-specific navigation — the same
/// information architecture scales, and only the measure changes.
class QMeasure extends StatelessWidget {
  const QMeasure({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: context.quiet.layout.contentMaxWidth,
        ),
        child: child,
      ),
    );
  }
}
