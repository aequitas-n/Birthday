import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

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
import 'package:kin/data/local/files/image_store.dart';
import 'package:kin/data/timezone/city_dataset.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/domain/models/profile.dart';
import 'package:kin/domain/models/settings.dart';
import 'package:kin/domain/repositories/person_repository.dart';
import 'package:kin/domain/repositories/settings_repository.dart';
import 'package:kin/features/home/application/home_providers.dart';
import 'package:kin/features/home/presentation/home_screen.dart';
import 'package:kin/features/journal/application/journal_providers.dart';
import 'package:kin/features/person_editor/application/person_editor_notifier.dart';
import 'package:kin/features/person_editor/presentation/add_person_sheet.dart';
import 'package:kin/features/today/application/today_providers.dart';

void main() {
  testWidgets('adds a person from home in dark theme', (tester) async {
    final database = KinDatabase(NativeDatabase.memory());
    final personRepository = _MemoryPersonRepository();
    final settingsRepository = _MemorySettingsRepository(
      initial: AppSettings(
        themeMode: StoredThemeMode.dark,
        onboardingCompletedAt: DateTime.utc(2026, 7),
      ),
    );

    addTearDown(database.close);
    addTearDown(personRepository.dispose);
    addTearDown(settingsRepository.dispose);
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          kinDatabaseProvider.overrideWithValue(database),
          settingsRepositoryProvider.overrideWithValue(settingsRepository),
          personRepositoryProvider.overrideWithValue(personRepository),
          peopleStreamProvider.overrideWith(
            (ref) => personRepository.watchAll(),
          ),
          profilesStreamProvider.overrideWith(
            (ref) => Stream.value(const <RelationshipProfile>[]),
          ),
          journalEntriesProvider.overrideWith(
            (ref, key) => Stream.value(const []),
          ),
          todayUpcomingProvider.overrideWithValue(const []),
          todayBirthdayProvider.overrideWithValue(const []),
          imageStoreProvider.overrideWithValue(const _NoopImageStore()),
          idGeneratorProvider.overrideWithValue(
            const _FixedIdGenerator('draft-001'),
          ),
          clockProvider.overrideWithValue(const _FixedClock()),
          initialAppSettingsProvider.overrideWithValue(
            AppSettings(
              themeMode: StoredThemeMode.dark,
              onboardingCompletedAt: DateTime.utc(2026, 7),
            ),
          ),
          initialThemePreferenceProvider.overrideWithValue(
            const ThemePreference(choice: ThemeChoice.dark),
          ),
        ],
        child: const MediaQuery(
          data: MediaQueryData(platformBrightness: Brightness.dark),
          child: KinApp(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Launch is Universal Home — open Kin before the birthday add flow.
    await tester.tap(find.bySemanticsLabel('Kin'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final addOnKin = find.descendant(
      of: find.byType(HomeScreen),
      matching: find.bySemanticsLabel('Add someone'),
    );
    expect(addOnKin, findsWidgets);
    await tester.tap(addOnKin.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));
    expect(find.text('Add someone'), findsWidgets);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(KinApp)),
    );

    final notifier = container.read(personEditorProvider.notifier)
      ..setName('Asha Nair')
      ..setBirthDay('28')
      ..setBirthMonth(7)
      ..setBirthYear('1994')
      ..setLocation(cityDataset.firstWhere((city) => city.city == 'Chennai'));
    await notifier.save();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    Navigator.of(tester.element(find.byType(AddPersonSheet))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Asha Nair'), findsOneWidget);
    expect(find.text('Today'), findsWidgets);
  });
}

class _FixedClock extends Clock {
  const _FixedClock();

  @override
  DateTime now() => DateTime.utc(2026, 7, 28, 12);
}

class _FixedIdGenerator extends IdGenerator {
  const _FixedIdGenerator(this.value);

  final String value;

  @override
  String next() => value;
}

class _NoopImageStore implements ImageStore {
  const _NoopImageStore();

  @override
  Future<void> delete(String relativePath) async {}

  @override
  Future<void> deleteOrphans(Set<String> retainedRelativePaths) async {}

  @override
  Future<StoredImageWrite> putJpeg(Uint8List bytes) {
    throw UnimplementedError();
  }

  @override
  Future<File> resolve(String relativePath) {
    throw UnimplementedError();
  }
}

class _MemorySettingsRepository implements SettingsRepository {
  _MemorySettingsRepository({required AppSettings initial})
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

class _MemoryPersonRepository implements PersonRepository {
  _MemoryPersonRepository()
    : _controller = StreamController<List<Person>>.broadcast() {
    _controller.add(_people);
  }

  final StreamController<List<Person>> _controller;
  final List<Person> _people = [];

  void dispose() {
    _controller.close();
  }

  @override
  Future<void> restore(String id) async {}

  @override
  Future<Person> save(Person person) async {
    _people
      ..removeWhere((value) => value.id == person.id)
      ..add(person)
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
    _controller.add(List<Person>.unmodifiable(_people));
    return person;
  }

  @override
  Future<List<Person>> search(String query) async {
    final normalized = query.toLowerCase();
    return _people
        .where(
          (person) => person.displayName.toLowerCase().contains(normalized),
        )
        .toList(growable: false);
  }

  @override
  Future<void> softDelete(String id) async {
    _people.removeWhere((person) => person.id == id);
    _controller.add(List<Person>.unmodifiable(_people));
  }

  @override
  Stream<List<Person>> watchAll() async* {
    yield List<Person>.unmodifiable(_people);
    yield* _controller.stream;
  }

  @override
  Stream<Person?> watchById(String id) async* {
    yield _firstOrNull(_people, id);
    yield* _controller.stream.map((people) => _firstOrNull(people, id));
  }
}

Person? _firstOrNull(List<Person> people, String id) {
  for (final person in people) {
    if (person.id == id) return person;
  }
  return null;
}
