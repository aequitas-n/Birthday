import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:kin/design/components/surfaces/illustrated_paper_details.dart';
import 'package:kin/design/theme/illustrated_theme.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

enum IllustratedSurfaceKind { card, calendar, navigation, search, profile, tag }

/// Resolution-independent paper, drawn around live content rather than
/// stretching baked-in image frames. Content keeps its natural text size.
class QIllustratedSurface extends StatelessWidget {
  const QIllustratedSurface({
    required this.child,
    this.padding = EdgeInsets.zero,
    this.kind = IllustratedSurfaceKind.card,
    this.art,
    super.key,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final IllustratedSurfaceKind kind;
  final IllustratedTheme? art;

  @override
  Widget build(BuildContext context) {
    final direction = art ?? context.appTheme.art;
    if (direction == null) {
      final q = context.quiet;
      return DecoratedBox(
        decoration: BoxDecoration(
          color: q.journal.paper,
          borderRadius: BorderRadius.circular(q.radius.md),
          border: Border.all(
            color: q.journal.edge,
            width: context.hairlineWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: q.journal.shadow,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(padding: padding, child: child),
      );
    }
    return RepaintBoundary(
      child: CustomPaint(
        painter: IllustratedSurfacePainter(direction, kind),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class IllustratedSurfacePainter extends CustomPainter {
  const IllustratedSurfacePainter(this.art, this.kind);
  final IllustratedTheme art;
  final IllustratedSurfaceKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = (Offset.zero & size).deflate(2);
    final compact =
        kind == IllustratedSurfaceKind.navigation ||
        kind == IllustratedSurfaceKind.search ||
        kind == IllustratedSurfaceKind.tag;
    final radius = compact ? math.min<double>(art.corner, 18) : art.corner;
    final outline = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    final pen = Paint()
      ..color = art.ink.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    if (art.style == IllustrationStyle.comic) {
      canvas.drawPath(
        outline.shift(const Offset(4, 5)),
        Paint()..color = art.ink,
      );
      pen
        ..color = art.ink
        ..strokeWidth = 2;
    } else if (!compact) {
      canvas.drawShadow(outline, art.ink.withValues(alpha: 0.18), 5, true);
      if (art.style == IllustrationStyle.postcard ||
          art.style == IllustrationStyle.vintage) {
        canvas
          ..save()
          ..translate(size.width / 2, size.height / 2)
          ..rotate(-0.017)
          ..translate(-size.width / 2, -size.height / 2)
          ..drawRRect(
            RRect.fromRectAndRadius(
              rect.shift(const Offset(-2, 5)),
              Radius.circular(radius),
            ),
            Paint()..color = Color.lerp(art.paper, art.secondary, 0.18)!,
          )
          ..restore();
      }
    }
    canvas
      ..drawPath(outline, Paint()..color = art.paper)
      ..drawPath(outline, pen)
      ..save()
      ..clipPath(outline);

    if (!compact) IllustratedPaperDetails.paint(canvas, size, art);

    // Quiet, deterministic paper flecks. No shader or per-frame random work.
    final grain = Paint()..color = art.ink.withValues(alpha: 0.045);
    for (var i = 0; i < (compact ? 35 : 120); i++) {
      canvas.drawCircle(
        Offset((i * 83.7 + 17) % size.width, (i * 47.3 + 9) % size.height),
        0.55,
        grain,
      );
    }
    switch (art.style) {
      case IllustrationStyle.postcard:
        for (var x = -12.0; x < size.width; x += 24) {
          final stripe = Paint()
            ..color = ((x / 24).round().isEven ? art.accent : art.secondary)
                .withValues(alpha: 0.68)
            ..strokeWidth = 5;
          canvas.drawLine(Offset(x, 3), Offset(x + 7, 3), stripe);
          if (!compact) {
            canvas.drawLine(
              Offset(x, size.height - 3),
              Offset(x + 7, size.height - 3),
              stripe,
            );
          }
        }
      case IllustrationStyle.comic:
        final dot = Paint()..color = art.secondary.withValues(alpha: 0.30);
        for (var x = size.width - 37; x < size.width - 5; x += 6) {
          for (var y = 9.0; y < (compact ? 24 : 40); y += 6) {
            canvas.drawCircle(Offset(x, y), 0.8, dot);
          }
        }
      case IllustrationStyle.botanical:
        if (!compact) {
          pen
            ..color = art.secondary.withValues(alpha: 0.32)
            ..strokeWidth = 1;
          canvas.drawLine(
            const Offset(15, 25),
            Offset(15, size.height - 20),
            pen,
          );
          for (var y = 36.0; y < size.height - 20; y += 13) {
            canvas.drawLine(Offset(11, y), Offset(17, y - 6), pen);
          }
        }
      case IllustrationStyle.seaside:
        for (var row = 0; row < (compact ? 1 : 3); row++) {
          final wave = Path()..moveTo(0, size.height - 7 - row * 4);
          for (var x = 0.0; x <= size.width; x += 3) {
            wave.lineTo(
              x,
              size.height - 7 - row * 4 + math.sin(x / 22 + row) * 2,
            );
          }
          canvas.drawPath(
            wave,
            Paint()
              ..color = art.accent.withValues(alpha: 0.13)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.3,
          );
        }
      case IllustrationStyle.storybook:
        pen
          ..color = art.accent.withValues(alpha: 0.45)
          ..strokeWidth = 0.8;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            rect.deflate(5),
            Radius.circular(math.max(0, radius - 4)),
          ),
          pen,
        );
        if (!compact) _star(canvas, Offset(size.width - 21, 20), 5, art.accent);
      case IllustrationStyle.arcade:
        pen
          ..color = art.accent.withValues(alpha: 0.6)
          ..strokeWidth = 1.2;
        final inset = rect.deflate(5);
        for (final point in [inset.topLeft, inset.bottomRight]) {
          final flip = point == inset.topLeft ? 1.0 : -1.0;
          canvas
            ..drawLine(point, point + Offset(13 * flip, 0), pen)
            ..drawLine(point, point + Offset(0, 10 * flip), pen);
        }
        if (!compact) {
          for (var i = 0; i < 3; i++) {
            canvas.drawCircle(
              Offset(size.width - 20 - i * 9, 16),
              2,
              Paint()..color = art.secondary.withValues(alpha: 0.65),
            );
          }
        }
      case IllustrationStyle.vintage:
        pen
          ..color = art.accent.withValues(alpha: 0.17)
          ..strokeWidth = 0.7;
        if (!compact) {
          canvas
            ..drawLine(
              const Offset(13, 18),
              Offset(13, size.height - 18),
              pen,
            )
            ..drawLine(
              const Offset(16, 18),
              Offset(16, size.height - 18),
              pen,
            );
          final fold = Path()
            ..moveTo(size.width - 19, 2)
            ..lineTo(size.width - 19, 19)
            ..lineTo(size.width - 2, 19)
            ..close();
          canvas.drawPath(
            fold,
            Paint()..color = art.secondary.withValues(alpha: 0.2),
          );
        }
    }
    canvas.restore();
    if (art.style == IllustrationStyle.botanical && !compact) {
      canvas
        ..save()
        ..translate(size.width * 0.68, 3)
        ..rotate(0.09)
        ..drawRect(
          const Rect.fromLTWH(-29, -6, 58, 15),
          Paint()..color = art.secondary.withValues(alpha: 0.52),
        )
        ..restore();
    }
  }

  void _star(Canvas canvas, Offset center, double radius, Color color) {
    final pen = Paint()
      ..color = color
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(
        center - Offset(radius, 0),
        center + Offset(radius, 0),
        pen,
      )
      ..drawLine(
        center - Offset(0, radius),
        center + Offset(0, radius),
        pen,
      );
  }

  @override
  bool shouldRepaint(IllustratedSurfacePainter oldDelegate) =>
      oldDelegate.art != art || oldDelegate.kind != kind;
}
