import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/design/components/buttons/q_icon_button.dart';
import 'package:kin/design/components/rows/q_section_header.dart';
import 'package:kin/design/components/rows/q_setting_row.dart';
import 'package:kin/design/components/surfaces/q_hairline.dart';
import 'package:kin/design/components/surfaces/q_screen.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/notifications/application/notification_coordinator.dart';

class NotificationDebugScreen extends ConsumerWidget {
  const NotificationDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = context.quiet;
    final snapshot = ref.watch(notificationDebugSnapshotProvider);

    return QScreen(
      child: QMeasure(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            context.gutter,
            q.space.base,
            context.gutter,
            q.space.emptiness,
          ),
          children: [
            Row(
              children: [
                QIconButton(
                  glyph: QuietGlyph.chevronLeft,
                  onPressed: () => context.pop(),
                  semanticLabel: 'Back',
                ),
                SizedBox(width: q.space.sm),
                Expanded(
                  child: Text(
                    'Notification Inspector',
                    style: q.text.pageTitle.tinted(q.color.textPrimary),
                  ),
                ),
              ],
            ),
            SizedBox(height: q.space.base),
            snapshot.when(
              data: (data) => _Body(snapshot: data),
              loading: () => Text(
                'Loading debug state…',
                style: q.text.body.tinted(q.color.textSecondary),
              ),
              error: (error, stackTrace) => Text(
                'Debug state unavailable: $error',
                style: q.text.body.tinted(q.color.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.snapshot});

  final NotificationDebugSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const QSectionHeader('Runtime', isFirst: true),
        QSettingRow(
          label: 'Current timezone',
          value: snapshot.status.deviceTimeZone,
        ),
        const QHairline(),
        QSettingRow(
          label: 'Pending on Android',
          value: '${snapshot.pending.length}',
        ),
        const QHairline(),
        QSettingRow(
          label: 'Planned in Drift',
          value: '${snapshot.scheduled.length}',
        ),
        const QHairline(),
        QSettingRow(
          label: 'Desired plans',
          value: '${snapshot.desiredPlans.length}',
        ),
        const QHairline(),
        QSettingRow(
          label: 'Last reconciled',
          value: _stamp(snapshot.status.lastReconciledAt),
        ),
        const QSectionHeader('Pending Payloads'),
        if (snapshot.pending.isEmpty)
          Text(
            'Nothing pending at the platform level.',
            style: q.text.body.tinted(q.color.textSecondary),
          )
        else
          for (final item in snapshot.pending) ...[
            Text(
              '#${item.id} · ${item.title ?? 'Untitled'}',
              style: q.text.label.tinted(q.color.textPrimary),
            ),
            SizedBox(height: q.space.hair),
            Text(
              item.payload ?? 'No payload',
              style: q.text.caption.tinted(q.color.textTertiary),
            ),
            SizedBox(height: q.space.base),
          ],
        const QSectionHeader('Planner Output'),
        if (snapshot.desiredPlans.isEmpty)
          Text(
            'No reminders are currently desired.',
            style: q.text.body.tinted(q.color.textSecondary),
          )
        else
          for (final plan in snapshot.desiredPlans.take(12)) ...[
            Text(
              '${plan.source.storageValue} · ${plan.personId ?? plan.reminderId} · ${plan.ruleId ?? ''}',
              style: q.text.label.tinted(q.color.textPrimary),
            ),
            SizedBox(height: q.space.hair),
            Text(
              '${_stamp(plan.fireAtUtc)} UTC · ${plan.targetLocalInstant.timeZone}',
              style: q.text.caption.tinted(q.color.textTertiary),
            ),
            SizedBox(height: q.space.base),
          ],
        const QSectionHeader('Next Occurrences'),
        if (snapshot.people.isEmpty)
          Text(
            'No people are available for planner diagnostics.',
            style: q.text.body.tinted(q.color.textSecondary),
          )
        else
          for (final person in snapshot.people.take(12)) ...[
            Text(
              person.displayName,
              style: q.text.label.tinted(q.color.textPrimary),
            ),
            SizedBox(height: q.space.hair),
            Text(
              'Anchor ${_stamp(person.occurrence.anchorUtc)} UTC · '
              '${person.plans.length} reminder(s)',
              style: q.text.caption.tinted(q.color.textTertiary),
            ),
            SizedBox(height: q.space.base),
          ],
      ],
    );
  }

  String _stamp(DateTime? value) {
    if (value == null) {
      return 'Never';
    }
    return value.toLocal().toIso8601String();
  }
}
