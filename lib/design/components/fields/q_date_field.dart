import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/fields/q_field.dart';
import 'package:kin/design/components/surfaces/q_surface.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

class QDateField extends StatelessWidget {
  const QDateField({
    required this.dayController,
    required this.yearController,
    required this.monthLabel,
    required this.onMonthPressed,
    this.error,
    this.helper,
    this.dayFocusNode,
    this.yearFocusNode,
    this.onDayChanged,
    this.onYearChanged,
    super.key,
  });

  final TextEditingController dayController;
  final TextEditingController yearController;
  final String? monthLabel;
  final VoidCallback onMonthPressed;
  final String? error;
  final String? helper;
  final FocusNode? dayFocusNode;
  final FocusNode? yearFocusNode;
  final ValueChanged<String>? onDayChanged;
  final ValueChanged<String>? onYearChanged;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BIRTHDAY',
          textScaler: context.structuralTextScaler,
          style: q.text.eyebrow.tinted(q.color.textTertiary),
        ),
        SizedBox(height: q.space.sm),
        Row(
          children: [
            Expanded(
              child: QField(
                controller: dayController,
                focusNode: dayFocusNode,
                placeholder: 'Day',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.none,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 2,
                showHelperLine: false,
                onChanged: onDayChanged,
              ),
            ),
            SizedBox(width: q.space.md),
            Expanded(
              flex: 2,
              child: _MonthButton(
                label: monthLabel ?? 'Month',
                isPlaceholder: monthLabel == null,
                onPressed: onMonthPressed,
              ),
            ),
            SizedBox(width: q.space.md),
            Expanded(
              flex: 2,
              child: QField(
                controller: yearController,
                focusNode: yearFocusNode,
                placeholder: 'Year (optional)',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.none,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 4,
                showHelperLine: false,
                onChanged: onYearChanged,
              ),
            ),
          ],
        ),
        SizedBox(height: q.space.sm - 2),
        SizedBox(
          height: context.structuralTextScaler.scale(16),
          child: error == null
              ? helper == null
                    ? null
                    : Text(
                        helper!,
                        textScaler: context.structuralTextScaler,
                        style: q.text.caption.tinted(q.color.textTertiary),
                      )
              : Text(
                  error!,
                  textScaler: context.structuralTextScaler,
                  style: q.text.caption.tinted(q.color.danger),
                ),
        ),
      ],
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({
    required this.label,
    required this.isPlaceholder,
    required this.onPressed,
  });

  final String label;
  final bool isPlaceholder;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    return QPressable(
      onTap: onPressed,
      radius: q.radius.sm,
      semanticLabel: 'Choose month',
      child: QSurface(
        level: QuietLevel.sunken,
        radius: q.radius.sm,
        padding: EdgeInsets.symmetric(
          horizontal: q.space.md + 2,
          vertical: q.space.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: q.text.bodyLg.tinted(
                  isPlaceholder ? q.color.textTertiary : q.color.textPrimary,
                ),
              ),
            ),
            SizedBox(width: q.space.xs),
            QGlyphIcon(
              QuietGlyph.chevronDown,
              color: q.color.textTertiary,
              size: context.structuralTextScaler.scale(18),
            ),
          ],
        ),
      ),
    );
  }
}
