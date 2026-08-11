import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/app/theme_controller.dart';
import 'package:kin/design/components/buttons/q_icon_button.dart';
import 'package:kin/design/components/controls/q_collection_picker.dart';
import 'package:kin/design/components/controls/q_segmented.dart';
import 'package:kin/design/components/controls/q_toggle.dart';
import 'package:kin/design/components/rows/q_section_title.dart';
import 'package:kin/design/components/rows/q_setting_row.dart';
import 'package:kin/design/components/surfaces/q_hairline.dart';
import 'package:kin/design/components/surfaces/q_screen.dart';
import 'package:kin/design/components/text/q_voice.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/domain/models/settings.dart';
import 'package:kin/notifications/application/notification_coordinator.dart';
import 'package:kin/notifications/notification_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = context.quiet;
    final settings = ref
        .watch(appSettingsProvider)
        .maybeWhen(
          data: (value) => value,
          orElse: () => ref.watch(initialAppSettingsProvider),
        );
    final notificationStatus = ref.watch(notificationStatusProvider);
    final theme = ref.watch(themePreferenceProvider);

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
                SizedBox(width: q.space.xs),
                Expanded(
                  child: QVoice(
                    'Settings',
                    style: q.text.voiceLg.tinted(q.color.textPrimary),
                  ),
                ),
              ],
            ),
            const QSectionTitle(
              'Collections',
              support: 'Each one changes the paper, not just the accent.',
              isFirst: true,
            ),
            QCollectionPicker(
              selected: theme.collection,
              onSelected: (collection) => ref
                  .read(themePreferenceProvider.notifier)
                  .setCollection(collection),
            ),
            const QSectionTitle('Appearance'),
            QSegmented(
              options: const ['System', 'Light', 'Dark'],
              selected: switch (theme.choice) {
                ThemeChoice.system => 'System',
                ThemeChoice.light => 'Light',
                ThemeChoice.dark => 'Dark',
              },
              onSelected: (value) {
                final choice = switch (value) {
                  'Light' => ThemeChoice.light,
                  'Dark' => ThemeChoice.dark,
                  _ => ThemeChoice.system,
                };
                ref.read(themePreferenceProvider.notifier).setChoice(choice);
              },
            ),
            SizedBox(height: q.space.base),
            if (theme.choice != ThemeChoice.light) ...[
              QSettingRow(
                label: 'Pure black',
                subtitle: 'Only in dark mode.',
                trailing: QToggle(
                  value: theme.amoled,
                  onChanged: (value) {
                    ref
                        .read(themePreferenceProvider.notifier)
                        .setAmoled(enabled: value);
                  },
                ),
              ),
              const QHairline(),
            ],
            const QSectionTitle('Privacy'),
            QSettingRow(
              label: 'Show details on lock screen',
              subtitle:
                  'Remembered details stay visible in notifications later.',
              trailing: QToggle(
                value: settings.showDetailsOnLockScreen,
                onChanged: (value) => _updateSettings(
                  ref,
                  settings.copyWith(showDetailsOnLockScreen: value),
                ),
              ),
            ),
            const QHairline(),
            const QSectionTitle('Reminders'),
            QSettingRow(
              label: 'Birthday reminders',
              subtitle: notificationStatus.maybeWhen(
                data: _reminderSummary,
                orElse: () => 'Quiet reminders when Android allows them.',
              ),
              trailing: QToggle(
                value: settings.notificationsEnabled,
                onChanged: (value) =>
                    _setNotificationsEnabled(ref, value: value),
              ),
            ),
            const QHairline(),
            QSettingRow(
              label: 'Notification permission',
              subtitle:
                  'Android 13 and later may ask before showing reminders.',
              value: notificationStatus.maybeWhen(
                data: (value) => _permissionLabel(value.notificationPermission),
                orElse: () => 'Checking',
              ),
              showChevron: true,
              onTap: () => _reviewNotificationPermission(ref),
            ),
            const QHairline(),
            QSettingRow(
              label: 'Exact birthday timing',
              subtitle:
                  'If unavailable, Kin still reminds you with softer timing.',
              value: notificationStatus.maybeWhen(
                data: (value) => _permissionLabel(value.exactAlarmPermission),
                orElse: () => 'Checking',
              ),
              showChevron: true,
              onTap: () => _reviewExactAlarms(ref),
            ),
            const QHairline(),
            QSettingRow(
              label: 'Design gallery',
              subtitle: 'Review the Quiet system in isolation.',
              showChevron: true,
              onTap: () => context.push('/gallery'),
            ),
            const QHairline(),
            if (kDebugMode) ...[
              QSettingRow(
                label: 'Notification inspector',
                subtitle: 'Internal RC1 diagnostics.',
                showChevron: true,
                onTap: () => context.push('/debug/notifications'),
              ),
              const QHairline(),
            ],
            const QSettingRow(label: 'Version', value: '0.1.0+1'),
          ],
        ),
      ),
    );
  }

  Future<void> _updateSettings(WidgetRef ref, AppSettings settings) {
    return ref.read(settingsRepositoryProvider).saveSettings(settings);
  }

  Future<void> _setNotificationsEnabled(
    WidgetRef ref, {
    required bool value,
  }) async {
    final coordinator = ref.read(notificationCoordinatorProvider);
    await coordinator.setNotificationsEnabled(value: value);
    if (value) {
      await coordinator.requestNotificationPermission();
      await coordinator.requestExactAlarmPermission();
    }
    await coordinator.synchronize();
    ref
      ..invalidate(notificationStatusProvider)
      ..invalidate(appSettingsProvider);
  }

  Future<void> _reviewNotificationPermission(WidgetRef ref) async {
    final coordinator = ref.read(notificationCoordinatorProvider);
    final result = await coordinator.requestNotificationPermission();
    if (result == AndroidCapabilityState.denied) {
      await coordinator.openNotificationSettings();
    }
    ref.invalidate(notificationStatusProvider);
  }

  Future<void> _reviewExactAlarms(WidgetRef ref) async {
    final coordinator = ref.read(notificationCoordinatorProvider);
    final result = await coordinator.requestExactAlarmPermission();
    if (result == AndroidCapabilityState.denied) {
      await coordinator.openExactAlarmSettings();
    }
    ref.invalidate(notificationStatusProvider);
  }

  String _reminderSummary(NotificationRuntimeStatus status) {
    if (!status.notificationsEnabled) {
      return 'Off until you choose otherwise.';
    }
    final permission = _permissionLabel(status.notificationPermission);
    final exact = _permissionLabel(status.exactAlarmPermission);
    return 'Notifications: $permission. Exact timing: $exact.';
  }

  String _permissionLabel(AndroidCapabilityState state) {
    return switch (state) {
      AndroidCapabilityState.granted => 'Allowed',
      AndroidCapabilityState.denied => 'Needs review',
      AndroidCapabilityState.notRequired => 'Not needed',
    };
  }
}
