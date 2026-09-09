import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/app/app_shell.dart';
import 'package:kin/app/kin_app.dart';
import 'package:kin/app/router.dart';
import 'package:kin/app/theme_controller.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/core/id.dart';
import 'package:kin/data/local/database/kin_database.dart';
import 'package:kin/data/repositories/journal_repository_drift.dart';
import 'package:kin/design/components/navigation/q_primary_nav.dart';
import 'package:kin/domain/models/personal_reminder.dart';
import 'package:kin/domain/models/settings.dart';
import 'package:kin/domain/repositories/settings_repository.dart';
import 'package:kin/features/home/application/home_providers.dart';
import 'package:kin/features/journal/application/journal_providers.dart';
import 'package:kin/features/reminders/application/reminder_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final onboarded = AppSettings(
    onboardingCompletedAt: DateTime.utc(2026, 7, 28),
  );

  Future<ProviderContainer> pumpApp(WidgetTester tester) async {
    final database = KinDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final settingsRepository = _MemorySettingsRepository(initial: onboarded);
    addTearDown(settingsRepository.dispose);
    final journalRepository = DriftJournalRepository(
      database,
      const _FixedIdGenerator(),
      const _FixedClock(),
    );

    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = ProviderContainer(
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
        journalDayProvider.overrideWith((ref, key) => Stream.value(null)),
        remindersForDateProvider.overrideWith(
          (ref, key) => Stream.value(const <PersonalReminder>[]),
        ),
        initialThemePreferenceProvider.overrideWithValue(
          const ThemePreference(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: KinApp(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    return container;
  }

  AppShellState shellState(WidgetTester tester) {
    return tester.state<AppShellState>(find.byType(AppShell));
  }

  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(QPrimaryNav),
        matching: find.bySemanticsLabel(label),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<bool> systemBack(WidgetTester tester) {
    return tester.binding.handlePopRoute();
  }

  testWidgets('bottom navigation switches Today, Kin, and Journal', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Nothing written yet.'), findsOneWidget);

    await tapTab(tester, 'Kin');
    expect(find.text('Birthdays'), findsWidgets);
    expect(find.text('Nothing written yet.'), findsNothing);

    await tapTab(tester, 'Journal');
    expect(find.textContaining('days'), findsOneWidget);
    expect(find.text('Birthdays'), findsNothing);

    await tapTab(tester, 'Today');
    expect(find.text('Nothing written yet.'), findsOneWidget);
  });

  testWidgets('Kin Birthdays/People switches do not push module history', (
    tester,
  ) async {
    await pumpApp(tester);

    await tapTab(tester, 'Kin');
    expect(shellState(tester).debugActiveModule, 1);

    // Flip Kin internal modes repeatedly — back still returns to Today.
    await tester.tap(find.text('People').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Birthdays').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('People').first);
    await tester.pumpAndSettle();

    expect(shellState(tester).debugActiveModule, 1);

    final handled = await systemBack(tester);
    expect(handled, isTrue);
    await tester.pumpAndSettle();

    expect(shellState(tester).debugActiveModule, 0);
    expect(find.text('Nothing written yet.'), findsOneWidget);
  });

  testWidgets('zigzag tab switches do not accumulate back stack', (
    tester,
  ) async {
    await pumpApp(tester);

    await tapTab(tester, 'Kin');
    await tapTab(tester, 'Journal');
    await tapTab(tester, 'Kin');
    await tapTab(tester, 'Journal');

    expect(shellState(tester).debugActiveModule, 2);
    expect(shellState(tester).debugJournalBackTarget, 1);

    // Re-tapping Journal is a no-op.
    await tapTab(tester, 'Journal');
    expect(shellState(tester).debugActiveModule, 2);

    // Back: Journal → Kin → Today (not an endless Kin/Journal replay).
    expect(await systemBack(tester), isTrue);
    await tester.pumpAndSettle();
    expect(shellState(tester).debugActiveModule, 1);
    expect(find.text('Birthdays'), findsWidgets);

    expect(await systemBack(tester), isTrue);
    await tester.pumpAndSettle();
    expect(shellState(tester).debugActiveModule, 0);
    expect(find.text('Nothing written yet.'), findsOneWidget);

    // Final back allows the platform to exit.
    expect(await systemBack(tester), isFalse);
  });

  testWidgets('Journal opened from Today backs to Today directly', (
    tester,
  ) async {
    await pumpApp(tester);

    await tapTab(tester, 'Journal');
    expect(shellState(tester).debugJournalBackTarget, 0);

    expect(await systemBack(tester), isTrue);
    await tester.pumpAndSettle();
    expect(shellState(tester).debugActiveModule, 0);
  });

  testWidgets('child journal day pops before module history unwinds', (
    tester,
  ) async {
    final container = await pumpApp(tester);

    await tapTab(tester, 'Kin');
    await tapTab(tester, 'Journal');
    expect(shellState(tester).debugJournalBackTarget, 1);

    final router = container.read(routerProvider);
    router.pushNamed(
      AppRoute.journalDay.name,
      pathParameters: {'date': '2026-10-24'},
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(router.canPop(), isTrue);
    expect(find.text('Journal of the Day'), findsOneWidget);

    expect(await systemBack(tester), isTrue);
    await tester.pumpAndSettle();

    // Child gone; still on Journal.
    expect(shellState(tester).debugActiveModule, 2);
    expect(find.text('Journal of the Day'), findsNothing);
    expect(find.textContaining('days'), findsOneWidget);

    expect(await systemBack(tester), isTrue);
    await tester.pumpAndSettle();
    expect(shellState(tester).debugActiveModule, 1);
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
