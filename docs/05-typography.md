# 05 — Typography System

Typography is the primary visual element of Kin. If the type is wrong, nothing
else can rescue the product.

> **Implementation status:** `QuietTypography` implements the Fraunces and
> Inter token families, variable-font axes, semantic tinting, display trimming,
> and structural/name text-scaling helpers. The remaining screen-level optical
> corrections and responsive behaviours in this document are target work for
> product screens.

Apple's guidance informs three decisions here: avoid light weights below display
sizes, minimise the number of typefaces, and preserve relative hierarchy when
the user scales text. We follow all three.

---

## 1. The families

Two families. Never a third.

### Voice — `Fraunces`

A variable serif with optical-size, `SOFT`, and `WONK` axes. Used for **human
content**: people's names, screen titles, remembered details presented as
quotations, and the celebratory moment.

Why: it carries warmth and editorial confidence without nostalgia, and its
variable axes let us soften it at large sizes — which is exactly where a serif
usually turns severe. It is the reason the app will not read as a utility.

Axis settings used:

| Context | `opsz` | `SOFT` | `WONK` | Weight |
|---|---|---|---|---|
| `voice.xl` | 96 | 40 | 0 | 400 |
| `voice.lg` | 72 | 30 | 0 | 400 |
| `voice.md` | 36 | 20 | 0 | 400 |
| `voice.sm` | 14 | 10 | 0 | 500 |

`WONK` stays at 0 throughout — the wonky variants are charming once and
irritating thereafter.

### Text — `Inter`

A variable neutral grotesque with true tabular figures and excellent small-size
legibility. Used for **everything functional**: labels, body copy, buttons,
inputs, metadata, settings.

Contextual alternates `cv05` (lowercase L with tail) and `ss03` (curved r) are
enabled to reduce the "default web font" familiarity.

### Numerals

Numerals always come from Inter with `fontFeatures: [tnum, lnum]` (tabular,
lining). The countdown column, ages, and dates must never shift horizontally as
values change.

### Fallback chain

If a variable font fails to load, fall back to the platform serif/sans rather
than to Roboto: `Fraunces → Georgia → serif`, `Inter → SF Pro / Roboto → sans`.
Fonts are bundled as assets, not fetched at runtime — an offline-first app must
not depend on a font CDN.

---

## 2. The scale

Sizes are logical points. Line height is expressed absolutely, then converted to
Flutter's unitless `height` multiplier.

### Voice (Fraunces)

| Token | Size | Line | `height` | Weight | Tracking | Use |
|---|---|---|---|---|---|---|
| `voice.xl` | 44 | 48 | 1.09 | 400 | −0.020em | Birthday moment, person name on hero |
| `voice.lg` | 32 | 38 | 1.19 | 400 | −0.014em | Screen titles, person name |
| `voice.md` | 24 | 31 | 1.29 | 400 | −0.008em | Section moments, quoted notes |
| `voice.sm` | 17 | 24 | 1.41 | 500 | 0 | Note values, emphasised inline detail |

### Text (Inter)

| Token | Size | Line | `height` | Weight | Tracking | Use |
|---|---|---|---|---|---|---|
| `title` | 20 | 26 | 1.30 | 600 | −0.011em | Sheet titles, group headers |
| `bodyLg` | 17 | 25 | 1.47 | 400 | −0.002em | Primary reading text, notes |
| `body` | 15 | 22 | 1.47 | 400 | 0 | Default UI text, row subtitles |
| `label` | 13 | 18 | 1.38 | 500 | +0.004em | Buttons, field labels, metadata |
| `caption` | 12 | 16 | 1.33 | 500 | +0.010em | Helper text, errors, timestamps |
| `eyebrow` | 11 | 14 | 1.27 | 600 | +0.075em | Section eyebrows, **uppercase** |

### Numerals (Inter, tabular)

| Token | Size | Line | Weight | Tracking | Use |
|---|---|---|---|---|---|
| `numeral.hero` | 64 | 64 | 400 | −0.030em | Days-until on the birthday moment |
| `numeral.lg` | 28 | 32 | 500 | −0.020em | Age on person screen |
| `numeral.md` | 17 | 22 | 500 | −0.010em | Countdown column on home |

---

## 3. Tracking law

Letter-spacing is a **function of size**, never a constant. The rule, applied
when adding any new style:

```
size ≥ 40 → −0.020em
size 28–39 → −0.014em
size 20–27 → −0.008em
size 15–19 → −0.002em to 0
size 12–14 → +0.004em to +0.010em
size ≤ 11 → +0.050em and above, uppercase only
```

This single rule is responsible for a large share of the "designed by a human"
impression. Flutter's default is 0 at every size, which is what makes untouched
Flutter type look flat.

---

## 4. Optical corrections

Target shared-widget behaviour:

- **Left side bearing.** `voice.xl` and `voice.lg` are shifted −1pt and −0.5pt
  horizontally so the glyph edge — not the bounding box — aligns to the gutter.
- **Baseline-first spacing.** Vertical gaps around `voice.*` are measured
  baseline-to-baseline, not box-to-box. A `TextBaselineGap` helper is planned;
  it is not present in the current repository.
- **Trailing-line trim.** `TextHeightBehavior(applyHeightToFirstAscent: false,
  applyHeightToLastDescent: false)` on all display type, so line-height padding
  does not create phantom space above headings.
- **Widow control.** Person names longer than the measure wrap with a soft
  no-break between the final two words where feasible. This has not yet been
  implemented because person screens are not present.

---

## 5. Dynamic Type behaviour

Categories, and how each responds to `TextScaler`:

| Category | Scaling | Rationale |
|---|---|---|
| Content (`bodyLg`, `body`, `voice.sm`, note values) | **Unclamped** | This is what the user wants bigger |
| Names (`voice.lg`, `voice.xl`) | Clamped at **1.4×** | Beyond this, names dominate the layout |
| Structural (`title`, `label`, `eyebrow`) | Clamped at **1.3×** | Chrome should not outgrow content |
| Numerals (`numeral.md`) | Clamped at **1.3×** | Preserves column alignment |
| Icons | Clamped at **1.3×** | Matches adjacent structural text |

At scales above 1.3×, the home row switches from a single line with a trailing
numeral to a two-line stacked layout. This is a layout change, not a truncation
— text is never ellipsised for want of space at accessible sizes.

Implemented components use `TextScaler` helpers from `context.quiet` for
structural and name content. The broader screen-level use of
`MediaQuery.withClampedTextScaling` remains target work for the product screens.

---

## 6. Applied examples

**Home row**

```
Priya Raman              voice.lg  →  but rendered at voice.sm weight 500
                                       (see note)
relationship             caption, text.tertiary
                                          in 3   numeral.md, text.secondary
```

*Note:* home rows use `voice.sm` (17pt serif, w500) rather than `voice.lg`.
The serif appears at list scale to establish the voice, and reaches full size
only on the person screen. This creates the sense of "zooming into" a person.

**Person screen header**

```
                        [ avatar.lg ]

                        Priya Raman            voice.xl
                        Sister · Chennai       label, text.secondary

                        29                     numeral.lg
                        turns 30 on 4 March    body, text.secondary
```

**A remembered note**

```
FAVOURITE FLOWER          eyebrow, text.tertiary
Peonies, the pale ones    voice.sm, text.primary
```

The eyebrow/serif pairing is the core typographic motif of the notes system: a
tiny, quiet label above a warm, human value.

---

## 7. Implementation notes learned in build

Two findings from Phase 1 that are easy to get wrong:

**Every style sets `inherit: false`.** A design token must be complete. With
inheritance on, a style merges with whatever ambient `DefaultTextStyle` is in
scope — and because Kin has no `Scaffold` anywhere, that ambient style is the
framework's yellow-double-underlined "you forgot a text style" fallback. It
appeared on every single line of type in the first golden run. `QScreen` also
supplies a real `DefaultTextStyle` so a bare `Text` still lands in the product's
voice.

**The `wght` axis is set explicitly, not via `fontWeight`.** When a `TextStyle`
supplies its own `fontVariations` list, `fontWeight` does not reach the variable
weight axis — Fraunces rendered at its file default and every serif line looked
bold. Each style now passes `FontVariation('wght', …)` alongside its optical
size, which also keeps the intended weight visible next to the `opsz` it was
tuned against.

## 8. Rules and prohibitions

1. **Never** use Flutter's default `TextTheme` or any `Theme.of(context).textTheme.*`.
2. **Never** declare a `TextStyle` outside `design/tokens/type_tokens.dart`.
3. **Never** mix Voice and Text within a single line of type.
4. **Never** use italic. Fraunces has one, and it is not needed.
5. **Never** use `FontWeight.w100`–`w300` at any size (Apple HIG legibility).
6. **Never** use `TextOverflow.ellipsis` on a person's name at ≤1.0× scale — the
   measure must accommodate realistic names. Ellipsis is permitted only for
   free-form note previews.
7. **Never** centre-align text longer than one line.
8. Uppercase is permitted **only** for `eyebrow`.
9. Maximum measure for reading text: **68 characters**.
10. All text colours come from the semantic roles in doc 06 — never a hardcoded
    opacity on a colour.
