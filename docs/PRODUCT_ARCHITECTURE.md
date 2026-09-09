# Product Architecture — Phase 4 Universal Home

**Status:** Implemented (Phase 4)  
**Companion:** [JOURNAL_ARCHITECTURE.md](JOURNAL_ARCHITECTURE.md), [ARCHITECTURE_FREEZE.md](ARCHITECTURE_FREEZE.md)

---

## 1. Product model

```
Kin App
├── Today (launch destination)     ← Universal Home
│   ├── Today's journal (preview + add)
│   └── Coming up (2–3 birthdays)
├── Kin
│   ├── Birthdays
│   └── People
└── Journal
    ├── Month
    ├── Day
    └── Memory
```

Mental model: **people I care about + things I want to remember.**  
Today answers: **what matters today?**

Person / Profile / Birthday / Notification architecture is unchanged.

---

## 2. Navigation

Bottom destinations (custom `QPrimaryNav`, not Material):

| Tab | Route | Role |
|---|---|---|
| Today | `/` | Launch surface |
| Kin | `/kin` | Full Birthdays / People |
| Journal | `/journal` | Full month map |

Deep routes stay on the root navigator:

- `/person/:id`
- `/journal/:date`
- `/journal/:date/:entryId`
- `/settings`

Notifications and deep links remain direct — Universal Home is not a gate.

Welcome still completes with `context.go('/')`, which is now Today.

---

## 3. Universal Home composition

Screen: `lib/features/today/presentation/today_screen.dart`  
Providers: `todayUpcomingProvider`, `todayBirthdayProvider` (compose `homeGroupsProvider`)

Data:

| Region | Source |
|---|---|
| Local day | `journalTodayProvider` / `clockProvider` |
| Today's memories | `journalEntriesProvider(dateKey)` — preview ≤ 3 |
| Upcoming people | `homeGroupsProvider` → take 3 |
| Birthday today | `HomeSection.today` entries |

Actions:

- **Add memory** → `openJournalMemoryEditorFlow` (`lib/app/journal_memory_launcher.dart`)
- **Add someone** → `showAddPersonFlow`
- **View today's journal** → `/journal/:today`
- **See all birthdays** → Kin branch (`/kin`)

Visual language: `QuietJournal` desk + archive / Voice typography — editorial page, not dashboard cards.

---

## 4. Typography unification

`QuietTypography` is the shared semantic layer:

| Role | Family | Use |
|---|---|---|
| Editorial (`pageTitle`, `sectionTitle`, `emptyStateTitle`, `headline`) | Fraunces | Screen titles, section headings, sheet titles |
| Voice (`voice*`, `personName`, `memoryTitle`) | Fraunces | Names, memory titles, editorial numerals |
| Handwriting (`journalWriting`, `diaryNote`) | Caveat | Memory body, personal notes, prompts on paper |
| Archive / universal (`ui*`, `archive*`, `body`) | Courier Prime | Dates, metadata, labels, buttons, nav |

Kin Birthdays / People inherit archive metadata on person rows and a Voice `Kin` masthead so Kin and Journal read as one product.

---

## 5. Architecture boundaries

- No new DB migration
- No duplicate birthday / journal domain logic
- Cross-feature UI flows via `lib/app/*_launcher.dart` (ARCH-03)
- Journal photos remain Journal-owned (`JournalEntryPhoto`); Profile notes unchanged

---

## 6. Files

| Area | Path |
|---|---|
| Today UI | `lib/features/today/presentation/today_screen.dart` |
| Today providers | `lib/features/today/application/today_providers.dart` |
| Router / shell | `lib/app/router.dart`, `lib/app/app_shell.dart` |
| Nav | `lib/design/components/navigation/q_primary_nav.dart` |
| Memory launcher | `lib/app/journal_memory_launcher.dart` |
| Docs | `docs/PRODUCT_ARCHITECTURE.md`, `docs/JOURNAL_ARCHITECTURE.md` |
