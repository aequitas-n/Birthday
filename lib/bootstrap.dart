import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/app/desktop/desktop_phone_shell.dart';
import 'package:kin/app/kin_app.dart';
import 'package:kin/app/theme_controller.dart';
import 'package:kin/data/local/database/kin_database.dart';
import 'package:kin/data/local/files/image_store.dart';
import 'package:kin/data/repositories/settings_repository_drift.dart';
import 'package:kin/notifications/flutter_local_notification_service.dart';
import 'package:kin/notifications/notification_service.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDesktopPhoneShell();

  final database = KinDatabase();
  final settingsRepository = DriftSettingsRepository(database);
  final initialSettings = await settingsRepository.readSettings();
  final initialTheme = ThemePreference.fromSettings(initialSettings);
  // Desktop/web phone preview skips OS notification plugins.
  final notificationService = wantsDesktopPhoneShell
      ? const NoopNotificationService()
      : FlutterLocalNotificationService();
  await notificationService.initialize();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    Zone.current.handleUncaughtError(error, stack);
    return true;
  };

  runApp(
    ProviderScope(
      overrides: [
        kinDatabaseProvider.overrideWithValue(database),
        imageStoreProvider.overrideWithValue(const LocalImageStore()),
        initialAppSettingsProvider.overrideWithValue(initialSettings),
        initialThemePreferenceProvider.overrideWithValue(initialTheme),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const KinApp(),
    ),
  );
}
