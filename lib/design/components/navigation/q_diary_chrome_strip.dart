import 'package:flutter/widgets.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/design/tokens/vintage_diary_tokens.dart';

/// Aged parchment strip from [VintageDiaryAssets.chromeStrip].
///
/// **Bottom navigation only.** Do not use for top bars — titles sit on the
/// dark diary canvas with cream chrome ink.
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

    content = DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(VintageDiaryAssets.chromeStrip),
          fit: BoxFit.cover,
        ),
      ),
      child: content,
    );

    if (safeBottom || safeTop) {
      content = SafeArea(
        top: safeTop,
        bottom: safeBottom,
        child: content,
      );
    }

    return content;
  }
}
