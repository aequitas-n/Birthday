# 06 — Color System

> **Implementation status:** Vintage Diary is the sole product theme. Raw
> values live in `ColorTokens` (`vd*` prefix) and semantic roles on
> `QuietColors`. See [VINTAGE_DIARY_THEME.md](VINTAGE_DIARY_THEME.md).

## The constraint

**One visual identity. One accent family.** Colour never carries meaning alone;
it always accompanies type, position, or shape.

Three brightness adaptations ship — **Light**, **Dark**, **AMOLED** — all
sharing the same Vintage Diary atmosphere (dark parchment, cream ink). AMOLED
deepens the canvas to true black-brown; it is not a separate theme.

---

## Interactive surfaces

Dark vintage desk ≠ cream parchment controls ≠ burgundy accents ≠ brown ink.

| Role | Token | Use |
|---|---|---|
| Desk primary CTA | `interactive.primaryAction` | Cream fill on vintage-bg |
| Desk CTA ink | `interactive.primaryActionInk` | Brown ink on cream CTA |
| Sheet / modal | `interactive.sheet` | Warm parchment bottom sheets |
| Sheet ink | `interactive.ink*` | Brown type on parchment |
| Toggle track/thumb | `interactive.toggle*` | Cream track + ink/burgundy thumb |
| Navigation strip | `navigation.surface` | Cream parchment on desk, brown ink |

Ambient [QuietControlSurface] (`desk` vs `parchment`) flips CTA treatment so
journal-card **Add memory** stays burgundy on cream paper while desk **Save**
buttons become cream parchment.

See [VINTAGE_DIARY_THEME.md](VINTAGE_DIARY_THEME.md).

---

## 1. The accent — faded burgundy

Primary accent for **selection / indicators** uses `#713D3A`. On parchment
hosts (sheets, journal cards), primary buttons still fill with burgundy.
On the dark desk, primary buttons fill with cream parchment instead.

### Where accent is allowed

Same density rule — roughly 2% of any screen:

1. Today / nav indicators
2. Primary button on parchment hosts
3. Focus rings
4. Selected picker/segment state
5. Toggle ON thumb

---

## 2. Semantic roles

Widgets consume `QuietColors` roles. They never consume raw `ColorTokens`.

### Vintage Diary (default)

| Role | Hex | Notes |
|---|---|---|
| `canvas` | `#2A1E18` | Dark aged paper (texture via asset) |
| `surface` | `#3A2E26` | Level 1 on canvas |
| `text.primary` | `#F4EEDF` | Warm cream |
| `text.secondary` | `#E4D0C2` | Soft parchment |
| `text.tertiary` | `#C9B4A4` | Meta on dark canvas |
| `accent` | `#713D3A` | Faded burgundy |
| `accentWash` | `#4A3228` | Selection / wash |

Journal paper cards use `QuietJournal` (`paper`, `ink`, `edge`, `tape`).

---

## Legacy note

Previous multi-collection presets (Ember, Ocean Mist, etc.) and warm-paper
light themes are **removed**. Documentation below the fold describing those
presets is historical reference only.
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
