import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/app/desktop/desktop_phone_shell.dart';
import 'package:kin/app/kin_app.dart';
import 'package:kin/app/phase5_diag.dart';
import 'package:kin/app/phase6_diag.dart';
import 'package:kin/app/phase7_diag.dart';
import 'package:kin/app/theme_controller.dart';
import 'package:kin/data/local/database/kin_database.dart';
import 'package:kin/data/local/files/image_store.dart';
import 'package:kin/data/repositories/settings_repository_drift.dart';
import 'package:kin/notifications/application/notification_coordinator.dart';
import 'package:kin/notifications/flutter_local_notification_service.dart';
import 'package:kin/notifications/notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

/// Matches Android `launch_background` (white) so the first Flutter frame does
/// not flash a different color while Drift/settings finish opening.
const Color _bootstrapCanvas = Color(0xFFFFFFFF);

Future<void> bootstrap() async {
  Phase5Diag.ensureBoot();
  Phase6Diag.ensureBoot();
  Phase5Diag.mark('ensureInitialized_begin');
  Phase6Diag.mark('ensureInitialized_begin');
  WidgetsFlutterBinding.ensureInitialized();
  Phase6Diag.attachAfterBinding();
  Phase7Diag.install();
  Phase5Diag.mark('ensureInitialized_done');
  Phase6Diag.mark('ensureInitialized_done');
  Phase7Diag.mark('ensureInitialized_done');
  await configureDesktopPhoneShell();
  Phase5Diag.mark('desktopShell_done');
  Phase6Diag.mark('desktopShell_done');

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    Zone.current.handleUncaughtError(error, stack);
    return true;
  };

  // Paint immediately. Heavy Drift/settings work continues after the first
  // frame so the event loop can produce frames while NativeDatabase opens on
  // its background isolate (see KinDatabase._openConnection).
  runApp(const _BootstrapApp());
  Phase5Diag.mark('runApp');
  Phase6Diag.mark('runApp');
}

class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp();

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  ProviderContainer? _container;
  late final Future<void> _timezonePrewarm;

  @override
  void initState() {
    super.initState();
    // Phase 5: pay timezone DB load on the white bootstrap canvas after the
    // first frame, overlapping Drift/settings — not during KinApp/Today paint.
    final tzCompleter = Completer<void>();
    _timezonePrewarm = tzCompleter.future;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Phase5Diag.mark('firstFlutterFrame');
      Phase6Diag.onFirstFlutterFrame();
      if (wantsDesktopPhoneShell) {
        tzCompleter.complete();
        return;
      }
      Phase5Diag.mark('tzPrewarm_begin');
      Phase6Diag.mark('tzPrewarm_begin');
      final sw = Stopwatch()..start();
      tzdata.initializeTimeZones();
      Phase5Diag.mark('tzPrewarm_done_${sw.elapsedMilliseconds}ms');
      Phase6Diag.mark('tzPrewarm_done_${sw.elapsedMilliseconds}ms');
      tzCompleter.complete();
    });
    unawaited(_open());
  }

  Future<void> _open() async {
    Phase5Diag.mark('settingsOpen_begin');
    Phase6Diag.mark('settingsOpen_begin');
    final database = KinDatabase();
    final settingsRepository = DriftSettingsRepository(database);
    final initialSettings = await settingsRepository.readSettings();
    Phase5Diag.mark('settingsOpen_done');
    Phase6Diag.mark('settingsOpen_done');
    Phase6Diag.onSettingsDone();
    final initialTheme = ThemePreference.fromSettings(initialSettings);

    await _timezonePrewarm;

    final notificationService = wantsDesktopPhoneShell
        ? const NoopNotificationService()
        : FlutterLocalNotificationService(initializeTimeZones: false);

    final container = ProviderContainer(
      overrides: [
        kinDatabaseProvider.overrideWithValue(database),
        imageStoreProvider.overrideWithValue(const LocalImageStore()),
        initialAppSettingsProvider.overrideWithValue(initialSettings),
        initialThemePreferenceProvider.overrideWithValue(initialTheme),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
    );

    // Phase 5: finish cold-start notification initialize + synchronizeStartup on
    // the white canvas. KinApp/Today then mount without that UI-isolate hitch.
    if (notificationService is! NoopNotificationService) {
      Phase5Diag.mark('notifColdStart_begin');
      Phase6Diag.mark('notifColdStart_begin');
      final coordinator = container.read(notificationCoordinatorProvider);
      final coldSw = Stopwatch()..start();
      final initSw = Stopwatch()..start();
      await coordinator.initialize();
      Phase6Diag.mark('notifInitialize_done_${initSw.elapsedMilliseconds}ms');
      final syncSw = Stopwatch()..start();
      await coordinator.synchronizeStartup();
      Phase6Diag.mark('notifSyncStartup_done_${syncSw.elapsedMilliseconds}ms');
      Phase5Diag.mark(
        'notifColdStart_done_${coldSw.elapsedMilliseconds}ms',
      );
      Phase6Diag.mark('notifColdStart_done_${coldSw.elapsedMilliseconds}ms');
    }

    if (!mounted) {
      container.dispose();
      await database.close();
      return;
    }

    Phase5Diag.watchExpensiveFrames();
    Phase5Diag.markImageCache('appReady_beforeKinApp');
    Phase6Diag.onBeforeKinApp();
    Phase5Diag.mark('appReady_setState_begin');
    Phase6Diag.mark('appReady_setState_begin');
    Phase7Diag.mark('appReady');
    setState(() {
      _container = container;
    });
    Phase5Diag.mark('appReady_setState_end');
    Phase6Diag.mark('appReady_setState_end');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Phase5Diag.mark('kinApp_firstFrame');
      Phase5Diag.markImageCache('kinApp_firstFrame');
      Phase6Diag.mark('kinApp_firstFrame');
      Phase6Diag.markImageCache('kinApp_firstFrame');
      Phase7Diag.mark('kinApp_firstFrame');
    });
  }

  @override
  void dispose() {
    _container?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final container = _container;
    if (container == null) {
      return const ColoredBox(color: _bootstrapCanvas);
    }
    return UncontrolledProviderScope(
      container: container,
      child: const KinApp(),
    );
  }
}
