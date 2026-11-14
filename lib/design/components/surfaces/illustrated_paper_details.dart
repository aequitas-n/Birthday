import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:kin/design/theme/illustrated_theme.dart';

/// Static pigment and margin sketches beneath live card content. The middle
/// stays quiet; every mark is clipped by the owning surface painter.
class IllustratedPaperDetails {
  const IllustratedPaperDetails._();

  static void paint(Canvas canvas, Size size, IllustratedTheme art) {
    final extent = math.min(
      132,
      math.min(size.width * 0.42, size.height * 0.6),
    );
    if (extent < 30) return;

    void wash(Offset center, double radius, Color color, double opacity) {
      final area = Rect.fromCircle(center: center, radius: radius);
      canvas.drawOval(
        area,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: opacity * 0.45),
              color.withValues(alpha: 0),
            ],
            stops: const [0, 0.48, 1],
          ).createShader(area),
      );
    }

    wash(
      Offset(size.width * 0.98, size.height * 0.96),
      extent * 1.65,
      art.secondary,
      art.dark ? 0.12 : 0.10,
    );
    wash(
      Offset(size.width * 0.04, size.height * 0.02),
      extent * 1.25,
      art.accent,
      art.dark ? 0.065 : 0.055,
    );

    // One small drawing tucked into a corner, scaled independently of text.
    canvas
      ..save()
      ..translate(size.width - extent - 5, size.height - extent - 6)
      ..scale(extent / 120);
    final pen = Paint()
      ..color = art.accent.withValues(alpha: art.dark ? 0.18 : 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final pigment = Paint()
      ..color = art.secondary.withValues(alpha: art.dark ? 0.13 : 0.10);

    switch (art.style) {
      case IllustrationStyle.seaside:
        _seaside(canvas, pen, pigment);
      case IllustrationStyle.botanical:
        _sprig(canvas, pen, pigment);
      case IllustrationStyle.vintage:
        _sprig(canvas, pen, pigment);
        _flower(canvas, const Offset(56, 43), pen, pigment);
        _flower(canvas, const Offset(37, 68), pen, pigment);
      case IllustrationStyle.postcard:
        _postcard(canvas, pen, pigment);
      case IllustrationStyle.comic:
        _comic(canvas, pen, pigment);
      case IllustrationStyle.arcade:
        _arcade(canvas, pen, pigment);
      case IllustrationStyle.storybook:
        _night(canvas, pen, pigment);
    }
    canvas.restore();
  }

  static void _seaside(Canvas canvas, Paint pen, Paint pigment) {
    // A small scallop shell and loose tidelines, like pencil over watercolor.
    final shell = Path()
      ..moveTo(82, 96)
      ..cubicTo(24, 82, 30, 37, 51, 44)
      ..cubicTo(50, 26, 68, 23, 73, 38)
      ..cubicTo(80, 19, 99, 27, 97, 43)
      ..cubicTo(116, 34, 125, 57, 111, 70)
      ..quadraticBezierTo(101, 87, 82, 96)
      ..close();
    canvas
      ..drawPath(shell, pigment)
      ..drawPath(shell, pen);
    for (final tip in const [
      Offset(50, 49),
      Offset(62, 37),
      Offset(82, 34),
      Offset(103, 49),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(82, 94)
          ..quadraticBezierTo(tip.dx, 69, tip.dx, tip.dy),
        pen,
      );
    }
    for (var row = 0; row < 2; row++) {
      canvas.drawPath(
        Path()
          ..moveTo(9, 103 + row * 6)
          ..cubicTo(40, 93 + row * 6, 63, 116 + row * 6, 118, 102 + row * 6),
        pen,
      );
    }
  }

  static void _sprig(Canvas canvas, Paint pen, Paint pigment) {
    canvas.drawPath(
      Path()
        ..moveTo(111, 117)
        ..cubicTo(76, 102, 66, 76, 54, 34),
      pen,
    );
    for (var i = 0; i < 5; i++) {
      final y = 48.0 + i * 12;
      final x = 58.0 + i * 6;
      final left = i.isEven;
      final tip = Offset(x + (left ? -29 : 26), y - 19);
      final leaf = Path()
        ..moveTo(x, y + 9)
        ..quadraticBezierTo(tip.dx - (left ? 1 : 6), y + 3, tip.dx, tip.dy)
        ..quadraticBezierTo(x + (left ? -1 : 13), y - 15, x, y + 9);
      canvas
        ..drawPath(leaf, pigment)
        ..drawPath(leaf, pen)
        ..drawLine(Offset(x, y + 9), tip, pen);
    }
  }

  static void _flower(Canvas canvas, Offset center, Paint pen, Paint pigment) {
    for (var i = 0; i < 5; i++) {
      final angle = i * math.pi * 2 / 5;
      final petal = center + Offset(math.cos(angle), math.sin(angle)) * 6;
      canvas
        ..drawOval(
          Rect.fromCenter(center: petal, width: 8, height: 10),
          pigment,
        )
        ..drawOval(Rect.fromCenter(center: petal, width: 8, height: 10), pen);
    }
    canvas.drawCircle(center, 2, pen);
  }

  static void _postcard(Canvas canvas, Paint pen, Paint pigment) {
    const stamp = Rect.fromLTWH(54, 48, 48, 54);
    canvas
      ..save()
      ..translate(80, 75)
      ..rotate(-0.13)
      ..translate(-80, -75)
      ..drawRRect(
        RRect.fromRectAndRadius(stamp, const Radius.circular(3)),
        pigment,
      )
      ..drawRRect(RRect.fromRectAndRadius(stamp, const Radius.circular(3)), pen)
      ..drawCircle(const Offset(77, 70), 10, pen)
      ..drawPath(
        Path()
          ..moveTo(59, 91)
          ..lineTo(75, 77)
          ..lineTo(91, 91),
        pen,
      )
      ..restore();
    for (var i = 0; i < 3; i++) {
      final y = 79.0 + i * 7;
      canvas.drawPath(
        Path()
          ..moveTo(8, y)
          ..cubicTo(22, y - 7, 36, y + 7, 62, y),
        pen,
      );
    }
  }

  static void _comic(Canvas canvas, Paint pen, Paint pigment) {
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col <= row; col++) {
        canvas.drawCircle(
          Offset(113 - col * 9.0, 111 - row * 9.0),
          1.4 - row * 0.1,
          pigment,
        );
      }
    }
    final burst = Path()
      ..moveTo(68, 46)
      ..lineTo(75, 60)
      ..lineTo(90, 57)
      ..lineTo(81, 70)
      ..lineTo(88, 84)
      ..lineTo(73, 80)
      ..lineTo(62, 91)
      ..lineTo(62, 75)
      ..lineTo(48, 68)
      ..lineTo(63, 64)
      ..close();
    canvas
      ..drawPath(burst, pigment)
      ..drawPath(burst, pen)
      ..drawLine(const Offset(98, 54), const Offset(106, 48), pen)
      ..drawLine(const Offset(51, 46), const Offset(47, 39), pen);
  }

  static void _arcade(Canvas canvas, Paint pen, Paint pigment) {
    final orbit = Path()
      ..moveTo(26, 105)
      ..lineTo(49, 105)
      ..lineTo(49, 89)
      ..lineTo(77, 89)
      ..lineTo(77, 53)
      ..lineTo(112, 53);
    canvas.drawPath(orbit, pen);
    for (final point in const [
      Offset(26, 105),
      Offset(77, 53),
      Offset(112, 53),
    ]) {
      canvas.drawRect(
        Rect.fromCenter(center: point, width: 5, height: 5),
        pigment,
      );
    }
    const pixels = [
      Offset(46, 45),
      Offset(54, 45),
      Offset(70, 45),
      Offset(78, 45),
      Offset(38, 53),
      Offset(46, 53),
      Offset(54, 53),
      Offset(62, 53),
      Offset(70, 53),
      Offset(78, 53),
      Offset(86, 53),
      Offset(46, 61),
      Offset(54, 61),
      Offset(62, 61),
      Offset(70, 61),
      Offset(78, 61),
      Offset(54, 69),
      Offset(62, 69),
      Offset(70, 69),
      Offset(62, 77),
    ];
    for (final point in pixels) {
      canvas.drawRect(Rect.fromLTWH(point.dx, point.dy, 6, 6), pigment);
    }
  }

  static void _night(Canvas canvas, Paint pen, Paint pigment) {
    final moon = Path()
      ..moveTo(91, 35)
      ..cubicTo(55, 38, 56, 86, 94, 85)
      ..cubicTo(73, 75, 72, 48, 91, 35)
      ..close();
    canvas
      ..drawPath(moon, pigment)
      ..drawPath(moon, pen);
    const stars = [
      Offset(19, 66),
      Offset(37, 41),
      Offset(49, 76),
      Offset(34, 102),
    ];
    final constellation = Path()..moveTo(stars.first.dx, stars.first.dy);
    for (final star in stars.skip(1)) {
      constellation.lineTo(star.dx, star.dy);
    }
    canvas.drawPath(constellation, pen);
    for (final star in stars) {
      canvas
        ..drawCircle(star, 2.5, pigment)
        ..drawLine(star - const Offset(3, 0), star + const Offset(3, 0), pen)
        ..drawLine(star - const Offset(0, 3), star + const Offset(0, 3), pen);
    }
  }
}
