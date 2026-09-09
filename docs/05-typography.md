# 05 — Typography System

Typography is the primary visual element of Kin. If the type is wrong, nothing
else can rescue the product.

> **Implementation status:** Strict three-font architecture in
> `QuietTypography` + `QuietTypeExpression`. Themes own primary + secondary
> personality. The product owns universal Courier Prime. Inter is not used in
> visible themed UI.

---

## 1. Three voices

```
APP / INTERFACE          PERSONAL WRITING       PRODUCT
└── Secondary (Fraunces) └── Primary (Caveat)   └── Universal (Courier Prime)
```

Hierarchy is intentional — not three equal fonts:

1. **Secondary** — editorial / application interface (titles, headings)
2. **Primary** — handwritten human voice on paper
3. **Universal** — quiet typewritten archive / utility

Screens request **semantic roles**, never `fontFamily:` strings.

### Theme-owned (`QuietTypeExpression`)

| Role | Vintage Diary | Use |
|---|---|---|
| `pageTitle` / `displayTitle` / `sectionTitle` | Fraunces | Today, Kin, Journal, Settings, sheet titles |
| `emptyStateTitle` | Fraunces | Empty-state headings on canvas |
| `personName` / `memoryTitle` / `journalTitle` | Fraunces | Names, memory titles, editorial titles |
| `editorialBody` / large `numeral*` | Fraunces | Day numbers, literary figures |
| `headline` | Fraunces | Subsection headings (Moments, etc.) |
| `diaryNote` / `annotation` / `emotionalBody` | Caveat | Emotional handwritten statements |
| `journalWriting` | Caveat | Memory body, prompts, user writing on paper |

### Product-owned universal (always Courier Prime)

Themes **must not** override `QuietTypography.universalFamily`.

| Role | Use |
|---|---|
| `uiButton` / `buttonLabel` | Buttons, primary controls |
| `uiNavigation` | Bottom nav labels |
| `uiLabel` / `uiControl` | Field labels, compact controls |
| `uiBody` / `body` / `emptyStateBody` | Functional + empty support copy |
| `uiInput` / `uiPlaceholder` | Forms |
| `uiMetadata` / `uiCaption` / `metadata` | Supporting info |
| `uiDate` / `uiTimestamp` | Dates, weekdays, times |
| `uiCount` / small numerals | "12 memories", "347 days" |
| `archive*` | Typewriter archive chrome |
| `decorativeLabel` | "August", "No. 1", paper stamps |

---

## 2. Contrast with Vintage Diary

On `vintage-bg` (dark): cream / parchment ink via `q.inked` (canvas).

On cream paper cards: brown ink via `surface: QuietSurfaceKind.paper`.

```dart
style: q.inked(q.text.pageTitle)
style: q.inked(q.text.uiDate, tone: QuietInkTone.secondary)
style: q.inked(q.text.diaryNote, surface: QuietSurfaceKind.paper)
style: q.inked(q.text.memoryTitle, surface: QuietSurfaceKind.paper)
```

Never put brown paper ink on the dark diary background.
Never put cream chrome ink on cream paper.

---

## 3. Scale notes

- Fraunces headings use optical-size variations (`opsz`, `SOFT`, `wght`).
- Caveat memory body (`journalWriting`) is 20pt with generous line height for wrapping on paper.
- Line heights are recalibrated per family after the font change.
- Future themes swap only `primaryFamily` / `secondaryFamily` on
  `QuietTypeExpression`; widgets keep calling the same roles.

### Primary — Caveat (handwriting on paper)

| Token | Size | Use |
|---|---|---|
| `journalWriting` | 20 | Memory body, prompts, writing on paper |
| `diaryNote` / `handwrittenMd` | 22 | Emotional handwritten statements |
| `handwrittenSm` | 17 | Annotations |

### Secondary — Fraunces (editorial interface)

| Token | Size | Use |
|---|---|---|
| `displayTitle` / `voice.xl` | 44 | Celebratory display |
| `pageTitle` / `voice.lg` | 32 | Screen titles |
| `sectionTitle` | 22 | Section headings |
| `voice.sm` / `personName` / `memoryTitle` | 17 | Names and memory titles |

### Universal — Courier Prime

| Token | Size | Use |
|---|---|---|
| `body` / `uiBody` | 15 | Default supporting copy |
| `label` / `uiButton` | 13 | Controls |
| `metadata` / `uiDate` | 12 | Dates and metadata |
