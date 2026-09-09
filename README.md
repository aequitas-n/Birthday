# Kin

Kin is an offline-first birthday reminder and relationship-memory companion:
it helps people remember birthdays, places, and the small details that make
someone feel known.

## Repository status

**Current implementation:** Phases 0 and 1 are complete. The app launches
into the Quiet design-system gallery; it does not yet contain product screens,
local persistence, timezone calculation, notification scheduling, or backup.

| Area | Status |
|---|---|
| Flutter Android/iOS scaffold, fonts, linting, architecture guard, CI | Implemented |
| Quiet tokens, themes, glyphs, core components, gallery, tests, goldens | Implemented |
| Database, domain models, repositories | Planned for Phase 2 |
| Timezone and notification engine | Planned for Phase 3 |
| Product screens and flows | Planned from Phase 4 |

The implementation record is [IMPLEMENTATION_PHASES_0_1.md](IMPLEMENTATION_PHASES_0_1.md).
The product, UX, design, architecture, and delivery specifications are indexed
in [docs/README.md](docs/README.md). Where a design document describes a
future capability, it is a target specification rather than an assertion that
the capability exists in code.

## Local checks

```bash
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos --fatal-warnings
dart run tool/check_architecture.dart
flutter test --exclude-tags golden
flutter test --tags golden
```

Golden baselines are platform-sensitive and are intended to be compared on the
Ubuntu CI reference environment.

there are few chnages i would like to proceed with:
1st
i dont feel like the primary 	
Caveat font family suits the title, like in the home pagee, and in any page, the the header has this, make the primary as the Fraunces
 and use the Caveat for the journal, like what i wanted, i want the jounrl motees to be old page which is done, and the note, like what people write on them to be hand written work, so chnage them 
make the wetring on them to be the Caveat, and the primary is the Fraunces
