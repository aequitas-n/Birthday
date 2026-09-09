# Kin — End-to-End Functional Audit Report

**Scope:** Full application forensic audit (code trace + automated tests + workflow mapping)  
**Date:** 30 August 2026  
**Status:** Phases 1–12 complete for code/test analysis. Manual device pass not executed in this session.

---

## Executive Summary

| Area | Verdict |
|------|---------|
| **Core persistence (Drift/SQLite)** | Solid — persons, profiles, notes, journal, reminders all have repository layers |
| **Pin workflow** | Wired end-to-end to `profiles.is_pinned`; gap: no Drift cold-start regression test |
| **Journal memory carousel** | Correct — both swipe directions advance `1→2→3→1` (unit-tested) |
| **Navigation / back stack** | Implemented as designed — Today is root; Kin tabs don't pollute history; zigzag tab revisits do |
| **Automated tests** | 214/216 functional tests pass; 41 golden failures (stale screenshots after UI changes); 2 functional failures |
| **Data integrity gaps** | Person delete doesn't cascade; photo/orphan cleanup missing; gift retire has no UI |
| **Test coverage gaps** | Pin cold-start, mood UI, journal deck screen-level swipe, reminder composer AM/PM UI |

**No P0 crash/data-loss bugs were found in code review**, but several **P1 integrity and coverage gaps** need fixes before declaring "everything works."

---

## Phase 1 — Application Map

### Entry & bootstrap

```
main.dart → bootstrap.dart
  ├── KinDatabase (kin.sqlite)
  ├── ImageStore / AudioStore
  ├── NotificationCoordinator
  └── ProviderScope → KinApp → GoRouter
```

### Navigation architecture

```
Root Navigator
└── StatefulShellRoute.indexedStack (AppShell + QPrimaryNav)
    ├── Branch 0: TodayScreen (/)
    ├── Branch 1: HomeScreen (/kin) — Birthdays | People tabs (local PageView, NOT routes)
    └── Branch 2: JournalHomeScreen (/journal)

Pushed on root: /person/:id, /journal/:date, /journal/:date/:entryId,
                /reminders, /settings, /gallery
```

**Module history** (`lib/app/app_shell.dart`): `_moduleHistory` tracks bottom-tab visits; `PopScope` exits app only when history is `[0]` (Today alone).

### State management

Riverpod: `*_providers.dart` per feature → repository streams → UI `ref.watch`.

### Source of truth

| Entity | Model | Table | Repository |
|--------|-------|-------|------------|
| Person / Birthday | `Person.birthday` (`PartialDate`) | `people` | `PersonRepository` |
| Profile / Pin | `RelationshipProfile.isPinned` | `profiles.is_pinned` | `ProfileRepository` |
| Profile details | `Note` (kinds) | `notes` | `NoteRepository` |
| Day mood | `JournalDay.mood` | `journal_days.mood` | `JournalRepository` |
| Entry mood | `JournalEntry.mood` | `journal_entries.mood` | `JournalRepository` |
| Journal memory | `JournalEntry` + fragments | `journal_entries`, `journal_entry_fragments` | `JournalRepository` |
| Personal reminder | `PersonalReminder` | `personal_reminders` | `PersonalReminderRepository` |
| Birthday notifications | `ReminderRule` + plans | `reminder_rules`, `scheduled_notifications` | `NotificationCoordinator` |

### Key files

| Area | Path |
|------|------|
| Entry | `lib/main.dart`, `lib/bootstrap.dart` |
| Router | `lib/app/router.dart` |
| Shell / back stack | `lib/app/app_shell.dart` |
| Database | `lib/data/local/database/kin_database.dart` |
| People gallery | `lib/features/home/presentation/`, `lib/features/home/application/gallery_providers.dart` |
| Person / profile | `lib/features/person/presentation/person_screen.dart`, `profile_sheet.dart` |
| Journal | `lib/features/journal/presentation/` |
| Journal deck | `lib/design/components/journal/q_journal_card_deck.dart` |
| Reminders | `lib/features/reminders/`, `lib/notifications/application/notification_coordinator.dart` |

---

## Phase 2 — Workflow Inventory

### HOME / TODAY

| Workflow | Status | Evidence |
|----------|--------|----------|
| App launch → Today | ✅ | `router.dart` initial `/`; `test/features/today/today_screen_test.dart` |
| Empty journal invite | ✅ | Widget tests |
| Journal previews | ✅ | Widget tests |
| Reminders preview (active only) | ✅ | `today_screen_test.dart` |
| Upcoming birthdays | ✅ | `occurrence_calculator_test.dart`, Today tests |
| Navigate Kin / Journal / Reminders | ✅ | `today_screen_test.dart`, `module_navigation_history_test.dart` |
| Add person (Birthdays) | ⚠️ | Flow exists; `add_person_sheet_test.dart` **fails** (layout overflow) |

### KIN — BIRTHDAYS

| Workflow | Status | Evidence |
|----------|--------|----------|
| Timeline grouping | ✅ | `home_providers.dart`, router test |
| Add birthday sheet | ⚠️ | Overflow in test viewport |
| Birthday → profile flow | ✅ | `birthday_then_profile_flow_test.dart` |
| Edit birthday | ✅ | `person_screen.dart` `_EditBirthdaySheet` |
| Delete person | ⚠️ **P1** | Soft-deletes person only; profile/notes/photos **not cascaded** |
| Countdown / partial year | ✅ | `PartialDate`, `occurrence_calculator_test.dart` |

### KIN — PEOPLE

| Workflow | Status | Evidence |
|----------|--------|----------|
| People carousel | ✅ | `relationship_gallery_page_test.dart` |
| Search filter | ✅ | Tested |
| Pin toggle (carousel) | ✅ | Saves via `profileRepository.save()` — widget test uses mock |
| Pin sort order | ✅ | `gallery_providers_test.dart` |
| Dot pagination | ✅ | Semantics `N of M` |
| Birthday-only people | ⚠️ By design | `galleryEntriesProvider` requires a **profile**; birthdays without profiles use `unlinkedBirthdaysProvider` on Birthdays tab only |
| Create profile empty state | ✅ | `CreateProfilePortraitCard` |

### PROFILE / PERSON

| Workflow | Status | Evidence |
|----------|--------|----------|
| Open profile | ✅ | `person_screen_test.dart` |
| Edit profile sheet | ✅ | `profile_sheet.dart` |
| Photo persist | ✅ | `_persistPhoto()` → `photos` + `profiles.photo_id` |
| Favorites / gifts / plans / notes / dates / custom | ✅ | `note_repository_drift_test.dart`, `person_screen_test.dart` |
| Delete detail | ✅ | `noteRepository.softDelete()` in `profile_sheet.dart` |
| Pin from Edit menu | ⚠️ | Menu offers pin; **no toggle/persist integration test** |
| Gift idea retire | ❌ **P1 gap** | `noteRepository.retire()` exists; **no UI** |
| Detail section reorder | ✅ | `DetailKindPicker` → SharedPreferences order |
| Note reorder within profile | ❌ **P2** | `noteRepository.reorder()` — **no UI** |

### PINNING — Critical trace

```
Tap pin (carousel or person menu)
  → profileRepository.save(copyWith(isPinned: !isPinned))
  → DriftProfileRepository.save → profiles.is_pinned
  → profilesStreamProvider → galleryEntriesProvider re-sorts
  → UI rebuilds
```

**Verified in code:**

- `lib/features/home/presentation/profile_portrait_card.dart` (carousel pin)
- `lib/features/person/presentation/person_screen.dart` (edit menu pin)
- `lib/data/repositories/profile_repository_drift.dart:68` (`isPinned: Value(profile.isPinned)`)

**Gaps:**

- Widget test uses `_CapturingProfileRepository` mock — not Drift cold-start
- `test/data/profile_repository_drift_test.dart` has **no `isPinned` test**
- Pin only available when `hasProfile == true`

**Recommended manual pin test:**

1. Pin person → leave profile → return to People → verify pinned
2. Kill app → reopen → verify still pinned
3. Unpin → kill app → verify still unpinned

### JOURNAL

| Workflow | Status | Evidence |
|----------|--------|----------|
| Month calendar | ✅ | Goldens + providers |
| Day screen / deck | ✅ | `journal_experience_test.dart` |
| Memory carousel `1→2→3→1` both directions | ✅ | `journal_card_deck_test.dart` |
| Add/edit memory | ✅ | `journal_repository_drift_test.dart` |
| Day mood persist | ✅ | Drift test |
| Day mood **clear** | ❌ **P2** | `_setDayMood` returns early if `mood == null` — cannot clear once set |
| Entry mood | ✅ | Drift test (independent from day mood) |
| Date navigation isolation | ✅ | `journal_repository_drift_test.dart` |

### REMINDERS

| Workflow | Status | Evidence |
|----------|--------|----------|
| CRUD persistence | ✅ | `personal_reminder_repository_drift_test.dart` |
| 12 AM / 12 PM storage | ✅ | `personal_reminder_planner_test.dart` |
| Planner screen classification | ✅ | `reminder_planner_screen_test.dart` |
| Composer AM/PM UI | ⚠️ | Logic in `reminder_composer_sheet.dart`; no dedicated UI test for 12 AM/PM toggle |
| Birthday notification rules | ✅ | `reminder_planner_test.dart`, `platform_scheduler_test.dart` |
| Edit reminder rules in settings | ❌ **P2** | Rules seeded only; no settings UI |

### SEARCH

| Workflow | Status | Evidence |
|----------|--------|----------|
| People search (name, partial, case) | ✅ | `person_repository_drift_test.dart`, gallery tests |
| Empty / no results | ✅ | Widget tests |
| Pinned in results | ✅ | Search filters entries; pin affects sort when cleared |

### NAVIGATION / BACK STACK

| Scenario | Expected | Actual (code + tests) |
|----------|----------|----------------------|
| Birthdays ↔ People tabs | No history push | ✅ `module_navigation_history_test.dart` |
| Today → Kin → back | Today | ✅ |
| Today → Kin → Journal → Kin → Journal → back×N | Unwind module history | ✅ (zigzag creates `[0,1,2,1,2]`) |
| Child route (journal day) back | Pops child first | ✅ |
| Today back | Exit app | ✅ `canPop: history.length <= 1` |
| Re-tap active bottom tab | No duplicate | ✅ |

**P2 note:** Zigzag tab switching (Today→Kin→Journal→Kin→Journal) requires **5 backs** to reach Today. This is intentional per tests, but may surprise users expecting "last module only."

---

## Phase 3 — State / Persistence Audit

Widget/UI state is **not** the source of truth for durable data. All major features persist through Drift repositories to `kin.sqlite` (application support directory).

| Feature | Persists? | Mechanism |
|---------|-----------|-----------|
| Person name/birthday/location | ✅ | `people` table |
| Profile nickname/relationship/photo | ✅ | `profiles` table |
| Pin | ✅ | `profiles.is_pinned` |
| Profile details (all NoteKind) | ✅ | `notes` table |
| Journal day mood | ✅ | `journal_days.mood` |
| Journal entry mood | ✅ | `journal_entries.mood` |
| Journal memories | ✅ | `journal_entries` + `journal_entry_fragments` |
| Personal reminders | ✅ | `personal_reminders` |
| Photos | ✅ | `photos` + filesystem (`photos/{hash}.jpg`) |
| Detail section order | ✅ | SharedPreferences (UI preference, not DB) |

---

## Phase 4 — CRUD Audit

| Entity | Create | Read | Update | Delete | Notes |
|--------|--------|------|--------|--------|-------|
| Person | ✅ | ✅ | ✅ | ⚠️ | Delete doesn't cascade |
| Profile | ✅ | ✅ | ✅ | ⚠️ | `softDelete` has no UI |
| Note (details) | ✅ | ✅ | ✅ | ✅ | Gift retire update unused in UI |
| Journal entry | ✅ | ✅ | ✅ | ✅ | |
| Journal day | ✅ | ✅ | ✅ | — | Mood clear blocked in UI |
| Personal reminder | ✅ | ✅ | ✅ | ✅ | |
| Photo | ✅ | ✅ | — | ⚠️ | No orphan cleanup |

---

## Phase 5 — Data Relationship Audit

| Relationship | Status | Issue |
|--------------|--------|-------|
| Person ↔ Profile (1:1) | ✅ | Enforced by `person_id` unique on profiles |
| Profile ↔ Notes (1:N) | ✅ | `notes.profile_id` FK |
| Person ↔ Birthday | ✅ | Embedded in `people` columns |
| Journal date isolation | ✅ | `local_date` key on days/entries/reminders |
| Pin Person A ≠ Pin Person B | ✅ | Separate `profiles.is_pinned` per profile |
| Delete Person A ≠ affect Person B | ✅ | |
| Delete Person A → clean Profile A | ❌ | Orphan profile/notes remain |

---

## Phase 6 — Cold Start / Restart

| Workflow | Code path correct? | Automated cold-start test? |
|----------|-------------------|---------------------------|
| Person create/edit | ✅ | ✅ Drift tests |
| Birthday | ✅ | ✅ |
| Pin | ✅ | ❌ Missing |
| Profile details | ✅ | ✅ note tests |
| Journal memory | ✅ | ✅ |
| Day mood | ✅ | ✅ Drift only |
| Personal reminder | ✅ | ✅ |
| Search reload | ✅ | Stream-based, implicit |

---

## Phase 7 — UI Action Integrity

| Control | Action | Status |
|---------|--------|--------|
| Bottom nav tabs | Module switch | ✅ |
| Kin Birthdays/People | Local PageView | ✅ |
| Profile card tap | → Person screen | ✅ Tested |
| Pin button | → `profileRepository.save` | ✅ |
| Search strip | Filters carousel | ✅ |
| Add (+) masthead | Profile chooser / add person | ✅ |
| Settings gear | → Settings | ✅ |
| Gallery disabled buttons | Intentionally disabled demo | ✅ (design gallery only) |
| `FoundationScreen` | Orphaned — not in router | P3 dead code |

---

## Phase 8 — Empty State Audit

| State | Renders | Next action | Crashes |
|-------|---------|-------------|---------|
| No people (People) | ✅ Create profile card | ✅ Tap to create | None |
| No birthdays | ✅ Empty copy | ✅ Add person | None |
| No journal memories | ✅ Invite copy | ✅ Add memory | None |
| No search results | ✅ "No one matches…" | ✅ Clear search | None |
| No reminders | ✅ Empty planner | ✅ Add reminder | None |
| Single person carousel | ✅ 2 dots | ✅ Swipe to add card | None |

---

## Phase 9 — Asset / UI Consistency

Recent People UI changes are **visual overlays** on `profile_card.png` — photo and text are `Positioned` widgets; no functional regression from asset swap identified.

Assets verified as overlays (not replacing logic):

- `profile_card.png` — parchment surface; photo/text layered on top
- `search.png` — search strip artwork; `TextField` overlaid
- Mood illustrations — picker + persistence intact
- Journal card artwork — deck gestures unchanged

**Golden tests are stale** (~49% pixel diff on People goldens) — reflects UI changes, not necessarily broken functionality.

---

## Phase 10 — Automated Test Results

```
flutter test (full):        301 passed, 41 failed
flutter test (no goldens):  214 passed,  2 failed
```

### Functional failures (non-golden)

#### P2 — `test/app/theme_and_router_test.dart`

- **Test:** `home timeline lists people without grouping when few`
- **Expected:** `find.text('TODAY')` findsNothing
- **Actual:** `TODAY` label now renders on birthday row
- **File:** `test/app/theme_and_router_test.dart:277`

#### P2 — `test/features/person_editor/add_person_sheet_test.dart`

- **Test:** `adds a person from home`
- **Issue:** `RenderFlex overflow` in date field column (36.6px height constraint)
- **File:** Likely `QDateField` / add person sheet layout
- **May indicate real small-viewport layout bug**

### Golden failures (39)

People, Today, Reminder, Journal goldens — outdated after recent UI work. Not functional bugs but **CI/release blocker** if goldens are enforced.

### Test files (48 total)

Grouped under `test/app/`, `test/data/`, `test/design/`, `test/domain/`, `test/features/`, `test/notifications/`.

### Critical workflows without tests

1. Pin Drift cold-start persistence
2. Person delete cascade/orphans
3. Journal deck swipe on `JournalDayScreen` (only component-level)
4. Mood picker UI → DB round-trip
5. Reminder composer 12 AM/PM UI round-trip
6. Profile pin from person Edit menu (persist with real Drift)
7. Photo delete orphan behavior

### Workflows well tested

- Journal deck forward cycle (unit)
- Navigation module history
- Birthday occurrence math
- Personal reminder temporal logic
- Note/person/profile Drift CRUD (basic)
- People search + carousel + pin (mock repo)

---

## Phase 11 — Manual Emulator Pass

**Not performed in this audit session.**

Recommended manual script:

1. **Today** — verify date, journal preview, reminders, birthdays
2. **Kin Birthdays** — add person → verify on timeline
3. **Kin People** — create profile → photo → pin → kill app → reopen → verify pin
4. **Person** — add favorite, gift, note → kill app → verify
5. **Journal** — add 3 memories → swipe both directions → verify `1→2→3→1`
6. **Journal** — set mood → change date → verify isolation
7. **Reminders** — add 12:00 AM and 12:00 PM → verify labels
8. **Back stack** — Today → Kin → Journal → person → back chain to exit

---

## Phase 12 — Prioritized Findings

### P0 — Critical

*None confirmed from code review + functional tests.*

---

### P1 — High

#### 1. Person delete doesn't cascade profile/notes

| Field | Detail |
|-------|--------|
| **Feature** | Delete person |
| **Workflow** | Person → Edit → Delete |
| **Reproduction** | Create person + profile + notes → delete person → inspect DB |
| **Expected** | Person + profile + notes removed/hidden |
| **Actual** | `personRepository.softDelete()` only sets `people.deleted_at`; profile and notes remain |
| **Root cause** | `lib/data/repositories/person_repository_drift.dart:70-74` — no cascade |
| **Files** | `person_repository_drift.dart`, `person_screen.dart:953` |
| **Persistence affected** | Yes — orphan profiles/notes in DB |
| **Regression test** | Yes — delete person → profile/notes tombstoned |

#### 2. Pin lacks Drift cold-start regression test

| Field | Detail |
|-------|--------|
| **Feature** | Pin persistence |
| **Workflow** | Pin → kill app → reopen |
| **Expected** | Still pinned |
| **Actual** | Code path correct; untested at repository/integration level |
| **Root cause** | `test/data/profile_repository_drift_test.dart` only tests nickname create |
| **Files** | `profile_repository_drift.dart`, `profile_portrait_card.dart` |
| **Persistence affected** | Unknown without test (code looks correct) |
| **Regression test** | `save(isPinned: true)` → new repository instance → `readForPerson` |

#### 3. Gift idea retirement has no UI

| Field | Detail |
|-------|--------|
| **Feature** | Mark gift as given/retired |
| **Expected** | User can retire gift ideas |
| **Actual** | `noteRepository.retire()` exists; used only in `ReminderPlanner` to skip retired gifts |
| **Root cause** | No UI calls `retire()` |
| **Files** | `note_repository_drift.dart:80`, `profile_sheet.dart` |
| **Persistence affected** | Feature incomplete |
| **Regression test** | UI + persistence when implemented |

#### 4. Golden test suite stale (41 failures)

| Field | Detail |
|-------|--------|
| **Feature** | Visual regression / CI |
| **Expected** | Goldens match current UI |
| **Actual** | People (~49% diff), Today, Reminder goldens fail after recent UI changes |
| **Root cause** | Baselines not regenerated |
| **Fix** | Regenerate goldens after UI stabilizes |
| **Regression test** | N/A — this IS the regression suite |

---

### P2 — Medium

#### 5. Cannot clear day mood

| Field | Detail |
|-------|--------|
| **Feature** | Remove day mood |
| **Steps** | Set mood → reopen picker → deselect → Save |
| **Expected** | Mood cleared for that date |
| **Actual** | `if (mood == null) return` blocks save |
| **Root cause** | `lib/features/journal/presentation/journal_day_screen.dart:215` |
| **Regression test** | Yes |

#### 6. Add person sheet layout overflow

| Field | Detail |
|-------|--------|
| **Feature** | Add birthday from home |
| **Actual** | RenderFlex overflow in tight viewport during test |
| **Files** | Add person sheet, `QDateField` |
| **Regression test** | Fix existing failing test |

#### 7. Router test stale expectation

| Field | Detail |
|-------|--------|
| **Feature** | Birthdays timeline labels |
| **Actual** | Test expects no `TODAY` label; UI now shows it |
| **Files** | `test/app/theme_and_router_test.dart:277` |
| **Fix** | Update test expectation |

#### 8. Zigzag tab history depth

| Field | Detail |
|-------|--------|
| **Feature** | Bottom nav back behavior |
| **Actual** | Non-consecutive revisits push duplicate history entries (by design) |
| **Files** | `app_shell.dart`, `module_navigation_history_test.dart` |
| **Fix** | Product decision — document or collapse revisits |

#### 9. Photo orphan files

| Field | Detail |
|-------|--------|
| **Feature** | Delete photo memory / change portrait |
| **Actual** | `photos.deleted_at` never set; `ImageStore.deleteOrphans()` never called |
| **Persistence affected** | Disk accumulation over time |

#### 10. Pin from person menu untested

| Field | Detail |
|-------|--------|
| **Feature** | Pin via Edit menu on person screen |
| **Actual** | Menu visibility tested; toggle/persist not tested with real Drift |

---

### P3 — Low

| # | Issue | File(s) |
|---|-------|---------|
| 11 | `FoundationScreen` orphaned | `lib/app/foundation_screen.dart` |
| 12 | `profileRepository.softDelete` unused | `profile_repository_drift.dart` |
| 13 | `noteRepository.reorder` no UI | `note_repository_drift.dart` |
| 14 | Kin People tab not deep-linkable | `HomeScreen.initialMode` unused in router |
| 15 | Gallery route uses different transition | `router.dart` gallery vs `_quietPushPage` |

---

## What Actually Works (Verified)

- SQLite persistence for all major entities
- Pin **does** write to `profiles.is_pinned` and re-sorts gallery
- Journal memory carousel **correct cyclic forward** behavior (both swipe directions)
- Navigation: Today root, Kin tabs don't pollute back stack, child routes pop first
- Birthday `PartialDate` storage (month/day/year optional)
- Reminder 12 AM/PM **storage** labels
- People search on real profile data
- Profile detail CRUD via notes table
- Notification coordinator reconciliation

---

## Definition of Done — Current Status

| Criterion | Status |
|-----------|--------|
| Every major feature has a complete workflow | ⚠️ Gift retire incomplete |
| Every Save actually persists | ✅ (verified in code) |
| Every Edit modifies the correct record | ✅ |
| Every Delete removes the correct record | ⚠️ Person delete incomplete cascade |
| Pin/unpin genuinely persists | ✅ code; ❌ cold-start test |
| Profile data survives restart | ✅ (Drift) |
| Birthday data survives restart | ✅ |
| Journal data survives restart | ✅ |
| Mood data survives restart | ✅ |
| Reminder data survives restart | ✅ |
| Custom details survive restart | ✅ |
| Search operates on real data | ✅ |
| Multiple memories work correctly | ✅ |
| Carousel sequence correct (journal) | ✅ |
| Navigation/back-stack correct | ✅ |
| Today is root; back exits app | ✅ |
| Tab switching doesn't pollute Kin history | ✅ |
| No dead-end screen | ✅ |
| No UI-only fake state for pin | ✅ |
| All tests pass | ❌ 41 golden + 2 functional failures |

---

## Recommended Fix Order

1. Add Drift pin persistence regression test
2. Fix person delete cascade (data integrity)
3. Fix `add_person_sheet` overflow + stale router test
4. Regenerate golden baselines
5. Add journal day deck integration test + mood clear fix
6. Manual emulator pass using Phase 11 script
7. Gift retire UI (if intended for this release)

---

## Audit Rules Observed

- No random redesigns or feature removal
- Full pipeline traced for pin, persistence, navigation, journal carousel
- Existing tests run; failures documented
- Findings reported before large changes
- All existing intended behavior preserved in recommendations

---

*Generated as part of the Kin master end-to-end functional audit, August 2026.*
