import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/app/kin_app.dart';
import 'package:kin/app/theme_controller.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/core/id.dart';
import 'package:kin/data/local/database/kin_database.dart';
import 'package:kin/data/repositories/journal_repository_drift.dart';
import 'package:kin/domain/models/settings.dart';
import 'package:kin/domain/repositories/settings_repository.dart';
import 'package:kin/features/home/application/home_providers.dart';
import 'package:kin/features/journal/application/journal_providers.dart';

void main() {
  testWidgets('bottom navigation switches Today, Kin, and Journal', (
    tester,
  ) async {
    final database = KinDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final onboarded = AppSettings(
      onboardingCompletedAt: DateTime.utc(2026, 7, 28),
    );
    final settingsRepository = _MemorySettingsRepository(initial: onboarded);
    final journalRepository = DriftJournalRepository(
      database,
      const _FixedIdGenerator(),
      const _FixedClock(),
    );

    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(settingsRepository.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          kinDatabaseProvider.overrideWithValue(database),
          settingsRepositoryProvider.overrideWithValue(settingsRepository),
          journalRepositoryProvider.overrideWithValue(journalRepository),
          clockProvider.overrideWithValue(const _FixedClock()),
          appSettingsProvider.overrideWith(
            (ref) => settingsRepository.watchSettings(),
          ),
          initialAppSettingsProvider.overrideWithValue(onboarded),
          peopleStreamProvider.overrideWith((ref) => Stream.value(const [])),
          profilesStreamProvider.overrideWith((ref) => Stream.value(const [])),
          journalEntriesProvider.overrideWith(
            (ref, key) => Stream.value(const []),
          ),
          journalMonthMarkersProvider.overrideWith(
            (ref, key) => Stream.value(const []),
          ),
          initialThemePreferenceProvider.overrideWithValue(
            const ThemePreference(),
          ),
        ],
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: KinApp(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Nothing written yet.'), findsOneWidget);
    expect(find.text('Coming up'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Kin'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Birthdays'), findsWidgets);
    expect(find.text('Nothing written yet.'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Journal'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Journal'), findsWidgets);
    expect(find.textContaining('days'), findsOneWidget);
    expect(find.text('Birthdays'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Today'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Nothing written yet.'), findsOneWidget);
  });
}

class _MemorySettingsRepository implements SettingsRepository {
  _MemorySettingsRepository({AppSettings? initial})
    : _settings = initial ?? const AppSettings();

  AppSettings _settings;
  final _controller = StreamController<AppSettings>.broadcast();

  @override
  Stream<AppSettings> watchSettings() => _controller.stream;

  @override
  Future<AppSettings> readSettings() async => _settings;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _settings = settings;
    _controller.add(_settings);
  }

  @override
  Future<void> saveAppearance({
    required StoredThemeMode mode,
    required bool amoled,
  }) async {
    _settings = _settings.copyWith(themeMode: mode, amoled: amoled);
    _controller.add(_settings);
  }

  void dispose() {
    unawaited(_controller.close());
  }
}

class _FixedClock extends Clock {
  const _FixedClock();

  @override
  DateTime now() => DateTime.utc(2026, 8, 11, 12);
}

class _FixedIdGenerator extends IdGenerator {
  const _FixedIdGenerator();

  @override
  String next() => 'journal-test-id';
}
