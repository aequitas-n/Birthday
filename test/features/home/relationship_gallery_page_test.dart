import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart' show EditableText, MaterialApp;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/app/router.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/data/local/database/kin_database.dart' hide Note;
import 'package:kin/data/local/files/image_store.dart';
import 'package:kin/design/theme/material_shim.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/domain/models/note.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/domain/models/profile.dart';
import 'package:kin/domain/repositories/person_repository.dart';
import 'package:kin/domain/repositories/profile_repository.dart';
import 'package:kin/features/home/application/gallery_memory.dart';
import 'package:kin/features/home/application/gallery_providers.dart';
import 'package:kin/features/home/application/home_providers.dart';
import 'package:kin/features/home/presentation/home_screen.dart';
import 'package:kin/features/person/application/person_detail_providers.dart';
import 'package:kin/features/person/presentation/person_screen.dart';
import 'package:riverpod/misc.dart' show Override;

import '../../support/quiet_test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadQuietFonts);

  const clock = _FixedClock();

  Person person({
    required String id,
    required String name,
    int month = 7,
    int day = 28,
  }) {
    return Person(
      id: id,
      displayName: name,
      birthday: PartialDate(month: month, day: day, year: 1990),
      sortKey: name.toLowerCase(),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
  }

  RelationshipProfile profile({
    required String id,
    required String personId,
    String? nickname,
    RelationshipKind relationship = RelationshipKind.family,
    bool pinned = false,
  }) {
    return RelationshipProfile(
      id: id,
      personId: personId,
      nickname: nickname,
      relationship: relationship,
      isPinned: pinned,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
  }

  Future<void> pumpHome(
    WidgetTester tester, {
    required List<Override> overrides,
    HomeScreenMode mode = HomeScreenMode.birthdays,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildMaterialShim(const QuietTheme.light()),
          home: Builder(
            builder: (context) => ColoredBox(
              color: context.quiet.color.canvas,
              child: DefaultTextStyle(
                style: context.quiet.text.body.tinted(
                  context.quiet.color.textPrimary,
                ),
                child: HomeScreen(initialMode: mode),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  List<Override> peopleOverrides({
    required KinDatabase database,
    required List<Person> people,
    required List<RelationshipProfile> profiles,
    Map<String, GalleryMemorySummary> memories = const {},
  }) {
    return [
      clockProvider.overrideWithValue(clock),
      kinDatabaseProvider.overrideWithValue(database),
      imageStoreProvider.overrideWithValue(const _NoopImageStore()),
      peopleStreamProvider.overrideWith((ref) => Stream.value(people)),
      profilesStreamProvider.overrideWith((ref) => Stream.value(profiles)),
      galleryMemorySummariesProvider.overrideWith(
        (ref) => Stream.value(memories),
      ),
      personPhotoProvider.overrideWith((ref, photoId) async => null),
    ];
  }

  testWidgets('People mode shows Kin quote and People tab', (tester) async {
    final database = KinDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await pumpHome(
      tester,
      mode: HomeScreenMode.people,
      overrides: peopleOverrides(
        database: database,
        people: [person(id: 'p1', name: 'Ganesh')],
        profiles: [profile(id: 'pr1', personId: 'p1', nickname: 'Ganesh')],
      ),
    );

    expect(find.text('Kin'), findsOneWidget);
    expect(find.text('The people worth remembering.'), findsOneWidget);
    expect(find.text('People'), findsWidgets);
    expect(find.text('Search people'), findsOneWidget);
  });

  testWidgets('single person shows carousel dots', (tester) async {
    final database = KinDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await pumpHome(
      tester,
      mode: HomeScreenMode.people,
      overrides: peopleOverrides(
        database: database,
        people: [person(id: 'p1', name: 'Ganesh')],
        profiles: [profile(id: 'pr1', personId: 'p1')],
      ),
    );

    expect(find.bySemanticsLabel('1 of 2'), findsOneWidget);
    expect(find.text('Ganesh'), findsWidgets);
  });

  testWidgets('multiple people show position indicator', (tester) async {
    final database = KinDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await pumpHome(
      tester,
      mode: HomeScreenMode.people,
      overrides: peopleOverrides(
        database: database,
        people: [
          person(id: 'p1', name: 'Ganesh'),
          person(id: 'p2', name: 'Mom'),
        ],
        profiles: [
          profile(id: 'pr1', personId: 'p1', nickname: 'Ganesh'),
          profile(id: 'pr2', personId: 'p2', nickname: 'Mom'),
        ],
      ),
    );

    expect(find.bySemanticsLabel('1 of 3'), findsOneWidget);
  });

  testWidgets('search filters the carousel result set', (tester) async {
    final database = KinDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await pumpHome(
      tester,
      mode: HomeScreenMode.people,
      overrides: peopleOverrides(
        database: database,
        people: [
          person(id: 'p1', name: 'Ganesh'),
          person(id: 'p2', name: 'Mom'),
        ],
        profiles: [
          profile(id: 'pr1', personId: 'p1', nickname: 'Ganesh'),
          profile(id: 'pr2', personId: 'p2', nickname: 'Mom'),
        ],
      ),
    );

    await tester.enterText(find.byType(EditableText), 'mom');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Mom'), findsWidgets);
    expect(find.text('Ganesh'), findsNothing);
    // One filtered profile plus the add card.
    expect(find.bySemanticsLabel('1 of 2'), findsOneWidget);
  });

  testWidgets('active card shows name when memories exist', (
    tester,
  ) async {
    final database = KinDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await pumpHome(
      tester,
      mode: HomeScreenMode.people,
      overrides: peopleOverrides(
        database: database,
        people: [person(id: 'p1', name: 'Ganesh')],
        profiles: [
          profile(
            id: 'pr1',
            personId: 'p1',
            nickname: 'Ganesh',
          ),
        ],
        memories: {
          'pr1': GalleryMemorySummary.fromNotes([
            Note(
              id: 'n1',
              profileId: 'pr1',
              kind: NoteKind.free,
              value: 'That late-night drive',
              position: 0,
              createdAt: DateTime.utc(2026),
              updatedAt: DateTime.utc(2026, 1, 5),
            ),
            Note(
              id: 'n2',
              profileId: 'pr1',
              kind: NoteKind.flower,
              value: 'Peonies',
              position: 1,
              createdAt: DateTime.utc(2026, 1, 2),
              updatedAt: DateTime.utc(2026, 1, 2),
            ),
          ]),
        },
      ),
    );

    expect(find.text('Ganesh'), findsWidgets);
    expect(find.textContaining('2 memories'), findsNothing);
    expect(find.text('Latest memory'), findsNothing);
    expect(find.text('“That late-night drive”'), findsNothing);
  });

  testWidgets('active card shows only the name when no memories exist', (
    tester,
  ) async {
    final database = KinDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await pumpHome(
      tester,
      mode: HomeScreenMode.people,
      overrides: peopleOverrides(
        database: database,
        people: [person(id: 'p1', name: 'Ganesh')],
        profiles: [
          profile(
            id: 'pr1',
            personId: 'p1',
            nickname: 'Ganesh',
            relationship: RelationshipKind.brother,
          ),
        ],
      ),
    );

    expect(find.text('Ganesh'), findsWidgets);
    expect(find.text('Brother'), findsNothing);
    expect(find.textContaining('memories'), findsNothing);
    expect(find.text('Latest memory'), findsNothing);
  });

  testWidgets('two people show one centered card; swipe reveals next', (
    tester,
  ) async {
    final database = KinDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await pumpHome(
      tester,
      mode: HomeScreenMode.people,
      overrides: peopleOverrides(
        database: database,
        people: [
          person(id: 'p1', name: 'Ganesh'),
          person(id: 'p2', name: 'Mom'),
        ],
        profiles: [
          profile(
            id: 'pr1',
            personId: 'p1',
            nickname: 'Ganesh',
            relationship: RelationshipKind.brother,
          ),
          profile(
            id: 'pr2',
            personId: 'p2',
            nickname: 'Mom',
            relationship: RelationshipKind.mother,
          ),
        ],
      ),
    );

    expect(find.text('Ganesh').hitTestable(), findsWidgets);
    expect(find.text('Mom').hitTestable(), findsNothing);
    expect(find.bySemanticsLabel('1 of 3'), findsOneWidget);

    await tester.fling(
      find.text('Ganesh').hitTestable().first,
      const Offset(-320, 0),
      1000,
    );
    await tester.pumpAndSettle();

    expect(find.text('Mom').hitTestable(), findsWidgets);
    expect(find.bySemanticsLabel('2 of 3'), findsOneWidget);
  });

  testWidgets('pin button toggles profile pinned state', (tester) async {
    final database = KinDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final profiles = [
      profile(id: 'pr1', personId: 'p1', nickname: 'Ganesh'),
    ];
    final profileRepository = _CapturingProfileRepository(profiles.single);

    await pumpHome(
      tester,
      mode: HomeScreenMode.people,
      overrides: [
        ...peopleOverrides(
          database: database,
          people: [person(id: 'p1', name: 'Ganesh')],
          profiles: profiles,
        ),
        profileRepositoryProvider.overrideWithValue(profileRepository),
      ],
    );

    expect(find.bySemanticsLabel('Pin to top'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Pin to top'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(profileRepository.lastSaved?.isPinned, isTrue);
  });

  testWidgets('search with no matches shows empty copy', (tester) async {
    final database = KinDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await pumpHome(
      tester,
      mode: HomeScreenMode.people,
      overrides: peopleOverrides(
        database: database,
        people: [person(id: 'p1', name: 'Ganesh')],
        profiles: [profile(id: 'pr1', personId: 'p1')],
      ),
    );

    await tester.enterText(find.byType(EditableText), 'nobody');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('No one matches'), findsOneWidget);
  });

  testWidgets('tapping the active card opens the person profile', (
    tester,
  ) async {
    final database = KinDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final people = [person(id: 'p1', name: 'Ganesh')];
    final profiles = [profile(id: 'pr1', personId: 'p1', nickname: 'Ganesh')];
    final personRepository = _MemoryPersonRepository(people.single);
    final profileRepository = _MemoryProfileRepository(profiles.single);

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const HomeScreen(initialMode: HomeScreenMode.people),
        ),
        GoRoute(
          path: AppRoute.person.path,
          name: AppRoute.person.name,
          builder: (context, state) =>
              PersonScreen(personId: state.pathParameters['id']!),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(clock),
          kinDatabaseProvider.overrideWithValue(database),
          imageStoreProvider.overrideWithValue(const _NoopImageStore()),
          personRepositoryProvider.overrideWithValue(personRepository),
          profileRepositoryProvider.overrideWithValue(profileRepository),
          peopleStreamProvider.overrideWith((ref) => Stream.value(people)),
          profilesStreamProvider.overrideWith((ref) => Stream.value(profiles)),
          galleryMemorySummariesProvider.overrideWith(
            (ref) => Stream.value(const {}),
          ),
          personPhotoProvider.overrideWith((ref, photoId) async => null),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: buildMaterialShim(const QuietTheme.light()),
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    await tester.tap(find.text('Ganesh').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Moments'), findsOneWidget);
  });
}

class _FixedClock extends Clock {
  const _FixedClock();

  @override
  DateTime now() => DateTime.utc(2026, 7, 28, 12);
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

class _CapturingProfileRepository implements ProfileRepository {
  _CapturingProfileRepository(this._profile);

  RelationshipProfile _profile;
  RelationshipProfile? lastSaved;

  @override
  Future<RelationshipProfile?> readForPerson(String personId) async => _profile;

  @override
  Future<RelationshipProfile> save(RelationshipProfile profile) async {
    _profile = profile;
    lastSaved = profile;
    return profile;
  }

  @override
  Future<void> softDelete(String id) async {}

  @override
  Stream<List<RelationshipProfile>> watchAll() async* {
    yield [_profile];
  }

  @override
  Stream<RelationshipProfile?> watchForPerson(String personId) async* {
    yield _profile;
  }
}

class _MemoryPersonRepository implements PersonRepository {
  _MemoryPersonRepository(this._person)
    : _controller = StreamController<Person?>.broadcast() {
    _controller.add(_person);
  }

  Person? _person;
  final StreamController<Person?> _controller;

  @override
  Future<void> restore(String id) async {}

  @override
  Future<Person> save(Person person) async {
    _person = person;
    _controller.add(_person);
    return person;
  }

  @override
  Future<List<Person>> search(String query) async =>
      _person == null ? const [] : [_person!];

  @override
  Future<void> softDelete(String id) async {
    _person = null;
    _controller.add(null);
  }

  @override
  Stream<List<Person>> watchAll() async* {
    yield _person == null ? const [] : [_person!];
    yield* _controller.stream.map(
      (person) => person == null ? const <Person>[] : [person],
    );
  }

  @override
  Stream<Person?> watchById(String id) async* {
    yield _person;
    yield* _controller.stream;
  }
}

class _MemoryProfileRepository implements ProfileRepository {
  _MemoryProfileRepository(this._profile)
    : _controller = StreamController<List<RelationshipProfile>>.broadcast() {
    _controller.add([_profile]);
  }

  final RelationshipProfile _profile;
  final StreamController<List<RelationshipProfile>> _controller;

  @override
  Future<RelationshipProfile?> readForPerson(String personId) async => _profile;

  @override
  Future<RelationshipProfile> save(RelationshipProfile profile) async {
    _controller.add([profile]);
    return profile;
  }

  @override
  Future<void> softDelete(String id) async {}

  @override
  Stream<List<RelationshipProfile>> watchAll() async* {
    yield [_profile];
    yield* _controller.stream;
  }

  @override
  Stream<RelationshipProfile?> watchForPerson(String personId) async* {
    yield _profile;
    yield* _controller.stream.map((profiles) => profiles.firstOrNull);
  }
}
