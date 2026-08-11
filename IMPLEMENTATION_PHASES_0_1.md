# Kin — Implementation Report (Phases 0 & 1)

**Product:** Kin  
**Design language:** Quiet  
**Accent:** Ember (`#BF6039` light / `#E4A585` dark)  
**Current repository status:** Phases 0 and 1 are complete. The app launches
into the component gallery; no product screens, persistence, timezone engine,
notification scheduling, or backup are implemented.  
**Verification snapshot:** At the last recorded verification, 80 tests passed
and the analyzer, architecture guard, and formatter were clean. This is a
historical snapshot, not a claim that the checks were run for every later
documentation-only change.  

This document describes **what was actually built in code**, not the earlier
design dossier. The dossier lives under `docs/` (01–13). This file is the
implementation record of scaffolding, the Quiet design system, the component
library, the gallery, tests, CI, and the bugs found while building.

> Synchronization note: the dossier now distinguishes implemented Phase 0–1
> work from planned work. This report remains the authoritative historical
> implementation record for those two phases.

---

## 1. Purpose of this phase

Before any Home screen, Person screen, database, or notification code was written, the project needed:

1. A Flutter app that compiles for Android and iOS  
2. A strict lint and architecture fence so Material defaults cannot creep back in  
3. Bundled variable fonts (offline-first — no CDN)  
4. The complete Quiet design system as tokens + `ThemeExtension`  
5. Real UI components built only from primitives  
6. A visual gallery to review every component  
7. Widget tests and golden baselines across light / dark / AMOLED and two text scales  
8. CI that enforces all of the above  

**Exit criteria met:** gallery renders in three themes; goldens committed; zero Material widgets in `lib/design/components/`; a planted `Scaffold`/`Card`/`ElevatedButton` fails the architecture guard.

---

## 2. What is *not* built yet

Explicitly deferred to later roadmap phases:

| Missing | Phase |
|---|---|
| Drift / SQLite database | 2 |
| Domain models, repositories | 2 |
| Timezone engine & notification scheduler | 3 |
| Home, Person, Add, Settings screens | 4–6 |
| Google Sign-In / cloud backup | 7 |
| `riverpod_generator` codegen (blocked on Dart 3.12) | 2+ |

The app currently launches into the **component gallery**, not a product UI.

---

## 3. Project identity & tooling

| Item | Value |
|---|---|
| Package name | `kin` |
| Org / Android package | `com.kinapp` |
| Version | `0.1.0+1` |
| Dart SDK constraint | `^3.10.4` |
| Platforms | Android, iOS |
| State management | `flutter_riverpod` `^3.3.2` + `riverpod_annotation` `^4.0.3` |
| Analysis | `very_good_analysis` `^9.0.0` |
| Material Icons font | **Not bundled** (`uses-material-design: false`) |

### Dependencies (current)

**Runtime**

- `flutter`
- `flutter_riverpod`
- `riverpod_annotation`

**Dev**

- `flutter_test`
- `build_runner`
- `custom_lint`
- `very_good_analysis`

### Known limitation

Phase 1 did not wire `riverpod_generator` or `riverpod_lint`; the repository
contains hand-written Riverpod notifiers only. The project SDK constraint is
`>=3.10.4 <4.0.0`, and the phase was originally built with Dart 3.10.4.
Before Phase 2 introduces Drift/Freezed code generation, the project needs an
explicit compatible Flutter/Dart and generator-version decision.

---

## 4. Repository layout (built)

```
Birthday/
├── analysis_options.yaml          # very_good_analysis + strict language + Kin rules
├── dart_test.yaml                 # tags golden tests
├── pubspec.yaml
├── assets/fonts/
│   ├── Fraunces-Variable.ttf      # Voice — names, titles, remembered details
│   └── Inter-Variable.ttf         # Text — labels, body, numerals
├── docs/                          # Design & architecture dossier (separate)
├── .github/workflows/ci.yaml
├── tool/
│   └── check_architecture.dart    # Layer + Material ban + time rules
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── kin_app.dart           # MaterialApp shim + theme animation
│   │   └── theme_controller.dart  # System / Light / Dark + AMOLED toggle
│   ├── design/                    # Quiet design system (no feature code)
│   │   ├── tokens/
│   │   ├── theme/
│   │   ├── motion/
│   │   ├── glyphs/
│   │   └── components/
│   └── features/
│       └── gallery/presentation/
│           └── gallery_screen.dart
└── test/
    ├── support/quiet_test_app.dart
    └── design/
        ├── quiet_theme_test.dart
        ├── components_test.dart
        └── goldens/
            ├── quiet_goldens_test.dart
            └── _goldens/          # 48 PNG baselines
```

---

## 5. Phase 0 — Foundation

### 5.1 Flutter scaffold

Created with:

```bash
flutter create --org com.kinapp --project-name kin --platforms=android,ios .
```

Default Cupertino Icons dependency and Material Icons usage were removed. Default `widget_test.dart` (expecting `MyApp`) was replaced with Kin’s own test harness.

### 5.2 Fonts

Bundled as assets (offline-first):

| Family | File | Role |
|---|---|---|
| Fraunces | `assets/fonts/Fraunces-Variable.ttf` | Human content (names, titles, notes) |
| Inter | `assets/fonts/Inter-Variable.ttf` | Functional UI + tabular numerals |

Axes used: Fraunces `opsz`, `SOFT`, `wght`, `WONK=0`; Inter `opsz`, `wght`. Contextual Inter features `cv05` and `ss03` enabled where applicable.

### 5.3 Analysis options

`analysis_options.yaml` includes `very_good_analysis` and enables:

- `strict-casts`, `strict-inference`, `strict-raw-types`
- Fatal treatment for unused imports/locals, missing params/returns, deprecated member use
- Const / final / package-import / trailing-comma preferences
- Excludes `*.g.dart`, `*.freezed.dart`, `build/**`

### 5.4 Architecture guard

`tool/check_architecture.dart` — run via `dart run tool/check_architecture.dart`. CI fails on any violation.

**Layer rules**

| ID | Rule |
|---|---|
| ARCH-01 | `domain/` must not import Flutter, Drift, Firebase, Riverpod |
| ARCH-02 | `design/` must not import features / data / domain |
| ARCH-03 | Features must not import other features’ presentation |
| ARCH-04 | Features & components must not import raw `design/tokens/` |

**Style rules**

| ID | Rule |
|---|---|
| STYLE-01 | Banned Material/Cupertino widgets in features & components |
| STYLE-02 | No `Colors.` / `CupertinoColors.` outside tokens |
| STYLE-03 | No raw `Color(0x…)` outside tokens |
| STYLE-04 | No inline `TextStyle(` outside tokens / theme |
| STYLE-05 | No `Theme.of(context).colorScheme` / `textTheme` outside theme |
| STYLE-06 | No `ColorScheme.fromSeed` |

**Time rules** (prepare Phase 3)

| ID | Rule |
|---|---|
| TIME-01 | No `DateTime.now()` outside `lib/core/clock.dart` |
| TIME-02 | No `DateTime.parse` in `domain/` |

**Banned widgets** (STYLE-01) include among others:  
`Scaffold`, `AppBar`, `Card`, `ListTile`, `FloatingActionButton`, `AlertDialog`, `BottomNavigationBar`, `Chip`, `Divider`, `ElevatedButton` / `FilledButton` / `OutlinedButton` / `TextButton`, `IconButton`, `TextField` / `TextFormField`, `Switch`, `Checkbox`, `CircularProgressIndicator`, `showModalBottomSheet`, `showDialog`, `showDatePicker`, …

Verified by planting a probe file with `Scaffold` + `Card` + `ElevatedButton` under `features/` — guard reported 3 violations — then deleting the probe.

### 5.5 CI

`.github/workflows/ci.yaml` two jobs:

1. **verify** — `pub get`, `dart format --set-exit-if-changed`, `flutter analyze --fatal-infos --fatal-warnings`, architecture guard, optional codegen freshness, `flutter test --exclude-tags golden`
2. **goldens** — `flutter test --tags golden` on `ubuntu-latest`, upload failure artifacts

### 5.6 Dart test tags

`dart_test.yaml` tags golden tests so the main suite can run without pixel comparison.

---

## 6. Phase 1 — Quiet design system

### 6.1 Access pattern

Every widget reads the design language through:

```dart
final q = context.quiet;
Text('Priya', style: q.text.voiceLg.tinted(q.color.textPrimary));
Padding(padding: EdgeInsets.all(q.space.base), child: ...);
```

Typography is exposed as `q.text`, **not** `q.type`.  
Reason: `ThemeExtension` already has a `type` getter used as the map key for `ThemeData.extensions`. Naming a field `type` shadowed it and made `Theme.of(context).extension<QuietTheme>()` return null. A regression test guards this.

### 6.2 Token files (`lib/design/tokens/`)

| File | Contents |
|---|---|
| `color_tokens.dart` | Raw ramps: Ember, paper/charcoal/void neutrals, danger, scrims, shadows, monogram tints, selection |
| `type_tokens.dart` | `QuietTypography` — Voice (Fraunces) + Text (Inter) + numeral styles; `inherit: false`; explicit `wght` axis |
| `space_tokens.dart` | `QuietSpace` 4pt grid + `QuietLayout` gutters, row heights, breakpoints |
| `radius_tokens.dart` | `QuietRadius` + superellipse threshold (≥14) |
| `motion_tokens.dart` | Durations, curves, spring, stagger, press scale, sheet recede |
| `elevation_tokens.dart` | Light / dark / AMOLED shadow recipes |

Widgets **must not** import these files (ARCH-04). They consume semantic roles via `QuietTheme`.

### 6.3 Theme layer (`lib/design/theme/`)

| File | Role |
|---|---|
| `quiet_colors.dart` | Semantic roles for light / dark / AMOLED + monogram tint hashing + `lerp` |
| `quiet_theme.dart` | `ThemeExtension<QuietTheme>` bundling color, elevation, text, space, layout, radius, motion |
| `quiet_theme_x.dart` | `context.quiet`, hairline width, gutters, text scalers, `TextStyle.tinted` |
| `material_shim.dart` | Minimal `ThemeData` for framework plumbing only — no `fromSeed`, no splash |

**Three concrete themes**

| Mode | Canvas | Notes |
|---|---|---|
| Light | `#FBFAF8` warm paper | Accent Ember 500 |
| Dark | `#141311` warm charcoal | Accent Ember 300 |
| AMOLED | `#000000` | Canvas == surface; structure via hairlines |

**Theme preference** (`lib/app/theme_controller.dart`)

- Top-level: System / Light / Dark  
- AMOLED is a toggle nested under dark (not a fourth mode)  
- Theme changes animate via `QuietTheme.lerp` over `motion.base` (240ms)

### 6.4 Motion (`lib/design/motion/quiet_motion.dart`)

`QuietMotion.of(context)` resolves durations/offsets/scales against `MediaQuery.disableAnimations`. When reduced motion is on, positional/scale animation collapses; opacity fades remain.

### 6.5 Glyphs (`lib/design/glyphs/quiet_glyphs.dart`)

Twelve `CustomPainter` glyphs on a 24pt grid, 1.5pt stroke, round caps/joins:

`plus`, `search`, `chevronLeft`, `chevronRight`, `chevronDown`, `close`, `check`, `camera`, `calendar`, `pin`, `gift`, `ellipsis`

Rendered via `QGlyphIcon`. No Material Icons font.

---

## 7. Component library (`lib/design/components/`)

All components are prefixed `Q`. Built from Flutter primitives. No Material presentation widgets.

### Surfaces

| Component | File | Purpose |
|---|---|---|
| `QSurface` | `surfaces/q_surface.dart` | Fill levels (canvas/surface/raised/sunken), hairline/lift/overlay elevation, circular or superellipse corners |
| `QClip` | same | Clip children to Quiet corner geometry |
| `QHairline` | `surfaces/q_hairline.dart` | 1 physical-pixel separator with optional indent |
| `QScreen` | `surfaces/q_screen.dart` | Scaffold replacement: canvas + SafeArea + DefaultTextStyle |
| `QMeasure` | same | Centers content at max width 560 on large screens |

### Feedback

| Component | File | Purpose |
|---|---|---|
| `QPressable` | `feedback/q_pressable.dart` | Press scale anchored at touch point, sunken tint, focus ring, semantics |
| `QArc` | `feedback/q_arc.dart` | Thin sweeping loading arc (replaces Material progress indicators) |
| `QEmptyState` | `feedback/q_empty_state.dart` | Headline + support + optional glyph + action |

### Buttons

| Component | File | Purpose |
|---|---|---|
| `QButton` | `buttons/q_button.dart` | primary / secondary / tertiary / destructive; delayed spinner; frozen width while loading |
| `QIconButton` | `buttons/q_icon_button.dart` | 44×44 hit area; required semantic label |

### Media & rows

| Component | File | Purpose |
|---|---|---|
| `QAvatar` | `media/q_avatar.dart` | sm/md/lg/hero; photo or monogram; Hero tag support |
| `QSectionHeader` | `rows/q_section_header.dart` | Uppercase eyebrow section title |
| `QPersonRow` | `rows/q_person_row.dart` | Home list row: avatar, serif name, subtitle, countdown / today accent |

### Fields

| Component | File | Purpose |
|---|---|---|
| `QField` | `fields/q_field.dart` | Built on `EditableText` (not `TextField`); eyebrow label; sunken well; reserved helper/error line; constant border width so focus/error never shift layout |
| `QPill` / `QPillGroup` | `fields/q_note_kind_picker.dart` | Selectable pills for note kinds / relationships |

### Sheets

| Component | File | Purpose |
|---|---|---|
| `QSheet` | `sheets/q_sheet.dart` | Raised sheet with grabber, title, optional bottom actions |
| `QBottomActions` | same | Max two actions, right-aligned |
| `QSheetRoute` / `showQSheet` | `sheets/q_sheet_route.dart` | T2 slide/fade presentation; drag-to-dismiss with velocity |

---

## 8. Application shell

| File | Role |
|---|---|
| `lib/main.dart` | `ProviderScope` + `KinApp` |
| `lib/app/kin_app.dart` | `MaterialApp` only for routing/overlays/selection; theme from Quiet; home = `GalleryScreen` |
| `lib/features/gallery/presentation/gallery_screen.dart` | Live gallery of typography, colours, buttons, glyphs, avatars, person rows, fields, pills, surfaces, sheets, empty state; appearance switcher |

Run:

```bash
flutter run
```

---

## 9. Testing

### Support

`test/support/quiet_test_app.dart`

- Loads Fraunces + Inter into the test binding  
- `QuietTestApp` wraps ProviderScope + Material shim + fixed text scale  
- `pumpQuiet()` helper for consistent surface size  
- Exports `quietThemes` and `quietTextScales` maps  

### Suites

| Suite | Count (approx) | Covers |
|---|---|---|
| `quiet_theme_test.dart` | Theme/lerp/AMOLED/monogram/preference | Extension lookup, lerp endpoints, AMOLED black, warm canvas, monogram determinism |
| `components_test.dart` | Component behaviour | Buttons, icon buttons, avatars, person rows, fields, empty state, section headers, a11y labels, restack at large text scale |
| `quiet_goldens_test.dart` | 48 goldens | 8 specimens × 3 themes × 2 text scales |

**Total:** 80 tests passing at last verification.

### Golden specimens

`typography`, `buttons`, `person-rows`, `fields`, `avatars-glyphs`, `pills-surfaces`, `empty-state`, `sheet`  
each in `light` / `dark` / `amoled` at `1.0x` and `1.3x`.

Regenerate on the reference platform:

```bash
flutter test --tags golden --update-goldens
```

---

## 10. Bugs found and fixed during Phase 1

These are documented because they are easy to reintroduce.

### 10.1 `QuietTheme.type` broke theme lookup

Shadowing `ThemeExtension.type` made the extension disappear from `ThemeData`.  
**Fix:** rename to `text`. Regression test asserts `Theme.of(context).extension<QuietTheme>()` is non-null.

### 10.2 Yellow double underlines on every line of type

Without `Scaffold`, no ambient `DefaultTextStyle` existed; styles with `inherit: true` merged with Flutter’s debug “missing style” fallback.  
**Fix:** every typography token sets `inherit: false`; `QScreen` and `QuietTestApp` supply a real `DefaultTextStyle`.

### 10.3 Fraunces always looked bold

When `fontVariations` is set, `fontWeight` does not drive the variable `wght` axis.  
**Fix:** each style passes `FontVariation('wght', …)` explicitly alongside `opsz` / `SOFT`.

### 10.4 Field height jumped on error

A 1.5pt focus/error border changed the shape’s outer size.  
**Fix:** border always present at constant width; only colour changes between rest / focus / error. Helper/error text space always reserved.

### 10.5 Person-row semantics double-announced

Child text leaked under the row’s composite label.  
**Fix:** `QPressable` uses `excludeSemantics` when a `semanticLabel` is provided.

### 10.6 ARCH-04 violated by `tinted()` helper

Components imported `type_tokens.dart` only for `TextStyle.tinted`.  
**Fix:** move extension to `quiet_theme_x.dart`; remove token imports from components.

---

## 11. Design decisions encoded in code

| Decision | Implementation |
|---|---|
| Type is the interface | Fraunces for human content; Inter for UI; no Material text themes |
| One accent only | Ember roles; gallery and components use accent sparingly |
| No Material look | Banned widgets + custom components + `uses-material-design: false` |
| Superellipse corners | `RoundedSuperellipseBorder` / clip when radius ≥ 14 |
| Hairlines are physical pixels | `1 / devicePixelRatio` |
| Press feels expensive | Scale about touch point, not widget centre |
| Empty state is first-class | `QEmptyState` composition |
| Undo over confirm | Spec’d; undo bar not yet implemented (later phase) |
| Offline fonts | Assets only, no Google Fonts runtime fetch |

---

## 12. How to verify locally

```bash
# Dependencies
flutter pub get

# Static analysis
flutter analyze --fatal-infos --fatal-warnings

# Architecture fence
dart run tool/check_architecture.dart

# Format check
dart format --output=none --set-exit-if-changed .

# Unit / widget tests (no goldens)
flutter test --exclude-tags golden

# Golden comparison
flutter test --tags golden

# Full suite
flutter test

# Visual review
flutter run
```

---

## 13. Verification snapshot (last run)

| Check | Result |
|---|---|
| `flutter analyze` | No issues found |
| `dart run tool/check_architecture.dart` | Passed — 31 files scanned |
| `dart format --set-exit-if-changed` | Clean |
| `flutter test` | **80 passed** |
| Material probe | Guard fails correctly, then probe removed |
| Golden baselines | **48 PNGs** under `test/design/goldens/_goldens/` |

---

## 14. Next work

Per `docs/13-roadmap.md`:

1. **Phase 2** — Drift schema, repositories, domain models (needs Dart/Flutter upgrade for generators, or pinned alternatives)  
2. **Phase 3** — Timezone occurrence calculator + notification reconciler  
3. **Phase 4** — Core product screens (Home, Person, Add) using the Quiet components already built  

Phase 1 deliberately stops before product screens so the design language can
be reviewed and locked first. Documentation synchronization is complete; the
next implementation phase is Phase 2, subject to the generator/toolchain
decision above.

---

## 15. Relation to the dossier

| Document set | Location | Contents |
|---|---|---|
| Product & design dossier | `docs/01` … `docs/13` | Vision, UX, design system specs, architecture, DB, notifications, flows, roadmap |
| **This implementation report** | **this file** | What was coded in Phases 0–1 |

Submit `docs/` for the design/architecture review. Submit **this file** for the build/implementation review of work completed so far.

---

*End of implementation report.*
