import 'package:flutter/widgets.dart';

/// The complete glyph inventory.
///
/// Kin does not ship an icon font: at this count a font is heavier than the
/// paths, and drawing them ourselves guarantees they stay optically matched to
/// the type rather than to someone else's grid.
///
/// Specified in docs/04-design-system.md §9.
enum QuietGlyph {
  plus,
  search,
  chevronLeft,
  chevronRight,
  chevronDown,
  close,
  check,
  camera,
  calendar,
  pin,
  gift,
  ellipsis,
  settings,
  journal,
  kinMark,
  bell,
  sun,
  moon,
  dawn,
}

/// Renders a [QuietGlyph].
///
/// Glyphs inherit text colour and are never accent-coloured at rest. They
/// scale with Dynamic Type, clamped to match adjacent structural text.
class QGlyphIcon extends StatelessWidget {
  const QGlyphIcon(
    this.glyph, {
    required this.color,
    this.size = 22,
    this.strokeWidth = 1.5,
    super.key,
  });

  final QuietGlyph glyph;
  final Color color;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _QuietGlyphPainter(
          glyph: glyph,
          color: color,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

/// All paths are authored on a 24×24 grid and scaled to the requested size,
/// so stroke weight stays optically consistent across sizes.
class _QuietGlyphPainter extends CustomPainter {
  const _QuietGlyphPainter({
    required this.glyph,
    required this.color,
    required this.strokeWidth,
  });

  static const _grid = 24.0;

  final QuietGlyph glyph;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _grid;
    canvas
      ..save()
      ..scale(scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      // Divide out the canvas scale so the stroke stays the requested width
      // in logical pixels regardless of glyph size.
      ..strokeWidth = strokeWidth / scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    switch (glyph) {
      case QuietGlyph.plus:
        canvas
          ..drawLine(const Offset(12, 5), const Offset(12, 19), paint)
          ..drawLine(const Offset(5, 12), const Offset(19, 12), paint);

      case QuietGlyph.search:
        canvas
          ..drawCircle(const Offset(11, 11), 6, paint)
          ..drawLine(const Offset(15.5, 15.5), const Offset(20, 20), paint);

      case QuietGlyph.chevronLeft:
        canvas.drawPath(
          Path()
            ..moveTo(15, 5)
            ..lineTo(8, 12)
            ..lineTo(15, 19),
          paint,
        );

      case QuietGlyph.chevronRight:
        canvas.drawPath(
          Path()
            ..moveTo(9, 5)
            ..lineTo(16, 12)
            ..lineTo(9, 19),
          paint,
        );

      case QuietGlyph.chevronDown:
        canvas.drawPath(
          Path()
            ..moveTo(5, 9)
            ..lineTo(12, 16)
            ..lineTo(19, 9),
          paint,
        );

      case QuietGlyph.close:
        canvas
          ..drawLine(const Offset(6, 6), const Offset(18, 18), paint)
          ..drawLine(const Offset(18, 6), const Offset(6, 18), paint);

      case QuietGlyph.check:
        canvas.drawPath(
          Path()
            ..moveTo(5, 12.5)
            ..lineTo(10, 17.5)
            ..lineTo(19, 6.5),
          paint,
        );

      case QuietGlyph.camera:
        canvas
          ..drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(3, 7, 18, 13),
              const Radius.circular(3),
            ),
            paint,
          )
          ..drawCircle(const Offset(12, 13.5), 4, paint)
          ..drawPath(
            Path()
              ..moveTo(9, 7)
              ..lineTo(10.5, 4)
              ..lineTo(13.5, 4)
              ..lineTo(15, 7),
            paint,
          );

      case QuietGlyph.calendar:
        canvas
          ..drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(3.5, 5, 17, 15),
              const Radius.circular(3),
            ),
            paint,
          )
          ..drawLine(const Offset(3.5, 10), const Offset(20.5, 10), paint)
          ..drawLine(const Offset(8, 3), const Offset(8, 7), paint)
          ..drawLine(const Offset(16, 3), const Offset(16, 7), paint);

      case QuietGlyph.pin:
        canvas
          ..drawPath(
            Path()
              ..moveTo(12, 21)
              ..cubicTo(12, 21, 19, 14.8, 19, 10)
              ..cubicTo(19, 6.13, 15.87, 3, 12, 3)
              ..cubicTo(8.13, 3, 5, 6.13, 5, 10)
              ..cubicTo(5, 14.8, 12, 21, 12, 21)
              ..close(),
            paint,
          )
          ..drawCircle(const Offset(12, 10), 2.5, paint);

      case QuietGlyph.gift:
        canvas
          ..drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(3.5, 9, 17, 11.5),
              const Radius.circular(2.5),
            ),
            paint,
          )
          ..drawLine(const Offset(12, 9), const Offset(12, 20.5), paint)
          ..drawLine(const Offset(3.5, 13.5), const Offset(20.5, 13.5), paint)
          ..drawPath(
            Path()
              ..moveTo(12, 9)
              ..cubicTo(12, 9, 11, 3.5, 8, 3.5)
              ..cubicTo(5.8, 3.5, 5.8, 6.5, 8, 6.5)
              ..lineTo(12, 6.5),
            paint,
          )
          ..drawPath(
            Path()
              ..moveTo(12, 9)
              ..cubicTo(12, 9, 13, 3.5, 16, 3.5)
              ..cubicTo(18.2, 3.5, 18.2, 6.5, 16, 6.5)
              ..lineTo(12, 6.5),
            paint,
          );

      case QuietGlyph.ellipsis:
        final dot = Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;
        canvas
          ..drawCircle(const Offset(5.5, 12), strokeWidth / scale, dot)
          ..drawCircle(const Offset(12, 12), strokeWidth / scale, dot)
          ..drawCircle(const Offset(18.5, 12), strokeWidth / scale, dot);

      case QuietGlyph.settings:
        canvas.drawCircle(const Offset(12, 12), 3, paint);
        for (var i = 0; i < 8; i++) {
          final angle = i * 0.785398;
          final dx = 12 + 7 * _cos(angle);
          final dy = 12 + 7 * _sin(angle);
          canvas.drawLine(const Offset(12, 12), Offset(dx, dy), paint);
        }

      case QuietGlyph.journal:
        canvas
          ..drawPath(
            Path()
              ..moveTo(5, 6)
              ..lineTo(19, 6)
              ..lineTo(19, 20)
              ..lineTo(5, 20)
              ..close(),
            paint,
          )
          ..drawLine(const Offset(12, 6), const Offset(12, 20), paint)
          ..drawLine(const Offset(7, 10), const Offset(10, 10), paint)
          ..drawLine(const Offset(14, 10), const Offset(17, 10), paint)
          ..drawLine(const Offset(7, 14), const Offset(10, 14), paint);

      case QuietGlyph.kinMark:
        canvas
          ..drawCircle(const Offset(9, 12), 3.5, paint)
          ..drawCircle(const Offset(15, 12), 3.5, paint);

      case QuietGlyph.bell:
        canvas
          ..drawPath(
            Path()
              ..moveTo(6, 16)
              ..lineTo(6, 11)
              ..cubicTo(6, 7.5, 8.5, 4.5, 12, 4.5)
              ..cubicTo(15.5, 4.5, 18, 7.5, 18, 11)
              ..lineTo(18, 16)
              ..lineTo(20, 18.5)
              ..lineTo(4, 18.5)
              ..close(),
            paint,
          )
          ..drawLine(const Offset(10.5, 18.5), const Offset(10.5, 20), paint)
          ..drawLine(const Offset(13.5, 18.5), const Offset(13.5, 20), paint)
          ..drawLine(const Offset(10.5, 20), const Offset(13.5, 20), paint);

      case QuietGlyph.sun:
        canvas.drawCircle(const Offset(12, 12), 3.5, paint);
        for (var i = 0; i < 8; i++) {
          final angle = i * 0.785398;
          const inner = 6.2;
          const outer = 9.2;
          final dx = _cos(angle);
          final dy = _sin(angle);
          canvas.drawLine(
            Offset(12 + inner * dx, 12 + inner * dy),
            Offset(12 + outer * dx, 12 + outer * dy),
            paint,
          );
        }

      case QuietGlyph.moon:
        canvas.drawPath(
          Path()
            ..moveTo(15.5, 5.5)
            ..cubicTo(11.5, 5.8, 8.5, 9.2, 8.5, 13.2)
            ..cubicTo(8.5, 17.4, 11.8, 20.8, 16, 20.8)
            ..cubicTo(17.5, 20.8, 18.9, 20.4, 20, 19.6)
            ..cubicTo(16.2, 19.2, 13.2, 16, 13.2, 12.1)
            ..cubicTo(13.2, 9.2, 14.6, 6.7, 15.5, 5.5)
            ..close(),
          paint,
        );

      case QuietGlyph.dawn:
        canvas
          ..drawLine(const Offset(4, 16.5), const Offset(20, 16.5), paint)
          ..drawPath(
            Path()
              ..moveTo(7, 16.5)
              ..cubicTo(7, 12.5, 9.2, 9.5, 12, 9.5)
              ..cubicTo(14.8, 9.5, 17, 12.5, 17, 16.5),
            paint,
          )
          ..drawLine(const Offset(12, 5), const Offset(12, 7.5), paint)
          ..drawLine(const Offset(6.5, 8.5), const Offset(8, 10), paint)
          ..drawLine(const Offset(17.5, 8.5), const Offset(16, 10), paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_QuietGlyphPainter old) =>
      old.glyph != glyph ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}

double _cos(double radians) => _trig(radians, isCos: true);

double _sin(double radians) => _trig(radians, isCos: false);

double _trig(double radians, {required bool isCos}) {
  // Small-angle table step for eight spokes — no dart:math in painter hot path.
  const values = <double>[
    1,
    0.707106781,
    0,
    -0.707106781,
    -1,
    -0.707106781,
    0,
    0.707106781,
  ];
  final index = ((radians / 0.785398).round()) & 7;
  final v = values[index];
  return isCos ? v : values[(index + 2) & 7];
}
