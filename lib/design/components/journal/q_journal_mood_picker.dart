import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/journal/q_mood_illustration.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/design/theme/vintage_mood.dart';

/// Vintage Diary mood grid — exactly two rows of four illustrated moods.
///
/// Shared by Day mood and Memory mood sheets. Transparent PNGs use
/// [BoxFit.contain]; labels stay fully readable (no ellipsis truncation).
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
        final cellW =
            (constraints.maxWidth - gap * (_columns - 1)) / _columns;
        // Art scales with column width; leave room for a two-line label.
        final artWidth = (cellW * 0.78).clamp(40.0, 72.0);

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
}

class _MoodCell extends StatelessWidget {
  const _MoodCell({
    required this.id,
    required this.label,
    required this.selected,
    required this.artWidth,
    required this.onTap,
  });

  final String id;
  final String label;
  final bool selected;
  final double artWidth;
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
              // Transparent figure — no rectangular image plate.
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
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.visible,
                textScaler: context.structuralTextScaler.clamp(
                  minScaleFactor: 0.85,
                  maxScaleFactor: 1,
                ),
                style: q.text.uiCaption
                    .tinted(selected ? i.ink : i.inkSecondary)
                    .copyWith(height: 1.15, letterSpacing: 0.1),
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
