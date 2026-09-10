import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:kin/design/theme/mood_illustration_metrics.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

export 'package:kin/design/theme/mood_illustration_metrics.dart';

/// Transparent mood character from the active product theme — never cropped
/// into a circle. When the theme has no illustration for [moodId], renders
/// nothing (null asset is intentional, not an error).
class QMoodIllustration extends StatelessWidget {
  const QMoodIllustration({
    required this.moodId,
    required this.size,
    this.mirror = false,
    this.opacity = 1,
    this.width,
    super.key,
  });

  final String moodId;
  final MoodIllustrationSize size;
  final bool mirror;
  final double opacity;

  /// When set, sizes the art to this width (height from aspect ratio).
  /// Prefer for card-relative peeks instead of fixed [size] extents.
  final double? width;

  @override
  Widget build(BuildContext context) {
    final asset = context.appTheme.assets.mood.illustration(moodId);
    if (asset == null) return const SizedBox.shrink();

    final resolvedWidth = width ?? MoodIllustrationMetrics.widthFor(size);
    final resolvedHeight = width != null
        ? width! / MoodIllustrationMetrics.aspectRatio
        : MoodIllustrationMetrics.extent(size);

    Widget art = Image.asset(
      asset,
      width: resolvedWidth,
      height: resolvedHeight,
      fit: BoxFit.contain,
      gaplessPlayback: true,
    );

    if (mirror) {
      art = Transform(
        alignment: Alignment.center,
        transform: Matrix4.diagonal3Values(-1, 1, 1),
        child: art,
      );
    }

    if (opacity < 1) {
      art = Opacity(opacity: opacity, child: art);
    }

    return ExcludeSemantics(
      child: SizedBox(
        width: resolvedWidth,
        height: resolvedHeight,
        child: art,
      ),
    );
  }
}

/// Card-relative top-right peek recipes (fractions of card / art — not px).
abstract final class _CardMoodPeek {
  /// Today home journal preview.
  static const todayWidthOfCard = 0.46;
  static const todayHangAbove = 0.50;
  static const todayRightOfArt = 0.08;

  /// Journal of the Day memory card — freer hang, ~25–30% past the right edge.
  static const memoryWidthOfCard = 0.46;
  static const memoryHangAbove = 0.58;
  static const memoryRightOfArt = 0.28;
}

/// Pins a mood character onto a paper card according to [placement].
///
/// Parent must use `clipBehavior: Clip.none` when the placement overlaps.
class QMoodCardDecoration extends StatelessWidget {
  const QMoodCardDecoration({
    required this.moodId,
    required this.placement,
    this.artWidth,
    this.maxRightOverflow,
    super.key,
  });

  final String moodId;
  final MoodCardPlacement placement;

  /// Card-relative width for overlapping peeks; null uses fixed theme extents.
  final double? artWidth;

  /// Hard cap so art stays inside the phone viewport (never past screen edge).
  final double? maxRightOverflow;

  @override
  Widget build(BuildContext context) {
    if (context.appTheme.assets.mood.illustration(moodId) == null) {
      return const SizedBox.shrink();
    }

    final size = switch (placement) {
      MoodCardPlacement.memoryTopRightOverlap =>
        MoodIllustrationSize.memoryCard,
      MoodCardPlacement.dayTopRightOverlap => MoodIllustrationSize.dayCard,
      MoodCardPlacement.todayFirstOverlap ||
      MoodCardPlacement.todaySecondInset => MoodIllustrationSize.todayPreview,
    };
    final extent = artWidth != null
        ? artWidth! / MoodIllustrationMetrics.aspectRatio
        : MoodIllustrationMetrics.extent(size);
    final width = artWidth ?? MoodIllustrationMetrics.widthFor(size);
    final mirror = switch (placement) {
      MoodCardPlacement.todaySecondInset => false,
      _ => true,
    };

    final art = QMoodIllustration(
      moodId: moodId,
      size: size,
      width: artWidth,
      mirror: mirror,
    );

    final hangAbove = switch (placement) {
      MoodCardPlacement.todayFirstOverlap => _CardMoodPeek.todayHangAbove,
      MoodCardPlacement.memoryTopRightOverlap ||
      MoodCardPlacement.dayTopRightOverlap => _CardMoodPeek.memoryHangAbove,
      MoodCardPlacement.todaySecondInset => 0.0,
    };
    final rightFrac = switch (placement) {
      MoodCardPlacement.todayFirstOverlap => _CardMoodPeek.todayRightOfArt,
      MoodCardPlacement.memoryTopRightOverlap ||
      MoodCardPlacement.dayTopRightOverlap => _CardMoodPeek.memoryRightOfArt,
      MoodCardPlacement.todaySecondInset => 0.0,
    };

    return switch (placement) {
      MoodCardPlacement.memoryTopRightOverlap ||
      MoodCardPlacement.dayTopRightOverlap ||
      MoodCardPlacement.todayFirstOverlap => Positioned(
        top: -extent * hangAbove,
        right: -_clampedRightOverflow(
          context,
          width,
          desiredFraction: rightFrac,
          maxRoom: maxRightOverflow,
        ),
        child: IgnorePointer(child: art),
      ),
      MoodCardPlacement.todaySecondInset => Positioned(
        right: -width * 0.22,
        bottom: -extent * 0.18,
        child: IgnorePointer(child: art),
      ),
    };
  }
}

double _clampedRightOverflow(
  BuildContext context,
  double artWidth, {
  required double desiredFraction,
  double? maxRoom,
}) {
  final desired = artWidth * desiredFraction;
  final room = maxRoom ?? context.gutter;
  return math.min(desired, math.max(0.0, room));
}

bool _isTopRightCardPeek(MoodCardPlacement placement) => switch (placement) {
  MoodCardPlacement.memoryTopRightOverlap ||
  MoodCardPlacement.dayTopRightOverlap ||
  MoodCardPlacement.todayFirstOverlap => true,
  MoodCardPlacement.todaySecondInset => false,
};

double _peekWidthFraction(MoodCardPlacement placement) => switch (placement) {
  MoodCardPlacement.todayFirstOverlap => _CardMoodPeek.todayWidthOfCard,
  _ => _CardMoodPeek.memoryWidthOfCard,
};

/// Remaining horizontal room from the card's right edge to the screen edge.
double _viewportRoomPastCard(BuildContext context, double cardWidth) {
  final mq = MediaQuery.of(context);
  final screenW = mq.size.width - mq.padding.right;
  // Prefer live layout when the card has been laid out.
  final box = context.findRenderObject();
  if (box is RenderBox && box.hasSize && box.size.width > 0) {
    final cardRight = box.localToGlobal(Offset(box.size.width, 0)).dx;
    return math.max(0.0, screenW - cardRight);
  }
  // First frame / unbounded: card is inset by the screen gutter (and a slim
  // deck peek pad). That band is the only safe right overflow.
  return context.gutter + context.quiet.space.sm;
}

/// Wraps [child] so mood pins can sit on the paper without shifting layout.
///
/// [moodId] — top-right overlapping pin (Today first / memory / day).
/// [secondMoodId] — Today second-memory bottom-right inset (clipped by card).
class QMoodDecoratedPaper extends StatelessWidget {
  const QMoodDecoratedPaper({
    required this.child,
    this.moodId,
    this.secondMoodId,
    this.placement = MoodCardPlacement.memoryTopRightOverlap,
    super.key,
  });

  final Widget child;
  final String? moodId;
  final String? secondMoodId;
  final MoodCardPlacement placement;

  @override
  Widget build(BuildContext context) {
    final moodAssets = context.appTheme.assets.mood;
    final firstOk =
        moodId != null && moodAssets.illustration(moodId!) != null;
    final secondOk =
        secondMoodId != null &&
        moodAssets.illustration(secondMoodId!) != null;

    if (!firstOk && !secondOk) return child;

    var paper = child;

    // Second mood is clipped to the same rounded paper bounds as the card.
    if (secondOk) {
      paper = _TodaySecondMoodClipHost(
        moodId: secondMoodId!,
        child: paper,
      );
    }

    if (!firstOk) return paper;

    // Top-right peeks — size/position from the card box; no layout clearance.
    if (_isTopRightCardPeek(placement)) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;
          final artWidth = cardWidth * _peekWidthFraction(placement);
          final maxRight = _viewportRoomPastCard(context, cardWidth);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              paper,
              QMoodCardDecoration(
                moodId: moodId!,
                placement: placement,
                artWidth: artWidth,
                maxRightOverflow: maxRight,
              ),
            ],
          );
        },
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        paper,
        QMoodCardDecoration(moodId: moodId!, placement: placement),
      ],
    );
  }
}

/// Bottom-right mood overlay, clipped to the journal card's rounded paper.
class _TodaySecondMoodClipHost extends StatelessWidget {
  const _TodaySecondMoodClipHost({
    required this.moodId,
    required this.child,
  });

  final String moodId;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final radius = q.radius.lg;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Stack(
                children: [
                  QMoodCardDecoration(
                    moodId: moodId,
                    placement: MoodCardPlacement.todaySecondInset,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
