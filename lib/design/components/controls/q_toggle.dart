import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

class QToggle extends StatelessWidget {
  const QToggle({
    required this.value,
    required this.onChanged,
    this.semanticLabel,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  static const double _width = 46;
  static const double _height = 28;
  static const double _thumb = 24;
  static const double _padding = 2;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final i = q.interactive;
    final enabled = onChanged != null;
    final motion = q.motion;

    // Cream parchment track + ink/burgundy thumb — never submerged brown-on-brown.
    final trackColor = value ? i.toggleTrackOn : i.toggleTrackOff;
    final thumbColor = value ? i.toggleThumbOn : i.toggleThumbOff;
    final thumbAlignment = value ? Alignment.centerRight : Alignment.centerLeft;

    return Opacity(
      opacity: enabled ? 1 : 0.38,
      child: SizedBox(
        width: _width,
        height: _height,
        child: QPressable(
          enabled: enabled,
          onTap: enabled ? () => onChanged?.call(!value) : null,
          radius: q.radius.full,
          semanticLabel: semanticLabel,
          child: AnimatedContainer(
            duration: motion.base,
            curve: motion.emphasized,
            padding: const EdgeInsets.all(_padding),
            decoration: ShapeDecoration(
              color: trackColor,
              shape: StadiumBorder(
                side: BorderSide(
                  color: i.sheetBorder,
                  width: context.hairlineWidth,
                ),
              ),
            ),
            child: AnimatedAlign(
              duration: motion.base,
              curve: motion.emphasized,
              alignment: thumbAlignment,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: thumbColor,
                  shape: const CircleBorder(),
                  shadows: q.elevation.lift,
                ),
                child: const SizedBox.square(dimension: _thumb),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
