import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/journal/q_animated_illustration.dart';
import 'package:kin/design/components/sheets/q_sheet.dart';
import 'package:kin/design/components/sheets/q_sheet_route.dart';
import 'package:kin/design/components/surfaces/q_illustrated_surface.dart';
import 'package:kin/design/theme/app_theme_definition.dart';
import 'package:kin/design/theme/product_theme_id.dart';
import 'package:kin/design/theme/product_themes.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

Future<ProductThemeId?> showQThemePicker({
  required BuildContext context,
  required ProductThemeId selected,
}) => showQSheet<ProductThemeId>(
  context: context,
  builder: (context) => QSheet(
    title: 'Make yourself at home',
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'A different little world for your everyday.',
            style: context.quiet.text.uiBody.copyWith(
              color: context.quiet.interactive.inkSecondary,
            ),
          ),
          const SizedBox(height: 22),
          for (final theme in ProductThemes.all) ...[
            _ThemePreview(
              theme: theme,
              selected: selected == theme.id,
              onTap: () => Navigator.of(context).pop(theme.id),
            ),
            const SizedBox(height: 18),
          ],
        ],
      ),
    ),
  ),
);

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({
    required this.theme,
    required this.selected,
    required this.onTap,
  });
  final AppThemeDefinition theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final art = theme.art;
    final q = theme.quiet;
    return QPressable(
      onTap: onTap,
      selected: selected,
      semanticLabel: theme.label,
      semanticHint: 'Use this theme',
      radius: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DecoratedBox(
          decoration: BoxDecoration(color: q.color.canvas),
          child: Stack(
            children: [
              if (art != null)
                Positioned.fill(
                  child: Image.asset(
                    art.background,
                    fit: BoxFit.cover,
                    cacheWidth: 700,
                    excludeFromSemantics: true,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            theme.label,
                            style: q.text.sectionTitle.copyWith(
                              color: q.color.textPrimary,
                              fontSize: 22,
                            ),
                          ),
                        ),
                        if (selected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: q.color.accent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Current',
                              style: q.text.uiMetadata.copyWith(
                                color: q.color.textInverse,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (art != null)
                      QIllustratedSurface(
                        art: art,
                        padding: const EdgeInsets.fromLTRB(15, 12, 10, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    art.invitation,
                                    style: q.text.sectionTitle.copyWith(
                                      color: art.ink,
                                      fontSize:
                                          q.text.sectionTitle.fontSize! * 0.9,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'A little moment, worth keeping.',
                                    style: q.text.journalWriting.copyWith(
                                      color: art.muted,
                                      fontSize:
                                          q.text.journalWriting.fontSize! * 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            QAnimatedIllustration(
                              asset: art.atlas,
                              size: 78,
                              animate: selected,
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      art?.description ??
                          'Warm paper, beautiful type, room to breathe.',
                      style: q.text.uiBody.copyWith(
                        color: q.color.textSecondary,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
