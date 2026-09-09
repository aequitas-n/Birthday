import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/design/components/buttons/q_button.dart';
import 'package:kin/design/components/buttons/q_icon_button.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/fields/q_field.dart';
import 'package:kin/design/components/sheets/q_sheet.dart';
import 'package:kin/design/components/sheets/q_sheet_route.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/domain/models/local_clock_time.dart';
import 'package:kin/domain/models/personal_reminder.dart';
import 'package:kin/domain/models/reminder_day_part.dart';
import 'package:kin/features/reminders/application/reminder_providers.dart';
import 'package:kin/notifications/application/notification_coordinator.dart';

/// Opens the composer for a new or existing personal reminder.
///
/// [dayPart] remains domain metadata (defaults / future filters). The planner
/// presents a single chronological list — day-part is not a visual section.
Future<void> showReminderComposerSheet({
  required BuildContext context,
  required LocalCalendarDate date,
  ReminderDayPart dayPart = ReminderDayPart.anytime,
  PersonalReminder? existing,
}) {
  return showQSheet<void>(
    context: context,
    builder: (context) => ReminderComposerSheet(
      date: date,
      dayPart: existing?.dayPart ?? dayPart,
      existing: existing,
    ),
  );
}

class ReminderComposerSheet extends ConsumerStatefulWidget {
  const ReminderComposerSheet({
    required this.date,
    required this.dayPart,
    this.existing,
    super.key,
  });

  final LocalCalendarDate date;
  final ReminderDayPart dayPart;
  final PersonalReminder? existing;

  @override
  ConsumerState<ReminderComposerSheet> createState() =>
      _ReminderComposerSheetState();
}

class _ReminderComposerSheetState extends ConsumerState<ReminderComposerSheet> {
  late final TextEditingController _textController;
  late LocalClockTime _time;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _textController = TextEditingController(text: existing?.text ?? '');
    _time =
        existing?.localTime ??
        LocalClockTime.parseStorage(widget.dayPart.defaultLocalTime);
    _textController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool get _canSave => _textController.text.trim().isNotEmpty && !_saving;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final editing = widget.existing != null;

    return QSheet(
      title: editing ? 'Edit reminder' : 'Reminder',
      bottom: QBottomActions(
        children: [
          QButton.tertiary(
            label: 'Cancel',
            onPressed: _saving ? null : () => Navigator.of(context).pop(),
          ),
          QButton.primary(
            label: 'Save',
            loading: _saving,
            onPressed: _canSave ? _save : null,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            QField(
              controller: _textController,
              label: 'Reminder',
              placeholder: 'What do you need to remember?',
              maxLines: 3,
              textInputAction: TextInputAction.newline,
            ),
            SizedBox(height: q.space.lg),
            Text(
              'TIME',
              textScaler: context.structuralTextScaler,
              style: q.text.eyebrow.tinted(q.interactive.ink),
            ),
            SizedBox(height: q.space.sm),
            _TimeSteppers(
              time: _time,
              onChanged: (value) => setState(() => _time = value),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _saving) return;
    setState(() => _saving = true);

    final now = ref.read(clockProvider).now();
    final timezone = await ref.read(reminderTimezoneProvider.future);
    final existing = widget.existing;

    final reminder = PersonalReminder(
      id: existing?.id ?? '',
      localDate: widget.date,
      localTime: _time,
      dayPart: widget.dayPart,
      text: text,
      timezone: timezone,
      position: existing?.position ?? 0,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      await ref.read(personalReminderRepositoryProvider).upsert(reminder);
      final coordinator = ref.read(notificationCoordinatorProvider);
      // Exact alarms are required for on-the-minute delivery. Without them
      // Android batches into inexact windows (± a few minutes).
      await coordinator.requestExactAlarmPermission();
      try {
        await coordinator.synchronize();
      } on Object {
        // Scheduling is best-effort; permission may still be pending.
      }
      if (mounted) Navigator.of(context).pop();
    } on Object {
      if (mounted) setState(() => _saving = false);
    }
  }
}

/// Quiet hour / minute steppers — never a Material time picker dialog.
///
/// Hierarchy: large selected time is the hero; steppers and AM/PM support it.
class _TimeSteppers extends StatelessWidget {
  const _TimeSteppers({required this.time, required this.onChanged});

  final LocalClockTime time;
  final ValueChanged<LocalClockTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final i = q.interactive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          time.displayLabel,
          textAlign: TextAlign.center,
          textScaler: context.nameTextScaler,
          style: q.text.voiceLg.tinted(i.ink),
        ),
        SizedBox(height: q.space.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StepperColumn(
              label: _hour12(time.hour).toString().padLeft(2, '0'),
              onUp: () => onChanged(_bumpHour(time, 1)),
              onDown: () => onChanged(_bumpHour(time, -1)),
              semanticUp: 'Later hour',
              semanticDown: 'Earlier hour',
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: q.space.sm),
              child: Text(
                ':',
                style: q.text.voiceLg.tinted(i.inkSecondary),
              ),
            ),
            _StepperColumn(
              label: time.minute.toString().padLeft(2, '0'),
              onUp: () => onChanged(_bumpMinute(time, 1)),
              onDown: () => onChanged(_bumpMinute(time, -1)),
              semanticUp: 'Later minute',
              semanticDown: 'Earlier minute',
            ),
            SizedBox(width: q.space.xl),
            _PeriodToggle(
              isPm: time.hour >= 12,
              onChanged: (isPm) => onChanged(_withPeriod(time, isPm: isPm)),
            ),
          ],
        ),
      ],
    );
  }

  static int _hour12(int hour24) {
    final mod = hour24 % 12;
    return mod == 0 ? 12 : mod;
  }

  static LocalClockTime _bumpHour(LocalClockTime time, int delta) {
    final hour = (time.hour + delta) % 24;
    return time.copyWith(hour: hour < 0 ? hour + 24 : hour);
  }

  static LocalClockTime _bumpMinute(LocalClockTime time, int delta) {
    final minute = (time.minute + delta) % 60;
    return time.copyWith(minute: minute < 0 ? minute + 60 : minute);
  }

  static LocalClockTime _withPeriod(LocalClockTime time, {required bool isPm}) {
    final hour12 = _hour12(time.hour);
    final hour24 = isPm
        ? (hour12 == 12 ? 12 : hour12 + 12)
        : (hour12 == 12 ? 0 : hour12);
    return time.copyWith(hour: hour24);
  }
}

class _StepperColumn extends StatelessWidget {
  const _StepperColumn({
    required this.label,
    required this.onUp,
    required this.onDown,
    required this.semanticUp,
    required this.semanticDown,
  });

  final String label;
  final VoidCallback onUp;
  final VoidCallback onDown;
  final String semanticUp;
  final String semanticDown;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final i = q.interactive;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.flip(
          flipY: true,
          child: QIconButton(
            glyph: QuietGlyph.chevronDown,
            tone: QIconTone.secondary,
            onPressed: onUp,
            semanticLabel: semanticUp,
            glyphSize: 14,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: q.space.xs),
          child: Text(
            label,
            textScaler: context.nameTextScaler,
            style: q.text.numeralLg.tinted(i.ink),
          ),
        ),
        QIconButton(
          glyph: QuietGlyph.chevronDown,
          tone: QIconTone.secondary,
          onPressed: onDown,
          semanticLabel: semanticDown,
          glyphSize: 14,
        ),
      ],
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({required this.isPm, required this.onChanged});

  final bool isPm;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PeriodChip(
          label: 'AM',
          selected: !isPm,
          onTap: () => onChanged(false),
        ),
        SizedBox(height: q.space.xs),
        _PeriodChip(
          label: 'PM',
          selected: isPm,
          onTap: () => onChanged(true),
        ),
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final i = q.interactive;

    return QPressable(
      onTap: onTap,
      radius: q.radius.sm,
      selected: selected,
      semanticLabel: label,
      child: AnimatedContainer(
        duration: q.motion.quick,
        curve: q.motion.standard,
        padding: EdgeInsets.symmetric(
          horizontal: q.space.md,
          vertical: q.space.sm,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(q.radius.sm),
          color: selected ? i.accent : i.input,
          border: Border.all(
            color: selected ? i.accent : i.inputBorder,
            width: context.hairlineWidth,
          ),
        ),
        child: Text(
          label,
          textScaler: context.structuralTextScaler,
          style: q.text.label.tinted(
            selected ? i.primaryAction : i.ink,
          ),
        ),
      ),
    );
  }
}
