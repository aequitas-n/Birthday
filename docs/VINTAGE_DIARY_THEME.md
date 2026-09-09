# Vintage Diary — Product Theme

> **Status:** Vintage Diary is the sole visual identity of Kin. Superficial
> colour collections (Ember, Ocean Mist, etc.) are retired.

## Identity

The app reads as one old personal diary / memory archive:

- Dark aged parchment background (`vintage-bg.png`)
- Cream / ivory ink on dark surfaces
- Brown-black ink on paper cards
- Faded burgundy (`#713D3A`) for primary actions
- Literary serif (Fraunces), typewriter (Courier Prime), handwritten (Caveat)

Source specs:

- `assets/themes/Vintage-Diary/vintage_diary_app_visual_design_system.txt`
- `assets/themes/Vintage-Diary/vintage_diary_buttons_actions_decoration.txt`

## Interactive surfaces & navigation

Three environmental layers must stay visually distinct:

1. **Background** — dark textured `vintage-bg`
2. **App surfaces** — cream parchment sheets, dialogs, desk CTAs, inputs
3. **Navigation** — cream parchment strip (`QuietNavigation.surface`) with brown ink

Semantic tokens live on `QuietTheme.interactive` and `QuietTheme.navigation`.
Controls read ambient `QuietControlSurfaceScope` (`desk` vs `parchment`) so
the same `QButton.primary` is cream-on-desk or burgundy-on-card.

**Explicit exception:** Add memory inside Today's Journal card stays burgundy
(parchment host).

---

## Palette (semantic)

| Role | Token | Hex |
|---|---|---|
| Canvas (fallback) | `ColorTokens.vdDiaryCanvas` | `#2A1E18` |
| Surface | `ColorTokens.vdDiarySurface` | `#3A2E26` |
| Text primary | `ColorTokens.vdCreamPrimary` | `#F4EEDF` |
| Text secondary | `ColorTokens.vdCreamSecondary` | `#E4D0C2` |
| Text tertiary | `ColorTokens.vdCreamTertiary` | `#C9B4A4` |
| Accent | `ColorTokens.vdBurgundy` | `#713D3A` |
| Paper (journal cards) | `ColorTokens.vdPaperWarm` | `#F4EEDF` |
| Ink on paper | `ColorTokens.vdInkPrimary` | `#332B27` |

## Typography roles

Strict three-font architecture — screens request **roles**, never font families.

```
THEME                          PRODUCT
├── Primary  → Caveat          └── Universal → Courier Prime
└── Secondary → Fraunces
```

### Theme personality (`QuietTypeExpression.vintageDiary`)

| Role | Family |
|---|---|
| `pageTitle` / `sectionTitle` / `emptyStateTitle` / `headline` | Fraunces |
| `personName` / `memoryTitle` / `editorialBody` / literary `voice*` | Fraunces |
| `journalWriting` / `diaryNote` / `emotionalBody` | Caveat |

### Product universal (always Courier Prime)

`uiDate`, `uiTimestamp`, `uiMetadata`, `uiButton`, `uiNavigation`, `uiCount`,
`uiBody`, `emptyStateBody`, `decorativeLabel`, `body`, `label`, …

Themes may not override `QuietTypography.universalFamily`.

Cream on dark canvas / brown on paper — pick a surface, not a hex:

```dart
style: q.inked(q.text.pageTitle) // canvas primary (default)
style: q.inked(q.text.uiDate, tone: QuietInkTone.secondary)
style: q.inked(q.text.diaryNote, surface: QuietSurfaceKind.paper)
style: q.inked(q.text.memoryTitle, surface: QuietSurfaceKind.paper)
```

`q.canvas` / `q.paper` expose `primary` · `secondary` · `tertiary` · `border` · `fill`.
Bordered open wells: `QDiaryWell`.

## Background

`VintageDiaryCanvas` wraps every `QScreen` (unless `canvasColor` is overridden):

- `BoxFit.cover` texture from `assets/themes/Vintage-Diary/vintage-bg.png`
- Radial vignette for corner readability
- Fallback fill `vdDiaryCanvas` while the asset loads

## Material hierarchy

| Tier | Treatment |
|---|---|
| Primary artifact | Journal card asset, photo mounts, memory fragments |
| Secondary surface | Semi-transparent raised surfaces on dark canvas |
| Functional control | Burgundy primary button, hairline secondary, text tertiary |

## Journal card

Today's journal preview uses `VintageDiaryJournalCard` with the
`Journal-Card.png` asset as the physical page surface.

## Brightness modes

Three internal adaptations share the same identity:

- **Light** — standard Vintage Diary contrast
- **Dark** — slightly brighter cream type
- **AMOLED** — deepest black-brown canvas

There is no separate “modern light theme.”

## Handwritten font

**Caveat** (Google Fonts, OFL) — bundled at `assets/fonts/Caveat-Variable.ttf`.

## Accessibility

- Cream ink on dark parchment meets contrast targets for body and controls
- Decorative handwriting never carries sole responsibility for critical info
- Touch targets unchanged (44pt minimum)

## Implementation map

| Area | Location |
|---|---|
| Raw palette | `lib/design/tokens/color_tokens.dart` (`vd*` constants) |
| Assets | `lib/design/tokens/vintage_diary_tokens.dart` |
| Semantic colours | `lib/design/theme/quiet_colors.dart` |
| Journal surfaces | `lib/design/theme/quiet_journal.dart` |
| Background / journal card | `lib/design/theme/vintage_diary_background.dart` |
| Theme resolution | `lib/app/theme_controller.dart` |
