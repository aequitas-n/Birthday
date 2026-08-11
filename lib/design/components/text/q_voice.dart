import 'package:flutter/widgets.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Display type, optically aligned.
///
/// Large type has a visible left side bearing: the glyph starts a pixel or two
/// inside its own box. Set flush against a gutter, a 56pt name therefore looks
/// indented while the 15pt line beneath it looks correct — the larger the type,
/// the more obviously wrong it reads.
///
/// So the box is nudged left by the amount the glyph is inset, using a
/// transform rather than padding: the shift is optical, and must not move the
/// layout around it. Every headline in Kin that is set at 28pt or above goes
/// through here, which is the only way the correction stays consistent.
class QVoice extends StatelessWidget {
  const QVoice(
    this.text, {
    required this.style,
    this.maxLines,
    this.textAlign,
    this.textScaler,
    this.textHeightBehavior,
    super.key,
  });

  final String text;

  /// A Voice token, already tinted.
  final TextStyle style;

  final int? maxLines;
  final TextAlign? textAlign;

  /// Defaults to the name clamp, which is right for every display line that
  /// names a person or opens a screen.
  final TextScaler? textScaler;

  /// Pass the display behaviour when the line is the topmost thing in its
  /// column and its leading would otherwise show as a gap above it.
  final TextHeightBehavior? textHeightBehavior;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final bearing = q.text.sideBearingFor(style.fontSize ?? 0);

    final child = Text(
      text,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      textScaler: textScaler ?? context.nameTextScaler,
      textHeightBehavior: textHeightBehavior,
      style: style,
    );

    if (bearing == 0) return child;
    // Centred type is already balanced on both bearings; only flush-left type
    // needs the correction.
    if (textAlign == TextAlign.center) return child;

    return Transform.translate(offset: Offset(bearing, 0), child: child);
  }
}
