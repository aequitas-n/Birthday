# 08 — Component Library Specification

Every component below is specified to be built from Flutter primitives. **No
Material or Cupertino presentation component is used in the implemented Quiet
component layer.** Where the framework requires a Material ancestor (text
selection, overlays), a minimal shim provides it invisibly.

> **Implementation status:** Phase 1 implements `QSurface`, `QClip`,
> `QHairline`, `QScreen`, `QMeasure`, `QPressable`, `QArc`, `QEmptyState`,
> `QButton`, `QIconButton`, `QAvatar`, `QSectionHeader`, `QPersonRow`,
> `QField`, `QPill`/`QPillGroup`, `QSheet`, `QBottomActions`, and `QSheetRoute`.
> `QDateField`, `QSearchField`, note, gift, photo, undo, toggle, segmented,
> and settings-row components are specified here but are not implemented yet.

Naming convention: all components are prefixed `Q` (for Quiet) — `QButton`,
`QField`, `QSheet`. This makes an accidental `ElevatedButton` obvious in review.

Unless a component says otherwise, its target contract is the full state model
from doc 04 §5 and the motion tokens from doc 07. The current Phase 1
implementation and test coverage are recorded in the implementation report.

---

## 1. Buttons — `QButton`

Three variants. There is no fourth, and there are no sizes beyond these.

| Variant | Fill | Border | Text | Use |
|---|---|---|---|---|
| `primary` | `accent` | none | `text.inverse`, `label` w600 | The single most important action on a screen |
| `secondary` | `surface` | `hairlineStrong` | `text.primary`, `label` w500 | Alternative actions |
| `tertiary` | none | none | `text.secondary`, `label` w500 | Dismiss, skip, low-stakes |

**Anatomy**

```
┌─────────────────────────────┐
│  ↕ 12   [icon 18] ⟷8 Label  │   height 44 (min), radius.sm
└─────────────────────────────┘
   ⟷ 20 horizontal padding
```

| Property | Value |
|---|---|
| Min height | 44 |
| Horizontal padding | 20 (16 if icon-leading) |
| Radius | `radius.sm` (10) |
| Icon size | 18, optical-aligned to cap height |
| Icon gap | 8 |

**States**

| State | Treatment |
|---|---|
| Pressed | Scale 0.97 at touch point; primary → `ember.600`; secondary → `sunken` |
| Disabled | Opacity 0.38, no press response, cursor unchanged |
| Loading | Label replaced in place by a 16pt arc after 120ms delay; **width is frozen** so the button never resizes |
| Focus | 2pt `accent` ring, 3pt offset, radius 13 |

**Rules**

- Exactly **one** `primary` per screen or sheet. Zero is acceptable.
- Buttons are never full-width across the screen. Maximum width 320, or
  intrinsic + padding, whichever is smaller.
- Never stack more than two buttons. If three actions are needed, one belongs in
  a quick-actions sheet.
- Destructive actions use `secondary` with `danger` text — never a filled red
  button. Red fills read as alarm; this app does not alarm.

### `QIconButton`

44×44 hit area, 22pt glyph, no background at rest, `sunken` circle on press.
Used only for `close`, `search`, `chevron-left`, `ellipsis`.

---

## 2. Text fields — `QField`

A field is a **sunken well with a floating eyebrow**, not an outlined box and
not a Material underline.

**Anatomy**

```
FAVOURITE FLOWER                    eyebrow, text.tertiary
┌───────────────────────────────┐
│  Peonies, the pale ones       │   sunken, radius.sm, height 48
└───────────────────────────────┘
Helper or error line               caption  (space always reserved)
```

| Property | Value |
|---|---|
| Height | 48 single-line; grows to content when multiline |
| Fill | `sunken` |
| Border | none at rest; 1.5pt `accent` when focused; 1.5pt `danger` when errored |
| Radius | `radius.sm` |
| Inner padding | 14 horizontal, 12 vertical |
| Text | `bodyLg` (17pt) — larger than typical, because typing should feel unhurried |
| Placeholder | `bodyLg`, `text.tertiary` |
| Eyebrow gap | 8 above field |
| Helper gap | 6 below field, **height always reserved** so errors never shift layout |

**States**

| State | Treatment |
|---|---|
| Rest | `sunken` fill, no border |
| Focus | 1.5pt `accent` border, fill → `canvas`, `quick` |
| Filled | Identical to rest — no "has content" styling |
| Error | 1.5pt `danger` border + `caption` message in `danger` |
| Disabled | Opacity 0.38 |

**Rules**

- Labels are **eyebrows above**, never floating placeholders that animate into a
  border notch. That pattern is a Material signature.
- Validation fires on **blur or submit**, never per keystroke.
- No character counters unless a hard limit exists (notes: 280 chars).
- Multiline fields grow to a maximum of 6 lines, then scroll internally.

### `QSearchField`

A variant with a leading `search` glyph, `radius.full`, height 44, and a trailing
`close` that appears only when non-empty. Used in the search overlay only.

---

## 3. List rows

### `QPersonRow` — the most important component in the app

```
 ┌──────────────────────────────────────────────────────────┐
 │  (44)   Priya Raman                              in 3    │  height 64
 │  photo  Sister · Chennai                                 │
 └──────────────────────────────────────────────────────────┘
 ─────────────────────────────────────────────────────────── hairline (inset 20+44+16)
```

| Element | Token |
|---|---|
| Avatar | `avatar.md` (44), circle |
| Avatar → text gap | 16 |
| Name | `voice.sm` (17pt Fraunces, w500), `text.primary` |
| Subtitle | `caption`, `text.tertiary`, format `Relationship · City` |
| Countdown | `numeral.md`, `text.secondary`, right-aligned, tabular |
| Row height | 64 (grows to 76 above 1.3× text scale, layout restacks) |
| Press surface | `radius.md` superellipse, inset 8 horizontally from the gutter |
| Separator | Hairline, inset to align with the name's left edge, omitted on last row |

**Today variant.** When the countdown is 0: a 6pt `accent` dot replaces the
numeral column, the name shifts to `text.primary` w600, and the subtitle is
replaced by `turns 29` in `label`/`accent`.

**Swipe-to-remove.** Swiping left reveals a `danger`-text `Remove` action.
Committing soft-deletes immediately and shows the undo affordance. There is no
confirmation dialog.

### `QSettingRow`

Height 52, `body` label, optional `caption` sublabel, trailing value in
`label`/`text.secondary` or a `QToggle`. Hairline separators inset to the gutter.

### `QSectionHeader`

```
THIS WEEK                                    eyebrow, text.tertiary
```

Sticky on scroll with **no background change and no shadow** — it simply
persists at the top of its section against the canvas. Padding: 40 above
(`space.section`), 12 below. First header on a screen uses 24 above, not 40.

---

## 4. Sheets — `QSheet`

The primary presentation surface. Replaces dialogs, menus, and pickers.

| Property | Value |
|---|---|
| Corner radius | `radius.xl` (28), top corners only, superellipse |
| Fill | `raised` |
| Max height | 92% of viewport |
| Grabber | 36×4, `radius.full`, `hairlineStrong`, 8 from top |
| Inner padding | `space.xxl` (32) horizontal, 24 top / safe-area bottom |
| Elevation | `elev.overlay` + scrim |
| Entry / exit | T2 (doc 07) |

**Behaviour**

- Drag-to-dismiss with velocity handoff to a spring settle
- Scrollable content uses a nested scroll so the sheet drags only when the
  content is at its top
- Two detents maximum (`medium` at 50%, `large` at 92%) — used only by the Add
  flow; every other sheet is single-detent and sized to content
- Tapping the scrim dismisses, unless the sheet has unsaved input, in which case
  it settles back with a 4pt resistance bounce

**Variants**

| Variant | Use |
|---|---|
| `QSheet.form` | Add person, edit person |
| `QSheet.actions` | Long-press quick actions |
| `QSheet.picker` | Date, relationship, note kind |
| `QSheet.confirm` | The single irreversible action (erase all data) |

---

## 5. Bottom action area — `QBottomActions`

Not a persistent bar. It appears only inside sheets and full-screen editors.

- Sits above the safe-area inset with 16pt breathing room
- Background: `raised`, with a hairline on top **only when content scrolls
  beneath it** (detected via scroll offset, animated over `quick`)
- Contains at most two buttons, right-aligned: `tertiary` then `primary`
- Never contains three or more actions

There is no floating action button anywhere in the app. The "add someone"
affordance is a `QIconButton` with a `plus` glyph in the top-right of the home
screen, plus an explicit `primary` button in the empty state.

---

## 6. Note components

The notes system is the emotional core, so it gets bespoke components.

### `QNoteCard`

```
FAVOURITE FLOWER                     eyebrow, text.tertiary
Peonies, the pale ones               voice.sm, text.primary
```

- No box, no fill, no border — just the eyebrow/serif pair on the canvas
- Vertical padding 14, full-width tap target
- Separated by hairlines when stacked
- Tap opens an inline editor in place (the text becomes a `QField` with the same
  metrics, so nothing shifts)

### `QNoteKindPicker`

A wrapping row of pills for the eight note kinds:
`flower`, `dessert`, `colour`, `coffee`, `movie`, `food`, `gift idea`, `note`.

| Property | Value |
|---|---|
| Height | 34 |
| Padding | 14 horizontal |
| Radius | `radius.full` |
| Rest | `surface` fill + `hairline` border, `label`/`text.secondary` |
| Selected | `accentWash` fill, `accent` border 1.5pt, `accent` text |
| Gap | 8 both axes |

### `QGiftIdeaRow`

A note of kind `gift idea` renders with a leading 16pt `gift` glyph in
`text.tertiary` and supports a struck-through "given" state (opacity 0.5,
line-through) so ideas can be retired without deletion.

---

## 7. Avatars — `QAvatar`

Sizes and shapes per doc 04 §10.

| Prop | Behaviour |
|---|---|
| `photo` | `BoxFit.cover`, decoded at 2× the display size, cached |
| `monogram` | 1–2 letters, `voice` serif, `text.secondary`, deterministic tint |
| `heroTag` | Required when the avatar participates in T1 |
| Loading | The monogram is shown while the photo decodes — never a grey box |
| Failure | Falls back permanently to the monogram; failure is never surfaced |

---

## 8. Dialogs — `QSheet.confirm` only

**Kin has no dialogs.** `AlertDialog` is forbidden. The one genuinely
irreversible action (erase all data) uses a confirm sheet:

- `voice.md` headline stating the consequence in plain words
- `body` explanation of what cannot be recovered
- Two buttons: `tertiary` "Keep my data" (left), `secondary` with `danger` text
  "Erase everything" (right)
- The destructive button requires a **400ms press-and-hold** with a hairline
  progress arc, rather than a second confirmation screen

Everything else uses undo.

---

## 9. Undo affordance — `QUndoBar`

Replaces confirmation dialogs throughout.

| Property | Value |
|---|---|
| Position | Floating, 16 above safe-area bottom, 20 from each side |
| Fill | `raised`, `radius.md` superellipse, `elev.lift` |
| Height | 48 |
| Content | `body` message left, `label`/`accent` "Undo" right |
| Lifetime | 6s, with a hairline progress track draining along the bottom edge |
| Entry / exit | Y +16 → 0 fade in over `base`/`enter`; fade out over `quick`/`exit` |
| Stacking | Never more than one; a new one replaces the current immediately |

---

## 10. Toggle — `QToggle`

- Track 46×28, `radius.full`; thumb 24, `radius.full`
- Off: track `sunken`, thumb `surface` with `elev.hairline`
- On: track `accent`, thumb `surface`
- Transition: `base`, `emphasized`; the thumb travels with a 2pt overshoot
- No labels inside the track, no icons on the thumb

## 11. Segmented control — `QSegmented`

Used for theme mode and reminder presets.

- Container: `sunken`, `radius.sm`, 4pt inner padding, height 40
- Selected indicator: `surface` fill, `radius.xs`, `elev.hairline`, slides
  between segments over `base`/`emphasized`
- Labels: `label`; selected `text.primary` w600, unselected `text.secondary` w500
- Maximum 3 segments

## 12. Date input — `QDateField`

Birthdays are not ordinary dates, so this is not a calendar picker.

- Three linked, tabular inline fields: **Day**, **Month**, **Year (optional)**
- Month opens a `QSheet.picker` with a 12-row list, not a grid
- Year is visually secondary (`text.secondary`) and labelled "optional"
- No calendar grid — nobody scrolls a calendar back to 1987
- Validates day-in-month reactively, including 29 February, which is stored
  faithfully and resolved to 28 February in non-leap years for scheduling

## 13. Photo picker — `QPhotoSheet`

`QSheet.actions` with three rows: *Take a photo*, *Choose from library*,
*Remove photo* (only when a photo exists, in `danger` text). After selection, a
square crop editor with a superellipse mask, pinch-to-zoom, and drag-to-pan.
Output is resized to 1024×1024, encoded as JPEG q85, and stored in app documents.

---

## 14. Build order

| Tier | Components | Blocks |
|---|---|---|
| 1 | `QAvatar`, `QSectionHeader`, `QPersonRow`, `QButton`, `QIconButton` | Home screen |
| 2 | `QSheet`, `QBottomActions`, `QField`, `QDateField`, `QNoteKindPicker` | Add / edit flows |
| 3 | `QNoteCard`, `QGiftIdeaRow`, `QPhotoSheet` | Person screen |
| 4 | `QUndoBar`, `QToggle`, `QSegmented`, `QSettingRow`, `QSearchField` | Settings, search |

For future component work, the completion criterion is a **widget test**
covering all relevant states and a golden test in light, dark, and AMOLED at
1.0× and 1.3× text scale. The current Phase 1 suites cover the implemented
gallery specimens; see the implementation report for their exact scope.
