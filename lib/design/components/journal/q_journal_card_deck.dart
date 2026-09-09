import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:kin/design/components/journal/journal_deck_cursor.dart';
import 'package:kin/design/components/journal/q_journal_memory_card.dart';
import 'package:kin/design/motion/quiet_motion.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// One memory in the circular diary card deck (presentation only).
@immutable
class QJournalDeckItem {
  const QJournalDeckItem({
    required this.id,
    required this.title,
    required this.body,
    this.moodId,
    this.moodLabel,
    this.fragmentLabel,
    this.photo,
  });

  final String id;
  final String title;
  final String body;
  final String? moodId;
  final String? moodLabel;
  final String? fragmentLabel;
  final Widget? photo;
}

/// Physical stacked diary cards — horizontal swipe in a circular loop.
///
/// Any completed horizontal swipe **advances** one card forward
/// (`(front + 1) % length`). Gesture direction only drives the fly-off
/// animation — it never retreats. Vertical-dominant gestures snap back.
/// Repository order is preserved; [onFrontChanged] reports the front entry id
/// without mutating persistence.
class QJournalCardDeck extends StatefulWidget {
  const QJournalCardDeck({
    required this.items,
    required this.onOpen,
    this.onFrontChanged,
    this.initialFrontId,
    super.key,
  });

  final List<QJournalDeckItem> items;
  final ValueChanged<QJournalDeckItem> onOpen;
  final ValueChanged<QJournalDeckItem>? onFrontChanged;
  final String? initialFrontId;

  @override
  State<QJournalCardDeck> createState() => QJournalCardDeckState();
}

class QJournalCardDeckState extends State<QJournalCardDeck>
    with TickerProviderStateMixin {
  static const _maxVisibleLayers = 4;
  static const _dismissFraction = 0.28;
  static const _velocityThreshold = 780.0;

  late JournalDeckCursor _cursor;
  late final AnimationController _fly;
  var _flyDx = 0.0;

  var _dragDx = 0.0;
  var _dragDy = 0.0;
  var _rawDragDy = 0.0;
  var _dragging = false;
  var _flying = false;

  @override
  void initState() {
    super.initState();
    _cursor = _cursorFor(widget.items, widget.initialFrontId);
    _fly = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
  }

  @override
  void didUpdateWidget(covariant QJournalCardDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length ||
        !_sameIds(oldWidget.items, widget.items)) {
      _cursor = _cursor.withLength(widget.items.length);
      if (widget.initialFrontId != null) {
        _cursor = _cursorFor(widget.items, widget.initialFrontId);
      }
    }
  }

  @override
  void dispose() {
    _fly.dispose();
    super.dispose();
  }

  JournalDeckCursor get cursor => _cursor;

  QJournalDeckItem? get frontItem {
    if (_cursor.isEmpty) return null;
    return widget.items[_cursor.front];
  }

  static bool _sameIds(List<QJournalDeckItem> a, List<QJournalDeckItem> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  static JournalDeckCursor _cursorFor(
    List<QJournalDeckItem> items,
    String? frontId,
  ) {
    if (items.isEmpty) return const JournalDeckCursor(length: 0);
    if (frontId != null) {
      final i = items.indexWhere((e) => e.id == frontId);
      if (i >= 0) return JournalDeckCursor(length: items.length, front: i);
    }
    return JournalDeckCursor(length: items.length);
  }

  void _notifyFront() {
    final item = frontItem;
    if (item != null) widget.onFrontChanged?.call(item);
  }

  Future<void> _commit(int direction) async {
    if (_flying || widget.items.length <= 1) return;
    _flying = true;
    final motion = QuietMotion.of(context);
    final width = context.size?.width ?? 360;
    // Animation follows the finger; index always advances forward.
    final target = direction * width * 1.35;
    final start = _dragDx;

    if (motion.reduced) {
      setState(() {
        _cursor = _cursor.advance();
        _dragDx = 0;
        _dragDy = 0;
        _rawDragDy = 0;
        _flyDx = 0;
        _flying = false;
        _dragging = false;
      });
      _notifyFront();
      return;
    }

    _fly.duration = const Duration(milliseconds: 300);
    void tick() {
      if (!mounted) return;
      final t = Curves.easeIn.transform(_fly.value);
      setState(() {
        _flyDx = start + (target - start) * t;
      });
    }

    _fly
      ..value = 0
      ..addListener(tick);
    setState(() => _flyDx = start);
    await _fly.forward();
    _fly.removeListener(tick);
    if (!mounted) return;

    setState(() {
      _cursor = _cursor.advance();
      _dragDx = 0;
      _dragDy = 0;
      _rawDragDy = 0;
      _flyDx = 0;
      _flying = false;
      _dragging = false;
      _fly.value = 0;
    });
    _notifyFront();
  }

  Future<void> _snapBack() async {
    if (_flying) return;
    _flying = true;
    final motion = QuietMotion.of(context);
    final startX = _dragDx;
    final startY = _dragDy;

    if (motion.reduced) {
      setState(() {
        _dragDx = 0;
        _dragDy = 0;
        _rawDragDy = 0;
        _flying = false;
        _dragging = false;
      });
      return;
    }

    final drive = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    final curved = CurvedAnimation(parent: drive, curve: Curves.easeOutCubic);
    void sync() {
      if (!mounted) return;
      final t = curved.value;
      setState(() {
        _dragDx = startX * (1 - t);
        _dragDy = startY * (1 - t);
      });
    }

    curved.addListener(sync);
    await drive.forward();
    curved.removeListener(sync);
    drive.dispose();

    if (!mounted) return;
    setState(() {
      _dragDx = 0;
      _dragDy = 0;
      _rawDragDy = 0;
      _flying = false;
      _dragging = false;
    });
  }

  void _onPanStart(DragStartDetails _) {
    if (_flying || widget.items.length <= 1) return;
    setState(() => _dragging = true);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_dragging || _flying) return;
    setState(() {
      _dragDx += details.delta.dx;
      _rawDragDy += details.delta.dy;
      _dragDy = _rawDragDy * 0.35;
    });
  }

  Future<void> _onPanEnd(DragEndDetails details) async {
    if (!_dragging || _flying) return;
    final width = context.size?.width ?? 360;
    final vx = details.velocity.pixelsPerSecond.dx;
    final vy = details.velocity.pixelsPerSecond.dy;

    // Horizontal deck only — ignore vertical-dominant gestures.
    // Require real horizontal travel/velocity so 0≈0 does not pass.
    final fromDrag =
        _dragDx.abs() > 12 && _dragDx.abs() >= _rawDragDy.abs() * 1.15;
    final fromVelocity =
        vx.abs() > _velocityThreshold && vx.abs() >= vy.abs() * 1.15;
    if (!fromDrag && !fromVelocity) {
      await _snapBack();
      return;
    }

    final passed =
        _dragDx.abs() > width * _dismissFraction ||
        vx.abs() > _velocityThreshold;

    if (!passed || widget.items.length <= 1) {
      await _snapBack();
      return;
    }

    // Gesture direction only drives fly-off animation; index always advances.
    final direction = _dragDx == 0 ? (vx < 0 ? -1 : 1) : (_dragDx < 0 ? -1 : 1);
    await _commit(direction);
  }

  void _onTap() {
    if (_dragging || _flying || _dragDx.abs() > 8) return;
    final item = frontItem;
    if (item != null) widget.onOpen(item);
  }

  /// Test helper — commit a forward swipe (top card to back).
  @visibleForTesting
  void debugAdvance() {
    if (widget.items.length <= 1) return;
    setState(() {
      _cursor = _cursor.advance();
      _dragDx = 0;
      _dragDy = 0;
      _rawDragDy = 0;
      _flyDx = 0;
      _flying = false;
      _dragging = false;
    });
    _notifyFront();
  }

  /// Test helper — commit a backward swipe.
  @visibleForTesting
  void debugRetreat() {
    if (widget.items.length <= 1) return;
    setState(() {
      _cursor = _cursor.retreat();
      _dragDx = 0;
      _dragDy = 0;
      _rawDragDy = 0;
      _flyDx = 0;
      _flying = false;
      _dragging = false;
    });
    _notifyFront();
  }

  double get _topDx => _flying ? _flyDx : _dragDx;
  double get _topDy => _flying ? _dragDy * 0.2 : _dragDy;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final items = widget.items;
    if (items.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;
        // Slim side pad for stacked page peeks only — mood art overlays and
        // does not consume layout width. Card fills the rest of the deck.
        final stackPad = q.space.sm;
        final availW = math.max(0.0, maxW - stackPad * 2);
        final availH = maxH.isFinite && maxH > 0
            ? math.max(0.0, maxH - stackPad)
            : double.infinity;
        var cardW = availW;
        var cardH = cardW / QJournalMemoryCard.aspectRatio;
        if (cardH > availH) {
          cardH = availH;
          cardW = cardH * QJournalMemoryCard.aspectRatio;
        }

        final layerCount = math.min(_maxVisibleLayers, items.length);
        final progress = (cardW <= 0)
            ? 0.0
            : (_topDx.abs() / (cardW * _dismissFraction)).clamp(0.0, 1.0);

        return Center(
          child: SizedBox(
            width: cardW + stackPad * 2,
            height: cardH + stackPad * 2,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                for (var depth = layerCount - 1; depth >= 0; depth--)
                  _buildLayer(
                    depth: depth,
                    cardW: cardW,
                    cardH: cardH,
                    progress: progress,
                    items: items,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLayer({
    required int depth,
    required double cardW,
    required double cardH,
    required double progress,
    required List<QJournalDeckItem> items,
  }) {
    final index = _cursor.indexAtDepth(depth);
    final item = items[index];
    final archive = 'No. ${(index + 1).toString().padLeft(2, '0')}';

    // Book-page stack: each back card is smaller + nudged down so a rim of
    // paper peeks on the sides and bottom (like pages under the open leaf).
    final restScale = switch (depth) {
      0 => 1.0,
      1 => 0.92,
      2 => 0.86,
      _ => 0.82,
    };
    final restDy = switch (depth) {
      0 => 0.0,
      1 => 14.0,
      2 => 26.0,
      _ => 36.0,
    };
    final lift = depth == 1
        ? progress * 0.06
        : depth == 2
        ? progress * 0.03
        : 0.0;
    final rise = depth == 1
        ? progress * 10.0
        : depth == 2
        ? progress * 6.0
        : 0.0;

    var scale = restScale + lift;
    var dy = restDy - rise;
    var dx = 0.0;
    var rot = 0.0;
    var opacity = switch (depth) {
      0 => 1.0,
      1 => 0.97,
      2 => 0.92,
      _ => 0.86,
    };

    final isTop = depth == 0;
    if (isTop) {
      dx = _topDx;
      dy = _topDy;
      rot = (_topDx / 320).clamp(-0.22, 0.22);
      scale = 1.0;
      opacity = 1.0;
    }

    final card = SizedBox(
      width: cardW,
      height: cardH,
      child: QJournalMemoryCard(
        key: ValueKey('deck-card-${item.id}-$depth'),
        archiveIndex: archive,
        title: item.title,
        bodyPreview: item.body,
        moodId: item.moodId,
        moodLabel: item.moodLabel,
        fragmentLabel: item.fragmentLabel,
        photo: item.photo,
        // Front + next card stay fully painted while swiping; deeper layers
        // remain paper silhouettes so the stack stays cheap.
        showContent: depth <= 1,
      ),
    );

    final transformed = Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: Transform.rotate(
          angle: rot,
          child: Transform.scale(
            scale: scale,
            // Centered so left/right page edges show, not only the bottom.
            child: card,
          ),
        ),
      ),
    );

    if (!isTop) return transformed;

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: transformed,
    );
  }
}

/// Compact deck position indicator — dots capped, plus "n of N".
class QJournalDeckCounter extends StatelessWidget {
  const QJournalDeckCounter({
    required this.position,
    required this.total,
    super.key,
  });

  final int position;
  final int total;

  static const _maxDots = 5;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    if (total <= 0) return const SizedBox.shrink();

    final dots = math.min(total, _maxDots);
    // Map position into a sliding window of dots when total > max.
    final activeDot = total <= _maxDots
        ? position - 1
        : ((position - 1) / (total - 1) * (dots - 1)).round().clamp(
            0,
            dots - 1,
          );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < dots; i++) ...[
              if (i > 0) SizedBox(width: q.space.sm),
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == activeDot
                      ? q.canvas.primary
                      : q.canvas.tertiary.withValues(alpha: 0.55),
                ),
                child: SizedBox(
                  width: i == activeDot ? 8 : 6,
                  height: i == activeDot ? 8 : 6,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: q.space.sm),
        Text(
          '$position of $total',
          textScaler: context.structuralTextScaler,
          style: q.inked(q.text.uiCaption, tone: QuietInkTone.secondary),
        ),
      ],
    );
  }
}
