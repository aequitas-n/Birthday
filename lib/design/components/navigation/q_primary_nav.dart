import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Primary app destinations — Today, Kin, and Journal.
enum PrimaryDestination {
  today('Today'),
  kin('Kin'),
  journal('Journal')
  ;

  const PrimaryDestination(this.label);

  final String label;
}

/// Custom bottom navigation — quiet, editorial, not Material stock chrome.
///
/// Labels only: no icons. The underline carries selection.
class QPrimaryNav extends StatelessWidget {
  const QPrimaryNav({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final PrimaryDestination selected;
  final ValueChanged<PrimaryDestination> onSelected;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: q.color.surface,
        border: Border(
          top: BorderSide(
            color: q.color.hairline,
            width: context.hairlineWidth,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: q.layout.minTouchTarget,
          child: Row(
            children: [
              for (final destination in PrimaryDestination.values)
                Expanded(
                  child: _NavItem(
                    destination: destination,
                    selected: destination == selected,
                    onTap: () => onSelected(destination),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final PrimaryDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final color = selected ? q.color.textPrimary : q.color.textTertiary;

    return QPressable(
      onTap: onTap,
      radius: q.radius.md,
      semanticLabel: destination.label,
      selected: selected,
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              destination.label,
              textScaler: context.structuralTextScaler,
              style: selected
                  ? q.text.buttonLabel.tinted(color)
                  : q.text.metadata.tinted(color),
            ),
            SizedBox(height: q.space.hair),
            AnimatedOpacity(
              duration: q.motion.base,
              opacity: selected ? 1 : 0,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: q.color.accent,
                  shape: const StadiumBorder(),
                ),
                child: const SizedBox(width: 16, height: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
