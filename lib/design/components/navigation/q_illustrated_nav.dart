import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/surfaces/q_illustrated_surface.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/illustrated_theme.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Postcard tabs, comic panels, or a single floating dock. Destinations retain
/// their order and labels across collections so navigation stays familiar.
class QIllustratedNav extends StatelessWidget {
  const QIllustratedNav({
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final art = context.appTheme.art!;
    const labels = ['Today', 'Kin', 'Journal'];
    const glyphs = [QuietGlyph.sun, QuietGlyph.kinMark, QuietGlyph.journal];
    final separated = switch (art.style) {
      IllustrationStyle.postcard ||
      IllustrationStyle.comic ||
      IllustrationStyle.botanical ||
      IllustrationStyle.vintage => true,
      _ => false,
    };
    final row = Row(
      children: [
        for (var index = 0; index < 3; index++) ...[
          if (index > 0) SizedBox(width: separated ? 9 : 2),
          Expanded(
            child: QPressable(
              onTap: () => onSelected(index),
              semanticLabel: labels[index],
              semanticHint: 'Open ${labels[index]}',
              selected: selectedIndex == index,
              radius: art.corner,
              child: _NavPaper(
                separate: separated,
                selected: selectedIndex == index,
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                      horizontal: 3,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            QGlyphIcon(
                              glyphs[index],
                              size: 17,
                              color: selectedIndex == index
                                  ? art.accent
                                  : art.muted,
                            ),
                            const SizedBox(width: 7),
                            Flexible(
                              child: Text(
                                labels[index],
                                textScaler: context.structuralTextScaler,
                                maxLines: 1,
                                style: q.text.uiNavigation.copyWith(
                                  fontSize: 12,
                                  color: selectedIndex == index
                                      ? art.accent
                                      : art.muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: selectedIndex == index
                                ? art.accent
                                : art.muted.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: SizedBox(
                            height: 2,
                            width: selectedIndex == index ? 20 : 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
    final content = separated
        ? row
        : QIllustratedSurface(
            kind: IllustratedSurfaceKind.navigation,
            padding: const EdgeInsets.all(6),
            child: row,
          );
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(18, 8, 18, 12),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: q.layout.contentMaxWidth),
        child: content,
      ),
    );
  }
}

class _NavPaper extends StatelessWidget {
  const _NavPaper({
    required this.separate,
    required this.selected,
    required this.child,
  });
  final bool separate;
  final bool selected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (separate) {
      return QIllustratedSurface(
        kind: IllustratedSurfaceKind.navigation,
        child: child,
      );
    }
    final art = context.appTheme.art!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected
            ? art.accent.withValues(alpha: 0.10)
            : context.quiet.color.transparent,
        borderRadius: BorderRadius.circular(art.corner - 6),
      ),
      child: child,
    );
  }
}
