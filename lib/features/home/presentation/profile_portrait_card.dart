import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/media/q_avatar.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/media/quiet_display_image.dart';
import 'package:kin/design/theme/app_theme_surface_layout.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/design/tokens/vintage_portrait_geometry.dart';
import 'package:kin/features/home/application/gallery_memory.dart';
import 'package:kin/features/home/application/gallery_providers.dart';
import 'package:kin/features/person/application/person_detail_providers.dart';

/// How much of a portrait card's editorial copy is shown.
enum ProfilePortraitDepth {
  /// The card in hand — full hierarchy.
  active,

  /// Reserved for compact contexts (search results, etc.).
  neighbour,
}

/// Profile portrait card — theme profile-card chrome when present,
/// otherwise a solid paper plate.
///
/// Active cards show a compact identity row (circle photo + name + countdown)
/// and one note / one moment preview — empty slots offer a + cue; the whole
/// plate opens the person.
class ProfilePortraitCard extends ConsumerWidget {
  const ProfilePortraitCard({
    required this.entry,
    required this.onTap,
    required this.width,
    required this.height,
    this.heroTag,
    this.depth = ProfilePortraitDepth.active,
    this.memory,
    super.key,
  });

  final GalleryEntry entry;
  final VoidCallback onTap;
  final double width;
  final double height;
  final Object? heroTag;
  final ProfilePortraitDepth depth;
  final GalleryMemorySummary? memory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = context.quiet;
    final width = this.width;
    final layout = context.appTheme.assets.layout.profileCard;
    final hasPlateArt = context.appTheme.assets.chrome.profileCard != null;
    // Decorative plates keep ink in the photo/CRT window. Default solid paper
    // uses the full plate — Vintage photoBottom would leave the lower third empty.
    final contentLeft =
        hasPlateArt ? (layout?.photoLeft ?? ProfileCardGeometry.photoLeft) : 0.08;
    final contentRight =
        hasPlateArt ? (layout?.photoRight ?? ProfileCardGeometry.photoRight) : 0.92;
    final contentTop =
        hasPlateArt ? (layout?.photoTop ?? ProfileCardGeometry.photoTop) : 0.06;
    final photoBottom = hasPlateArt
        ? (layout?.photoBottom ?? ProfileCardGeometry.photoBottom)
        : 0.94;
    final contentBottom = 1 - photoBottom;
    final clipCorners = layout?.clipPlateCorners ?? true;
    final plateCornerRadius = clipCorners
        ? (layout?.cornerRadius ?? q.radius.sm)
        : 0.0;
    final photo = ref.watch(personPhotoProvider(entry.profile.photoId));
    final relationship = entry.relationshipLabel;
    final isActive = depth == ProfilePortraitDepth.active;

    final plateChild = Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        _ProfileCardPlate(
          width: width,
          height: height,
          clipCorners: clipCorners,
          cornerRadius: plateCornerRadius,
        ),
        Positioned(
          left: width * contentLeft,
          right: width * (1 - contentRight),
          top: height * contentTop,
          bottom: height * contentBottom,
          child: _ProfileCardBody(
            entry: entry,
            memory: memory,
            photo: photo.asData?.value,
            heroTag: heroTag,
            compact: !isActive,
            cardWidth: width,
            cardHeight: height,
            contentTopFraction: contentTop,
            layout: layout,
          ),
        ),
      ],
    );

    final plate = SizedBox(
      width: width,
      height: height,
      child: plateCornerRadius > 0
          ? ClipRRect(
              borderRadius: BorderRadius.circular(plateCornerRadius),
              child: plateChild,
            )
          : plateChild,
    );

    final card = QPressable(
      onTap: onTap,
      onLongPress: isActive ? () => _togglePin(ref) : null,
      radius: q.radius.md,
      semanticLabel: [
        entry.primaryName,
        if (entry.isPinned) 'Pinned',
        if (isActive)
          entry.isPinned
              ? 'Long press to unpin from top'
              : 'Long press to pin to top',
        if (relationship != null) relationship,
        if (isActive) entry.countdownLabel(),
        if (memory != null && memory!.hasNote) 'Note: ${memory!.notePreview}',
        if (memory != null && memory!.hasMoment)
          'Moment: ${memory!.momentPreview}',
        if (memory != null && memory!.hasMemories) memory!.countLabel(),
      ].join(', '),
      child: plate,
    );

    return card;
  }

  Future<void> _togglePin(WidgetRef ref) async {
    final now = ref.read(clockProvider).now();
    await ref
        .read(profileRepositoryProvider)
        .save(
          entry.profile.copyWith(
            isPinned: !entry.isPinned,
            updatedAt: now,
          ),
        );
  }
}

/// Identity + note/moment previews on the plate artwork.
class _ProfileCardBody extends StatelessWidget {
  const _ProfileCardBody({
    required this.entry,
    required this.photo,
    required this.cardWidth,
    required this.cardHeight,
    required this.contentTopFraction,
    this.layout,
    this.memory,
    this.heroTag,
    this.compact = false,
  });

  final GalleryEntry entry;
  final GalleryMemorySummary? memory;
  final ImageProvider? photo;
  final Object? heroTag;
  final bool compact;
  final double cardWidth;
  final double cardHeight;
  final double contentTopFraction;
  final AppThemeProfileLayout? layout;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final paper = q.paper;

    final avatarFraction = layout?.avatarDiameterFraction;
    final avatarDiameter = avatarFraction == null
        ? QAvatarSize.lg.diameter
        : (cardWidth * avatarFraction).clamp(96.0, 168.0);
    final avatarBase = avatarDiameter >= 130
        ? QAvatarSize.hero
        : QAvatarSize.lg;

    final avatar = SizedBox.square(
      dimension: avatarDiameter,
      child: FittedBox(
        child: QAvatar(
          displayName: entry.primaryName,
          seed: entry.person.id,
          size: avatarBase,
          photo: photo,
          heroTag: heroTag,
        ),
      ),
    );

    final identity = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        avatar,
        SizedBox(width: q.space.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.primaryName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textScaler: context.nameTextScaler,
                textHeightBehavior: q.text.displayHeightBehavior,
                style: paper.inked(q.text.personName),
              ),
              SizedBox(height: q.space.hair),
              Text(
                entry.countdownLabel(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textScaler: context.structuralTextScaler,
                style: paper.inked(
                  q.text.uiMetadata,
                  tone: QuietInkTone.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (compact) return identity;

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentW = constraints.maxWidth;
        final contentH = constraints.maxHeight;
        final insetLeft = contentW * (layout?.avatarInsetLeft ?? 0);
        final insetTop = contentH * (layout?.avatarInsetTop ?? 0);
        // Note/moment band starts at 40% of the full plate height, but never
        // under the identity row.
        final idealNotesTop = cardHeight * ProfileCardGeometry.notesStartFraction -
            cardHeight * contentTopFraction;
        final minNotesTop = insetTop + avatarDiameter + q.space.sm;
        final notesTop =
            (idealNotesTop < minNotesTop ? minNotesTop : idealNotesTop)
                .clamp(0.0, contentH);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: insetLeft,
              top: insetTop,
              right: 0,
              child: identity,
            ),
            Positioned(
              left: 0,
              right: 0,
              top: notesTop,
              bottom: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProfilePeekRow(
                    eyebrow: 'Note',
                    preview: (memory?.hasNote ?? false)
                        ? memory!.notePreview
                        : null,
                  ),
                  SizedBox(height: q.space.lg),
                  _ProfilePeekRow(
                    eyebrow: 'Moment',
                    preview: (memory?.hasMoment ?? false)
                        ? memory!.momentPreview
                        : null,
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// One note or moment line — preview text, or a + cue when empty.
class _ProfilePeekRow extends StatelessWidget {
  const _ProfilePeekRow({
    required this.eyebrow,
    this.preview,
  });

  final String eyebrow;
  final String? preview;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final paper = q.paper;
    final hasPreview = preview != null && preview!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          eyebrow.toUpperCase(),
          maxLines: 1,
          textScaler: context.structuralTextScaler,
          style: paper.inked(
            q.text.decorativeLabel,
            tone: QuietInkTone.tertiary,
          ),
        ),
        SizedBox(height: q.space.hair),
        if (hasPreview)
          Text(
            preview!.trim(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textScaler: context.structuralTextScaler,
            style: paper.inked(q.text.uiBody),
          )
        else
          Row(
            children: [
              QGlyphIcon(
                QuietGlyph.plus,
                color: paper.secondary,
                size: context.structuralTextScaler.scale(16),
              ),
              SizedBox(width: q.space.xs),
              Text(
                'Add $eyebrow'.toLowerCase(),
                maxLines: 1,
                textScaler: context.structuralTextScaler,
                style: paper.inked(
                  q.text.uiBody,
                  tone: QuietInkTone.secondary,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// Positions copy relative to the profile card — not a visual container.
class _ParchmentTextAnchor extends StatelessWidget {
  const _ParchmentTextAnchor({
    required this.width,
    required this.height,
    required this.child,
  });

  final double width;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final layout = context.appTheme.assets.layout.profileCard;
    return Positioned(
      left: width * (layout?.textLeft ?? ProfileCardGeometry.textLeft),
      right: width * (1 - (layout?.textRight ?? ProfileCardGeometry.textRight)),
      bottom: height * (layout?.textBottom ?? ProfileCardGeometry.textBottom),
      child: child,
    );
  }
}

/// Empty-gallery invitation — two lines and a rule, no nested surface.
class _CreateProfileInk extends StatelessWidget {
  const _CreateProfileInk();

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final paper = q.paper;
    final rule = paper.border.withValues(alpha: 0.5);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'A place for someone',
          textAlign: TextAlign.center,
          textScaler: context.structuralTextScaler,
          textHeightBehavior: q.text.displayHeightBehavior,
          style: paper.inked(q.text.sectionTitle),
        ),
        SizedBox(height: q.space.xs),
        Text(
          'Create a profile',
          textAlign: TextAlign.center,
          textScaler: context.structuralTextScaler,
          textHeightBehavior: q.text.displayHeightBehavior,
          style: paper.inked(
            q.text.uiBody,
            tone: QuietInkTone.secondary,
          ),
        ),
        SizedBox(height: q.space.sm),
        Align(
          child: SizedBox(
            width: 120,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: rule,
                    width: context.hairlineWidth,
                  ),
                ),
              ),
              child: SizedBox(height: q.space.hair),
            ),
          ),
        ),
      ],
    );
  }
}

/// Empty-gallery invitation — two lines and a rule, no nested surface.
class CreateProfilePortraitCard extends StatelessWidget {
  const CreateProfilePortraitCard({
    required this.onTap,
    required this.width,
    required this.height,
    super.key,
  });

  final VoidCallback onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final layout = context.appTheme.assets.layout.profileCard;
    final clipCorners = layout?.clipPlateCorners ?? true;
    final plateCornerRadius =
        clipCorners ? (layout?.cornerRadius ?? q.radius.sm) : 0.0;

    return QPressable(
      onTap: onTap,
      radius: q.radius.md,
      semanticLabel: 'Create a relationship profile',
      child: SizedBox(
        width: width,
        height: height,
        child: plateCornerRadius > 0
            ? ClipRRect(
                borderRadius: BorderRadius.circular(plateCornerRadius),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _ProfileCardPlate(
                      width: width,
                      height: height,
                      clipCorners: clipCorners,
                      cornerRadius: plateCornerRadius,
                    ),
                    _ParchmentTextAnchor(
                      width: width,
                      height: height,
                      child: const _CreateProfileInk(),
                    ),
                  ],
                ),
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  _ProfileCardPlate(
                    width: width,
                    height: height,
                    clipCorners: clipCorners,
                    cornerRadius: plateCornerRadius,
                  ),
                  _ParchmentTextAnchor(
                    width: width,
                    height: height,
                    child: const _CreateProfileInk(),
                  ),
                ],
              ),
      ),
    );
  }
}

/// The card at the end of a populated carousel.
class AddProfileCarouselCard extends StatelessWidget {
  const AddProfileCarouselCard({
    required this.onTap,
    required this.width,
    required this.height,
    super.key,
  });

  final VoidCallback onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final paper = q.paper;
    final layout = context.appTheme.assets.layout.profileCard;
    final clipCorners = layout?.clipPlateCorners ?? true;
    final plateCornerRadius =
        clipCorners ? (layout?.cornerRadius ?? q.radius.sm) : 0.0;

    final stack = Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: 0.92,
          child: _ProfileCardPlate(
            width: width,
            height: height,
            clipCorners: clipCorners,
            cornerRadius: plateCornerRadius,
          ),
        ),
        _ParchmentTextAnchor(
          width: width,
          height: height,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QGlyphIcon(
                QuietGlyph.plus,
                color: paper.secondary,
                size: context.structuralTextScaler.scale(22),
              ),
              SizedBox(height: q.space.xs),
              Text(
                'Someone else',
                textAlign: TextAlign.center,
                textScaler: context.structuralTextScaler,
                style: paper.inked(
                  q.text.uiBody,
                  tone: QuietInkTone.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return QPressable(
      onTap: onTap,
      radius: q.radius.md,
      semanticLabel: 'Add a relationship profile',
      child: SizedBox(
        width: width,
        height: height,
        child: plateCornerRadius > 0
            ? ClipRRect(
                borderRadius: BorderRadius.circular(plateCornerRadius),
                child: stack,
              )
            : stack,
      ),
    );
  }
}

/// Profile plate — theme chrome image or solid paper fallback.
class _ProfileCardPlate extends StatelessWidget {
  const _ProfileCardPlate({
    required this.width,
    required this.height,
    this.clipCorners = true,
    this.cornerRadius = 0,
  });

  final double width;
  final double height;
  final bool clipCorners;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final asset = context.appTheme.assets.chrome.profileCard;
    if (asset != null) {
      final cache = QuietDisplayImage.cacheSize(
        context,
        Size(width, height),
      );
      // Cover fills the presentation plate; aspect is owned by theme layout.
      return Image.asset(
        asset,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        width: width,
        height: height,
        cacheWidth: cache.$1,
        cacheHeight: cache.$2,
        gaplessPlayback: true,
        filterQuality: FilterQuality.high,
      );
    }
    final r = cornerRadius > 0
        ? cornerRadius
        : (clipCorners ? q.radius.sm : 0.0);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: q.journal.paper,
        borderRadius: r > 0
            ? BorderRadius.circular(r)
            : BorderRadius.zero,
        border: Border.all(color: q.journal.edge, width: context.hairlineWidth),
        boxShadow: [
          BoxShadow(
            color: q.journal.shadow,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );
  }
}
