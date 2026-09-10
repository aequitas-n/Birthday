import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/app/place_picker_sheet.dart';
import 'package:kin/app/theme_controller.dart';
import 'package:kin/data/timezone/city_dataset.dart';
import 'package:kin/design/components/buttons/q_icon_button.dart';
import 'package:kin/design/components/controls/q_toggle.dart';
import 'package:kin/design/components/rows/q_section_title.dart';
import 'package:kin/design/components/rows/q_setting_row.dart';
import 'package:kin/design/components/sheets/q_choice_sheet.dart';
import 'package:kin/design/components/surfaces/q_hairline.dart';
import 'package:kin/design/components/surfaces/q_screen.dart';
import 'package:kin/design/components/text/q_voice.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/product_theme_id.dart';
import 'package:kin/design/theme/product_themes.dart';
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
    final themes = ProductThemes.all;
    final selectedThemeIndex = themes.indexWhere(
      (theme) => theme.id == settings.productThemeId,
    );

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
                    style: q.text.pageTitle.tinted(q.color.textPrimary),
                  ),
                ),
              ],
            ),
            const QSectionTitle(
              'Appearance',
              support: 'Choose how Kin looks across the whole app.',
              isFirst: true,
            ),
            QSettingRow(
              label: 'Theme',
              subtitle: settings.productThemeId.label,
              showChevron: true,
              onTap: () => _pickProductTheme(
                context,
                ref,
                selectedIndex: selectedThemeIndex < 0 ? 0 : selectedThemeIndex,
              ),
            ),
            const QHairline(),
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
              label: 'Reminder timezone',
              subtitle:
                  'Personal reminders fire in this zone — not the birthday one.',
              value: _reminderTimezoneLabel(settings),
              showChevron: true,
              onTap: () => _pickReminderTimezone(context, ref, settings),
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
              label: 'Exact reminder timing',
              subtitle:
                  'Needed for on-the-minute reminders. Without it, Android may fire a few minutes early or late.',
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

  Future<void> _pickProductTheme(
    BuildContext context,
    WidgetRef ref, {
    required int selectedIndex,
  }) async {
    final themes = ProductThemes.all;
    final index = await showQChoiceSheet(
      context: context,
      title: 'Theme',
      selectedIndex: selectedIndex,
      choices: [
        for (final theme in themes)
          QChoice(
            theme.label,
            support: switch (theme.id) {
              ProductThemeId.quietDefault => 'Warm paper, black ink, no decoration.',
              ProductThemeId.vintageDiary =>
                'Aged parchment journal on a dark desk.',
            },
          ),
      ],
    );
    if (index == null || !context.mounted) return;
    await ref
        .read(themePreferenceProvider.notifier)
        .setProductTheme(themes[index].id);
  }

  String _reminderTimezoneLabel(AppSettings settings) {
    final iana = settings.reminderTimezone;
    if (iana == null || iana.isEmpty) return 'Same as this phone';
    for (final city in cityDataset) {
      if (city.ianaTimezone == iana) return city.city;
    }
    return iana;
  }

  Future<void> _pickReminderTimezone(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) async {
    final city = await showPlacePickerSheet(context: context);
    if (city == null) return;
    final updated = settings.copyWith(reminderTimezone: city.ianaTimezone);
    await ref.read(settingsRepositoryProvider).saveSettings(updated);
    await ref
        .read(personalReminderRepositoryProvider)
        .updateTimezoneForAllLive(city.ianaTimezone);
    try {
      await ref.read(notificationCoordinatorProvider).synchronize();
    } on Object {
      // Scheduling is best-effort while wiring lands.
    }
    ref.invalidate(appSettingsProvider);
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
