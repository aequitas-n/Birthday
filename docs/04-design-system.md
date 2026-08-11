# 04 — Design System Specification

Design language: **Quiet**.

> **Implementation status:** The token/theme foundation, three color modes,
> glyphs, and the implemented `Q*` components are present in `lib/design/`.
> This document is the complete target contract; components and behaviours not
> listed in the Phase 0–1 implementation report remain planned. The current
> architecture guard enforces the documented high-level design boundaries, but
> it is not a complete lint implementation of every prose rule below.

All tokens are exposed to widgets through a single Flutter `ThemeExtension`
called `QuietTheme`, accessed as `context.quiet`. Widgets never read
`Theme.of(context).colorScheme` or `textTheme`. Material's `ThemeData` is
configured once, minimally, purely to keep framework internals (text selection,
scrollbars, overlay colours) from looking wrong.

```dart
// Access pattern used everywhere in the app.
final q = context.quiet;
Text('Priya', style: q.text.voiceLg.tinted(q.color.textPrimary))
Padding(padding: EdgeInsets.all(q.space.base), ...)
```

The typography sub-token is called `text`, not `type`. `ThemeExtension` already
declares a `type` getter, and that getter is the key `ThemeData.extensions` is
looked up by — shadowing it makes `Theme.of(context).extension<QuietTheme>()`
return null and silently breaks the entire design system. A regression test
guards this.

---

## 1. Spacing

A 4pt base grid. Named tokens only — raw numbers are a lint error.

| Token | Value | Primary use |
|---|---|---|
| `space.hair` | 2 | Optical nudges, icon-to-text kerning |
| `space.xs` | 4 | Inside chips, between stacked labels |
| `space.sm` | 8 | Icon gaps, tight pairs |
| `space.md` | 12 | Input inner padding, list row internals |
| `space.base` | 16 | Default gap between related elements |
| `space.lg` | 20 | Screen horizontal gutter (phone) |
| `space.xl` | 24 | Gap between unrelated elements |
| `space.xxl` | 32 | Sheet inner padding, block separation |
| `space.section` | 40 | Between sections on a screen |
| `space.chapter` | 56 | Between major regions |
| `space.void` | 96 | Above/below empty-state content |

**Layout constants**

| Token | Phone | Tablet / large |
|---|---|---|
| `gutter` | 20 | 24 |
| `contentMaxWidth` | ∞ | 560 |
| `rowHeight.person` | 64 | 64 |
| `rowHeight.setting` | 52 | 52 |
| `safeBottomInset` | `max(viewPadding.bottom, 16)` | same |

**Vertical rhythm rule.** Between any two adjacent blocks, use exactly one
spacing token — never a sum of two. If the needed gap is not in the scale, the
scale is wrong, not the layout.

---

## 2. Corner radius

| Token | Value | Shape | Applied to |
|---|---|---|---|
| `radius.xs` | 6 | Rounded rect | Tags, inline badges |
| `radius.sm` | 10 | Rounded rect | Inputs, small buttons, note pills |
| `radius.md` | 14 | Superellipse | List row press surface, tiles |
| `radius.lg` | 20 | Superellipse | Panels, photo frames, quick-action sheet |
| `radius.xl` | 28 | Superellipse | Bottom sheets (top corners only) |
| `radius.full` | 999 | Circle | Avatars, monograms, pill buttons |

**Superellipse policy.** Radii ≥14 use `ClipRSuperellipse` / a superellipse
border shape. Below 14 the visual difference is imperceptible and a standard
`BorderRadius` is used for performance.

**Nesting rule.** An inner radius equals the outer radius minus the padding
between them, floored at `radius.xs`. Concentric corners or none.

---

## 3. Surface hierarchy

Kin has **four** surface levels. There is no fifth.

| Level | Name | Meaning |
|---|---|---|
| 0 | `canvas` | The page itself. Most of the screen is this. |
| 1 | `surface` | A distinct region of content on the canvas |
| 2 | `raised` | Something temporarily above the page (sheet, menu) |
| −1 | `sunken` | An input well or a recessed region |

Rules:

- A screen may show at most **two** levels at rest. Level 2 exists only while a
  sheet or menu is open.
- Levels are never nested more than one step apart. A `raised` never contains a
  `raised`.
- On **light**, levels differ by lightness and a hairline.
- On **dark**, levels differ by lightness only (shadows are invisible).
- On **AMOLED**, `canvas` and `surface` are both pure black; separation is
  carried entirely by hairlines and type colour.

---

## 4. Elevation

Kin does not use Material elevation. Elevation is expressed as a named,
mode-aware recipe.

| Token | Light | Dark | AMOLED |
|---|---|---|---|
| `elev.flat` | none | none | none |
| `elev.hairline` | 1px `hairline` border | 1px `hairline` border | 1px `hairline` border |
| `elev.lift` | `0 2 8 rgba(38,30,22,.05)` + hairline | surface +1 step | surface +1 step |
| `elev.overlay` | `0 -2 32 rgba(38,30,22,.10)` + scrim | `0 -2 32 rgba(0,0,0,.44)` + scrim | `0 -2 32 rgba(0,0,0,.60)` + scrim |

- Shadow colour is a **warm brown-black**, never neutral black — neutral shadow
  on a warm canvas reads grey and dirty.
- Hairline width is always `1 / MediaQuery.devicePixelRatioOf(context)`.
- Scrim for overlays: `rgba(20,18,16,.32)` light, `rgba(0,0,0,.56)` dark/AMOLED.

---

## 5. Component state model

Every interactive component implements exactly these states. This table is the
contract; the component library (doc 08) only specifies deviations.

| State | Visual treatment | Duration |
|---|---|---|
| **Rest** | Base tokens | — |
| **Hover** (pointer only) | Surface lightens 3%, no movement | `quick` |
| **Focus** (keyboard / a11y) | 2pt accent ring, 3pt offset, `radius +3` | `quick` |
| **Pressed** | Scale 0.97 about the touch point, surface darkens 4% | `instant` |
| **Selected** | Accent 10% fill, accent text, no border change | `quick` |
| **Disabled** | Opacity 0.38, no shadow, no press response | `quick` |
| **Loading** | Content stays, replaced in place by a 16pt arc | see below |
| **Error** | Hairline → `danger`, message beneath in `caption` | `base` |
| **Success** | No colour change. Content updates + one haptic tick | — |

Notes:

- **Pressed scale is anchored to the touch point**, not the widget centre. This
  is the single most "expensive-feeling" micro-detail in the app.
- **Focus rings are never suppressed.** They only appear for keyboard and
  assistive input, never on touch.
- **There is no success colour.** Success is the absence of failure plus the
  changed content. Green checkmarks are a form of shouting.

---

## 6. Loading states

Ranked, in order of preference:

1. **No indicator** — operation is under 120ms. Do nothing.
2. **In-place arc** — a 16pt, 1.5pt-stroke arc in `text.tertiary`, replacing the
   label inside the control that caused it. Appears after a **120ms delay** so
   fast operations never flash.
3. **Inline whisper** — a `caption`-sized line of text ("Backing up…") in
   `text.tertiary`, used for background work like sync.
4. **Full screen** — only ever used once, on cold start while the database
   opens, and only if that exceeds 400ms.

Forbidden: shimmer skeletons over local data, progress bars for unknown
durations, modal blocking spinners.

---

## 7. Empty states

Every empty state has the same three-part anatomy and no illustration:

```
        [ optional 28pt glyph, text.tertiary ]
                    ↕ space.base
        Headline           voice.md, text.primary
                    ↕ space.sm
        One supporting line   body, text.secondary
                    ↕ space.xl
        [ single action ]     tertiary button
```

Centred in the available space, capped at 280pt wide, offset upward by 8% of
viewport height (optical centring — true centre reads low).

| Screen | Headline | Support | Action |
|---|---|---|---|
| Home, first run | No one here yet. | Add someone you'd hate to forget. | Add someone |
| Home, all deleted | Your list is empty. | The people you add will appear here. | Add someone |
| Search, no results | Nothing matches "elena". | Try a different name. | — |
| Notes, empty | Nothing saved yet. | Small details make good gifts. | Add a detail |
| Recently removed | Nothing here. | Removed people stay for 30 days. | — |

---

## 8. Error states

Three tiers, chosen by *recoverability*, never by severity.

| Tier | Presentation | Example |
|---|---|---|
| **Field** | Hairline → `danger`, `caption` message below the field, no icon | "Pick a date." |
| **Inline** | A `surface` block with a hairline in `danger` and a retry action | "Couldn't reach backup." |
| **Blocking** | Full-screen state with cause and one recovery action | Database failed to open |

Rules:
- Error text names the **cause** and the **fix**, never the exception.
- Never use the word "Error," "Failed," "Invalid," or an error code.
- Field errors appear on blur or submit, never on keystroke.
- Errors never move layout. Space for the message is reserved at build time.

---

## 9. Iconography

Kin uses a **minimal custom glyph set**, not an icon font. Approximately twelve
glyphs total, all drawn on a 24pt grid with a 1.5pt stroke, round caps, round
joins, optically balanced against the sans at `label` weight.

Complete inventory: `plus`, `search`, `chevron-left`, `chevron-right`,
`chevron-down`, `close`, `check`, `camera`, `calendar`, `pin`, `gift`,
`ellipsis`.

Rules:
- Icons never appear without a label except in the four cases above where the
  meaning is universal (`plus`, `search`, `close`, `chevron-left`)
- Icons inherit text colour; they are never accent-coloured except when selected
- Icons scale with text under Dynamic Type, clamped at 1.3×
- No filled/outlined duality — one weight only

---

## 10. Avatars

| Size token | Diameter | Use |
|---|---|---|
| `avatar.sm` | 32 | Search results, quick actions |
| `avatar.md` | 44 | Home list rows |
| `avatar.lg` | 96 | Person screen header |
| `avatar.hero` | 148 | Photo viewer entry state |

- Shape: circle at `sm`/`md`, superellipse at `lg`/`hero`
- With photo: `BoxFit.cover`, centre-weighted crop, no border
- Without photo: **monogram** — 1–2 letters from the display name in
  `voice` serif, `text.secondary`, on one of six deterministic warm neutral
  tints selected by `hash(person.id) % 6`
- Never: coloured initials on saturated backgrounds, generic person glyphs,
  gradient rings, presence dots

---

## 11. Theming implementation

```
design/
  tokens/
    color_tokens.dart      # raw ramps, no semantics
    type_tokens.dart
    space_tokens.dart
    radius_tokens.dart
    motion_tokens.dart
    elevation_tokens.dart
  theme/
    quiet_colors.dart      # semantic roles per mode
    quiet_theme.dart       # ThemeExtension<QuietTheme>
    quiet_theme_x.dart     # context.quiet extension getter
    material_shim.dart     # minimal ThemeData so framework internals behave
```

Rules enforced by review and lint:

1. No widget imports from `tokens/` directly. Widgets read semantic roles from
   `QuietTheme` only.
2. No `Color(0x...)`, no magic doubles, no `TextStyle(...)` literals outside
   `design/`.
3. Three concrete themes are constructed: `QuietTheme.light()`,
   `QuietTheme.dark()`, `QuietTheme.amoled()`. Mode selection is a persisted
   user setting with a `system` default that maps to light/dark.
4. `QuietTheme.lerp` is implemented properly so theme changes animate over
   `base` (240ms) rather than snapping.

---

## 12. Responsive behaviour

Kin targets phones first. Two breakpoints only.

| Breakpoint | Width | Behaviour |
|---|---|---|
| `compact` | < 600 | Single column, full-bleed rows, sheets from bottom |
| `expanded` | ≥ 600 | Content centred at 560pt max; sheets become centred panels at 480pt with `radius.lg` on all corners |

There is no tablet-specific navigation, no master-detail split. The same
information architecture scales; only the measure changes.
