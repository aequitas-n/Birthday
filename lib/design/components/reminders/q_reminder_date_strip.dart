import 'package:flutter/widgets.dart';
import 'package:kin/design/components/buttons/q_icon_button.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/surfaces/q_illustrated_surface.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Seven-day strip centered on the selected calendar day.
///
/// Design-only: year / month / day ints — no domain imports.
class QReminderDateStrip extends StatelessWidget {
  const QReminderDateStrip({
    required this.selectedYear,
    required this.selectedMonth,
    required this.selectedDay,
    required this.onSelect,
    required this.onPreviousWeek,
    required this.onNextWeek,
    super.key,
  });

  final int selectedYear;
  final int selectedMonth;
  final int selectedDay;
  final void Function(int year, int month, int day) onSelect;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  static const _weekdayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final selected = DateTime(selectedYear, selectedMonth, selectedDay);
    final days = [
      for (var offset = -3; offset <= 3; offset++)
        selected.add(Duration(days: offset)),
    ];

    final previous = QIconButton(
      glyph: QuietGlyph.chevronLeft,
      onPressed: onPreviousWeek,
      semanticLabel: 'Previous week',
    );
    final next = QIconButton(
      glyph: QuietGlyph.chevronRight,
      onPressed: onNextWeek,
      semanticLabel: 'Next week',
    );
    final dayRow = Row(
      children: [
        for (final day in days)
          Expanded(
            child: _DayCell(
              letter: _weekdayLetters[day.weekday - 1],
              dayNumber: day.day,
              selected:
                  day.year == selectedYear &&
                  day.month == selectedMonth &&
                  day.day == selectedDay,
              onTap: () => onSelect(day.year, day.month, day.day),
            ),
          ),
      ],
    );

    final strip = LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  previous,
                  Text(
                    'Week of $selectedDay / $selectedMonth',
                    textScaler: context.structuralTextScaler,
                    style: context.quiet.inked(context.quiet.text.uiCaption),
                  ),
                  next,
                ],
              ),
              dayRow,
            ],
          );
        }
        return Row(
          children: [
            previous,
            Expanded(child: dayRow),
            next,
          ],
        );
      },
    );
    if (context.appTheme.art == null) return strip;
    return QIllustratedSurface(
      kind: IllustratedSurfaceKind.calendar,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: strip,
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.letter,
    required this.dayNumber,
    required this.selected,
    required this.onTap,
  });

  final String letter;
  final int dayNumber;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final size = context.structuralTextScaler.scale(36);

    return QPressable(
      onTap: onTap,
      radius: size / 2,
      selected: selected,
      semanticLabel: 'Day $dayNumber',
      child: SizedBox(
        width: size,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              letter,
              textScaler: context.structuralTextScaler,
              style: q.text.uiCaption.tinted(
                selected ? q.color.textPrimary : q.color.textTertiary,
              ),
            ),
            SizedBox(height: q.space.hair),
            AnimatedContainer(
              duration: q.motion.quick,
              curve: q.motion.standard,
              width: size * 0.78,
              height: size * 0.78,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? q.color.accent : null,
              ),
              child: Text(
                '$dayNumber',
                textScaler: context.structuralTextScaler,
                style: q.text.uiCount.tinted(
                  selected ? q.color.textInverse : q.color.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
