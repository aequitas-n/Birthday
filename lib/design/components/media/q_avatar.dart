import 'package:flutter/widgets.dart';
import 'package:kin/design/components/surfaces/q_surface.dart';
import 'package:kin/design/media/quiet_display_image.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Avatar sizes. See docs/04-design-system.md §10.
enum QAvatarSize {
  /// Search results, quick actions.
  sm(32),

  /// Home list rows.
  md(44),

  /// Person screen header.
  lg(96),

  /// Photo viewer entry state.
  hero(148)
  ;

  const QAvatarSize(this.diameter);
  final double diameter;

  /// Small avatars are circles; large ones are superellipses, where the
  /// difference in corner geometry is actually visible.
  bool get isCircle => this == QAvatarSize.sm || this == QAvatarSize.md;
}

/// A person, as a photograph or as a monogram.
///
/// Never a generic person glyph, never coloured initials on a saturated
/// background, never a presence dot. A person without a photo gets their
/// initials on one of six low-chroma paper tints, chosen deterministically
/// from their id so it never changes between launches.
class QAvatar extends StatelessWidget {
  const QAvatar({
    required this.displayName,
    required this.seed,
    this.size = QAvatarSize.md,
    this.photo,
    this.heroTag,
    super.key,
  });

  final String displayName;

  /// Stable identifier used to pick the monogram tint.
  final String seed;

  final QAvatarSize size;
  final ImageProvider? photo;
  final Object? heroTag;

  /// One or two letters, taken from the first and last word of the name.
  static String monogramFor(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '';
    if (words.length == 1) {
      return words.first.characters.first.toUpperCase();
    }
    return (words.first.characters.first + words.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final radius = size.isCircle ? size.diameter / 2 : q.radius.lg;

    final tint = q.color.monogramTintFor(seed);

    // The monogram also serves as the placeholder while a photo decodes.
    // A grey box would be a worse answer to "who is this".
    final Widget monogram = ColoredBox(
      color: tint,
      child: Center(
        child: Text(
          monogramFor(displayName),
          textScaler: TextScaler.noScaling,
          style: _monogramStyle(context).tinted(q.color.textSecondary),
        ),
      ),
    );

    final content = photo == null
        ? monogram
        : Image(
            image: QuietDisplayImage.at(
              photo!,
              context: context,
              logicalWidth: size.diameter,
              logicalHeight: size.diameter,
            ),
            fit: BoxFit.cover,
            width: size.diameter,
            height: size.diameter,
            gaplessPlayback: true,
            frameBuilder: (context, child, frame, wasSync) {
              if (wasSync || frame != null) return child;
              return monogram;
            },
            // A failed photo falls back permanently and silently. The user
            // does not need to be told their picture did not decode.
            errorBuilder: (context, error, stack) => monogram,
          );

    final avatar = SizedBox.square(
      dimension: size.diameter,
      child: QClip(radius: radius, child: content),
    );

    if (heroTag == null) return avatar;
    return Hero(tag: heroTag!, child: avatar);
  }

  TextStyle _monogramStyle(BuildContext context) {
    final t = context.quiet.text;
    return switch (size) {
      QAvatarSize.sm => t.voiceSm.copyWith(fontSize: 13),
      QAvatarSize.md => t.voiceSm,
      QAvatarSize.lg => t.voiceLg,
      QAvatarSize.hero => t.voiceXl,
    };
  }
}
