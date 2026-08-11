import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/app/profile_creation_launcher.dart';
import 'package:kin/design/components/fields/q_search_field.dart';
import 'package:kin/design/motion/quiet_motion.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/features/home/application/gallery_providers.dart';
// ignore: always_use_package_imports -- ARCH-03 requires relative imports within a feature
import 'portrait_gallery_carousel.dart';
// ignore: always_use_package_imports -- ARCH-03
import 'profile_portrait_card.dart';

/// Relationship gallery — the "who" mode. Photo-first portrait collection.
///
/// Search filters the deck in place. Order is pinned first (soonest birthday
/// among them), then everyone else by upcoming birthday.
class RelationshipGalleryPage extends ConsumerStatefulWidget {
  const RelationshipGalleryPage({super.key});

  @override
  ConsumerState<RelationshipGalleryPage> createState() =>
      _RelationshipGalleryPageState();
}

class _RelationshipGalleryPageState
    extends ConsumerState<RelationshipGalleryPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final allEntries = ref.watch(galleryEntriesProvider);
    final entries = _query.trim().isEmpty
        ? allEntries
        : allEntries
              .where((entry) => entry.matchesQuery(_query))
              .toList(growable: false);

    if (allEntries.isEmpty) {
      final cardHeight = math.min(
        MediaQuery.sizeOf(context).height * q.layout.heroHeightFraction,
        q.layout.galleryCardMaxHeight,
      );
      return _EntranceFrame(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: q.space.xl),
            child: CreateProfilePortraitCard(
              height: cardHeight,
              onTap: () =>
                  showProfileCreationChooser(context: context, ref: ref),
            ),
          ),
        ),
      );
    }

    return _EntranceFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              q.space.xl,
              q.space.base,
              q.space.xl,
              q.space.sm,
            ),
            child: QSearchField(
              controller: _searchController,
              placeholder: 'Search people',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          if (entries.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: q.space.xxl),
                  child: Text(
                    'No one matches “${_query.trim()}”.',
                    textAlign: TextAlign.center,
                    style: q.text.body.tinted(q.color.textSecondary),
                  ),
                ),
              ),
            )
          else
            PortraitGalleryCarousel(entries: entries, ref: ref),
        ],
      ),
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
