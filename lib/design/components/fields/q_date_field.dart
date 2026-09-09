import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/fields/q_field.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Birthday day / month / year row — responsive widths, never clipped labels.
///
/// Flex bias: Day (narrow) · Month (widest, full month names) · Year (medium).
/// Year placeholder stays short; optional-year guidance lives in [helper].
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
    final i = q.interactive;
    final onParchment = context.isParchmentControls;
    final eyebrow = onParchment ? i.ink : q.color.textSecondary;
    final helperInk = onParchment ? i.inkSecondary : q.color.textTertiary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BIRTHDAY',
          textScaler: context.structuralTextScaler,
          style: q.text.eyebrow.tinted(eyebrow),
        ),
        SizedBox(height: q.space.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            final gap = q.space.sm;
            final dayPlaceholder = constraints.maxWidth < 340 ? 'D' : 'Day';

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: QField(
                    controller: dayController,
                    focusNode: dayFocusNode,
                    placeholder: dayPlaceholder,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.none,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 2,
                    showHelperLine: false,
                    onChanged: onDayChanged,
                  ),
                ),
                SizedBox(width: gap),
                Expanded(
                  flex: 5,
                  child: _MonthButton(
                    label: monthLabel ?? 'Month',
                    isPlaceholder: monthLabel == null,
                    onPressed: onMonthPressed,
                  ),
                ),
                SizedBox(width: gap),
                Expanded(
                  flex: 3,
                  child: QField(
                    controller: yearController,
                    focusNode: yearFocusNode,
                    placeholder: 'Year',
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
            );
          },
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
                        style: q.text.caption.tinted(helperInk),
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
    final i = q.interactive;
    final onParchment = context.isParchmentControls;
    final fill = onParchment ? i.input : q.color.sunken;
    final border = onParchment ? i.inputBorder : q.color.hairline;
    final ink = onParchment
        ? (isPlaceholder ? i.inkSecondary : i.ink)
        : (isPlaceholder ? q.color.textTertiary : q.color.textPrimary);

    return QPressable(
      onTap: onPressed,
      radius: q.radius.sm,
      semanticLabel: 'Choose month',
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: QField.singleLineHeight),
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: fill,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(q.radius.sm)),
              side: BorderSide(
                color: border,
                width: QField.focusBorderWidth,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: q.space.md,
              vertical: q.space.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    textScaler: context.structuralTextScaler,
                    style: q.text.bodyLg.tinted(ink),
                  ),
                ),
                SizedBox(width: q.space.xs),
                QGlyphIcon(
                  QuietGlyph.chevronDown,
                  color: onParchment ? i.inkMuted : q.color.textTertiary,
                  size: context.structuralTextScaler.scale(18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
