import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/design/components/buttons/q_icon_button.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/reminders/q_reminder_date_strip.dart';
import 'package:kin/design/components/sheets/q_choice_sheet.dart';
import 'package:kin/design/components/surfaces/q_screen.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/motion/quiet_motion.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/domain/models/personal_reminder.dart';
import 'package:kin/features/reminders/application/reminder_providers.dart';
import 'package:kin/notifications/application/notification_coordinator.dart';
// ignore: always_use_package_imports -- ARCH-03
import 'reminder_composer_sheet.dart';

/// Personal reminder planner — one chronological list for the selected day.
class ReminderPlannerScreen extends ConsumerStatefulWidget {
  const ReminderPlannerScreen({super.key});

  @override
  ConsumerState<ReminderPlannerScreen> createState() =>
      _ReminderPlannerScreenState();
}

class _ReminderPlannerScreenState extends ConsumerState<ReminderPlannerScreen> {
  late LocalCalendarDate _selected;
  var _completedExpanded = false;

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _selected = ref.read(reminderTodayProvider);
  }

  void _select(int year, int month, int day) {
    setState(() {
      _selected = LocalCalendarDate(year: year, month: month, day: day);
      _completedExpanded = false;
    });
  }

  void _shiftWeek(int days) {
    final shifted = DateTime(
      _selected.year,
      _selected.month,
      _selected.day,
    ).add(Duration(days: days));
    _select(shifted.year, shifted.month, shifted.day);
  }

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final classifiedAsync = ref.watch(
      classifiedRemindersForDateProvider(_selected.storageKey),
    );
    final classified = classifiedAsync.asData?.value;
    final active = classified == null
        ? const <PersonalReminder>[]
        : _chronological(classified.active);
    final completed = classified == null
        ? const <PersonalReminder>[]
        : _chronological(classified.completed);
    final weekday =
        _weekdays[DateTime(
              _selected.year,
              _selected.month,
              _selected.day,
            ).weekday -
            1];

    return QScreen(
      child: QMeasure(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.gutter - q.space.sm,
                q.space.base,
                context.gutter,
                0,
              ),
              child: Row(
                children: [
                  QIconButton(
                    glyph: QuietGlyph.chevronLeft,
                    onPressed: () => context.pop(),
                    semanticLabel: 'Back',
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  context.gutter,
                  q.space.md,
                  context.gutter,
                  q.space.emptiness,
                ),
                children: [
                  Text(
                    weekday,
                    textScaler: context.nameTextScaler,
                    style: q.text.pageTitle.tinted(q.color.textPrimary),
                  ),
                  SizedBox(height: q.space.xs),
                  Text(
                    _archiveDateLabel(_selected),
                    style: q.text.uiDate.tinted(q.color.textSecondary),
                  ),
                  SizedBox(height: q.space.xl),
                  QReminderDateStrip(
                    selectedYear: _selected.year,
                    selectedMonth: _selected.month,
                    selectedDay: _selected.day,
                    onSelect: _select,
                    onPreviousWeek: () => _shiftWeek(-7),
                    onNextWeek: () => _shiftWeek(7),
                  ),
                  SizedBox(height: q.space.xxl),
                  _RemindersHeader(count: active.length),
                  SizedBox(height: q.space.lg),
                  if (active.isEmpty)
                    Text(
                      'Nothing planned yet.',
                      style: q.text.emptyStateBody.tinted(
                        q.color.textSecondary,
                      ),
                    )
                  else
                    for (final (index, reminder) in active.indexed) ...[
                      if (index > 0) SizedBox(height: q.space.md),
                      _ReminderRow(
                        reminder: reminder,
                        onTap: () => showReminderComposerSheet(
                          context: context,
                          date: _selected,
                          dayPart: reminder.dayPart,
                          existing: reminder,
                        ),
                        onDelete: () => _confirmDelete(reminder),
                      ),
                    ],
                  SizedBox(height: q.space.xl),
                  _AddReminderAction(
                    onTap: () => showReminderComposerSheet(
                      context: context,
                      date: _selected,
                    ),
                  ),
                  if (completed.isNotEmpty) ...[
                    SizedBox(height: q.space.xxl),
                    _CompletedDisclosure(
                      count: completed.length,
                      expanded: _completedExpanded,
                      onToggle: () {
                        setState(
                          () => _completedExpanded = !_completedExpanded,
                        );
                      },
                      children: [
                        for (final (index, reminder) in completed.indexed) ...[
                          if (index > 0) SizedBox(height: q.space.md),
                          _ReminderRow(
                            reminder: reminder,
                            muted: true,
                            onTap: () => showReminderComposerSheet(
                              context: context,
                              date: _selected,
                              dayPart: reminder.dayPart,
                              existing: reminder,
                            ),
                            onDelete: () => _confirmDelete(reminder),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _archiveDateLabel(LocalCalendarDate date) {
    return '${_months[date.month - 1]} ${_ordinal(date.day)}, ${date.year}';
  }

  String _ordinal(int day) {
    if (day >= 11 && day <= 13) return '${day}th';
    return switch (day % 10) {
      1 => '${day}st',
      2 => '${day}nd',
      3 => '${day}rd',
      _ => '${day}th',
    };
  }

  Future<void> _confirmDelete(PersonalReminder reminder) async {
    final choice = await showQChoiceSheet(
      context: context,
      title: 'Remove reminder?',
      choices: const [
        QChoice('Remove', destructive: true),
        QChoice('Keep'),
      ],
    );
    if (choice != 0 || !mounted) return;
    await ref.read(personalReminderRepositoryProvider).softDelete(reminder.id);
    try {
      await ref.read(notificationCoordinatorProvider).synchronize();
    } on Object {
      // Scheduling is best-effort while wiring lands.
    }
  }
}

/// Exact local time first; position breaks ties (domain order preserved).
List<PersonalReminder> _chronological(List<PersonalReminder> reminders) {
  return [...reminders]..sort((a, b) {
    final byTime = a.localTime.compareTo(b.localTime);
    if (byTime != 0) return byTime;
    return a.position.compareTo(b.position);
  });
}

class _RemindersHeader extends StatelessWidget {
  const _RemindersHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Reminders',
            textScaler: context.nameTextScaler,
            style: q.text.sectionTitle.tinted(q.color.textPrimary),
          ),
        ),
        Text(
          '$count',
          textScaler: context.structuralTextScaler,
          style: q.text.uiCount.tinted(q.color.textSecondary),
        ),
      ],
    );
  }
}

class _AddReminderAction extends StatelessWidget {
  const _AddReminderAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return Align(
      alignment: Alignment.centerLeft,
      child: QPressable(
        onTap: onTap,
        radius: q.radius.sm,
        semanticLabel: 'Add reminder',
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: q.space.sm,
            vertical: q.space.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              QGlyphIcon(
                QuietGlyph.plus,
                color: q.color.textSecondary,
                size: context.structuralTextScaler.scale(18),
              ),
              SizedBox(width: q.space.sm),
              Text(
                'Add reminder',
                style: q.text.uiBody.tinted(q.color.textSecondary),
              ),
            ],
          ),
        ),
      ),
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
                    style: q.text.uiMetadata.tinted(q.color.textSecondary),
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? 0 : -0.25,
                  duration: motion.move(q.motion.quick),
                  curve: motion.standard,
                  child: QGlyphIcon(
                    QuietGlyph.chevronDown,
                    color: q.color.textSecondary,
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
                    SizedBox(height: q.space.lg),
                    ...children,
                  ],
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({
    required this.reminder,
    required this.onTap,
    required this.onDelete,
    this.muted = false,
  });

  final PersonalReminder reminder;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final ink = muted ? q.color.textSecondary : q.color.textPrimary;
    final meta = q.color.textSecondary;

    return QPressable(
      onTap: onTap,
      onLongPress: onDelete,
      radius: q.radius.sm,
      semanticLabel: reminder.text,
      semanticHint: 'Long press to remove',
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: q.space.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: context.structuralTextScaler.scale(72),
              child: Text(
                reminder.localTime.displayLabel,
                style: q.text.uiTimestamp.tinted(meta),
              ),
            ),
            SizedBox(width: q.space.md),
            Expanded(
              child: Text(
                reminder.text,
                style: q.text.uiBody.tinted(ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
