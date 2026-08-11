import 'package:flutter/widgets.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// A true hairline: one physical pixel, not one logical pixel.
///
/// This is the only container Kin allows itself. When two things need
/// separating, the tools in order are space, then type weight, then this.
/// See docs/03-design-philosophy.md principle III.
class QHairline extends StatelessWidget {
  const QHairline({
    this.indent = 0,
    this.endIndent = 0,
    this.strong = false,
    super.key,
  });

  /// Separators are inset to align with the text they separate, not with the
  /// screen edge.
  final double indent;
  final double endIndent;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final c = context.quiet.color;
    return Padding(
      padding: EdgeInsetsDirectional.only(start: indent, end: endIndent),
      child: SizedBox(
        height: context.hairlineWidth,
        child: ColoredBox(color: strong ? c.hairlineStrong : c.hairline),
      ),
    );
  }
}
