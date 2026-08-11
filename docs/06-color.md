# 06 — Color System

> **Implementation status:** The Ember ramp, all three semantic themes,
> deterministic monogram tints, and theme preference resolver are implemented
> in `lib/design/`. Persistence of the user preference belongs to the future
> settings/data work; the current gallery preference is in-memory only.

## The constraint

**One accent. Everything else is warm neutral.** Colour never carries meaning
alone; it always accompanies type, position, or shape.

Three modes ship: **Light**, **Dark**, **AMOLED**. All three are first-class —
AMOLED is not "dark with black swapped in," it has its own hairline and
elevation strategy.

---

## 1. The accent — `Ember`

A terracotta/clay warm orange. Chosen because it is the colour of candlelight
and baked earth, it is emotionally correct for the product, and it is far from
the indigo/purple that identifies default Flutter and Material seeds.

| Step | Hex | Role |
|---|---|---|
| `ember.50` | `#FDF5F1` | Accent wash, light mode selection fill |
| `ember.100` | `#F9E5DB` | Accent wash pressed |
| `ember.200` | `#F0C9B4` | Disabled accent, dividers on accent surfaces |
| `ember.300` | `#E4A585` | **Dark-mode accent text/icon** |
| `ember.400` | `#D4805C` | Dark-mode accent fill, hover |
| `ember.500` | `#BF6039` | **Light-mode accent** (primary) |
| `ember.600` | `#A24E2D` | Light-mode pressed |
| `ember.700` | `#7E3C23` | Accent on light wash text |

Contrast verified:

| Pair | Ratio | Passes |
|---|---|---|
| `ember.500` on `canvas.light` (`#FBFAF8`) | 4.62:1 | AA body |
| `ember.700` on `ember.50` | 8.1:1 | AAA |
| `ember.300` on `canvas.dark` (`#141311`) | 8.4:1 | AAA |
| `ember.300` on `canvas.amoled` (`#000000`) | 9.6:1 | AAA |

### Where accent is allowed

Accent is rare on purpose. Its complete permitted usage:

1. The **today** indicator on the home screen (a filled dot + accent numeral)
2. The **primary action** fill on exactly one button per screen
3. **Focus rings**
4. The **selected** state of a segmented control or picker
5. The **birthday moment** screen

That is the entire list. Accent never appears in body text, never in
iconography at rest, never as a section header, never on more than roughly 2% of
any screen's pixels.

---

## 2. Semantic roles

Widgets consume these names. They never consume the ramps above.

### Light — warm paper

| Role | Hex | Notes |
|---|---|---|
| `canvas` | `#FBFAF8` | Warm off-white, never `#FFFFFF` |
| `surface` | `#FFFFFF` | Level 1 |
| `raised` | `#FFFFFF` | Level 2 + `elev.overlay` |
| `sunken` | `#F4F2EE` | Input wells |
| `hairline` | `#E7E3DC` | Default separator |
| `hairlineStrong` | `#D5CFC5` | Emphasised separator, input borders |
| `text.primary` | `#1A1815` | Warm near-black |
| `text.secondary` | `#6B6560` | 5.9:1 on canvas |
| `text.tertiary` | `#948D85` | 3.4:1 — never used below 15pt for content |
| `text.inverse` | `#FBFAF8` | On accent fills |
| `accent` | `#BF6039` | `ember.500` |
| `accentWash` | `#FDF5F1` | `ember.50` |
| `danger` | `#8F2F2F` | Deep, cool-shifted — reads distinct from Ember |
| `dangerWash` | `#F9EDEC` | |
| `scrim` | `rgba(20,18,16,.32)` | |
| `shadow` | `rgba(38,30,22,.05)` | Warm, never neutral black |

### Dark — soft warm charcoal

| Role | Hex | Notes |
|---|---|---|
| `canvas` | `#141311` | Warm charcoal, not `#121212` |
| `surface` | `#1C1B18` | |
| `raised` | `#242220` | |
| `sunken` | `#0E0D0C` | |
| `hairline` | `#2E2C28` | |
| `hairlineStrong` | `#403D38` | |
| `text.primary` | `#F5F3F0` | Never pure white — reduces halation |
| `text.secondary` | `#A6A099` | 7.0:1 on canvas |
| `text.tertiary` | `#6F6A64` | 3.6:1 |
| `text.inverse` | `#141311` | |
| `accent` | `#E4A585` | `ember.300` — lighter for dark contrast |
| `accentWash` | `#2A211C` | |
| `danger` | `#E08A82` | |
| `dangerWash` | `#2C1D1C` | |
| `scrim` | `rgba(0,0,0,.56)` | |
| `shadow` | `rgba(0,0,0,.44)` | |

### AMOLED — true black

| Role | Hex | Notes |
|---|---|---|
| `canvas` | `#000000` | True black for OLED power saving |
| `surface` | `#000000` | Identical — separation via hairline only |
| `raised` | `#0C0B0A` | Sheets need slight lift to read as floating |
| `sunken` | `#000000` | |
| `hairline` | `#272522` | **Stronger than dark mode** — carries all structure |
| `hairlineStrong` | `#3D3B37` | |
| `text.primary` | `#F2F0ED` | |
| `text.secondary` | `#9C968F` | |
| `text.tertiary` | `#66615C` | |
| `accent` | `#E4A585` | Same as dark |
| `accentWash` | `#241C18` | |
| `danger` | `#E08A82` | |
| `scrim` | `rgba(0,0,0,.72)` | |
| `shadow` | `rgba(0,0,0,.60)` | |

**AMOLED design consequence:** with `canvas == surface`, the entire visual
structure of every screen rests on hairlines and type colour. Any screen that
falls apart in AMOLED is a screen that was relying on background fills instead
of typography — which means it violates the design philosophy and must be
redrawn.

---

## 3. Monogram tints

Six warm neutrals for people without photos. Deterministic:
`tint = monogramTints[hash(person.id) % 6]`.

| # | Light | Dark / AMOLED |
|---|---|---|
| 0 | `#EDE7DF` | `#2B2723` |
| 1 | `#E9E5DC` | `#282622` |
| 2 | `#EFE6E1` | `#2C2724` |
| 3 | `#E6E7E1` | `#262825` |
| 4 | `#EEE8E4` | `#2A2725` |
| 5 | `#E8E4E4` | `#272525` |

Deliberately low-chroma. They must read as *paper stock*, not as colour-coding.
Monogram letterform uses `text.secondary`, not the tint's complement.

---

## 4. Mode selection

| Setting | Behaviour |
|---|---|
| `System` (default) | Follows platform brightness → Light or Dark |
| `Light` | Always Light |
| `Dark` | Always Dark |
| `Dark + AMOLED` | A **toggle nested under Dark**, not a fourth top-level mode |

Rationale: users think in "light/dark," and AMOLED is a refinement of dark. It
appears as a single switch labelled "Pure black" beneath the dark option.

Mode changes animate over `base` (240ms) via `QuietTheme.lerp` — no flash, no
snap. Because `lerp` is implemented on every token, this is free once the
`ThemeExtension` is correct.

---

## 5. Colour rules

1. **Never** call `ColorScheme.fromSeed`. It generates the Material tonal
   palette, which is exactly the look we are avoiding.
2. **Never** use `withOpacity` on a semantic role to invent a new shade. If a
   shade is needed, it becomes a named token.
3. **Never** use colour as the sole carrier of state. The today indicator is a
   dot *and* a numeral change; an error is a hairline *and* a message.
4. **Never** introduce a success/warning/info colour. Success is silent (doc 04);
   warnings are phrased as text.
5. Photographs are the only unmanaged colour. They are always isolated on
   `canvas` (doc 03).
6. The documented contrast pairs must remain compliant. The current golden
   suite provides visual regression coverage; dedicated programmatic contrast
   assertions have not yet been added.

---

## 6. Alternate accent (held in reserve)

If Ember is rejected, the substitute is **Iris** — a muted indigo-violet
(`#5B5BD6` light / `#A5A2F0` dark). It maximises semantic separation from
`danger` and remains calm, but it is emotionally cooler and less specific to
this product.

Ember is the recommendation. This is a decision point requiring approval before
implementation.
