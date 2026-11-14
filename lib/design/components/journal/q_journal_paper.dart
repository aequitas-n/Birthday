import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:kin/design/components/surfaces/q_illustrated_surface.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Soft paper stock for Journal fragments and writing surfaces.
///
/// Optional [torn] edges use restrained irregular path geometry — never a
/// crude zig-zag. Default paper prefers hairline over drop shadow.
class QJournalPaper extends StatelessWidget {
  const QJournalPaper({
    required this.child,
    this.padding,
    this.torn = false,
    this.elevated = false,
    this.tint,
    this.seed = 0,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool torn;

  /// When true, applies a restrained shadow. Prefer false — Quiet elevation
  /// is hairline-first.
  final bool elevated;
  final Color? tint;

  /// Stable seed for torn-edge variation (entry hash). Ignored when not torn.
  final int seed;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final j = q.journal;
    final pad =
        padding ??
        EdgeInsets.symmetric(horizontal: q.space.md, vertical: q.space.md);
    final paper = tint ?? j.paper;
    final content = Padding(padding: pad, child: child);

    if (context.appTheme.art != null && tint == null) {
      return QIllustratedSurface(child: content);
    }

    if (torn) {
      return CustomPaint(
        painter: _TornPaperPainter(
          fill: paper,
          edge: j.edge,
          shadow: elevated ? j.shadow : null,
          seed: seed,
        ),
        child: content,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: paper,
        border: Border.all(color: j.edge, width: context.hairlineWidth),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: j.shadow,
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      child: content,
    );
  }
}

class _TornPaperPainter extends CustomPainter {
  _TornPaperPainter({
    required this.fill,
    required this.edge,
    required this.seed,
    this.shadow,
  });

  final Color fill;
  final Color edge;
  final Color? shadow;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _tornPath(size);
    if (shadow != null) {
      canvas.drawPath(
        path.shift(const Offset(0, 1.5)),
        Paint()
          ..color = shadow!
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }
    canvas
      ..drawPath(path, Paint()..color = fill)
      ..drawPath(
        path,
        Paint()
          ..color = edge
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
  }

  Path _tornPath(Size size) {
    final phase = (seed % 17) * 0.37;
    final amp = 1.8 + (seed % 5) * 0.35;
    final path = Path()..moveTo(0, 3 + amp * 0.2);
    _wave(
      path,
      from: Offset.zero,
      to: Offset(size.width, 0),
      amplitude: amp,
      phase: phase,
    );
    path.lineTo(size.width, size.height - 2.5);
    _wave(
      path,
      from: Offset(size.width, size.height),
      to: Offset(0, size.height),
      amplitude: amp * 0.9,
      phase: phase + 1.1,
      reverse: true,
    );
    path.close();
    return path;
  }

  void _wave(
    Path path, {
    required Offset from,
    required Offset to,
    required double amplitude,
    required double phase,
    bool reverse = false,
  }) {
    const segments = 9;
    for (var i = 1; i <= segments; i++) {
      final t = i / segments;
      final x = from.dx + (to.dx - from.dx) * t;
      final baseY = from.dy + (to.dy - from.dy) * t;
      final wobble =
          math.sin(t * math.pi * 3.2 + phase + (reverse ? 0.8 : 0)) * amplitude;
      path.lineTo(x, baseY + wobble);
    }
  }

  @override
  bool shouldRepaint(covariant _TornPaperPainter oldDelegate) {
    return oldDelegate.fill != fill ||
        oldDelegate.edge != edge ||
        oldDelegate.shadow != shadow ||
        oldDelegate.seed != seed;
  }
}
