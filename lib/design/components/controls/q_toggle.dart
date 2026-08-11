import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/surfaces/q_surface.dart';
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
    final enabled = onChanged != null;
    final motion = q.motion;

    final trackColor = value ? q.color.accent : q.color.sunken;
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
              shape: const StadiumBorder(),
            ),
            child: AnimatedAlign(
              duration: motion.base,
              curve: motion.emphasized,
              alignment: thumbAlignment,
              child: QSurface(
                width: _thumb,
                height: _thumb,
                radius: q.radius.full,
                elevation: QuietElevationLevel.hairline,
                child: const SizedBox.square(dimension: _thumb),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
