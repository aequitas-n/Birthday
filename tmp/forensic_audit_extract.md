# Kin â€” Forensic Performance Audit (Read-Only)

**Mode:** STATIC CODE EVIDENCE unless marked **REQUIRES RUNTIME PROFILING**  
**No code was modified.**  
**Assets on disk:** ~4.88 MB total (`assets/` â‰ˆ 4.07 MB WebP + ~0.80 MB fonts).

---

## 1. Executive Summary

Kin is already in good shape for a Flutter offline app in several ways: Drift opens with `NativeDatabase.createInBackground`, there are **no** `Timer.periodic` / countdown storms, Default correctly avoids constructing Vintage `ImageProvider`s, and tab switches use `NoTransitionPage`.

The largest **architectural** risks are:

1. **Pre-`runApp` blocking** on settings DB open + notification/tz init (`bootstrap.dart`).
2. **`StatefulShellRoute.indexedStack`** keeps Today / Kin / Journal **mounted forever**, so their Drift streams stay subscribed off-tab.
3. **Theme images decode at full intrinsic resolution** (no `cacheWidth`/`cacheHeight`) â€” e.g. 2172Ã—724 chrome for a ~56dp bar â‰ˆ **~6 MB RGBA each**.
4. **Gesture `setState` storms** in People carousel and Journal card deck (Opacity + multi-Transform stacks).
5. **`galleryMemorySummariesProvider` watches all notes** â€” any note write recomputes gallery summaries.

No P0 â€œguaranteed catastropheâ€ was proven without runtime traces. Several **P1** items are strongly evidenced statically and should be the first optimization targets.

---

## 2. Architecture Performance Map

```
main() â†’ bootstrap()
  ensureInitialized
  desktop window setup (desktop only)
  KinDatabase()          // LazyDatabase â€” not opened yet
  await readSettings()   // OPENS DB + migrate + first query  [BLOCKS]
  await notificationService.initialize()  // + tzdata          [BLOCKS]
  runApp(ProviderScope â†’ KinApp)

KinApp watches themePreference + router
  â†’ MaterialApp.router
  â†’ NotificationLifecycleGate (post-frame synchronizeStartup)
  â†’ StatefulShellRoute.indexedStack
       â”œâ”€ TodayScreen   (always mounted)  people+journal+reminders watches
       â”œâ”€ HomeScreen    (always mounted)  people/profiles + gallery
       â””â”€ JournalHome   (always mounted)  month markers stream
```

| Trigger | What runs |
|---|---|
| Cold start | DB open/migrate, settings, notif init, then first frame |
| After first frame | Full notification reconcile (people/notes/rules/profiles) |
| Tab change | Branch stay alive â€” no remount; Offstage rebuilds still possible |
| Person/profile write | `people`/`profiles` streams â†’ Today + Kin derived providers |
| Note write | Journal streams + **all-notes gallery summaries** |
| Theme change | Root `KinApp` theme rebuild + Vintage asset resolve |
| App resume | Notification sync + settings write (`lastReconciledAt`) |

---

## 3. Startup Critical Path

| Step | File | Before first frame? | Class |
|---|---|---|---|
| Desktop shell | `configureDesktopPhoneShell` | Yes (desktop) | I/O + delay |
| `readSettings()` | `bootstrap.dart` â†’ Drift | **Yes â€” blocks** | DB / migrate |
| `notificationService.initialize()` | bootstrap | **Yes â€” blocks** | Plugin + tz |
| `runApp` | bootstrap | First frame starts | â€” |
| `synchronizeStartup` | NotificationLifecycleGate post-frame | After first frame | Heavy DB + OS |

**Classification**

| Work | Verdict |
|---|---|
| Settings read for theme | **A â€” must before first frame** (or show unthemed flash) |
| Full notification reconcile | **B â€” after first frame** (already) |
| Desktop window polish | **C â€” can be lazier** |
| Vintage assets | **C â€” lazy on theme** (already path-null for Default) |
| Photo resolves | **C â€” lazy per widget** |
| Migrations | **A when upgrading** â€” unavoidable on first open |

---

## 4. Rendering / Frame Performance

| Hotspot | Cost type | Evidence |
|---|---|---|
| `QThemeCanvas` full-bleed Vintage bg | PAINT / GPU / MEMORY | Stack + cover DecorationImage |
| `QDiaryChromeStrip` 2172Ã—724 into nav bar | MEMORY / GPU | Full decode, cover |
| Journal deck `Opacity`â†’`Translate`â†’`Rotate`â†’`Scale` | COMPOSITING / GPU | `q_journal_card_deck.dart` |
| Soft `BoxShadow` on large paper cards | PAINT | Journal / Default strips |
| `ClipRRect` over textured paper | PAINT | Journal/calendar surfaces |
| Many birthday strips Ã— same asset | COMPOSITING | N Image widgets; decode once |

**Positive:** No `BackdropFilter` / blur found.

---

## 5. Widget Rebuild Analysis

| Source | Dependents | Risk |
|---|---|---|
| `peopleStreamProvider` / `profilesStreamProvider` | `homeGroups`, Today, Kin | Broad â€” any row change |
| `galleryMemorySummariesProvider` | People carousel cards | **All notes** |
| `appSettingsProvider` | Theme notifier, reminders, settings UI | Whole settings object |
| Portrait `PageController` listener | Entire carousel `setState` | Every swipe frame |
| Journal deck pan/fly | Entire deck `setState` | Every pan tick |
| Home search `onChanged` | Whole `HomeScreen` `setState` | Every keystroke |
| `KinApp` theme watch | Entire `MaterialApp` | Theme switch only |

No `autoDispose` providers found â€” tab keep-alive keeps watches forever.

---

## 6. Image / Asset Analysis

Decoded estimate = `W Ã— H Ã— 4` (RGBA). **No `cacheWidth`/`cacheHeight`/`ResizeImage`/`precacheImage` in `lib/`.**

| Asset | Dims | File | Est. decoded | Usage | Risk |
|---|---|---|---|---|---|
| `vintage-bg.webp` | 941Ã—1672 | ~280 KB | **~6.0 MB** | Every Vintage screen | HIGH |
| `bottom-navbar.webp` | 2172Ã—724 | ~292 KB | **~6.0 MB** | Bottom nav | HIGH |
| `user-strip.webp` | 2172Ã—724 | ~225 KB | **~6.0 MB** | Birthday strips | HIGH |
| `profile_card.webp` | 941Ã—1672 | ~555 KB | **~6.0 MB** | People cards | HIGH |
| `Journal-Card.webp` | 1402Ã—1122 | ~296 KB | **~6.0 MB** | Journal paper | HIGH |
| `Calendar.webp` | 1254Ã—1254 | ~219 KB | **~6.0 MB** | Month grid | MED |
| `search.webp` | 2090Ã—341 | ~203 KB | **~2.7 MB** | People search | MED |
| Mood Ã—8 | 739Ã—768 | ~190â€“275 KB | **~2.2 MB each** | Picker / peeks | MEDâ€“HIGH burst |
| `Excited-home.webp` | 739Ã—768 | ~187 KB | **~2.2 MB** | Empty Today | LOWâ€“MED |

**If all theme WebPs hot:** ~**58 MB** RGBA (+ GPU copies). Typical shell (bg+nav) alone ~**12 MB**.

User photos: ingest capped at 1024 long edge; display still full `FileImage` without size hint (44px avatars can decode up to ~4 MB).

---

## 7. Theme Asset Loading Analysis

| Claim | Verdict |
|---|---|
| Default constructs Vintage ImageProviders | **No** â€” `AppThemeAssets.none()`, null guards |
| Vintage assets ship in APK always | **Yes** â€” install size, not RAM until resolved |
| Theme switch loads Vintage | **Yes** â€” first paint of bg/nav/etc. |
| Duplicate theme definition cost | Low â€” static registry |
| Image cache pollution across themes | **REQUIRES RUNTIME** â€” old textures may linger until eviction |

---

## 8. Database / Drift Analysis

| Pattern | Where | Issue |
|---|---|---|
| Full `people` / `profiles` watch | home providers | Fine at small N; scales poorly |
| Full non-deleted `notes` watch | `galleryMemorySummariesProvider` | Over-fetch for â€œlatest memoryâ€ |
| Month markers `asyncMap` + day re-fetch | journal repo | Extra query per emit |
| Notification `_desiredPlans` | coordinator | Full-table batch on start/resume |
| Settings `watchSingle` | app settings | Coarse invalidation |
| Schema v9 migrate | first open after upgrade | Can block cold start |

**Positive:** Indexes present; DB open on background isolate.

---

## 9. State Management Analysis

```
people/profiles write
  â†’ homeGroups + galleryEntries
  â†’ Today + Kin (even if Offstage)

notes write
  â†’ journal streams
  â†’ galleryMemorySummaries (if People ever subscribed)

settings write / resume sync
  â†’ appSettings fan-out
  â†’ theme notifier (theme id change â†’ full app theme)
```

Clock is a stable `Provider` â€” **no per-second rebuilds** (good). Day-boundary refresh is passive until another event.

---

## 10. Navigation Lifecycle Analysis

- Tabs: **`StatefulShellRoute.indexedStack`** â†’ keep-alive.
- Switching tabs does **not** remount roots (good for state; costly for streams).
- Child routes (person, journal day, settings) push on root navigator â€” remount on each visit (expected).
- Kin Birthdays/People: inner `PageView` keeps **both** children built.

Behavior must stay unchanged; only stream subscription / build scope should be optimized later.

---

## 11. Carousel / PageView Analysis

| Surface | Issue | Severity |
|---|---|---|
| People `PortraitGalleryCarousel` | `setState` every page tick; virtual loop Ã—500; profile plate + photo on adjacent pages | **P1** |
| Journal `QJournalCardDeck` | `setState` on pan; Opacity+3 Transforms; up to 4 card surfaces | **P1** |
| Home mode PageView | Both panes alive | **P2** |
| Welcome PageView | One-shot onboarding | **P4** |

---

## 12. Animation Analysis

- No infinite decorative loops found.
- `QPressable` / mood / nav underline animations are small-scope (OK).
- Deck fly + gallery swipe are the expensive ones (rebuild + compositing).
- Controllers: deck disposes fly controllers â€” **STATIC OK**; full leak check **REQUIRES RUNTIME**.

---

## 13. Memory / Leak Analysis

| Risk | Evidence |
|---|---|
| Theme ImageCache growth | Large bitmaps, no size hints |
| Tab keep-alive | Three roots + streams forever |
| No `autoDispose` on families | Person/journal providers may linger after pop |
| Controllers | Mostly look disposed; confirm in profiler |

---

## 14. UI-Isolate / CPU Analysis

| Work | Isolate | Notes |
|---|---|---|
| DB open | Background | Good |
| Provider map/sort of people | UI | Cheap at tens of people |
| All-notes map for gallery | UI | Grows with notes |
| TextPainter Ã—8 mood labels | UI | Negligible |
| Image decode | Engine/async | Can hitch UI if large |
| Notification plan build | UI post-frame | Can take seconds on Android (comment) |

---

## 15. Search Analysis

- People search: `TextEditingController` + `HomeScreen.setState` on every change â†’ rebuilds masthead + pager + gallery.
- Filtering is in-memory on `galleryEntries` (not a DB query per keystroke) â€” good.
- No debounce found â€” **P2** rebuild scope, not query spam.

---

## 16. Time / Live Update Analysis

- **No periodic timers** for countdowns.
- Days-until is static until data/lifecycle events.
- Midnight rollover wonâ€™t refresh UI until another trigger â€” correctness tradeoff, not jank.

---

## 17. APK / Asset Size Analysis

- Theme WebPs already compressed (~4.1 MB) â€” good.
- Fonts ~800 KB (Caveat+Fraunces+Courier) â€” both themes need them.
- Transparent chrome canvases (2172Ã—724 with empty margins) inflate **decoded** memory more than disk.
- Default ships with Vintage assets in the binary (install size only).

---

## 18. Cache Analysis

- Flutter default image cache only; no app tuning.
- Riverpod retains providers (no autoDispose).
- Drift is source of truth â€” appropriate.
- Missing: decode-at-display-size cache keys via `ResizeImage`.

---

## 19. Debug vs Profile vs Release

| Risk | Mostly |
|---|---|
| First-run jank / asserts | Debug |
| Image decode + compositor cost | **Release-visible** |
| IndexedStack stream fan-out | Release-visible |
| Notification sync duration | Release (worse on device) |
| Golden/test overhead | N/A for users |

**Validate with:** `flutter run --profile` + DevTools Performance / Memory / Rebuild stats.

---

## 20. Performance Hotspot Table (ranked)

| ID | Sev | Area | Location | Evidence | Impact | Fix direction |
|---|---|---|---|---|---|---|
| IMG-001 | **P1** | Theme decode | chrome/bg `Image.asset` / DecorationImage | No cacheWidth; 6MB RGBA for small paint | Memory, swipe hitch | Decode at display px |
| CAR-001 | **P1** | People carousel | `portrait_gallery_carousel.dart` listener | `setState` per frame | Jank | Narrow rebuild / listenables |
| DECK-001 | **P1** | Journal deck | `q_journal_card_deck.dart` | Opacity+Transforms + setState | Jank / GPU | RepaintBoundary; less Opacity |
| NAV-001 | **P1** | Tab keep-alive | `router.dart` indexedStack | Streams always live | CPU/DB wakeups | Narrow watches / pause offstage |
| DB-001 | **P1** | Gallery notes | `gallery_providers.dart` | Watch all notes | Rebuild/CPU | Aggregate query / limit |
| BOOT-001 | **P1** | Startup | `bootstrap.dart` | await DB+notif before runApp | Slow first paint | Defer non-theme work |
| SYNC-001 | **P1** | Notifications | coordinator startup | Full-table + OS sync | Post-start hitch | Stagger / yield |
| HOME-001 | **P2** | Search | `home_screen.dart` | setState whole tree | Typing lag | Localize state |
| SET-001 | **P2** | Settings fan-out | `appSettingsProvider` | Whole-row watch | Extra rebuilds | `select` / split |
| PHOTO-001 | **P2** | Avatars | `personPhotoProvider` | Full FileImage | List memory | ResizeImage |
| DUP-001 | **P2** | Derived compute | home vs gallery | Duplicate joins/sorts | CPU | Share one pipeline |
| FONT-001 | **P3** | Fonts | pubspec | Always load 3 families | Startup I/O | Keep (needed) |
| TIME-001 | **P4** | Countdowns | â€” | No timers | None | Donâ€™t add |

---

## 21. Quick Wins (do first after audit)

1. `cacheWidth`/`cacheHeight` (or `ResizeImage`) on theme chrome + moods + user avatars.  
2. Stop gallery from watching **all** notes â€” summary query or limit.  
3. Reduce carousel/deck `setState` blast radius.  
4. Measure cold start: split bootstrap awaits under a profile build.

---

## 22â€“24. Medium / Architectural / Donâ€™t touch

**Medium:** debounce People search; `select` on settings; RepaintBoundary on cards; pause Offstage tab providers carefully.

**Architectural:** reconsider indexedStack vs lazy branches **without** changing back-stack UX; notification sync scheduling.

**Donâ€™t touch yet:** typography system, product-theme architecture, navigation semantics, pin behavior, quality of Vintage art (donâ€™t crush quality blindly), adding isolates for tiny sorts.

---

## 25â€“26. Prioritized Implementation Plan

### PHASE 1 â€” Highest impact / lowest risk
| Fix | File | Problem | Change | Benefit | Risk | Must not change |
|---|---|---|---|---|---|---|
| Display-size decode | `q_diary_chrome_strip`, strips, plates, moods, `QPhoto`/`QAvatar` | Full-res RGBA | `cacheWidth` from logicalÃ—DPR | âˆ’memory, smoother swipe | Low | Visual look |
| Gallery notes scope | `gallery_providers.dart` | All-notes watch | Per-profile latest / SQL aggregate | Less rebuild | Med | Summary accuracy |
| Bootstrap deferral | `bootstrap.dart` | Notif init blocks first frame | Theme settings first; notif after runApp | Faster first paint | Med | Theme correctness |

### PHASE 2 â€” Rendering + rebuilds
| Fix | File | Problem | Change |
|---|---|---|---|
| Carousel listenables | `portrait_gallery_carousel.dart` | setState/frame | AnimatedBuilder / page-only rebuild |
| Deck compositing | `q_journal_card_deck.dart` | Opacity stacks | Avoid Opacity on full card; RepaintBoundary |
| Search localize | `home_screen.dart` | Whole-tree setState | Local StatefulBuilder / provider |

### PHASE 3 â€” Image + memory
| Fix | Detail |
|---|---|
| Crop transparent chrome canvases | Smaller intrinsic â†’ less decode waste |
| Precache only active theme | After first frame |
| ImageCache budget | Tune if profiler shows thrash |
| Avatar ResizeImage | 44â€“96 dp targets |

### PHASE 4 â€” Database + state
| Fix | Detail |
|---|---|
| Share home/gallery birthday pipeline | One derived source |
| Settings `select` | Avoid fan-out on unrelated fields |
| Month markers query | Remove redundant day fetch |
| autoDispose for pushed routes | After leave person/journal day |

### PHASE 5 â€” Startup + lazy init
| Fix | Detail |
|---|---|
| Keep settings-before-paint | Minimal |
| Defer notification sync | Already post-frame; yield between OS ops |
| Desktop window setup | Parallel / after first frame |

### PHASE 6 â€” Advanced
| Fix | Detail |
|---|---|
| Lazy shell branches | Only if UX/back stack preserved |
| Isolate for huge note aggregation | Only if N is large in profile |
| Density-specific asset packs | Optional |

---

## Runtime profiling checklist (before claiming wins)

1. `flutter run --profile`  
2. Cold start â†’ time to first useful frame  
3. DevTools: UI/Raster during People swipe + Journal deck dismiss  
4. ImageCache `currentSizeBytes` after Today â†’ People â†’ Journal â†’ mood sheet  
5. Rebuild stats: edit a person while on Journal (Offstage Today/Kin)  
6. Resume app: duration of `synchronize`

---

### Bottom line

Disk assets are already lean. The app will feel â€œinstantâ€ mainly by **decoding less**, **rebuilding less during gestures**, **watching less while Offstage**, and **not blocking first frame on non-theme work**. Default is not secretly loading Vintage images; Vintage pays a predictable ~12 MB+ shell decode tax unless display-size decoding is added.

**Next step when you want implementation:** start Phase 1 only, with profile traces before/after.
