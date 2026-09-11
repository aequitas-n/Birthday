import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// A wrapping row of selectable vintage labels.
///
/// Used for note kinds and relationship. On parchment sheets they read as
/// small archival tags — not Material pills.
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
    final i = q.interactive;
    final onParchment = context.isParchmentControls;

    final Color fill;
    final Color border;
    final Color ink;
    if (onParchment) {
      fill = selected ? i.accent : i.input;
      border = selected ? i.accent : i.inputBorder;
      // Ink on solid accent — never primaryAction (same hue as the fill on Neon).
      ink = selected ? i.primaryActionInk : i.ink;
    } else {
      fill = selected ? c.accentWash : c.surface;
      border = selected ? c.accent : c.hairline;
      ink = selected ? c.accent : c.textSecondary;
    }

    return QPressable(
      onTap: onTap,
      radius: q.radius.sm,
      semanticLabel: label,
      selected: selected,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: fill,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: border,
              width: selected ? 1.5 : context.hairlineWidth,
            ),
            borderRadius: BorderRadius.all(Radius.circular(q.radius.sm)),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: q.space.md),
          child: SizedBox(
            height: height,
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                textScaler: context.structuralTextScaler,
                style: q.text.chipLabel.tinted(ink),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
