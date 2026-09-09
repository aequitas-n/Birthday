import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart' show GridView, MaterialApp;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/data/local/database/kin_database.dart' show KinDatabase;
import 'package:kin/data/local/files/image_store.dart';
import 'package:kin/design/theme/material_shim.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/domain/models/note.dart';
import 'package:kin/domain/models/notification_plan.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/domain/models/profile.dart';
import 'package:kin/domain/repositories/note_repository.dart';
import 'package:kin/domain/repositories/person_repository.dart';
import 'package:kin/domain/repositories/profile_repository.dart';
import 'package:kin/features/person/application/person_detail_providers.dart';
import 'package:kin/features/person/presentation/person_screen.dart';
import 'package:kin/notifications/application/notification_coordinator.dart';
import 'package:kin/notifications/notification_service.dart';
import 'package:kin/notifications/scheduler/platform_scheduler.dart';

import '../../support/quiet_test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadQuietFonts);

  testWidgets('renders identity and empty journal plates', (
    tester,
  ) async {
    final database = KinDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final personRepository = _MemoryPersonRepository(
      Person(
        id: 'person-1',
        displayName: 'Priya Raman',
        birthday: const PartialDate(month: 7, day: 28, year: 1997),
        location: const LocationModel(
          label: 'Chennai, Tamil Nadu, India',
          timezone: TimezoneModel('Asia/Kolkata'),
        ),
        sortKey: 'priya raman',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    );

    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _TestHarness(
        database: database,
        personRepository: personRepository,
        profileRepository: _MemoryProfileRepository(),
        noteRepository: _MemoryNoteRepository(const []),
        child: const PersonScreen(personId: 'person-1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Priya Raman'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Turns 29 today'), findsOneWidget);
    // Full birthday + location live behind Edit Birthday — not on the view.
    expect(find.text('BIRTHDAY'), findsNothing);
    expect(find.text('28 July 1997'), findsNothing);
    expect(find.text('LOCATION'), findsNothing);
    expect(find.text('Chennai, Tamil Nadu, India'), findsNothing);
    expect(find.text('Moments'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(
      find.text('Save a photo of a moment you want to keep.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'What they love, gift ideas, or a plan you want to make for them.',
      ),
      findsOneWidget,
    );
    expect(find.text('Edit'), findsOneWidget);

    // The previous immersion layout is gone: no over-image CTA, no born-as
    // sentence, no uppercase field chips presented as content.
    expect(find.text('Remember more than the date'), findsNothing);
    expect(find.text('Born 28 July 1997'), findsNothing);
    expect(find.text('Open profile'), findsNothing);
    expect(find.text('View all moments →'), findsNothing);
    expect(find.textContaining('more behind'), findsNothing);
  });

  testWidgets('shows relationship and memories when a profile exists', (
    tester,
  ) async {
    final database = KinDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final personRepository = _MemoryPersonRepository(
      Person(
        id: 'person-1',
        displayName: 'Priya Raman',
        birthday: const PartialDate(month: 7, day: 28, year: 1997),
        location: const LocationModel(
          label: 'Chennai, Tamil Nadu, India',
          timezone: TimezoneModel('Asia/Kolkata'),
        ),
        sortKey: 'priya raman',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    );
    final profileRepository = _MemoryProfileRepository(
      RelationshipProfile(
        id: 'profile-1',
        personId: 'person-1',
        nickname: 'Priya',
        relationship: RelationshipKind.family,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    );
    final noteRepository = _MemoryNoteRepository([
      Note(
        id: 'note-1',
        profileId: 'profile-1',
        kind: NoteKind.flower,
        value: 'Peonies',
        position: 0,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
      Note(
        id: 'note-2',
        profileId: 'profile-1',
        kind: NoteKind.giftIdea,
        value: 'A handwritten letter',
        position: 1,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    ]);

    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _TestHarness(
        database: database,
        personRepository: personRepository,
        profileRepository: profileRepository,
        noteRepository: noteRepository,
        child: const PersonScreen(personId: 'person-1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('FAMILY'), findsOneWidget);
    expect(find.text('Priya'), findsOneWidget);
    expect(find.text('Priya Raman'), findsOneWidget);
    expect(find.text('Moments'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Peonies'), findsOneWidget);
    expect(find.text('Favorite flower'), findsOneWidget);
    expect(find.text('A handwritten letter'), findsOneWidget);
    expect(find.text('No memories yet'), findsNothing);
    // Nickname is the hero title; the full name sits under it — no quotes.
    expect(find.text('"Priya"'), findsNothing);
    expect(find.text('Open profile'), findsNothing);
    expect(find.text('View all moments →'), findsNothing);
    expect(find.textContaining('more behind'), findsNothing);
  });

  testWidgets('single moment hides the overflow CTA', (tester) async {
    await _expectMomentsCta(
      tester,
      photoCount: 1,
      expectCta: false,
    );
  });

  testWidgets('two moments show a count-independent CTA', (tester) async {
    await _expectMomentsCta(
      tester,
      photoCount: 2,
      expectCta: true,
    );
  });

  testWidgets('many moments keep the same overflow CTA phrase', (tester) async {
    await _expectMomentsCta(
      tester,
      photoCount: 7,
      expectCta: true,
    );
  });

  testWidgets('View all moments opens the gallery', (tester) async {
    await _pumpPersonWithPhotos(tester, photoCount: 3);

    expect(find.text(_viewAllMomentsLabel), findsOneWidget);
    expect(find.byType(GridView), findsNothing);

    await tester.tap(find.bySemanticsLabel('View all moments'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('Edit opens profile and birthday actions', (tester) async {
    final database = KinDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final personRepository = _MemoryPersonRepository(
      Person(
        id: 'person-1',
        displayName: 'Priya Raman',
        birthday: const PartialDate(month: 7, day: 28, year: 1997),
        sortKey: 'priya raman',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    );

    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _TestHarness(
        database: database,
        personRepository: personRepository,
        profileRepository: _MemoryProfileRepository(),
        noteRepository: _MemoryNoteRepository(const []),
        child: const PersonScreen(personId: 'person-1'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Create Profile'), findsOneWidget);
    expect(find.text('Edit Birthday'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Pin to top'), findsNothing);
  });

  testWidgets('Edit offers pin when a profile exists', (tester) async {
    final database = KinDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final personRepository = _MemoryPersonRepository(
      Person(
        id: 'person-1',
        displayName: 'Priya Raman',
        birthday: const PartialDate(month: 7, day: 28, year: 1997),
        sortKey: 'priya raman',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    );

    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _TestHarness(
        database: database,
        personRepository: personRepository,
        profileRepository: _MemoryProfileRepository(
          RelationshipProfile(
            id: 'profile-1',
            personId: 'person-1',
            relationship: RelationshipKind.friend,
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        ),
        noteRepository: _MemoryNoteRepository(const []),
        child: const PersonScreen(personId: 'person-1'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Pin to top'), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);
  });

  testWidgets('leaves when person is deleted from the repository', (
    tester,
  ) async {
    final database = KinDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final personRepository = _MemoryPersonRepository(
      Person(
        id: 'person-1',
        displayName: 'Priya Raman',
        birthday: const PartialDate(month: 7, day: 28, year: 1997),
        sortKey: 'priya raman',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    );

    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const Text('Home')),
        GoRoute(
          path: '/person/:id',
          builder: (context, state) =>
              PersonScreen(personId: state.pathParameters['id']!),
        ),
      ],
    );

    await tester.pumpWidget(
      _TestHarness(
        database: database,
        personRepository: personRepository,
        profileRepository: _MemoryProfileRepository(),
        noteRepository: _MemoryNoteRepository(const []),
        wrapApp: false,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: buildMaterialShim(const QuietTheme.light()),
          routerConfig: router,
        ),
      ),
    );
    unawaited(router.push('/person/person-1'));
    await tester.pumpAndSettle();

    expect(find.text('Priya Raman'), findsOneWidget);

    await personRepository.softDelete('person-1');
    await tester.pump();
    await tester.pump();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Priya Raman'), findsNothing);
  });

  testWidgets('delete pops before a slow notification sync finishes', (
    tester,
  ) async {
    final database = KinDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final personRepository = _MemoryPersonRepository(
      Person(
        id: 'person-1',
        displayName: 'Priya Raman',
        birthday: const PartialDate(month: 7, day: 28, year: 1997),
        sortKey: 'priya raman',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    );
    final slowSync = _SlowSyncTracker();

    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const Text('Home')),
        GoRoute(
          path: '/person/:id',
          builder: (context, state) =>
              PersonScreen(personId: state.pathParameters['id']!),
        ),
      ],
    );

    await tester.pumpWidget(
      _TestHarness(
        database: database,
        personRepository: personRepository,
        profileRepository: _MemoryProfileRepository(),
        noteRepository: _MemoryNoteRepository(const []),
        slowSync: slowSync,
        wrapApp: false,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: buildMaterialShim(const QuietTheme.light()),
          routerConfig: router,
        ),
      ),
    );
    unawaited(router.push('/person/person-1'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pump();

    expect(find.text('Home'), findsOneWidget);
    expect(slowSync.started, isTrue);
    expect(slowSync.completed, isFalse);
  });
}

class _TestHarness extends StatelessWidget {
  const _TestHarness({
    required this.database,
    required this.personRepository,
    required this.profileRepository,
    required this.noteRepository,
    required this.child,
    this.slowSync,
    this.wrapApp = true,
  });

  final KinDatabase database;
  final PersonRepository personRepository;
  final ProfileRepository profileRepository;
  final NoteRepository noteRepository;
  final Widget child;
  final _SlowSyncTracker? slowSync;
  final bool wrapApp;

  @override
  Widget build(BuildContext context) {
    final themedChild = wrapApp
        ? MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: buildMaterialShim(const QuietTheme.light()),
            home: Builder(
              builder: (context) => ColoredBox(
                color: context.quiet.color.canvas,
                child: DefaultTextStyle(
                  style: context.quiet.text.body.tinted(
                    context.quiet.color.textPrimary,
                  ),
                  child: child,
                ),
              ),
            ),
          )
        : child;

    return ProviderScope(
      overrides: [
        kinDatabaseProvider.overrideWithValue(database),
        imageStoreProvider.overrideWithValue(const _NoopImageStore()),
        personRepositoryProvider.overrideWithValue(personRepository),
        profileRepositoryProvider.overrideWithValue(profileRepository),
        noteRepositoryProvider.overrideWithValue(noteRepository),
        clockProvider.overrideWithValue(const _FixedClock()),
        if (slowSync != null)
          notificationCoordinatorProvider.overrideWith((ref) {
            return _SlowNotificationCoordinator(
              database: database,
              clock: ref.watch(clockProvider),
              deviceTimezoneSource: ref.watch(deviceTimezoneSourceProvider),
              notificationService: const _BlockingNotificationService(),
              occurrenceCalculator: ref.watch(occurrenceCalculatorProvider),
              reminderPlanner: ref.watch(reminderPlannerProvider),
              personalReminderPlanner: ref.watch(
                personalReminderPlannerProvider,
              ),
              personalReminderRepository: ref.watch(
                personalReminderRepositoryProvider,
              ),
              scheduledRepository: ref.watch(
                scheduledNotificationRepositoryProvider,
              ),
              settingsRepository: ref.watch(settingsRepositoryProvider),
              scheduler: ref.watch(platformSchedulerProvider),
              tracker: slowSync!,
            );
          }),
      ],
      child: themedChild,
    );
  }
}

class _SlowSyncTracker {
  bool started = false;
  bool completed = false;
  final gate = Completer<void>();
}

class _BlockingNotificationService implements NotificationService {
  const _BlockingNotificationService();

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<NotificationLaunchRequest?> consumeLaunchRequest() async => null;

  @override
  Future<AndroidCapabilityState> exactAlarmState() async =>
      AndroidCapabilityState.notRequired;

  @override
  Future<void> initialize() async {}

  @override
  Stream<NotificationLaunchRequest> get launchRequests =>
      const Stream<NotificationLaunchRequest>.empty();

  @override
  Future<Set<int>> pendingNotificationIds() async => const {};

  @override
  Future<List<PendingPlatformNotification>> pendingNotifications() async =>
      const [];

  @override
  Future<AndroidCapabilityState> notificationsPermissionState() async =>
      AndroidCapabilityState.notRequired;

  @override
  Future<void> openExactAlarmSettings() async {}

  @override
  Future<void> openNotificationSettings() async {}

  @override
  Future<AndroidCapabilityState> requestExactAlarmPermission() async =>
      AndroidCapabilityState.notRequired;

  @override
  Future<AndroidCapabilityState> requestNotificationsPermission() async =>
      AndroidCapabilityState.notRequired;

  @override
  Future<void> schedule(NotificationPlan plan) async {}
}

class _SlowNotificationCoordinator extends NotificationCoordinator {
  _SlowNotificationCoordinator({
    required super.database,
    required super.clock,
    required super.deviceTimezoneSource,
    required super.notificationService,
    required super.occurrenceCalculator,
    required super.reminderPlanner,
    required super.personalReminderPlanner,
    required super.personalReminderRepository,
    required super.scheduledRepository,
    required super.settingsRepository,
    required super.scheduler,
    required this.tracker,
  });

  final _SlowSyncTracker tracker;

  @override
  Future<PlatformSyncResult> synchronize() async {
    tracker.started = true;
    await tracker.gate.future;
    tracker.completed = true;
    return const PlatformSyncResult(
      added: 0,
      updated: 0,
      removed: 0,
      unchanged: 0,
      restored: 0,
    );
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
  _MemoryProfileRepository([this._profile])
    : _controller = StreamController<RelationshipProfile?>.broadcast() {
    _controller.add(_profile);
  }

  RelationshipProfile? _profile;
  final StreamController<RelationshipProfile?> _controller;

  @override
  Future<RelationshipProfile?> readForPerson(String personId) async => _profile;

  @override
  Future<RelationshipProfile> save(RelationshipProfile profile) async {
    _profile = profile;
    _controller.add(_profile);
    return profile;
  }

  @override
  Future<void> softDelete(String id) async {
    _profile = null;
    _controller.add(null);
  }

  @override
  Stream<List<RelationshipProfile>> watchAll() async* {
    yield _profile == null ? const [] : [_profile!];
    yield* _controller.stream.map(
      (profile) => profile == null ? const [] : [profile],
    );
  }

  @override
  Stream<RelationshipProfile?> watchForPerson(String personId) async* {
    yield _profile;
    yield* _controller.stream;
  }
}

class _MemoryNoteRepository implements NoteRepository {
  _MemoryNoteRepository(this._notes)
    : _controller = StreamController<List<Note>>.broadcast() {
    _controller.add(_notes);
  }

  List<Note> _notes;
  final StreamController<List<Note>> _controller;

  @override
  Future<Note> save(Note note) async {
    _notes = [..._notes.where((value) => value.id != note.id), note];
    _controller.add(_notes);
    return note;
  }

  @override
  Future<void> softDelete(String id) async {
    _notes = _notes.where((note) => note.id != id).toList(growable: false);
    _controller.add(_notes);
  }

  @override
  Future<void> retire(String id, {required bool value}) async {}

  @override
  Future<void> reorder({
    required String profileId,
    required List<String> noteIdsInOrder,
  }) async {}

  @override
  Stream<List<Note>> watchForPerson(String personId) async* {
    yield _notes;
    yield* _controller.stream;
  }

  @override
  Stream<List<Note>> watchForProfile(String profileId) async* {
    yield _notes;
    yield* _controller.stream;
  }
}

class _FixedClock extends Clock {
  const _FixedClock();

  @override
  DateTime now() => DateTime.utc(2026, 7, 28, 12);
}

List<Note> _photoNotes(int count) {
  return [
    for (var i = 0; i < count; i++)
      Note(
        id: 'photo-note-$i',
        profileId: 'profile-1',
        kind: NoteKind.photo,
        value: 'photo-$i',
        position: i,
        createdAt: DateTime.utc(2026, 1, count - i),
        updatedAt: DateTime.utc(2026, 1, count - i),
      ),
  ];
}

Future<void> _pumpPersonWithPhotos(
  WidgetTester tester, {
  required int photoCount,
}) async {
  final database = KinDatabase(NativeDatabase.memory());
  addTearDown(database.close);
  final profile = RelationshipProfile(
    id: 'profile-1',
    personId: 'person-1',
    relationship: RelationshipKind.family,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
  final notes = _photoNotes(photoCount);
  final person = Person(
    id: 'person-1',
    displayName: 'Priya Raman',
    birthday: const PartialDate(month: 7, day: 28, year: 1997),
    sortKey: 'priya raman',
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  await tester.binding.setSurfaceSize(const Size(400, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        kinDatabaseProvider.overrideWithValue(database),
        imageStoreProvider.overrideWithValue(const _NoopImageStore()),
        personRepositoryProvider.overrideWithValue(
          _MemoryPersonRepository(person),
        ),
        profileRepositoryProvider.overrideWithValue(
          _MemoryProfileRepository(profile),
        ),
        noteRepositoryProvider.overrideWithValue(_MemoryNoteRepository(notes)),
        clockProvider.overrideWithValue(const _FixedClock()),
        personProfileProvider('person-1').overrideWith(
          (ref) => Stream.value(profile),
        ),
        personNotesProvider('person-1').overrideWith(
          (ref) => Stream.value(notes),
        ),
        personPhotoProvider.overrideWith((ref, photoId) async => null),
      ],
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
              child: const PersonScreen(personId: 'person-1'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  for (var i = 0; i < 10; i++) {
    await tester.pump();
  }
}

const _viewAllMomentsLabel = 'View all moments →';

Future<void> _expectMomentsCta(
  WidgetTester tester, {
  required int photoCount,
  required bool expectCta,
}) async {
  await _pumpPersonWithPhotos(tester, photoCount: photoCount);

  expect(
    find.text('Save a photo of a moment you want to keep.'),
    findsNothing,
  );
  expect(find.textContaining('more behind'), findsNothing);
  expect(find.text('Tap to open'), findsNothing);

  if (expectCta) {
    expect(find.text(_viewAllMomentsLabel), findsOneWidget);
    expect(find.bySemanticsLabel('View all moments'), findsOneWidget);
  } else {
    expect(find.text(_viewAllMomentsLabel), findsNothing);
  }
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
