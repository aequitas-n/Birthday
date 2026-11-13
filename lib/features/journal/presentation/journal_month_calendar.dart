import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/motion/quiet_motion.dart';
import 'package:kin/design/theme/journal_mood_colors.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/design/components/surfaces/q_theme_surfaces.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/domain/repositories/journal_repository.dart';

/// Emotional month map — archival paper, not a stock calendar.
class JournalMonthCalendar extends StatelessWidget {
  const JournalMonthCalendar({
    required this.year,
    required this.month,
    required this.markers,
    required this.today,
    required this.onDaySelected,
    super.key,
  });

  final int year;
  final int month;
  final List<JournalDayMarker> markers;
  final LocalCalendarDate today;
  final ValueChanged<LocalCalendarDate> onDaySelected;

  static const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final cells = _buildCells();
    final markerByDate = {
      for (final marker in markers) marker.localDate.storageKey: marker,
    };

    // Calendar.png is cream parchment — brown ink for contrast.
    return QCalendarSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              for (final label in _weekdays)
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      textScaler: context.structuralTextScaler,
                      style: q.inked(
                        q.text.decorativeLabel,
                        surface: QuietSurfaceKind.paper,
                        tone: QuietInkTone.secondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: q.space.sm),
          // Fixed-height grid: avoid shrinkWrap, which forces GridView to
          // measure every cell to size itself (Phase 7/8 first-visit cost).
          LayoutBuilder(
            builder: (context, constraints) {
              const crossAxisCount = 7;
              const mainAxisSpacing = 2.0;
              const crossAxisSpacing = 2.0;
              final width = constraints.maxWidth;
              final cellExtent =
                  (width - (crossAxisCount - 1) * crossAxisSpacing) /
                  crossAxisCount;
              final rows = (cells.length / crossAxisCount).ceil();
              final gridHeight =
                  rows * cellExtent + (rows - 1) * mainAxisSpacing;

              return SizedBox(
                height: gridHeight,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: mainAxisSpacing,
                    crossAxisSpacing: crossAxisSpacing,
                  ),
                  itemCount: cells.length,
                  itemBuilder: (context, index) {
                    final cell = cells[index];
                    final marker = markerByDate[cell.date.storageKey];
                    return _DayCell(
                      date: cell.date,
                      inMonth: cell.inMonth,
                      isToday: cell.date == today,
                      marker: marker,
                      onTap: cell.inMonth
                          ? () => onDaySelected(cell.date)
                          : null,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<({LocalCalendarDate date, bool inMonth})> _buildCells() {
    final weekdayIndex = DateTime(year, month).weekday;
    final leading = weekdayIndex - 1;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final cells = <({LocalCalendarDate date, bool inMonth})>[];

    for (var i = leading; i > 0; i--) {
      final prevMonth = month == 1 ? 12 : month - 1;
      final prevYear = month == 1 ? year - 1 : year;
      final prevDays = DateTime(prevYear, prevMonth + 1, 0).day;
      final day = prevDays - i + 1;
      cells.add((
        date: LocalCalendarDate(year: prevYear, month: prevMonth, day: day),
        inMonth: false,
      ));
    }

    for (var day = 1; day <= daysInMonth; day++) {
      cells.add((
        date: LocalCalendarDate(year: year, month: month, day: day),
        inMonth: true,
      ));
    }

    while (cells.length % 7 != 0) {
      final nextIndex = cells.length - leading - daysInMonth + 1;
      final nextMonth = month == 12 ? 1 : month + 1;
      final nextYear = month == 12 ? year + 1 : year;
      cells.add((
        date: LocalCalendarDate(
          year: nextYear,
          month: nextMonth,
          day: nextIndex,
        ),
        inMonth: false,
      ));
    }

    return cells;
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.inMonth,
    required this.isToday,
    this.marker,
    this.onTap,
  });

  final LocalCalendarDate date;
  final bool inMonth;
  final bool isToday;
  final JournalDayMarker? marker;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final paper = q.paper;
    final mood = marker?.dayMood;
    final entryCount = marker?.entryCount ?? 0;
    final hasEntries = marker?.hasEntries ?? false;

    Color? circleFill;
    var textColor = inMonth
        ? paper.primary
        : paper.secondary.withValues(alpha: 0.4);
    if (mood != null && inMonth) {
      final (fill, ink) = JournalMoodColors.resolve(
        mood.storageValue,
        // Calendar parchment is cream — paper mood washes, not dark-canvas ones.
        dark: false,
      );
      // Soft ink stain on parchment.
      circleFill = fill.withValues(alpha: 0.88);
      textColor = ink;
    }

    final semantic = StringBuffer(date.storageKey);
    if (mood != null) semantic.write(', ${mood.displayName}');
    if (hasEntries) {
      semantic.write(
        entryCount == 1 ? ', 1 memory' : ', $entryCount memories',
      );
    }
    if (isToday) semantic.write(', today');

    final child = CustomPaint(
      painter: _DayCirclePainter(
        fill: circleFill,
        ring: isToday,
        ringColor: circleFill == null
            ? paper.primary.withValues(alpha: 0.7)
            : textColor.withValues(alpha: 0.45),
        memoryMark: hasEntries && inMonth,
        markColor: textColor.withValues(alpha: 0.7),
        entryCount: entryCount.clamp(0, 3),
        hairline: context.hairlineWidth,
      ),
      child: Center(
        child: Text(
          '${date.day}',
          textScaler: context.structuralTextScaler,
          style:
              (isToday || circleFill != null ? q.text.uiCount : q.text.uiBody)
                  .tinted(textColor),
        ),
      ),
    );

    if (onTap == null) {
      return Opacity(opacity: inMonth ? 1 : 0.35, child: child);
    }

    return QPressable(
      onTap: onTap,
      radius: q.radius.sm,
      semanticLabel: semantic.toString(),
      child: Opacity(opacity: inMonth ? 1 : 0.35, child: child),
    );
  }
}

/// Perfect day circle — mood fills the disc; today adds a quiet ring.
class _DayCirclePainter extends CustomPainter {
  _DayCirclePainter({
    required this.fill,
    required this.ring,
    required this.ringColor,
    required this.memoryMark,
    required this.markColor,
    required this.entryCount,
    required this.hairline,
  });

  final Color? fill;
  final bool ring;
  final Color ringColor;
  final bool memoryMark;
  final Color markColor;
  final int entryCount;
  final double hairline;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.38;

    if (fill != null) {
      canvas.drawCircle(center, radius, Paint()..color = fill!);
    }

    if (ring) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = ringColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = hairline * 2,
      );
    }

    if (memoryMark) {
      final y = center.dy + radius * 0.55;
      final start = center.dx - (entryCount - 1) * 2.5;
      for (var i = 0; i < entryCount; i++) {
        canvas.drawCircle(
          Offset(start + i * 5, y),
          1.4,
          Paint()..color = markColor,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DayCirclePainter oldDelegate) {
    return oldDelegate.fill != fill ||
        oldDelegate.ring != ring ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.memoryMark != memoryMark ||
        oldDelegate.entryCount != entryCount ||
        oldDelegate.markColor != markColor;
  }
}

/// Subtle page-open duration for selecting a journal day.
Duration journalPageOpenDuration(BuildContext context) {
  return QuietMotion.of(context).move(const Duration(milliseconds: 260));
}
