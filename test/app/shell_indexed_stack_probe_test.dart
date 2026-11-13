import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/painting.dart';
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
import 'package:kin/domain/models/personal_reminder.dart';
import 'package:kin/domain/models/settings.dart';
import 'package:kin/domain/repositories/settings_repository.dart';
import 'package:kin/features/home/application/home_providers.dart';
import 'package:kin/features/home/presentation/home_screen.dart';
import 'package:kin/features/journal/application/journal_providers.dart';
import 'package:kin/features/journal/presentation/journal_home_screen.dart';
import 'package:kin/features/reminders/application/reminder_providers.dart';
import 'package:kin/features/today/presentation/today_screen.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

/// Phase 4 probes: shell branch laziness + timezone init cost.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
  });

  test('PHASE4: tzdata.initializeTimeZones cost on host isolate', () {
    final sw = Stopwatch()..start();
    tzdata.initializeTimeZones();
    sw.stop();
    // ignore: avoid_print — Phase 4 evidence
    print('PHASE4_TZDATA_INIT_MS=${sw.elapsedMilliseconds}');
    expect(sw.elapsedMilliseconds, greaterThanOrEqualTo(0));
  });

  testWidgets(
    'PHASE4: shell builds Today first; Kin/Journal lazy until visited',
    (tester) async {
      final database = KinDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final onboarded = AppSettings(
        onboardingCompletedAt: DateTime.utc(2026, 7, 28),
      );
      final settingsRepository = _MemorySettingsRepository(initial: onboarded);
      addTearDown(settingsRepository.dispose);
      final journalRepository = DriftJournalRepository(
        database,
        const _FixedIdGenerator(),
        const _FixedClock(),
      );

      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

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
            profilesStreamProvider.overrideWith(
              (ref) => Stream.value(const []),
            ),
            journalEntriesProvider.overrideWith(
              (ref, key) => Stream.value(const []),
            ),
            journalMonthMarkersProvider.overrideWith(
              (ref, key) => Stream.value(const []),
            ),
            remindersForDateProvider.overrideWith(
              (ref, key) => Stream.value(const <PersonalReminder>[]),
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
      await tester.pump(const Duration(milliseconds: 50));

      int count(Type type, {required bool includeOffstage}) =>
          find.byType(type, skipOffstage: !includeOffstage).evaluate().length;

      // go_router StatefulShellBranch.preload defaults to false — only Today
      // is mounted on the initial route.
      expect(count(TodayScreen, includeOffstage: true), 1);
      expect(count(HomeScreen, includeOffstage: true), 0);
      expect(count(JournalHomeScreen, includeOffstage: true), 0);

      await tester.tap(find.bySemanticsLabel('Kin'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(count(HomeScreen, includeOffstage: true), 1);
      // Today remains mounted (IndexedStack keep-alive after first visit).
      expect(count(TodayScreen, includeOffstage: true), 1);

      await tester.tap(find.bySemanticsLabel('Journal'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(count(JournalHomeScreen, includeOffstage: true), 1);
      expect(count(HomeScreen, includeOffstage: true), 1);

      // ignore: avoid_print — Phase 4 evidence
      print(
        'PHASE4_INDEXED_STACK '
        'afterVisits today=1 kin=1 journal=1 '
        '(preload=false; keep-alive after first visit)',
      );
    },
  );
}

class _FixedClock implements Clock {
  const _FixedClock();

  @override
  DateTime now() => DateTime.utc(2026, 9, 11, 12);
}

class _FixedIdGenerator implements IdGenerator {
  const _FixedIdGenerator();

  @override
  String next() => 'id';
}

class _MemorySettingsRepository implements SettingsRepository {
  _MemorySettingsRepository({required AppSettings initial})
    : _settings = initial;

  AppSettings _settings;
  final _controller = StreamController<AppSettings>.broadcast();

  void dispose() => unawaited(_controller.close());

  @override
  Stream<AppSettings> watchSettings() async* {
    yield _settings;
    yield* _controller.stream;
  }

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
    _controller.add(settings);
  }
}
