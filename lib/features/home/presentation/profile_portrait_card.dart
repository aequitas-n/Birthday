import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/media/q_photo.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/design/tokens/color_tokens.dart';
import 'package:kin/design/tokens/vintage_diary_tokens.dart';
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

/// Vintage diary portrait — `profile_card.webp` is the surface; photo and text
/// are layered directly on top with no nested card or parchment plate.
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
    final photo = ref.watch(personPhotoProvider(entry.profile.photoId));
    final relationship = entry.relationshipLabel;
    final isActive = depth == ProfilePortraitDepth.active;

    final width = this.width;
    final photoBottom = VintagePortraitLayout.photoBottomNorm(width);

    final Widget portrait = QPhoto(
      displayName: entry.primaryName,
      seed: entry.person.id,
      photo: photo.asData?.value,
    );

    final plate = SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(q.radius.sm),
            child: Image.asset(
              VintageDiaryAssets.profileCard,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              width: width,
              height: height,
              gaplessPlayback: true,
              filterQuality: FilterQuality.high,
            ),
          ),
          Positioned(
            left: width * ProfileCardGeometry.photoLeft,
            right: width * (1 - ProfileCardGeometry.photoRight),
            top: height * ProfileCardGeometry.photoTop,
            bottom: height * (1 - photoBottom),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: ColorTokens.vdInkPrimary.withValues(alpha: 0.22),
                  width: context.hairlineWidth * 2,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(q.space.xs),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(q.radius.xs),
                  child: heroTag == null
                      ? portrait
                      : Hero(tag: heroTag!, child: portrait),
                ),
              ),
            ),
          ),
          _ParchmentTextAnchor(
            width: width,
            height: height,
            child: _ProfileNameInk(name: entry.primaryName),
          ),
        ],
      ),
    );

    final card = QPressable(
      onTap: onTap,
      radius: q.radius.md,
      semanticLabel: [
        entry.primaryName,
        if (entry.isPinned) 'Pinned',
        if (relationship != null) relationship,
        if (isActive) entry.countdownLabel(),
        if (memory != null && memory!.hasMemories) memory!.countLabel(),
      ].join(', '),
      child: plate,
    );

    final composed = !isActive
        ? card
        : SizedBox(
            width: width,
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                card,
                Positioned(
                  top: height * ProfileCardGeometry.photoTop + q.space.xs,
                  right:
                      width * (1 - ProfileCardGeometry.photoRight) + q.space.xs,
                  child: _PinButton(
                    pinned: entry.isPinned,
                    onToggle: () => _togglePin(ref),
                  ),
                ),
              ],
            ),
          );

    return SizedBox(
      width: double.infinity,
      height: height,
      child: composed,
    );
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
    return Positioned(
      left: width * ProfileCardGeometry.textLeft,
      right: width * (1 - ProfileCardGeometry.textRight),
      bottom: height * ProfileCardGeometry.textBottom,
      child: child,
    );
  }
}

/// Person name printed directly on the parchment artwork.
class _ProfileNameInk extends StatelessWidget {
  const _ProfileNameInk({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final paper = q.paper;

    return Text(
      name,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      textScaler: context.nameTextScaler,
      textHeightBehavior: q.text.displayHeightBehavior,
      style: paper.inked(q.text.personName),
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

class _PinButton extends StatelessWidget {
  const _PinButton({required this.pinned, required this.onToggle});

  final bool pinned;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final ink = pinned ? ColorTokens.vdBurgundy : ColorTokens.vdInkSecondary;

    return QPressable(
      onTap: onToggle,
      radius: q.radius.full,
      semanticLabel: pinned ? 'Unpin from top' : 'Pin to top',
      child: Padding(
        padding: EdgeInsets.all(q.space.sm),
        child: QGlyphIcon(
          QuietGlyph.pin,
          color: ink,
          size: context.structuralTextScaler.scale(18),
        ),
      ),
    );
  }
}

/// The empty state of the gallery: one card, and an invitation.
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

    return QPressable(
      onTap: onTap,
      radius: q.radius.md,
      semanticLabel: 'Create a relationship profile',
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              VintageDiaryAssets.profileCard,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              gaplessPlayback: true,
              filterQuality: FilterQuality.high,
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

    return QPressable(
      onTap: onTap,
      radius: q.radius.md,
      semanticLabel: 'Add a relationship profile',
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: 0.92,
              child: Image.asset(
                VintageDiaryAssets.profileCard,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                gaplessPlayback: true,
                filterQuality: FilterQuality.high,
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
        ),
      ),
    );
  }
}
