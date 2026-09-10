import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/navigation/q_diary_chrome_strip.dart';
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

/// Custom bottom navigation on the product-theme chrome strip.
///
/// Labels only: no icons. The underline carries selection.
/// Theme [AppThemeChrome.navStrip] may supply artwork; otherwise a solid bar.
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

    return QDiaryChromeStrip(
      safeBottom: true,
      padding: EdgeInsets.symmetric(horizontal: q.space.sm),
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
    final nav = q.navigation;
    final color = selected ? nav.inkActive : nav.inkInactive;

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
                  ? q.text.uiNavigation.tinted(color)
                  : q.text.tab.tinted(color),
            ),
            SizedBox(height: q.space.hair),
            AnimatedOpacity(
              duration: q.motion.base,
              opacity: selected ? 1 : 0,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: nav.indicator,
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
