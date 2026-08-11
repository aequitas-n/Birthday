import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/surfaces/q_surface.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

class QSegmented extends StatelessWidget {
  const QSegmented({
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String>? onSelected;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final selectedIndex = options
        .indexOf(selected)
        .clamp(0, options.length - 1);
    final motion = q.motion;

    return LayoutBuilder(
      builder: (context, constraints) {
        final segmentWidth =
            (constraints.maxWidth - q.space.xs * 2) / options.length;

        return QSurface(
          level: QuietLevel.sunken,
          radius: q.radius.sm,
          padding: EdgeInsets.all(q.space.xs),
          height: 40,
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: motion.base,
                curve: motion.emphasized,
                left: q.space.xs + segmentWidth * selectedIndex,
                top: q.space.xs,
                bottom: q.space.xs,
                width: segmentWidth,
                child: QSurface(
                  radius: q.radius.xs,
                  elevation: QuietElevationLevel.hairline,
                  child: const SizedBox.expand(),
                ),
              ),
              Row(
                children: [
                  for (final option in options)
                    Expanded(
                      child: QPressable(
                        enabled: onSelected != null,
                        onTap: () => onSelected?.call(option),
                        radius: q.radius.xs,
                        semanticLabel: option,
                        selected: option == selected,
                        child: Center(
                          child: Text(
                            option,
                            textScaler: context.structuralTextScaler,
                            style: option == selected
                                ? q.text.buttonLabel.tinted(q.color.textPrimary)
                                : q.text.label.tinted(q.color.textSecondary),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
