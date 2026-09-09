import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/app/profile_creation_launcher.dart';
import 'package:kin/app/router.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/design/tokens/vintage_portrait_geometry.dart';
import 'package:kin/features/home/application/gallery_providers.dart';
// ignore: always_use_package_imports -- ARCH-03 requires relative imports within a feature
import 'profile_portrait_card.dart';

/// Single-card People carousel — one centered profile plate at a time.
///
/// Swipe left/right for the next person; pages are full-width so neighbours
/// stay outside the viewport at rest. Infinite wrap when there is more than
/// one item. Visually linear — no peeks, arcs, or side-card scale.
class PortraitGalleryCarousel extends ConsumerStatefulWidget {
  const PortraitGalleryCarousel({
    required this.entries,
    super.key,
  });

  final List<GalleryEntry> entries;

  @override
  ConsumerState<PortraitGalleryCarousel> createState() =>
      _PortraitGalleryCarouselState();
}

class _PortraitGalleryCarouselState
    extends ConsumerState<PortraitGalleryCarousel> {
  static const _loopBlocks = 500;

  PageController? _controller;
  double _page = 0;
  var _baseItemCount = 0;
  var _initialPage = 0;

  int get _itemCount => widget.entries.length + 1; // profiles + add card

  bool get _loops => _itemCount > 1;

  int get _virtualCount => _loops ? _itemCount * _loopBlocks : _itemCount;

  int _realIndex(int virtual) {
    final n = _itemCount;
    if (n <= 0) return 0;
    return virtual % n;
  }

  @override
  void didUpdateWidget(covariant PortraitGalleryCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries.length != widget.entries.length) {
      _reseedController();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _reseedController() {
    final fraction = _controller?.viewportFraction;
    _controller?.dispose();
    _controller = null;
    _baseItemCount = 0;
    if (fraction != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  PageController _controllerFor(double viewportFraction) {
    final existing = _controller;
    final count = _itemCount;
    if (existing != null &&
        existing.viewportFraction == viewportFraction &&
        _baseItemCount == count) {
      return existing;
    }
    existing?.dispose();

    _baseItemCount = count;
    _initialPage = _loops ? count * (_loopBlocks ~/ 2) : 0;
    _page = _initialPage.toDouble();

    final created = PageController(
      viewportFraction: viewportFraction,
      initialPage: _initialPage,
    );
    created.addListener(() {
      if (!created.hasClients) return;
      final page = created.page;
      if (page != null && page != _page) {
        setState(() => _page = page);
      }
    });
    return _controller = created;
  }

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final memories =
        ref.watch(galleryMemorySummariesProvider).asData?.value ?? const {};
    final controller = _controllerFor(q.layout.galleryViewportFraction);
    final realActive = _realIndex(_page.round());
    final pageCount = _itemCount;
    final showIndicator = pageCount > 1;
    final indicatorIndex = realActive.clamp(0, pageCount - 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final indicatorSpace = showIndicator ? q.space.xl + q.space.sm : 0.0;
        final size = _cardSizeFor(
          maxWidth: constraints.maxWidth,
          maxHeight: math.max(0.0, constraints.maxHeight - indicatorSpace),
          q: q,
        );

        return Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: _virtualCount,
                clipBehavior: Clip.hardEdge,
                itemBuilder: (context, index) {
                  final real = _realIndex(index);
                  final isSettledFront = (_page - index).abs() < 0.5;

                  final child = real == widget.entries.length
                      ? AddProfileCarouselCard(
                          width: size.width,
                          height: size.height,
                          onTap: () => showProfileCreationChooser(
                            context: context,
                            ref: ref,
                          ),
                        )
                      : ProfilePortraitCard(
                          entry: widget.entries[real],
                          width: size.width,
                          height: size.height,
                          memory: memories[widget.entries[real].profile.id],
                          heroTag: isSettledFront
                              ? 'person-${widget.entries[real].person.id}'
                              : null,
                          onTap: () {
                            final personId = widget.entries[real].person.id;
                            context.pushNamed(
                              AppRoute.person.name,
                              pathParameters: {'id': personId},
                            );
                          },
                        );

                  return SizedBox(
                    width: constraints.maxWidth,
                    child: child,
                  );
                },
              ),
            ),
            if (showIndicator) ...[
              SizedBox(height: q.space.md),
              _CarouselIndicator(
                count: pageCount,
                activeIndex: indicatorIndex,
              ),
            ],
          ],
        );
      },
    );
  }

  Size _cardSizeFor({
    required double maxWidth,
    required double maxHeight,
    required QuietTheme q,
  }) {
    final cappedH = math.min(maxHeight, q.layout.galleryCardMaxHeight);
    final size = VintagePortraitLayout.fitIn(
      maxWidth: maxWidth,
      maxHeight: cappedH,
      widthFraction: q.layout.galleryCardWidthFraction,
    );
    // Keep a usable minimum on tiny heights without inventing a new ratio.
    if (size.height < 260 && maxWidth > 0) {
      final minH = math.min(260.0, cappedH);
      return Size(maxWidth, minH);
    }
    return size;
  }
}

class _CarouselIndicator extends StatelessWidget {
  const _CarouselIndicator({
    required this.count,
    required this.activeIndex,
  });

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return Semantics(
      label: '${activeIndex + 1} of $count',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: q.space.xs),
              child: SizedBox(
                width: i == activeIndex ? 8 : 6,
                height: i == activeIndex ? 8 : 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == activeIndex
                        ? q.color.accent
                        : q.color.hairlineStrong,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
