import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/app/profile_creation_launcher.dart';
import 'package:kin/app/router.dart';
import 'package:kin/design/motion/quiet_motion.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/features/home/application/gallery_providers.dart';
// ignore: always_use_package_imports -- ARCH-03 requires relative imports within a feature
import 'profile_portrait_card.dart';

/// A collection of portraits, held one at a time.
///
/// Depth is carried by three things moving together, all driven off the same
/// fractional page value so they stay in lockstep with the finger: a
/// neighbouring card is smaller, lower, and fainter than the one in hand.
/// Scale alone reads as a bug; scale plus drop plus fade reads as a stack of
/// physical cards.
///
/// The curve applied to that distance matters more than the amounts. Linear
/// interpolation makes the neighbours snap to full size just before the page
/// settles; easing it keeps the card that is arriving arriving until it has
/// actually arrived.
class PortraitGalleryCarousel extends StatefulWidget {
  const PortraitGalleryCarousel({
    required this.entries,
    required this.ref,
    super.key,
  });

  final List<GalleryEntry> entries;
  final WidgetRef ref;

  @override
  State<PortraitGalleryCarousel> createState() =>
      _PortraitGalleryCarouselState();
}

class _PortraitGalleryCarouselState extends State<PortraitGalleryCarousel> {
  PageController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  PageController _controllerFor(double viewportFraction) {
    final existing = _controller;
    if (existing != null && existing.viewportFraction == viewportFraction) {
      return existing;
    }
    existing?.dispose();
    return _controller = PageController(viewportFraction: viewportFraction);
  }

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final motion = QuietMotion.of(context);
    final media = MediaQuery.sizeOf(context);
    final cardHeight = math.min(
      media.height * q.layout.galleryCardHeightFraction,
      q.layout.galleryCardMaxHeight,
    );
    final controller = _controllerFor(q.layout.galleryViewportFraction);
    final itemCount = widget.entries.length + 1;

    return SizedBox(
      // Room for the drop and for the float shadow, which would otherwise be
      // clipped off the bottom of the viewport.
      height: cardHeight + q.layout.galleryNeighbourDrop + q.space.xl,
      child: PageView.builder(
        controller: controller,
        itemCount: itemCount,
        // A shadow that is clipped at the page boundary is worse than none.
        clipBehavior: Clip.none,
        padEnds: false,
        itemBuilder: (context, index) {
          final child = index == widget.entries.length
              ? AddProfileCarouselCard(
                  height: cardHeight,
                  onTap: () => showProfileCreationChooser(
                    context: context,
                    ref: widget.ref,
                  ),
                )
              : ProfilePortraitCard(
                  entry: widget.entries[index],
                  height: cardHeight,
                  // Same tag as PersonScreen so the portrait carries across.
                  heroTag: 'person-${widget.entries[index].person.id}',
                  onTap: () {
                    final personId = widget.entries[index].person.id;
                    context.pushNamed(
                      AppRoute.person.name,
                      pathParameters: {'id': personId},
                    );
                  },
                );

          return _CardDepth(
            controller: controller,
            index: index,
            motion: motion,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: q.space.sm),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

/// Scales, drops and fades one card according to its distance from rest.
///
/// Listens to the controller itself rather than being rebuilt by the parent, so
/// dragging the carousel never rebuilds the cards — only their transforms.
class _CardDepth extends StatelessWidget {
  const _CardDepth({
    required this.controller,
    required this.index,
    required this.motion,
    required this.child,
  });

  final PageController controller;
  final int index;
  final QuietMotion motion;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        final page = controller.hasClients && controller.position.hasPixels
            ? (controller.page ?? controller.initialPage.toDouble())
            : controller.initialPage.toDouble();
        final raw = (page - index).abs().clamp(0.0, 1.0);
        // Eased so the arriving card keeps arriving until it settles.
        final distance = Curves.easeOutCubic.transform(raw);

        final scale = motion.scale(
          1 - (1 - q.layout.galleryNeighbourScale) * distance,
        );
        final drop = motion
            .offset(Offset(0, q.layout.galleryNeighbourDrop * distance))
            .dy;
        final opacity = 1 - q.layout.galleryNeighbourFade * distance;

        final scaled = Transform.scale(scale: scale, child: child);

        return Transform.translate(
          offset: Offset(0, drop),
          // Opacity forces a saveLayer, and a saveLayer over a card that also
          // casts a shadow is the most expensive thing in this carousel. The
          // card at rest is fully opaque, so it never pays for one.
          child: opacity >= 1
              ? scaled
              : Opacity(opacity: opacity, child: scaled),
        );
      },
    );
  }
}
