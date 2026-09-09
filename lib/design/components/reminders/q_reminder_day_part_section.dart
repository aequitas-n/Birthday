import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/motion/quiet_motion.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Collapsible day-part bucket (Anytime / Morning / Afternoon / Evening).
///
/// Design-only: label, count, invitation strings — no domain imports.
class QReminderDayPartSection extends StatelessWidget {
  const QReminderDayPartSection({
    required this.label,
    required this.count,
    required this.expanded,
    required this.onToggle,
    required this.invitation,
    required this.onAdd,
    this.children = const [],
    this.completedCount = 0,
    this.completedExpanded = false,
    this.onToggleCompleted,
    this.completedChildren = const [],
    super.key,
  });

  final String label;
  final int count;
  final bool expanded;
  final VoidCallback onToggle;
  final String invitation;
  final VoidCallback onAdd;
  final List<Widget> children;
  final int completedCount;
  final bool completedExpanded;
  final VoidCallback? onToggleCompleted;
  final List<Widget> completedChildren;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final motion = QuietMotion.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QPressable(
          onTap: onToggle,
          radius: q.radius.sm,
          semanticLabel: expanded ? 'Collapse $label' : 'Expand $label',
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: q.space.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    textScaler: context.nameTextScaler,
                    style: q.inked(q.text.sectionTitle),
                  ),
                ),
                Text(
                  '$count',
                  textScaler: context.structuralTextScaler,
                  style: q.inked(
                    q.text.uiMetadata,
                    tone: QuietInkTone.secondary,
                  ),
                ),
                SizedBox(width: q.space.sm),
                AnimatedRotation(
                  turns: expanded ? 0 : -0.25,
                  duration: motion.move(q.motion.quick),
                  curve: motion.standard,
                  child: QGlyphIcon(
                    QuietGlyph.chevronDown,
                    color: q.canvas.secondary,
                    size: context.structuralTextScaler.scale(18),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: motion.move(q.motion.base),
          curve: motion.emphasized,
          alignment: Alignment.topCenter,
          child: expanded
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (children.isEmpty && completedCount == 0)
                      _EmptyInvitation(
                        invitation: invitation,
                        onAdd: onAdd,
                      )
                    else ...[
                      for (final (index, child) in children.indexed) ...[
                        if (index > 0) SizedBox(height: q.space.xs),
                        child,
                      ],
                      SizedBox(height: q.space.sm),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: QPressable(
                          onTap: onAdd,
                          radius: q.radius.full,
                          semanticLabel: 'Add to $label',
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: q.space.sm,
                              vertical: q.space.xs,
                            ),
                            child: QGlyphIcon(
                              QuietGlyph.plus,
                              color: q.canvas.secondary,
                              size: context.structuralTextScaler.scale(18),
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (completedCount > 0 && onToggleCompleted != null)
                      _CompletedDisclosure(
                        count: completedCount,
                        expanded: completedExpanded,
                        onToggle: onToggleCompleted!,
                        children: completedChildren,
                      ),
                    SizedBox(height: q.space.md),
                  ],
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _CompletedDisclosure extends StatelessWidget {
  const _CompletedDisclosure({
    required this.count,
    required this.expanded,
    required this.onToggle,
    required this.children,
  });

  final int count;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final motion = QuietMotion.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: q.space.sm),
        QPressable(
          onTap: onToggle,
          radius: q.radius.sm,
          semanticLabel: expanded
              ? 'Hide completed reminders'
              : 'Show completed reminders',
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: q.space.xs),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Completed · $count',
                    style: q.inked(
                      q.text.uiMetadata,
                      tone: QuietInkTone.secondary,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? 0 : -0.25,
                  duration: motion.move(q.motion.quick),
                  curve: motion.standard,
                  child: QGlyphIcon(
                    QuietGlyph.chevronDown,
                    color: q.canvas.secondary,
                    size: context.structuralTextScaler.scale(16),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: motion.move(q.motion.base),
          curve: motion.emphasized,
          alignment: Alignment.topCenter,
          child: expanded
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: q.space.xs),
                    for (final (index, child) in children.indexed) ...[
                      if (index > 0) SizedBox(height: q.space.xs),
                      child,
                    ],
                  ],
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _EmptyInvitation extends StatelessWidget {
  const _EmptyInvitation({
    required this.invitation,
    required this.onAdd,
  });

  final String invitation;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return QPressable(
      onTap: onAdd,
      radius: q.radius.md,
      semanticLabel: invitation,
      child: CustomPaint(
        painter: _DashedRRectPainter(
          color: q.color.hairline,
          radius: q.radius.md,
          strokeWidth: context.hairlineWidth,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: q.space.lg,
            vertical: q.space.lg,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  invitation,
                  style: q.inked(q.text.uiBody, tone: QuietInkTone.secondary),
                ),
              ),
              SizedBox(width: q.space.md),
              QGlyphIcon(
                QuietGlyph.plus,
                color: q.canvas.secondary,
                size: context.structuralTextScaler.scale(18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
  });

  final Color color;
  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      const dash = 5.0;
      const gap = 4.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth;
}
