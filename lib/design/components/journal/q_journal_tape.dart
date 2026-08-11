import 'package:flutter/widgets.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Archival washi / masking tape accent — used sparingly.
class QJournalTape extends StatelessWidget {
  const QJournalTape({
    this.width = 48,
    this.angle = -0.1,
    super.key,
  });

  final double width;
  final double angle;

  @override
  Widget build(BuildContext context) {
    final j = context.quiet.journal;
    return Transform.rotate(
      angle: angle,
      child: IgnorePointer(
        child: Container(
          width: width,
          height: 11,
          decoration: BoxDecoration(
            color: j.tape.withValues(alpha: 0.55),
            border: Border.symmetric(
              horizontal: BorderSide(
                color: j.edge.withValues(alpha: 0.25),
                width: context.hairlineWidth,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small metal paperclip accent for archival fragments.
class QJournalClip extends StatelessWidget {
  const QJournalClip({this.angle = 0.14, super.key});

  final double angle;

  @override
  Widget build(BuildContext context) {
    final j = context.quiet.journal;
    return Transform.rotate(
      angle: angle,
      child: IgnorePointer(
        child: CustomPaint(
          size: const Size(12, 24),
          painter: _ClipPainter(color: j.clip.withValues(alpha: 0.7)),
        ),
      ),
    );
  }
}

class _ClipPainter extends CustomPainter {
  _ClipPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * 0.55, size.height * 0.08)
      ..cubicTo(
        size.width * 0.95,
        size.height * 0.12,
        size.width * 0.95,
        size.height * 0.55,
        size.width * 0.55,
        size.height * 0.62,
      )
      ..cubicTo(
        size.width * 0.15,
        size.height * 0.7,
        size.width * 0.2,
        size.height * 0.95,
        size.width * 0.55,
        size.height * 0.92,
      )
      ..cubicTo(
        size.width * 0.85,
        size.height * 0.9,
        size.width * 0.78,
        size.height * 0.72,
        size.width * 0.5,
        size.height * 0.7,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ClipPainter oldDelegate) =>
      oldDelegate.color != color;
}
