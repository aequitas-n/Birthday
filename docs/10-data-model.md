# 10 — Local Database Design

Target engine: **SQLite via Drift**, opened on a background isolate. Its
reactive streams will drive the UI once Phase 2 is implemented.

> **Implementation status:** This is the Phase 2 target data design. The
> repository currently has no Drift dependency, database, schema, domain model,
> DAO, repository, migration harness, photo store, or persisted settings.

---

## 1. Design decisions that shape the schema

### Birthdays are partial dates, not `DateTime`

A birthday is a **recurring day-of-year**, and the year is frequently unknown.
Storing a `DateTime` would be wrong three ways: it implies a year, it implies an
instant, and it implies a timezone.

Stored as three columns: `birth_month`, `birth_day`, `birth_year` (nullable).

Consequences:
- Age is computed, and simply absent when the year is unknown
- 29 February is stored faithfully and resolved at scheduling time
- No timezone is baked into the stored date — the date is a *label*, and the
  timezone turns it into an *instant*

### Timezone is stored as an IANA identifier, never an offset

`Asia/Kolkata`, not `+05:30`. Offsets change with DST and with legislation; the
IANA name is stable and the `timezone` package resolves it correctly for any
year.

`iana_timezone` is nullable. When null, the person's birthday is anchored to the
**device's** timezone — the sensible default for someone in the same place.

### Soft deletes everywhere

Every user-owned table has `deleted_at`. Nothing is hard-deleted on user action.
Rationale: it powers undo, it powers "Recently removed," and it is a hard
requirement for correct sync (a tombstone must propagate).

A background task purges rows where `deleted_at < now - 30 days`.

### Sync metadata on every row

`updated_at` (UTC millis) and `sync_rev` (int) on every syncable table. This is
what makes last-writer-wins possible without a server-side merge engine.

---

## 2. Tables

### `people`

Person is the only durable root identity. Birthday fields are inlined because
Birthday is a mandatory 1:1 capability. Profile fields live on `profiles`.

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | TEXT PK | no | UUID v7 — time-ordered, sorts naturally |
| `display_name` | TEXT | no | Birthday identity name |
| `birth_month` | INT | no | 1–12 |
| `birth_day` | INT | no | 1–31, validated against month |
| `birth_year` | INT | yes | Null when unknown |
| `place_label` | TEXT | yes | "Chennai, India" — what the user sees |
| `iana_timezone` | TEXT | yes | "Asia/Kolkata" — null means device timezone |
| `sort_key` | TEXT | no | Normalised name for search/collation |
| `created_at` | INT | no | UTC millis |
| `updated_at` | INT | no | UTC millis |
| `deleted_at` | INT | yes | Tombstone |
| `sync_rev` | INT | no | Default 0 |

Indexes: `(deleted_at, birth_month, birth_day)` for the home query,
`(sort_key)` for search.

Domain code exposes these birthday fields as a `BirthdayCapability` object.

### `profiles`

Optional 0:1 relationship profile per Person.

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | TEXT PK | no | UUID v7 |
| `person_id` | TEXT FK | no | → `people.id`, unique |
| `nickname` | TEXT | yes | Shown when present |
| `relationship` | TEXT | yes | Enum-as-text: `sister`, `friend`, … , `other` |
| `relationship_label` | TEXT | yes | Free text when `relationship = other` |
| `photo_id` | TEXT | yes | FK → `photos.id` |
| `is_pinned` | BOOL | no | Favourites stay at the front of People |
| `created_at` | INT | no | |
| `updated_at` | INT | no | |
| `deleted_at` | INT | yes | |
| `sync_rev` | INT | no | |

### `notes`

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | TEXT PK | no | UUID v7 |
| `profile_id` | TEXT FK | no | → `profiles.id` |
| `kind` | TEXT | no | `flower`, `dessert`, `colour`, `drink`, `movie`, `food`, `place`, `gift_idea`, `plan`, `free`, … |
| `kind_label` | TEXT | yes | Custom category label |
| `value` | TEXT | no | Max 280 chars |
| `is_retired` | BOOL | no | Only meaningful for `gift_idea` (already given) |
| `position` | INT | no | Manual ordering within a profile |
| `created_at` | INT | no | |
| `updated_at` | INT | no | |
| `deleted_at` | INT | yes | |
| `sync_rev` | INT | no | |

Index: `(profile_id, deleted_at, position)`.

Notes require a Profile. Birthday-only people have no notes until a profile is
created. Scheduling and notifications never require notes or a profile.

### `photos`

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | TEXT PK | no | Content hash — deduplicates identical images |
| `person_id` | TEXT FK | yes | |
| `rel_path` | TEXT | no | Relative to app documents dir; never absolute (iOS containers move between installs) |
| `width` / `height` | INT | no | |
| `bytes` | INT | no | For backup accounting |
| `remote_path` | TEXT | yes | Firebase Storage path once uploaded |
| `created_at` | INT | no | |
| `deleted_at` | INT | yes | |

### `reminder_rules`

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | TEXT PK | no | |
| `person_id` | TEXT FK | yes | **Null = global default rule** |
| `kind` | TEXT | no | `days_before` \| `at_their_midnight` \| `morning_of` |
| `offset_days` | INT | yes | For `days_before` |
| `local_time` | TEXT | yes | `HH:mm` in **device** local time, for `morning_of` |
| `enabled` | BOOL | no | |
| `updated_at` / `deleted_at` / `sync_rev` | | | |

Defaults seeded on first launch (person_id null):

| Rule | Fires |
|---|---|
| `days_before 7` | 09:00 device local, 7 days before their date |
| `days_before 1` | 09:00 device local, the day before |
| `at_their_midnight` | The exact instant their birthday begins where they are |

Per-person rules override the global set entirely when any exist.

### `scheduled_notifications`

The **desired state** of the OS notification queue. Reconciled against the
platform's pending list on every app resume.

| Column | Type | Null | Notes |
|---|---|---|---|
| `os_id` | INT PK | no | The integer id handed to the OS |
| `person_id` | TEXT FK | no | |
| `rule_id` | TEXT FK | no | |
| `occurrence_year` | INT | no | Which birthday this is for |
| `fire_at_utc` | INT | no | Canonical instant |
| `fire_at_device_local` | INT | no | Denormalised, for debugging and the inspector |
| `device_tz` | TEXT | no | Timezone assumed when scheduled — invalidates on change |
| `title` | TEXT | no | Composed copy, stored so it can be diffed |
| `body` | TEXT | no | |
| `note_id_used` | TEXT | yes | Which detail was woven in, to avoid repeats |
| `state` | TEXT | no | `planned` \| `registered` \| `fired` \| `stale` |
| `created_at` | INT | no | |

Index: `(state, fire_at_utc)`.

### `settings`

Single-row table (`id = 0`) rather than key-value, so the schema is typed and
migrations are checked.

| Column | Notes |
|---|---|
| `theme_mode` | `system` \| `light` \| `dark` |
| `amoled` | bool, only meaningful when resolved theme is dark |
| `show_details_on_lock_screen` | bool, default **true** |
| `notifications_enabled` | bool |
| `onboarding_completed_at` | int, nullable |
| `device_timezone_cache` | text — detects tz change on resume |
| `last_reconciled_at` | int |

### `sync_state`

| Column | Notes |
|---|---|
| `device_id` | Stable per install |
| `account_id` | Null when signed out |
| `last_pulled_at` / `last_pushed_at` | UTC millis |
| `last_error` | Nullable text |

---

## 3. Entity relationships

```
                    ┌──────────┐
                    │ settings │   (single row)
                    └──────────┘

  ┌────────────┐ 1      * ┌─────────┐
  │   people   │──────────│  notes  │
  └────────────┘          └─────────┘
        │ 1
        │ 0..1        ┌──────────┐
        ├─────────────│  photos  │
        │             └──────────┘
        │ 1      *  ┌─────────────────┐
        ├───────────│ reminder_rules  │  (person_id null = global)
        │           └─────────────────┘
        │ 1      *  ┌─────────────────────────┐
        └───────────│ scheduled_notifications │
                    └─────────────────────────┘
```

---

## 4. Core queries

### Home list

Returns everyone, ordered by days-until-next-occurrence. The ordering is
computed in Dart rather than SQL, because "next occurrence" depends on each
person's timezone and on 29 February handling — logic that does not belong in a
query.

```sql
SELECT * FROM people
WHERE deleted_at IS NULL
ORDER BY sort_key;
```

Drift streams this; `groupedPeopleProvider` (doc 09 §2) sorts and groups it.
With ≤ 2,000 people this is comfortably sub-millisecond and keeps all
timezone logic in one tested place.

### Person with notes

A single watched join, mapped into `Person` + `List<Note>`.

### Search

`sort_key LIKE ?` plus a match against `nickname` and `place_label`.
No FTS table in v1 — at this data volume it would be over-engineering.

---

## 5. Migrations

- `schemaVersion` starts at 1 and increments on every shipped schema change.
- Every version is exported with `drift_dev schema dump` into
  `drift_schemas/`, and generated verifiers assert that migrating
  `v(n-1) → v(n)` produces the expected schema **and** preserves data.
- Migration tests run in CI for every adjacent version pair and for
  `v1 → vLatest`.
- Destructive column changes are done as create-copy-drop-rename, never as an
  in-place type change.

```dart
@override
MigrationStrategy get migration => MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        await _seedDefaultReminderRules();
      },
      onUpgrade: (m, from, to) async {
        // one guarded block per version step
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
```

`PRAGMA foreign_keys = ON` is set in `beforeOpen` — SQLite defaults it off, and
without it the cascade deletes silently do nothing.

---

## 6. Photo storage

Photos are **files**, not blobs. Storing 1MB images in SQLite would bloat the
database and slow every query.

```
<app documents>/photos/<content-hash>.jpg
```

- `rel_path` is stored, never an absolute path — iOS rewrites the container path
  on every install and restore
- Content-hash naming deduplicates and makes uploads idempotent
- Images are resized to 1024×1024 and JPEG q85 before storage
- Orphan sweep runs with the tombstone purge

---

## 7. Encryption

**Not encrypted in v1**, deliberately. The data is birthdays and favourite
flowers; it is already protected by the OS sandbox and device encryption.
SQLCipher would add build complexity and a key-management problem for no
meaningful threat reduction.

Drift supports migrating a plaintext database to an encrypted one via
`VACUUM INTO` + `PRAGMA rekey`, so this remains a clean future option if the
data model ever grows more sensitive.

---

## 8. Synchronisation strategy

**Backup and restore, not realtime collaboration.** The local database is
authoritative at all times.

### Model

| Property | Choice |
|---|---|
| Trigger | On sign-in, on app resume (throttled to 15 min), on explicit "Back up now" |
| Direction | Push local changes, then pull remote changes |
| Conflict resolution | Last-writer-wins on `updated_at`, tie-break on `id` |
| Deletes | Tombstones propagate; a delete always wins against an older edit |
| Granularity | Row-level |
| Transport | Firestore documents; photos to Firebase Storage |
| Failure mode | Silent retry. Sync **never** blocks the UI or shows a modal. |

### Remote layout

```
users/{uid}/
  people/{personId}          ← mirrors the row + updated_at + deleted_at
  notes/{noteId}
  reminderRules/{ruleId}
  meta/backup                ← schemaVersion, lastPushedAt, deviceId
```

Photos: `users/{uid}/photos/{contentHash}.jpg`, uploaded only over unmetered
connections by default.

### Algorithm

```
push:
  rows where updated_at > last_pushed_at  →  batched writes (500/batch)
  set last_pushed_at = max(updated_at) pushed

pull:
  query where updated_at > last_pulled_at
  for each remote row:
      local = find(id)
      if local == null                      → insert
      else if remote.updated_at > local.updated_at → overwrite
      else                                  → keep local
  set last_pulled_at = server time

after pull:
  if anything changed → trigger notification reconciliation
```

### Clock safety

`updated_at` comes from the device clock, which can be wrong. Guard: a
monotonic check ensures a row's `updated_at` never moves backwards, and the
value is clamped to `max(deviceNow, existingUpdatedAt + 1)`. Firestore server
timestamps are recorded alongside for diagnostics but are not used for merge
ordering, because offline writes have no server timestamp until they land.

### Sign-out

Signing out **never deletes local data**. It clears `sync_state.account_id` and
stops syncing. This is the behaviour that makes "optional login" honest.

---

## 9. Data export

A user can export everything as a single JSON file plus a photo folder, zipped,
from Settings. This is a hard requirement of an offline-first product: the user's
data must be retrievable without our servers and without our app.

Import accepts the same archive and merges by `id` using the same LWW rule.
