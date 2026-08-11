import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/design/components/media/q_photo.dart';
import 'package:kin/design/components/surfaces/q_card.dart';
import 'package:kin/design/components/surfaces/q_surface.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/features/home/application/gallery_providers.dart';
import 'package:kin/features/person/application/person_detail_providers.dart';

/// A portrait in the relationship gallery.
///
/// The photograph is the card. Previously the image sat inside a frame with the
/// name printed on the mount below it, which is a contact-list row wearing a
/// card: it produced two competing rectangles and a lot of dead paper. Here the
/// image bleeds to all four corners and the words sit in the picture, the way
/// they do on a pass in Wallet or a cover in Photos.
class ProfilePortraitCard extends ConsumerWidget {
  const ProfilePortraitCard({
    required this.entry,
    required this.onTap,
    required this.height,
    this.heroTag,
    super.key,
  });

  final GalleryEntry entry;
  final VoidCallback onTap;
  final double height;
  final Object? heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = context.quiet;
    final photo = ref.watch(personPhotoProvider(entry.profile.photoId));
    final relationship = entry.relationshipLabel;

    final Widget portrait = QPhoto(
      displayName: entry.primaryName,
      seed: entry.person.id,
      photo: photo.asData?.value,
    );

    return QCard(
      tone: QCardTone.gallery,
      onTap: onTap,
      semanticLabel: [
        entry.primaryName,
        if (entry.isPinned) 'Pinned',
        if (relationship != null) relationship,
        entry.countdownLabel(),
      ].join(', '),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: QClip(
          radius: q.radius.xxl,
          child: Stack(
            fit: StackFit.expand,
            children: [
              RepaintBoundary(
                child: heroTag == null
                    ? portrait
                    : Hero(tag: heroTag!, child: portrait),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: q.photo.cardScrim,
                        stops: q.photo.cardScrimStops,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: q.space.xl,
                right: q.space.xl,
                bottom: q.space.xl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (entry.isPinned) ...[
                      Text(
                        'Pinned',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textScaler: context.heroTextScaler,
                        style: context.onImage(
                          q.text.relationship,
                          secondary: true,
                        ),
                      ),
                      SizedBox(height: q.space.xs),
                    ] else if (relationship != null) ...[
                      Text(
                        relationship,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textScaler: context.heroTextScaler,
                        style: context.onImage(
                          q.text.relationship,
                          secondary: true,
                        ),
                      ),
                      SizedBox(height: q.space.xs),
                    ],
                    if (entry.isPinned && relationship != null) ...[
                      Text(
                        relationship,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textScaler: context.heroTextScaler,
                        style: context.onImage(
                          q.text.metadata,
                          secondary: true,
                        ),
                      ),
                      SizedBox(height: q.space.xs),
                    ],
                    Text(
                      entry.primaryName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textScaler: context.heroTextScaler,
                      textHeightBehavior: q.text.displayHeightBehavior,
                      style: context.onImage(q.text.voiceLg),
                    ),
                    SizedBox(height: q.space.md),
                    Text(
                      entry.countdownLabel(),
                      maxLines: 1,
                      textScaler: context.heroTextScaler,
                      style: context.onImage(
                        q.text.numeralSm,
                        secondary: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The empty state of the gallery: one card, and an invitation.
class CreateProfilePortraitCard extends StatelessWidget {
  const CreateProfilePortraitCard({
    required this.onTap,
    required this.height,
    super.key,
  });

  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return QCard(
      tone: QCardTone.gallery,
      onTap: onTap,
      semanticLabel: 'Create a relationship profile',
      padding: EdgeInsets.all(q.space.xxl),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A place for someone',
              style: q.text.voiceMd.tinted(q.color.textPrimary),
            ),
            SizedBox(height: q.space.md),
            Text(
              'Their photograph, their nickname, and the details you would '
              'hate to have to ask about.',
              style: q.text.body.tinted(q.color.textSecondary),
            ),
            SizedBox(height: q.space.xl),
            Row(
              children: [
                QGlyphIcon(
                  QuietGlyph.plus,
                  color: q.color.accent,
                  size: context.structuralTextScaler.scale(18),
                ),
                SizedBox(width: q.space.sm),
                Text(
                  'Create a profile',
                  style: q.text.buttonLabel.tinted(q.color.accent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The card at the end of a populated carousel.
///
/// The same silhouette as the portraits beside it — same radius, same lift —
/// because a differently shaped card at the end of the stack reads as a
/// different kind of object rather than as one more place to put someone.
class AddProfileCarouselCard extends StatelessWidget {
  const AddProfileCarouselCard({
    required this.onTap,
    required this.height,
    super.key,
  });

  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return QCard(
      tone: QCardTone.gallery,
      onTap: onTap,
      semanticLabel: 'Add a relationship profile',
      padding: EdgeInsets.all(q.space.xxl),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QGlyphIcon(
              QuietGlyph.plus,
              color: q.color.textTertiary,
              size: context.structuralTextScaler.scale(24),
            ),
            SizedBox(height: q.space.base),
            Text(
              'Someone else',
              textAlign: TextAlign.center,
              style: q.text.body.tinted(q.color.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
