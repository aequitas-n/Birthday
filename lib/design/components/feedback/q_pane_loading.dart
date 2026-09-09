import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_arc.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Lightweight in-pane loading — a centered [QArc] inside reserved space.
///
/// Use instead of [SizedBox.shrink] while local Drift streams resolve so the
/// layout does not jump or flash empty chrome.
class QPaneLoading extends StatelessWidget {
  const QPaneLoading({this.minHeight = 120, super.key});

  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Center(
        child: SizedBox.square(
          dimension: 16,
          child: QArc(color: q.color.textTertiary),
        ),
      ),
    );
  }
}
