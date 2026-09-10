import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/app/theme_controller.dart';
import 'package:kin/data/local/database/kin_database.dart';
import 'package:kin/data/repositories/settings_repository_drift.dart';
import 'package:kin/design/theme/product_theme_id.dart';
import 'package:kin/design/theme/quiet_collection.dart';
import 'package:kin/design/tokens/vintage_diary_tokens.dart';

void main() {
  group('runtime theme switching', () {
    late KinDatabase database;
    late DriftSettingsRepository repository;
    late ProviderContainer container;

    setUp(() async {
      database = KinDatabase(NativeDatabase.memory());
      repository = DriftSettingsRepository(database);
      final initial = await repository.readSettings();
      container = ProviderContainer(
        overrides: [
          kinDatabaseProvider.overrideWithValue(database),
          settingsRepositoryProvider.overrideWithValue(repository),
          initialAppSettingsProvider.overrideWithValue(initial),
          initialThemePreferenceProvider.overrideWithValue(
            ThemePreference.fromSettings(initial),
          ),
        ],
      );
      // Keep providers alive so stream updates rebuild the notifier.
      container.listen(themePreferenceProvider, (_, __) {});
    });

    tearDown(() async {
      container.dispose();
      await database.close();
    });

    Future<void> waitForTheme(ProductThemeId id) async {
      if (container.read(themePreferenceProvider).productThemeId == id) {
        return;
      }
      final completer = Completer<void>();
      final sub = container.listen(themePreferenceProvider, (_, next) {
        if (next.productThemeId == id && !completer.isCompleted) {
          completer.complete();
        }
      });
      await completer.future.timeout(const Duration(seconds: 2));
      sub.close();
    }

    test('Default → Vintage → Default isolates assets and typefaces', () async {
      expect(
        container.read(themePreferenceProvider).productThemeId,
        ProductThemeId.quietDefault,
      );
      expect(
        container.read(themePreferenceProvider).definition.assets.backgrounds.app,
        isNull,
      );
      expect(
        container.read(themePreferenceProvider).resolve().collection,
        QuietCollection.quietDefault,
      );
      expect(
        container
            .read(themePreferenceProvider)
            .resolve()
            .text
            .expression
            .primaryFamily,
        'Caveat',
      );
      expect(
        container
            .read(themePreferenceProvider)
            .resolve()
            .text
            .journalWriting
            .fontFamily,
        'Caveat',
      );
      expect(
        container
            .read(themePreferenceProvider)
            .resolve()
            .text
            .pageTitle
            .fontFamily,
        'Fraunces',
      );

      await container
          .read(themePreferenceProvider.notifier)
          .setProductTheme(ProductThemeId.vintageDiary);
      await waitForTheme(ProductThemeId.vintageDiary);

      expect(
        container.read(themePreferenceProvider).definition.assets.backgrounds.app,
        VintageDiaryAssets.background,
      );
      expect(
        container
            .read(themePreferenceProvider)
            .resolve()
            .text
            .expression
            .primaryFamily,
        'Caveat',
      );
      expect(
        container.read(themePreferenceProvider).definition.assets.chrome.navStrip,
        isNotNull,
      );

      await container
          .read(themePreferenceProvider.notifier)
          .setProductTheme(ProductThemeId.quietDefault);
      await waitForTheme(ProductThemeId.quietDefault);

      expect(
        container.read(themePreferenceProvider).definition.assets.backgrounds.app,
        isNull,
      );
      expect(
        container.read(themePreferenceProvider).definition.assets.chrome.navStrip,
        isNull,
      );
      expect(
        container.read(themePreferenceProvider).definition.assets.mood.emptyInvite,
        isNull,
      );
      expect(
        container
            .read(themePreferenceProvider)
            .resolve()
            .text
            .expression
            .primaryFamily,
        'Caveat',
      );
      expect(
        container
            .read(themePreferenceProvider)
            .resolve()
            .collection,
        QuietCollection.quietDefault,
      );
    });
  });
}
