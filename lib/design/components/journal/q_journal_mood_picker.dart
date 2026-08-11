import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/theme/journal_mood_colors.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// A restrained visual mood selector — ink marks, not filter chips.
class QJournalMoodPicker extends StatelessWidget {
  const QJournalMoodPicker({
    required this.options,
    required this.onSelected,
    this.selectedId,
    super.key,
  });

  /// `(id, label)` pairs. Ids match JournalMood storage values.
  final List<(String id, String label)> options;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    return Wrap(
      spacing: q.space.md,
      runSpacing: q.space.md,
      children: [
        for (final (id, label) in options)
          _MoodMark(
            id: id,
            label: label,
            selected: selectedId == id,
            onTap: () => onSelected(selectedId == id ? null : id),
          ),
      ],
    );
  }
}

class _MoodMark extends StatelessWidget {
  const _MoodMark({
    required this.id,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String id;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final j = q.journal;
    final (fill, ink) = JournalMoodColors.resolve(id, dark: q.isDark);

    return QPressable(
      onTap: onTap,
      radius: q.radius.sm,
      semanticLabel: '$label${selected ? ', selected' : ''}',
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: q.space.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: const Size(22, 10),
              painter: _InkStainPainter(
                color: fill.withValues(alpha: selected ? 0.9 : 0.45),
              ),
            ),
            SizedBox(height: q.space.xs),
            Text(
              label,
              textScaler: context.structuralTextScaler,
              style: q.text.archiveLabel.tinted(
                selected ? ink : j.inkMuted,
              ),
            ),
            SizedBox(height: q.space.xs),
            Container(
              width: selected ? 18 : 0,
              height: context.hairlineWidth * 2,
              color: selected ? ink.withValues(alpha: 0.55) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _InkStainPainter extends CustomPainter {
  _InkStainPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(2, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.3,
        0,
        size.width * 0.55,
        size.height * 0.35,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.7,
        size.width - 1,
        size.height * 0.45,
      )
      ..quadraticBezierTo(
        size.width * 0.6,
        size.height,
        size.width * 0.25,
        size.height * 0.7,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _InkStainPainter oldDelegate) =>
      oldDelegate.color != color;
}
