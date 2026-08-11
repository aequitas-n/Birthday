import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/app/theme_controller.dart';
import 'package:kin/design/components/buttons/q_button.dart';
import 'package:kin/design/components/feedback/q_empty_state.dart';
import 'package:kin/design/components/rows/q_section_header.dart';
import 'package:kin/design/components/surfaces/q_screen.dart';
import 'package:kin/design/components/surfaces/q_surface.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

class FoundationScreen extends ConsumerWidget {
  const FoundationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = context.quiet;
    final theme = ref.watch(themePreferenceProvider);
    final settings = ref.watch(appSettingsProvider);

    return QScreen(
      child: QMeasure(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            q.space.lg,
            q.space.xl,
            q.space.lg,
            q.space.xl,
          ),
          children: [
            Text('Kin', style: q.text.voiceLg.tinted(q.color.textPrimary)),
            SizedBox(height: q.space.sm),
            Text(
              'Phase 2 foundation is live. Routing, persistence, the database, '
              'repositories, and the application shell are in place. Product '
              'screens still wait for Phase 4.',
              style: q.text.body.tinted(q.color.textSecondary),
            ),
            const QSectionHeader('Current shell', isFirst: true),
            QSurface(
              radius: q.radius.lg,
              elevation: QuietElevationLevel.hairline,
              padding: EdgeInsets.all(q.space.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _KeyValueRow(
                    label: 'Appearance',
                    value:
                        '${theme.choice.name}${theme.amoled ? ' + AMOLED' : ''}',
                  ),
                  SizedBox(height: q.space.base),
                  const _KeyValueRow(
                    label: 'Database',
                    value: 'Drift schema v1 ready',
                  ),
                  SizedBox(height: q.space.base),
                  const _KeyValueRow(label: 'Routing', value: '/ and /gallery'),
                  if (settings.hasValue) ...[
                    SizedBox(height: q.space.base),
                    _KeyValueRow(
                      label: 'Privacy',
                      value: settings.requireValue.showDetailsOnLockScreen
                          ? 'Lock-screen details on'
                          : 'Lock-screen details off',
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: q.space.section),
            QEmptyState(
              headline: 'Product screens start in Phase 4.',
              support:
                  'The gallery remains available for design review while the '
                  'data foundation settles underneath it.',
              action: QButton.primary(
                label: 'Open Gallery',
                onPressed: () => context.go('/gallery'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: q.text.eyebrow.tinted(q.color.textTertiary),
        ),
        SizedBox(height: q.space.xs),
        Text(value, style: q.text.body.tinted(q.color.textPrimary)),
      ],
    );
  }
}
