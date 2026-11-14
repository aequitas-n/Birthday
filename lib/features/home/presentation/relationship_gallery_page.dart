import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/app/profile_creation_launcher.dart';
import 'package:kin/design/components/feedback/q_pane_loading.dart';
import 'package:kin/design/motion/quiet_motion.dart';
import 'package:kin/design/theme/profile_surface_geometry.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/features/home/application/gallery_providers.dart';
import 'package:kin/features/home/application/home_providers.dart';

// ignore: always_use_package_imports -- ARCH-03 requires relative imports within a feature
import 'portrait_gallery_carousel.dart';
// ignore: always_use_package_imports -- ARCH-03
import 'profile_portrait_card.dart';

/// Relationship gallery — the "who" mode. Vintage portrait collection.
///
/// Search lives in `HomeScreen` above this pane. [query] filters the deck.
class RelationshipGalleryPage extends ConsumerWidget {
  const RelationshipGalleryPage({this.query = '', super.key});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = context.quiet;
    final peopleAsync = ref.watch(peopleStreamProvider);
    final profilesAsync = ref.watch(profilesStreamProvider);
    final allEntries = ref.watch(galleryEntriesProvider);
    final entries = query.trim().isEmpty
        ? allEntries
        : allEntries
              .where((entry) => entry.matchesQuery(query))
              .toList(growable: false);

    if (peopleAsync.isLoading || profilesAsync.isLoading) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final layout = context.appTheme.assets.layout;
          final size = VintagePortraitLayout.fitGalleryCard(
            maxWidth: constraints.maxWidth,
            maxHeight: constraints.maxHeight,
            widthFraction:
                layout.galleryCardWidthFraction ??
                q.layout.galleryCardWidthFraction,
            heightFraction:
                layout.galleryCardHeightFraction ??
                q.layout.galleryCardHeightFraction,
            maxHeightCap:
                layout.galleryCardMaxHeight ?? q.layout.galleryCardMaxHeight,
            maxWidthCap: layout.galleryCardMaxWidth,
            aspectRatio:
                layout.profileCard?.aspectRatio ??
                ProfileCardGeometry.aspectRatio,
          );
          return QPaneLoading(minHeight: size.height);
        },
      );
    }

    if (allEntries.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final layout = context.appTheme.assets.layout;
          final size = VintagePortraitLayout.fitGalleryCard(
            maxWidth: constraints.maxWidth,
            maxHeight: constraints.maxHeight,
            widthFraction:
                layout.galleryCardWidthFraction ??
                q.layout.galleryCardWidthFraction,
            heightFraction:
                layout.galleryCardHeightFraction ??
                q.layout.galleryCardHeightFraction,
            maxHeightCap:
                layout.galleryCardMaxHeight ?? q.layout.galleryCardMaxHeight,
            maxWidthCap: layout.galleryCardMaxWidth,
            aspectRatio:
                layout.profileCard?.aspectRatio ??
                ProfileCardGeometry.aspectRatio,
          );
          return _EntranceFrame(
            child: Center(
              child: CreateProfilePortraitCard(
                width: size.width,
                height: size.height,
                onTap: () =>
                    showProfileCreationChooser(context: context, ref: ref),
              ),
            ),
          );
        },
      );
    }

    if (entries.isEmpty) {
      return _EntranceFrame(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: q.space.xxl),
            child: Text(
              'No one matches “${query.trim()}”.',
              textAlign: TextAlign.center,
              style: q.inked(
                q.text.uiBody,
                tone: QuietInkTone.secondary,
              ),
            ),
          ),
        ),
      );
    }

    return _EntranceFrame(
      child: PortraitGalleryCarousel(entries: entries),
    );
  }
}

class _EntranceFrame extends StatefulWidget {
  const _EntranceFrame({required this.child});

  final Widget child;

  @override
  State<_EntranceFrame> createState() => _EntranceFrameState();
}

class _EntranceFrameState extends State<_EntranceFrame> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final resolvedMotion = QuietMotion.of(context);
    final tokens = context.quiet.motion;

    return AnimatedOpacity(
      duration: tokens.base,
      curve: resolvedMotion.enter,
      opacity: _visible ? 1 : 0,
      child: AnimatedSlide(
        duration: resolvedMotion.move(tokens.base),
        curve: resolvedMotion.enter,
        offset: _visible
            ? Offset.zero
            : resolvedMotion.offset(const Offset(0, 0.02)),
        child: widget.child,
      ),
    );
  }
}
