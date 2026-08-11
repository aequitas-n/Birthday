import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/app/profile_creation_launcher.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/core/id.dart';
import 'package:kin/data/local/database/kin_database.dart';
import 'package:kin/data/local/files/image_store.dart';
import 'package:kin/data/timezone/city_dataset.dart';
import 'package:kin/design/theme/material_shim.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/domain/models/profile.dart';
import 'package:kin/domain/repositories/person_repository.dart';
import 'package:kin/domain/repositories/profile_repository.dart';
import 'package:kin/features/home/application/home_providers.dart';
import 'package:kin/features/person/presentation/profile_sheet.dart';
import 'package:kin/features/person_editor/application/person_editor_notifier.dart';
import 'package:kin/features/person_editor/presentation/add_person_sheet.dart';

import '../../support/quiet_test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadQuietFonts);

  testWidgets('birthday-only sheet keeps Save and Not now', (tester) async {
    await _pumpSheet(tester, mode: BirthdayCreationMode.birthdayOnly);

    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
    expect(find.text('Next'), findsNothing);
    expect(find.text('Cancel'), findsNothing);
  });

  testWidgets('birthday-then-profile sheet shows Next and Cancel', (
    tester,
  ) async {
    await _pumpSheet(tester, mode: BirthdayCreationMode.birthdayThenProfile);

    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Save'), findsNothing);
    expect(find.text('Not now'), findsNothing);
  });

  testWidgets(
    'create new birthday continues into the profile sheet on Next',
    (tester) async {
      final database = KinDatabase(NativeDatabase.memory());
      final personRepository = _MemoryPersonRepository();
      final profileRepository = _MemoryProfileRepository();
      addTearDown(database.close);
      addTearDown(personRepository.dispose);
      addTearDown(profileRepository.dispose);

      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      late WidgetRef hostRef;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            kinDatabaseProvider.overrideWithValue(database),
            personRepositoryProvider.overrideWithValue(personRepository),
            profileRepositoryProvider.overrideWithValue(profileRepository),
            profilesStreamProvider.overrideWith(
              (ref) => profileRepository.watchAll(),
            ),
            imageStoreProvider.overrideWithValue(const _NoopImageStore()),
            idGeneratorProvider.overrideWithValue(
              const _FixedIdGenerator('person-new'),
            ),
            clockProvider.overrideWithValue(const _FixedClock()),
          ],
          child: MaterialApp(
            theme: buildMaterialShim(const QuietTheme.light()),
            home: Consumer(
              builder: (context, ref, _) {
                hostRef = ref;
                return const SizedBox.expand(
                  key: Key('flow-host'),
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();

      final flow = showCreateBirthdayThenProfileFlow(
        context: tester.element(find.byKey(const Key('flow-host'))),
        ref: hostRef,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));

      expect(find.byType(AddPersonSheet), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      final notifier = hostRef.read(personEditorProvider.notifier)
        ..setName('Kavin Rao')
        ..setBirthDay('8')
        ..setBirthMonth(3)
        ..setBirthYear('2004')
        ..setLocation(
          cityDataset.firstWhere((city) => city.city == 'Chennai'),
        );
      final saved = await notifier.save();
      expect(saved, isNotNull);
      expect(personRepository.people.single.displayName, 'Kavin Rao');

      Navigator.of(tester.element(find.byType(AddPersonSheet))).pop(saved);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));

      expect(find.byType(ProfileSheet), findsOneWidget);
      expect(find.text('Kavin Rao'), findsWidgets);

      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      await flow;

      expect(profileRepository.profiles, hasLength(1));
      expect(profileRepository.profiles.single.personId, 'person-new');
      expect(find.byType(ProfileSheet), findsNothing);
    },
  );

  testWidgets(
    'chooser create-new path opens birthday sheet after the chooser closes',
    (tester) async {
      final database = KinDatabase(NativeDatabase.memory());
      final personRepository = _MemoryPersonRepository();
      final profileRepository = _MemoryProfileRepository();
      addTearDown(database.close);
      addTearDown(personRepository.dispose);
      addTearDown(profileRepository.dispose);

      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      late WidgetRef hostRef;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            kinDatabaseProvider.overrideWithValue(database),
            personRepositoryProvider.overrideWithValue(personRepository),
            profileRepositoryProvider.overrideWithValue(profileRepository),
            profilesStreamProvider.overrideWith(
              (ref) => profileRepository.watchAll(),
            ),
            imageStoreProvider.overrideWithValue(const _NoopImageStore()),
            idGeneratorProvider.overrideWithValue(
              const _FixedIdGenerator('person-from-chooser'),
            ),
            clockProvider.overrideWithValue(const _FixedClock()),
          ],
          child: MaterialApp(
            theme: buildMaterialShim(const QuietTheme.light()),
            home: Consumer(
              builder: (context, ref, _) {
                hostRef = ref;
                return const SizedBox.expand(
                  key: Key('flow-host'),
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();

      unawaited(
        showProfileCreationChooser(
          context: tester.element(find.byKey(const Key('flow-host'))),
          ref: hostRef,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));

      expect(find.text('How would you like to begin?'), findsOneWidget);
      await tester.tap(find.text('Create New Birthday'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));

      // The bug: after the chooser pops, continuation used to die on the
      // chooser's unmounted context. The birthday sheet must still open.
      expect(find.byType(AddPersonSheet), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    },
  );
}

Future<void> _pumpSheet(
  WidgetTester tester, {
  required BirthdayCreationMode mode,
}) async {
  final database = KinDatabase(NativeDatabase.memory());
  addTearDown(database.close);

  await tester.binding.setSurfaceSize(const Size(800, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        kinDatabaseProvider.overrideWithValue(database),
        personRepositoryProvider.overrideWithValue(_MemoryPersonRepository()),
        imageStoreProvider.overrideWithValue(const _NoopImageStore()),
        idGeneratorProvider.overrideWithValue(
          const _FixedIdGenerator('draft'),
        ),
        clockProvider.overrideWithValue(const _FixedClock()),
      ],
      child: MaterialApp(
        theme: buildMaterialShim(const QuietTheme.light()),
        home: AddPersonSheet(mode: mode),
      ),
    ),
  );
  await tester.pump();
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

class _MemoryPersonRepository implements PersonRepository {
  _MemoryPersonRepository()
    : _controller = StreamController<List<Person>>.broadcast() {
    _controller.add(_people);
  }

  final StreamController<List<Person>> _controller;
  final List<Person> _people = [];

  List<Person> get people => List<Person>.unmodifiable(_people);

  void dispose() {
    _controller.close();
  }

  @override
  Future<void> restore(String id) async {}

  @override
  Future<Person> save(Person person) async {
    _people
      ..removeWhere((value) => value.id == person.id)
      ..add(person);
    _controller.add(List<Person>.unmodifiable(_people));
    return person;
  }

  @override
  Future<List<Person>> search(String query) async => _people;

  @override
  Future<void> softDelete(String id) async {}

  @override
  Stream<List<Person>> watchAll() async* {
    yield List<Person>.unmodifiable(_people);
    yield* _controller.stream;
  }

  @override
  Stream<Person?> watchById(String id) async* {
    yield null;
    yield* _controller.stream.map((_) => null);
  }
}

class _MemoryProfileRepository implements ProfileRepository {
  _MemoryProfileRepository()
    : _controller = StreamController<List<RelationshipProfile>>.broadcast() {
    _controller.add(_profiles);
  }

  final StreamController<List<RelationshipProfile>> _controller;
  final List<RelationshipProfile> _profiles = [];

  List<RelationshipProfile> get profiles =>
      List<RelationshipProfile>.unmodifiable(_profiles);

  void dispose() {
    _controller.close();
  }

  @override
  Future<RelationshipProfile?> readForPerson(String personId) async {
    for (final profile in _profiles) {
      if (profile.personId == personId) return profile;
    }
    return null;
  }

  @override
  Future<RelationshipProfile> save(RelationshipProfile profile) async {
    final stored = profile.id.isEmpty
        ? profile.copyWith(id: 'profile-${_profiles.length + 1}')
        : profile;
    _profiles
      ..removeWhere(
        (value) => value.id == stored.id || value.personId == stored.personId,
      )
      ..add(stored);
    _controller.add(List<RelationshipProfile>.unmodifiable(_profiles));
    return stored;
  }

  @override
  Future<void> softDelete(String id) async {
    _profiles.removeWhere((profile) => profile.id == id);
    _controller.add(List<RelationshipProfile>.unmodifiable(_profiles));
  }

  @override
  Stream<List<RelationshipProfile>> watchAll() async* {
    yield List<RelationshipProfile>.unmodifiable(_profiles);
    yield* _controller.stream;
  }

  @override
  Stream<RelationshipProfile?> watchForPerson(String personId) async* {
    yield await readForPerson(personId);
    yield* _controller.stream.map((profiles) {
      for (final profile in profiles) {
        if (profile.personId == personId) return profile;
      }
      return null;
    });
  }
}
