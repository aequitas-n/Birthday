import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/app/kin_app.dart';
import 'package:kin/app/theme_controller.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/data/local/database/kin_database.dart';
import 'package:kin/data/repositories/settings_repository_drift.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/domain/models/settings.dart';
import 'package:kin/domain/repositories/settings_repository.dart';
import 'package:kin/features/home/application/home_providers.dart';

void main() {
  group('theme persistence', () {
    late KinDatabase database;
    late DriftSettingsRepository repository;

    setUp(() {
      database = KinDatabase(NativeDatabase.memory());
      repository = DriftSettingsRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('theme controller persists appearance changes', () async {
      final container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repository),
          initialThemePreferenceProvider.overrideWithValue(
            const ThemePreference(),
          ),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(themePreferenceProvider.notifier)
          .setChoice(ThemeChoice.dark);
      container.read(themePreferenceProvider.notifier).setAmoled(enabled: true);

      await Future<void>.delayed(Duration.zero);
      final settings = await repository.readSettings();

      expect(settings.themeMode, StoredThemeMode.dark);
      expect(settings.amoled, isTrue);
    });
  });

  testWidgets('first run opens welcome and Begin lands on empty home', (
    tester,
  ) async {
    final repository = _MemorySettingsRepository();

    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repository),
          appSettingsProvider.overrideWith((ref) => repository.watchSettings()),
          initialAppSettingsProvider.overrideWithValue(const AppSettings()),
          peopleStreamProvider.overrideWith((ref) => Stream.value(const [])),
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

    expect(find.text('Remember the people who matter.'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Begin'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('No one here yet.'), findsOneWidget);
    expect((await repository.readSettings()).onboardingCompletedAt, isNotNull);
  });

  testWidgets('onboarded users open home and can reach gallery from settings', (
    tester,
  ) async {
    final onboarded = AppSettings(
      onboardingCompletedAt: DateTime.utc(2026, 7, 28),
    );
    final repository = _MemorySettingsRepository(initial: onboarded);

    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repository),
          appSettingsProvider.overrideWith((ref) => repository.watchSettings()),
          initialAppSettingsProvider.overrideWithValue(onboarded),
          peopleStreamProvider.overrideWith((ref) => Stream.value(const [])),
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

    expect(find.text('Birthdays'), findsWidgets);
    expect(find.text('Kin'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.ensureVisible(find.text('Design gallery'));
    await tester.tap(find.text('Design gallery'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Quiet'), findsOneWidget);
  });

  testWidgets('home timeline lists people without grouping when few', (
    tester,
  ) async {
    final onboarded = AppSettings(
      onboardingCompletedAt: DateTime.utc(2026, 7, 28),
    );
    final repository = _MemorySettingsRepository(initial: onboarded);

    final people = [
      Person(
        id: 'a1',
        displayName: 'Priya Raman',
        birthday: const PartialDate(month: 7, day: 28, year: 1997),
        sortKey: 'priya raman',
        location: const LocationModel(label: 'Chennai'),
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
      Person(
        id: 'b2',
        displayName: 'Arjun Mehta',
        birthday: const PartialDate(month: 8, day: 2),
        sortKey: 'arjun mehta',
        location: const LocationModel(label: 'Mumbai'),
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
      Person(
        id: 'c3',
        displayName: 'Sara Lindqvist',
        birthday: const PartialDate(month: 9, day: 15),
        sortKey: 'sara lindqvist',
        location: const LocationModel(label: 'Stockholm'),
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    ];

    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repository),
          appSettingsProvider.overrideWith((ref) => repository.watchSettings()),
          initialAppSettingsProvider.overrideWithValue(onboarded),
          peopleStreamProvider.overrideWith((ref) => Stream.value(people)),
          profilesStreamProvider.overrideWith((ref) => Stream.value(const [])),
          clockProvider.overrideWithValue(
            _FixedClock(DateTime.utc(2026, 7, 28, 6)),
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

    // Sentence case countdown still appears on today's row; section titles
    // only appear once there are enough people to need chapters.
    expect(find.text('Today'), findsWidgets);
    expect(find.text('This week'), findsNothing);
    expect(find.text('Later'), findsNothing);
    expect(find.text('Later this year'), findsNothing);
    expect(find.text('TODAY'), findsNothing);
    expect(find.text('Birthdays'), findsWidgets);
    expect(find.text("Everyone you'd hate to forget."), findsNothing);
    expect(find.text('Priya Raman'), findsOneWidget);
    expect(find.text('Arjun Mehta'), findsOneWidget);
    expect(find.text('Sara Lindqvist'), findsOneWidget);
  });
}

class _FixedClock extends Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}

class _MemorySettingsRepository implements SettingsRepository {
  _MemorySettingsRepository({AppSettings initial = const AppSettings()})
    : _settings = initial,
      _controller = StreamController<AppSettings>.broadcast() {
    _controller.add(_settings);
  }

  AppSettings _settings;
  final StreamController<AppSettings> _controller;

  void dispose() {
    _controller.close();
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
    _controller.add(_settings);
  }

  @override
  Stream<AppSettings> watchSettings() async* {
    yield _settings;
    yield* _controller.stream;
  }
}
