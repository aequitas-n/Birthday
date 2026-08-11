import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// A bare glyph with a full-size hit area.
///
/// Reserved for the four glyphs whose meaning is universal: plus, search,
/// close and back. Every other icon in the app carries a label.
///
/// Hit area and visual area are decoupled: the target is always at least
/// 44×44 regardless of how small the glyph looks.
class QIconButton extends StatelessWidget {
  const QIconButton({
    required this.glyph,
    required this.onPressed,
    required this.semanticLabel,
    this.glyphSize = 22,
    this.tone = QIconTone.primary,
    super.key,
  });

  final QuietGlyph glyph;
  final VoidCallback? onPressed;

  /// Required: an unlabelled control must still announce itself.
  final String semanticLabel;

  final double glyphSize;
  final QIconTone tone;

  static const double target = 44;
  static const double disabledOpacity = 0.38;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final enabled = onPressed != null;

    final color = switch (tone) {
      QIconTone.primary => q.color.textPrimary,
      QIconTone.secondary => q.color.textSecondary,
      QIconTone.tertiary => q.color.textTertiary,
      QIconTone.danger => q.color.danger,
      QIconTone.onImage => q.photo.onImagePrimary,
    };

    final Widget mark = QGlyphIcon(
      glyph,
      color: color,
      size: context.structuralTextScaler.scale(glyphSize),
    );

    return Opacity(
      opacity: enabled ? 1 : disabledOpacity,
      child: SizedBox.square(
        dimension: target,
        child: QPressable(
          enabled: enabled,
          onTap: onPressed,
          radius: q.radius.full,
          // Over a photograph the press tint has to be light, because the
          // sunken neutral is invisible against an image.
          pressTint: tone == QIconTone.onImage ? q.photo.flatScrim : null,
          semanticLabel: semanticLabel,
          child: Center(
            child: tone == QIconTone.onImage
                // A stroked glyph alone disappears over a pale sky. A small
                // scrim disc costs nothing and makes it unconditional.
                ? DecoratedBox(
                    decoration: ShapeDecoration(
                      color: q.photo.flatScrim,
                      shape: const CircleBorder(),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(q.space.sm),
                      child: mark,
                    ),
                  )
                : mark,
          ),
        ),
      ),
    );
  }
}

enum QIconTone {
  primary,
  secondary,
  tertiary,
  danger,

  /// Sitting on a photograph.
  onImage,
}
