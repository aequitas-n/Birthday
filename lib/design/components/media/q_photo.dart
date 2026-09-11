import 'package:flutter/widgets.dart';
import 'package:kin/design/components/media/q_avatar.dart';
import 'package:kin/design/media/quiet_display_image.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// A photograph that fills whatever box it is given.
///
/// [QAvatar] is a fixed square at one of four diameters — right for a list row,
/// wrong for a hero or a portrait card, both of which are the shape of the
/// composition rather than of the person. This is the fill counterpart, and it
/// keeps the same promise: a person without a photo gets their initials on
/// paper stock, never a grey box and never a generic person glyph.
///
/// Unclipped and uncornered on purpose. The caller owns the shape, because a
/// hero and a card round different corners by different amounts.
class QPhoto extends StatelessWidget {
  const QPhoto({
    required this.displayName,
    required this.seed,
    this.photo,
    this.alignment = const Alignment(0, -0.2),
    super.key,
  });

  final String displayName;

  /// Stable identifier used to pick the monogram tint.
  final String seed;

  final ImageProvider? photo;

  /// Which part of the image survives the crop.
  ///
  /// Biased above centre by default: in a frame taller than it is wide, a
  /// centred crop puts the subject's chin in the middle and their forehead
  /// outside it.
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final monogram = _Monogram(displayName: displayName, seed: seed);
    if (photo == null) return monogram;

    return LayoutBuilder(
      builder: (context, constraints) {
        final image = QuietDisplayImage.maybeAt(
          photo!,
          context: context,
          constraints: constraints,
        );
        return Image(
          image: image,
          fit: BoxFit.cover,
          alignment: alignment,
          width: double.infinity,
          height: double.infinity,
          gaplessPlayback: true,
          excludeFromSemantics: true,
          frameBuilder: (context, child, frame, wasSync) {
            if (wasSync || frame != null) return child;
            // The monogram is the placeholder. "Who is this" deserves a better
            // answer than a grey rectangle.
            return monogram;
          },
          // A photo that fails to decode falls back permanently and silently.
          errorBuilder: (context, error, stack) => monogram,
        );
      },
    );
  }
}

class _Monogram extends StatelessWidget {
  const _Monogram({required this.displayName, required this.seed});

  final String displayName;
  final String seed;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return ColoredBox(
      color: q.color.monogramTintFor(seed),
      child: Center(
        // Scaled down rather than up: initials that grow to fill a hero read
        // as a logo.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: EdgeInsets.all(q.space.xxl),
            child: Text(
              QAvatar.monogramFor(displayName),
              textScaler: TextScaler.noScaling,
              style: q.text.voiceXl.tinted(q.color.textTertiary),
            ),
          ),
        ),
      ),
    );
  }
}
