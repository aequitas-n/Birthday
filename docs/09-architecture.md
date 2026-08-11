# 09 — Flutter Architecture

> **Implementation status:** This is the target architecture for Phases 2–8.
> The current repository contains `lib/app/`, `lib/design/`, and the gallery
> feature only. There is no `bootstrap.dart`, router, lifecycle observer,
> `core/`, `domain/`, `data/`, `notifications/`, product feature, database, or
> generated provider source yet.

## Principles

1. **Local database is the single source of truth.** The UI never reads from the
   network. Sync writes to the database; the database drives the UI.
2. **Layer inward.** `presentation → application → domain ← data`. The domain
   layer knows nothing about Flutter, Drift, or Firebase.
3. **Reactive by default.** Drift emits streams; Riverpod exposes them; widgets
   rebuild. There are no manual refresh calls.
4. **Scalable, not over-engineered.** Four layers, not seven. No use-case class
   per action, no mappers where a named constructor suffices, no interface where
   there will only ever be one implementation — with the deliberate exception of
   repositories, which are abstracted because they must be faked in tests.

---

## 1. Target folder structure

```
lib/
├── main.dart                       # runApp only
├── bootstrap.dart                  # DI container, error zone, init order
│
├── app/
│   ├── kin_app.dart                # root widget, theme wiring, MaterialApp shim
│   ├── router.dart                 # GoRouter config + deep links
│   └── lifecycle_observer.dart     # resume → reschedule, tz-change detection
│
├── design/                         # the Quiet design system — zero feature code
│   ├── tokens/
│   │   ├── color_tokens.dart
│   │   ├── type_tokens.dart
│   │   ├── space_tokens.dart
│   │   ├── radius_tokens.dart
│   │   ├── motion_tokens.dart
│   │   └── elevation_tokens.dart
│   ├── theme/
│   │   ├── quiet_colors.dart
│   │   ├── quiet_theme.dart        # ThemeExtension<QuietTheme> + lerp
│   │   ├── quiet_theme_x.dart      # context.quiet
│   │   └── material_shim.dart
│   ├── motion/
│   │   ├── quiet_motion.dart       # reduce-motion resolver
│   │   ├── transitions.dart        # T1–T9
│   │   └── stagger.dart
│   ├── glyphs/
│   │   └── quiet_glyphs.dart       # 12 CustomPainter glyphs
│   └── components/
│       ├── buttons/  fields/  sheets/  rows/  feedback/  media/
│
├── core/
│   ├── result.dart                 # sealed Result<T, Failure>
│   ├── failure.dart
│   ├── clock.dart                  # injectable now() — critical for tz tests
│   ├── id.dart                     # uuid v7 (time-ordered)
│   ├── logger.dart
│   └── extensions/
│
├── domain/                         # pure Dart. No Flutter import allowed.
│   ├── models/
│   │   ├── person.dart                 # root identity + birthday fields
│   │   ├── birthday_capability.dart    # required capability view
│   │   ├── profile.dart                # optional RelationshipProfile
│   │   ├── note.dart                   # profile-owned notes
│   │   ├── reminder_rule.dart
│   │   └── …
│   ├── repositories/               # abstract interfaces only
│   │   ├── person_repository.dart      # identity + birthday + location/tz
│   │   ├── profile_repository.dart     # optional profile lifecycle
│   │   ├── note_repository.dart        # profile notes only
│   │   ├── settings_repository.dart
│   │   └── backup_repository.dart
│   └── services/
│       ├── occurrence_calculator.dart   # PartialDate + tz → next Occurrence
│       ├── reminder_planner.dart        # Occurrence + rules → ReminderPlan
│       ├── countdown.dart
│       └── notification_composer.dart   # plan + notes → title/body copy
│
├── data/
│   ├── local/
│   │   ├── database/
│   │   │   ├── kin_database.dart
│   │   │   ├── tables/
│   │   │   ├── daos/
│   │   │   └── migrations/
│   │   ├── preferences/
│   │   └── files/                  # photo storage
│   ├── remote/
│   │   ├── auth/                   # Google Sign-In + Firebase Auth
│   │   └── backup/                 # Firestore + Storage
│   ├── timezone/
│   │   ├── city_dataset.dart       # bundled city → IANA, offline
│   │   └── device_timezone.dart
│   └── repositories/               # concrete impls of domain interfaces
│
├── notifications/
│   ├── notification_service.dart   # plugin wrapper
│   ├── channels.dart
│   ├── payload.dart                # typed deep-link payload
│   ├── permission_coordinator.dart
│   └── scheduler/
│       ├── schedule_reconciler.dart   # desired vs OS-pending diff
│       └── horizon.dart               # rolling window + platform budget
│
├── features/
│   ├── home/
│   │   ├── application/            # providers + notifiers
│   │   └── presentation/
│   │       ├── home_screen.dart
│   │       └── widgets/
│   ├── person/
│   ├── person_editor/
│   ├── notes/
│   ├── search/
│   ├── today/
│   ├── settings/
│   ├── backup/
│   └── onboarding/
│
└── l10n/
```

**Target boundaries.** The current repository enforces a subset with
`tool/check_architecture.dart`; `custom_lint` is a development dependency, but
no `custom_lint` or `import_lint` boundary package is configured yet:

| Layer | May import |
|---|---|
| `domain/` | `core/` only. **No `package:flutter`.** |
| `data/` | `domain/`, `core/` |
| `design/` | `core/`, Flutter |
| `features/` | `domain/`, `design/`, `core/`, `application` of own feature |
| `features/a/` | **never** `features/b/presentation/` |

---

## 2. State management — Riverpod 3; code generation planned

Chosen over Bloc for the reduced ceremony at this app's size, and over
`setState`/`InheritedWidget` for testability and stream composition.

### Provider taxonomy

| Kind | Purpose | Example |
|---|---|---|
| Infrastructure | Singletons resolved at bootstrap | `kinDatabaseProvider`, `notificationServiceProvider` |
| Repository | Domain interface → concrete impl | `personRepositoryProvider` |
| Stream | Reactive DB reads | `peopleStreamProvider`, `personStreamProvider(id)` |
| Derived | Pure computation over streams | `groupedPeopleProvider` |
| Notifier | Mutating, transient UI state | `PersonEditorNotifier`, `BackupNotifier` |

### The rule that keeps this simple

> **Reads are streams. Writes are notifiers. Nothing else holds state.**

A screen that only displays data has no notifier at all — it watches a stream
provider directly. Notifiers exist only where there is *draft* state (an editor)
or *process* state (a sync run).

### Example shape

```dart
// data → domain, reactive
@riverpod
Stream<List<Person>> peopleStream(Ref ref) =>
    ref.watch(personRepositoryProvider).watchAll();

// pure derivation, no state of its own
@riverpod
List<PersonGroup> groupedPeople(Ref ref) {
  final people = ref.watch(peopleStreamProvider).valueOrNull ?? const [];
  final now = ref.watch(clockProvider).now();
  return GroupByProximity(now).call(people);
}

// draft state for the add/edit sheet
@riverpod
class PersonEditor extends _$PersonEditor {
  @override
  PersonDraft build(String? personId) => /* load or empty */;

  void setName(String v) => state = state.copyWith(name: v);

  Future<void> commit() async {
    final saved = await ref.read(personRepositoryProvider).upsert(state.toPerson());
    await ref.read(reminderCoordinatorProvider).onPersonChanged(saved.id);
  }
}
```

`autoDispose` is the target default once generated providers are introduced;
only infrastructure providers should be kept alive. Current Phase 1 code uses a
hand-written `ThemePreferenceNotifier` because generator packages are not
configured.

---

## 3. Repository layer

Interfaces live in `domain/repositories`, implementations in
`data/repositories`. Each implementation composes a DAO, a mapper, and — where
relevant — the file store.

```dart
abstract interface class PersonRepository {
  Stream<List<Person>> watchAll();
  Stream<Person?> watch(String id);
  Future<Person> upsert(Person person);
  Future<void> softDelete(String id);
  Future<void> restore(String id);
  Future<void> purgeExpired(Duration retention);
  Future<List<Person>> search(String query);
}
```

Rules:

- Repositories return **domain models**, never Drift row classes.
- Repositories never throw raw exceptions; they return `Result` or throw a
  typed `Failure`.
- Repositories are the only place that knows a row is soft-deleted. Callers
  never see tombstones.
- Every repository has a `Fake*Repository` in `test/fakes/` backed by an
  in-memory list, so widget tests need no database.

---

## 4. Dependency injection & bootstrap

Riverpod is the container. `bootstrap.dart` performs ordered initialisation and
overrides the infrastructure providers with concrete instances.

```
bootstrap()
 ├─ WidgetsFlutterBinding.ensureInitialized()
 ├─ initialise timezone database (tz.initializeTimeZones)
 ├─ resolve device IANA timezone
 ├─ open Drift database (background isolate)
 ├─ load preferences
 ├─ construct NotificationService (no permission request yet)
 ├─ register app lifecycle observer
 ├─ runApp(ProviderScope(overrides: [...], child: KinApp()))
 └─ post-frame: reconcile notification schedule
```

Ordering constraints that matter:

- The timezone database must be initialised **before** any `TZDateTime` is
  constructed, including in the notification tap handler.
- The Drift database opens on a background isolate
  (`NativeDatabase.createInBackground`) so a slow disk never blocks first frame.
- Notification **permission is never requested at bootstrap**. It is requested
  contextually, after the user adds their first person (doc 11 §6).

---

## 5. Navigation

`go_router`, configured with a flat route table and custom transitions.

| Route | Path | Presentation |
|---|---|---|
| Home | `/` | root |
| Person | `/person/:id` | push, T1 shared element |
| Today | `/today` | push, T3 |
| Add person | `/add` | sheet, T2 |
| Edit person | `/person/:id/edit` | sheet, T2 |
| Search | `/search` | overlay, fade |
| Settings | `/settings` | push, T3 |
| Backup | `/settings/backup` | push, T3 |
| Removed | `/settings/removed` | push, T3 |
| Onboarding | `/welcome` | full-screen, shown once |

**Deep links.** Notification payloads resolve to `/person/:id`. The router
guarantees the back stack is `[/ , /person/:id]` even on a cold start from a
notification, so the back gesture always lands on Home rather than exiting.

---

## 6. Error handling

```dart
sealed class Failure {
  const Failure();
}
final class StorageFailure extends Failure { ... }
final class NetworkFailure extends Failure { ... }
final class PermissionFailure extends Failure { ... }
final class NotFoundFailure extends Failure { ... }
```

- Domain services and repositories return `Result<T, Failure>` for operations
  that can fail recoverably.
- Unrecoverable errors are thrown, caught by the bootstrap error zone, logged,
  and surfaced as a blocking error state (doc 04 §8, tier 3).
- `FlutterError.onError` and `PlatformDispatcher.instance.onError` both route to
  the same logger.
- **No crash reporting SDK in v1.** An offline-first, no-account app should not
  phone home by default. If added later, it is opt-in.

---

## 7. Testing strategy

| Level | Scope | Tooling |
|---|---|---|
| Unit | `domain/services` — especially `OccurrenceCalculator` and `ReminderPlanner` | `test`, injected `Clock`, fixed timezones |
| Unit | Repositories against in-memory Drift | `drift/native` |
| Migration | Every schema version pair | `drift_dev schema` + generated verifiers |
| Widget | Every `Q*` component, all states | `flutter_test` |
| Golden | Every component × 3 themes × 2 text scales | `golden_toolkit` |
| Integration | Add person → schedule → simulate fire → deep link | `integration_test` |
| Performance | Home scroll, T1 transition | `flutter drive` traces in CI |

**The critical test suite** is timezone correctness. It runs a matrix of:

- Person timezones: `America/Chicago`, `Asia/Kolkata`, `Pacific/Kiritimati`,
  `Pacific/Niue`, `Australia/Lord_Howe` (30-min offset), `Asia/Kathmandu` (45-min)
- Device timezones: the same set
- Dates: 29 February, 1 January, DST spring-forward, DST fall-back
- Expectation: the notification instant equals the person's local midnight,
  expressed correctly in device local time

This suite is the reason `Clock` is injected everywhere and why no code calls
`DateTime.now()` directly. That is enforced by a lint rule.

---

## 8. Package selection

| Concern | Package | Why |
|---|---|---|
| State | `flutter_riverpod` + `riverpod_generator` | Compile-safe, testable, minimal ceremony |
| Database | `drift` + `sqlite3_flutter_libs` | Reactive streams, typed queries, real migration tooling |
| Routing | `go_router` | Declarative, deep-link support |
| Notifications | `flutter_local_notifications` | The only mature offline scheduler |
| Timezone | `timezone` + `flutter_timezone` | IANA database, `TZDateTime` maths |
| Models | `freezed` + `json_serializable` | Immutability, unions, `copyWith` |
| Images | `image_picker`, `crop_your_image`, `flutter_image_compress` | Photo pipeline |
| Auth (optional) | `google_sign_in`, `firebase_auth` | Backup only |
| Backup (optional) | `cloud_firestore`, `firebase_storage` | Backup only |
| Lints | `very_good_analysis` + `custom_lint` | Strict baseline + boundary rules |

**Deliberately excluded:** `get_it`, `injectable` (Riverpod is the container),
`intl` beyond date formatting, any UI kit, any animation library, any state
package beyond Riverpod, analytics of any kind.

---

## 9. Target build configuration

**Current repository state:** Android and iOS are standard Flutter templates.
There are no `dev`/`prod` flavors or flavor-specific Firebase configuration;
Android uses Flutter's configured minimum SDK and iOS deployment is currently
13.0. The following items are target release configuration, not current state.

- **Flavors:** `dev`, `prod`. Firebase config differs; the dev flavor points at
  a separate project and enables a debug schedule inspector.
- **Codegen:** `dart run build_runner watch` during development; CI verifies
  generated files are committed and current.
- **Min SDK:** Android 26 (needed for reliable exact alarms and channels), iOS 15.
- **Obfuscation and split debug info** on release builds.
