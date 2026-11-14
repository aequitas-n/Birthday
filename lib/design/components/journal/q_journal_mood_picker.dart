import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/journal/q_mood_illustration.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Mood grid — exactly two rows of four illustrated moods.
///
/// Shared by Day mood and Memory mood sheets across all product themes.
/// Transparent illustrations use [BoxFit.contain]; labels stay on one line
/// at a **shared** font size (sized to the longest label in the grid).
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

  static const _columns = 4;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final rows = <List<(String, String)>>[];
    for (var i = 0; i < options.length; i += _columns) {
      final end = (i + _columns).clamp(0, options.length);
      rows.add(options.sublist(i, end));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = q.space.sm;
        final cellW = (constraints.maxWidth - gap * (_columns - 1)) / _columns;
        final artWidth = (cellW * 0.78).clamp(40.0, 72.0);
        final labelStyle = _sharedLabelStyle(
          context: context,
          cellWidth: cellW,
          labels: [for (final option in options) option.$2],
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (rowIndex, row) in rows.indexed) ...[
              if (rowIndex > 0) SizedBox(height: q.space.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var colIndex = 0; colIndex < _columns; colIndex++) ...[
                    if (colIndex > 0) SizedBox(width: gap),
                    Expanded(
                      child: colIndex < row.length
                          ? _MoodCell(
                              id: row[colIndex].$1,
                              label: row[colIndex].$2,
                              selected: selectedId == row[colIndex].$1,
                              artWidth: artWidth,
                              labelStyle: labelStyle,
                              onTap: () => onSelected(
                                selectedId == row[colIndex].$1
                                    ? null
                                    : row[colIndex].$1,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  /// One size for every mood name — the smallest that fits the longest label.
  TextStyle _sharedLabelStyle({
    required BuildContext context,
    required double cellWidth,
    required List<String> labels,
  }) {
    final q = context.quiet;
    final base = q.text.moodLabel;
    final scaler = context.structuralTextScaler.clamp(
      minScaleFactor: 0.85,
      maxScaleFactor: 1,
    );
    final maxWidth = math.max(1, cellWidth - q.space.hair * 2);
    var scale = 1.0;

    for (final label in labels) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: base),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      if (painter.width > maxWidth) {
        scale = math.min(scale, maxWidth / painter.width);
      }
    }

    final baseSize = base.fontSize ?? 12;
    // Floor so Courier stays readable; never larger than the token.
    final size = (baseSize * scale).clamp(9.0, baseSize);
    return base.copyWith(fontSize: size);
  }
}

class _MoodCell extends StatelessWidget {
  const _MoodCell({
    required this.id,
    required this.label,
    required this.selected,
    required this.artWidth,
    required this.labelStyle,
    required this.onTap,
  });

  final String id;
  final String label;
  final bool selected;
  final double artWidth;
  final TextStyle labelStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final i = q.interactive;

    return QPressable(
      onTap: onTap,
      radius: q.radius.md,
      semanticLabel: '$label${selected ? ', selected' : ''}',
      child: AnimatedScale(
        scale: selected ? 1.03 : 1,
        duration: q.motion.quick,
        curve: q.motion.emphasized,
        child: AnimatedContainer(
          duration: q.motion.quick,
          curve: q.motion.standard,
          padding: EdgeInsets.symmetric(
            horizontal: q.space.hair,
            vertical: q.space.sm,
          ),
          decoration: BoxDecoration(
            color: selected
                ? i.accent.withValues(alpha: 0.10)
                : q.color.transparent,
            borderRadius: BorderRadius.circular(q.radius.md),
            border: Border.all(
              color: selected
                  ? i.accent.withValues(alpha: 0.45)
                  : i.sheetBorder.withValues(alpha: 0),
              width: context.hairlineWidth,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QMoodIllustration(
                moodId: id,
                size: MoodIllustrationSize.picker,
                width: artWidth,
                opacity: selected ? 1 : 0.9,
              ),
              SizedBox(height: q.space.xs),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.clip,
                textScaler: TextScaler.noScaling,
                style: labelStyle.tinted(
                  selected ? i.ink : i.inkSecondary,
                ),
              ),
              SizedBox(height: q.space.hair),
              AnimatedContainer(
                duration: q.motion.quick,
                width: selected ? 18 : 0,
                height: context.hairlineWidth * 2,
                color: selected ? i.accent.withValues(alpha: 0.75) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
