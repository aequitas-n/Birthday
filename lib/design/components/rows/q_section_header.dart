import 'package:flutter/widgets.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// A section eyebrow.
///
/// Sticky on scroll with no background change and no shadow — it simply
/// persists at the top of its section against the canvas. Uppercase is
/// permitted here and nowhere else in the app.
class QSectionHeader extends StatelessWidget {
  const QSectionHeader(this.label, {this.isFirst = false, super.key});

  final String label;

  /// The first header on a screen sits closer to the top than a header that
  /// follows a previous section.
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return Padding(
      padding: EdgeInsets.only(
        top: isFirst ? q.space.xl : q.space.section,
        bottom: q.space.md,
      ),
      child: Text(
        label.toUpperCase(),
        textScaler: context.structuralTextScaler,
        style: q.text.eyebrow.tinted(context.controlInk),
      ),
    );
  }
}
