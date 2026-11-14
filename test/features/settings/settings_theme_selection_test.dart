import 'dart:async';

import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/app/theme_controller.dart';
import 'package:kin/design/theme/material_shim.dart';
import 'package:kin/design/theme/product_theme_id.dart';
import 'package:kin/design/theme/product_themes.dart';
import 'package:kin/domain/models/settings.dart';
import 'package:kin/domain/repositories/settings_repository.dart';
import 'package:kin/features/settings/presentation/settings_screen.dart';
import 'package:kin/notifications/application/notification_coordinator.dart';
import 'package:kin/notifications/notification_service.dart';

import '../../support/quiet_test_app.dart';

void main() {
  setUpAll(loadQuietFonts);

  testWidgets('Settings Theme row reflects and persists product theme', (
    tester,
  ) async {
    final repo = _MemorySettingsRepository(
      initial: const AppSettings(),
    );
    addTearDown(repo.dispose);

    final container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(repo),
        appSettingsProvider.overrideWith((ref) => repo.watchSettings()),
        initialAppSettingsProvider.overrideWithValue(repo.current),
        initialThemePreferenceProvider.overrideWithValue(
          ThemePreference.fromSettings(repo.current),
        ),
        notificationStatusProvider.overrideWith(
          (ref) async => const NotificationRuntimeStatus(
            notificationsEnabled: false,
            notificationPermission: AndroidCapabilityState.granted,
            exactAlarmPermission: AndroidCapabilityState.granted,
            deviceTimeZone: 'Asia/Kolkata',
            pendingCount: 0,
            plannedCount: 0,
            lastReconciledAt: null,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(themePreferenceProvider, (_, _) {});

    Future<void> pumpSettings() async {
      final preference = container.read(themePreferenceProvider);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: buildMaterialShim(
              preference.definition.quiet,
              appTheme: preference.definition,
            ),
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump();
    }

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpSettings();
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Default'), findsWidgets);
    expect(hasVintageDiaryAsset(collectAssetImagePaths(tester)), isFalse);

    await container
        .read(themePreferenceProvider.notifier)
        .setProductTheme(ProductThemeId.vintageDiary);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));

    expect(
      container.read(themePreferenceProvider).productThemeId,
      ProductThemeId.vintageDiary,
    );
    await pumpSettings();

    expect(find.text('Vintage Diary'), findsWidgets);
    expect(repo.current.productThemeId, ProductThemeId.vintageDiary);
    expect(
      container.read(themePreferenceProvider).definition.assets.backgrounds.app,
      isNotNull,
    );

    await container
        .read(themePreferenceProvider.notifier)
        .setProductTheme(ProductThemeId.quietDefault);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));

    expect(
      container.read(themePreferenceProvider).productThemeId,
      ProductThemeId.quietDefault,
    );
    await pumpSettings();

    expect(find.text('Default'), findsWidgets);
    expect(repo.current.productThemeId, ProductThemeId.quietDefault);
    expect(
      container.read(themePreferenceProvider).definition.assets,
      ProductThemes.quietDefault.assets,
    );
    expect(hasVintageDiaryAsset(collectAssetImagePaths(tester)), isFalse);
  });
}

class _MemorySettingsRepository implements SettingsRepository {
  _MemorySettingsRepository({required AppSettings initial})
    : _settings = initial,
      _controller = StreamController<AppSettings>.broadcast() {
    _controller.add(_settings);
  }

  AppSettings _settings;
  final StreamController<AppSettings> _controller;

  AppSettings get current => _settings;

  void dispose() => _controller.close();

  @override
  Future<AppSettings> readSettings() async => _settings;

  @override
  Future<void> saveAppearance({
    required StoredThemeMode mode,
    required bool amoled,
  }) async {
    _settings = _settings.copyWith(themeMode: mode, amoled: amoled);
    _controller.add(_settings);
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _settings = settings;
    _controller.add(_settings);
  }

  @override
  Stream<AppSettings> watchSettings() async* {
    yield _settings;
    yield* _controller.stream;
  }
}
