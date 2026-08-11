import 'package:flutter/widgets.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// What a chip is carrying.
enum QChipTone {
  /// A remembered detail: a flower, a colour, a film.
  quiet,

  /// A gift idea — the one kind of detail the user acts on.
  accent,

  /// Sitting on a photograph.
  onImage,
}

/// A read-only chip.
///
/// Deliberately not `QPill`, which is a control: pills are chosen from, chips
/// are read. Sharing one widget between the two made a favourite flower look
/// tappable and a relationship picker look inert.
///
/// Drawn directly rather than through `QSurface` because two of the three tones
/// fill with an accent wash, and surface levels are neutrals only.
class QChip extends StatelessWidget {
  const QChip(this.label, {this.tone = QChipTone.quiet, super.key});

  final String label;
  final QChipTone tone;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    final (fill, border, ink) = switch (tone) {
      QChipTone.quiet => (
        q.color.surface,
        q.color.hairline,
        q.color.textPrimary,
      ),
      QChipTone.accent => (q.color.accentWash, q.color.accent, q.color.accent),
      QChipTone.onImage => (
        q.photo.flatScrim,
        q.photo.onImageSecondary,
        q.photo.onImagePrimary,
      ),
    };

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: fill,
        shape: StadiumBorder(
          side: BorderSide(color: border, width: context.hairlineWidth),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: q.space.md + q.space.hair,
          vertical: q.space.sm,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textScaler: context.structuralTextScaler,
          style: q.text.chipLabel.tinted(ink),
        ),
      ),
    );
  }
}
