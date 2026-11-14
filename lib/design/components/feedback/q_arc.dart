import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// The only loading indicator in the app.
///
/// A thin sweeping arc that replaces a label in place. Material's progress
/// indicators are banned, and skeleton shimmer over local data is dishonest —
/// the data is already there. See docs/04-design-system.md §6.
class QArc extends StatefulWidget {
  const QArc({
    required this.color,
    this.size = 16,
    this.strokeWidth = 1.5,
    super.key,
  });

  final Color color;
  final double size;
  final double strokeWidth;

  @override
  State<QArc> createState() => _QArcState();
}

class _QArcState extends State<QArc> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.prefersReducedMotion || !TickerMode.valuesOf(context).enabled) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _ArcPainter(
            turns: _controller.value,
            color: widget.color,
            strokeWidth: widget.strokeWidth,
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({
    required this.turns,
    required this.color,
    required this.strokeWidth,
  });

  final double turns;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      turns * 2 * math.pi,
      math.pi * 1.4,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.turns != turns ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}
