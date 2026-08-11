import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// A wrapping row of selectable pills.
///
/// Used for note kinds and for relationship, because picking from a short list
/// always beats typing. See docs/02-ux-philosophy.md law 3.
class QPillGroup extends StatelessWidget {
  const QPillGroup({
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    return Wrap(
      spacing: q.space.sm,
      runSpacing: q.space.sm,
      children: [
        for (final option in options)
          QPill(
            label: option,
            selected: option == selected,
            onTap: () => onSelected(option),
          ),
      ],
    );
  }
}

class QPill extends StatelessWidget {
  const QPill({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const double height = 34;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final c = q.color;

    return QPressable(
      onTap: onTap,
      radius: q.radius.full,
      semanticLabel: label,
      selected: selected,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: selected ? c.accentWash : c.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: selected ? c.accent : c.hairline,
              width: selected ? 1.5 : context.hairlineWidth,
            ),
            borderRadius: BorderRadius.all(Radius.circular(q.radius.full)),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: q.space.md + 2),
          child: SizedBox(
            height: height,
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                textScaler: context.structuralTextScaler,
                style: q.text.chipLabel.tinted(
                  selected ? c.accent : c.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
