# Kin — Design & Architecture Dossier

> Working product name: **Kin**. Working design language name: **Quiet**.
> Quiet is implemented as the current design language. Kin remains a working
> product name and can be changed before the first release build.

An offline-first birthday reminder and relationship memory companion.
This folder is the product, UX, design, and target-architecture specification.
It was produced before implementation and is now maintained alongside the
repository.

## Implementation status

**Phases 0, 1, and the scoped Phase 2 core foundation are complete.** The
repository now contains the Flutter foundation, the Quiet design system,
Drift-backed persistence, domain models, repository implementations, Riverpod
infrastructure providers, persisted appearance state, a local image-store
abstraction, and the first application router/shell. The runtime app opens the
Phase 2 foundation shell, with the Quiet gallery still available at `/gallery`.

No product screens, timezone engine, notification scheduler, photo picker/crop
UI, export/import flow, or cloud backup exist yet. Documents 09–12 remain the
target specifications for those later phases, not descriptions of shipped UI.

For the exact Phase 0–1 implementation, verification snapshot, and known
limitations, see [`../IMPLEMENTATION_PHASES_0_1.md`](../IMPLEMENTATION_PHASES_0_1.md).

## How to read this

| # | Document | Covers |
|---|---|---|
| — | [Architecture Freeze](ARCHITECTURE_FREEZE.md) | **Canonical V1 domain model — Person root, Birthday required, Profile optional** |
| 01 | [Product Vision](01-product-vision.md) | What Kin is, who it is for, what it refuses to become |
| 02 | [UX Philosophy](02-ux-philosophy.md) | Interaction laws, information architecture principles |
| 03 | [Design Philosophy](03-design-philosophy.md) | The visual thesis and its non-negotiables |
| 04 | [Design System](04-design-system.md) | Spacing, radius, surfaces, elevation, layout, states |
| 05 | [Typography System](05-typography.md) | Families, scale, tracking, numerals, responsive rules |
| 06 | [Color System](06-color.md) | Light / Dark / AMOLED, single accent, semantic roles |
| 07 | [Motion System](07-motion.md) | Durations, curves, choreography, transition catalogue |
| 08 | [Component Library](08-components.md) | Every component, every state, anatomy and sizing |
| 09 | [Architecture](09-architecture.md) | Folder structure, layering, state management, DI |
| 10 | [Data Model](10-data-model.md) | Drift schema, migrations, timezone storage, sync |
| 11 | [Notification Architecture](11-notifications.md) | Timezone engine, scheduling, budget, copywriting |
| 12 | [Screen Map & Flows](12-screens-and-flows.md) | Every screen, every flow, diagrams |
| 13 | [Roadmap](13-roadmap.md) | Phased delivery plan with exit criteria |

## Scope lock

The product implements exactly six features. Anything not on this list is out of
scope and requires an explicit decision to add:

1. Optional Google Sign-In — cloud backup only, never required
2. Offline-first local storage
3. Birthday management — name, date, location, derived timezone (required Person capability)
4. Timezone-aware reminders — person-centric; Profile never required
5. Relationship profiles — optional Person capability: nickname, relationship, photo
6. Relationship notes — favourites, gift ideas, free-form memories (belong to Profile)

**Canonical identity:** Person is the only root. See
[`ARCHITECTURE_FREEZE.md`](ARCHITECTURE_FREEZE.md).

## Research sources

Principles were extracted from primary sources, never copied:

- Apple Human Interface Guidelines — [Motion](https://developer.apple.com/design/human-interface-guidelines/motion),
  [Typography](https://developer.apple.com/design/human-interface-guidelines/typography)
- Material 3 — [easing and duration token specs](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs)
  (used only as a numeric reference for curves; the Material *look* is rejected)
- Flutter documentation — theming, `ThemeExtension`, variable fonts, `Hero`,
  implicit animations, `TextScaler`, `ClipRSuperellipse`
- Riverpod 3, Drift, `flutter_local_notifications`, `timezone` package documentation

## Phase 1 environment snapshot

| Tool | Version |
|---|---|
| Dart SDK | 3.10.4 (stable, when Phase 1 was built) |
| Target platforms | Android, iOS |

## Documentation conventions

- Documents 01–03 state the enduring product, UX, and visual principles.
- Documents 04–08 specify Quiet. Phase 1 implements the token/theme foundation
  and the components listed in the implementation report; unimplemented
  components and transitions remain target work.
- Documents 09–12 describe the target architecture, data, notifications, and
  product flows. They are not implemented yet.
- Document 13 records delivery status and the remaining roadmap.
