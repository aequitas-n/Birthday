# 07 — Motion System

Apple's guidance is the constitution here: *add motion purposefully; aim for
brevity and precision; avoid motion on frequent interactions; let people cancel
motion; make motion optional.* Every rule below implements one of those.

> **Implementation status:** Phase 1 implements duration/curve tokens, the
> `QuietMotion` reduced-motion resolver, press feedback, and the basic T2 sheet
> route. T1 and T3–T9, stagger helpers, screen choreography, and feature-level
> haptics are not implemented because the corresponding product surfaces do not
> exist yet.

## The test

Before any animation ships it must answer **one** of three questions:

1. **Where did this come from?** (entrance, expansion, shared element)
2. **Where did it go?** (exit, collapse, dismissal)
3. **Did that work?** (feedback, commit, failure)

If it answers none, it is deleted. There is no fourth category, and
"it looks nice" is not one.

---

## 1. Duration tokens

| Token | Value | Use |
|---|---|---|
| `motion.instant` | 90ms | Press/release, selection tick, colour-only change |
| `motion.quick` | 160ms | Fades, small reveals, focus rings, hover |
| `motion.base` | 240ms | Standard transitions, theme change, list reorder |
| `motion.slow` | 360ms | Sheets, page pushes, shared-element morphs |
| `motion.deliberate` | 520ms | The birthday moment only |

Nothing in the app is slower than 520ms. Nothing that responds to a finger is
slower than 240ms.

## 2. Curve tokens

Numeric values reference the Material 3 easing specification, used purely as a
well-researched source of curve mathematics — not as a visual style.

| Token | Cubic | Use |
|---|---|---|
| `curve.standard` | `Cubic(0.2, 0.0, 0.0, 1.0)` | Default for anything on-screen changing in place |
| `curve.enter` | `Cubic(0.0, 0.0, 0.0, 1.0)` | Elements arriving — decelerate into rest |
| `curve.exit` | `Cubic(0.3, 0.0, 1.0, 1.0)` | Elements leaving — accelerate off |
| `curve.emphasized` | `Curves.easeInOutCubicEmphasized` | Shared-element morphs, sheets |
| `curve.spring` | `SpringDescription(mass: 1, stiffness: 380, damping: 30)` | Anything the finger is currently holding |

**Asymmetry rule.** Entrances and exits never share a curve or a duration.
Entrances decelerate over `base`; exits accelerate over `quick`. Leaving should
always feel faster than arriving.

---

## 3. The transition catalogue

Every navigation and state change in the app maps to exactly one of these.

### T1 — Person open (shared element)

Home row → Person screen. The signature transition of the app.

| Element | From | To | Duration | Curve |
|---|---|---|---|---|
| Avatar | `avatar.md` circle in row | `avatar.lg` superellipse, centred | `slow` | `emphasized` |
| Name | `voice.sm` at row position | `voice.xl` centred | `slow` | `emphasized` |
| Row hairlines | opacity 1 | opacity 0 | `quick` | `exit` |
| Person content below fold | offset +12pt, opacity 0 | rest | `base` @ 80ms delay | `enter` |
| Canvas | — | crossfade | `base` | `standard` |

Implemented with `Hero` for avatar and name, plus a `PageRouteBuilder` for the
surrounding fade. The shape interpolation from circle to superellipse happens in
the `flightShuttleBuilder`.

### T2 — Sheet present

Add person, edit, quick actions, photo options.

- Sheet: translate Y from `100%` → `0`, `slow`, `emphasized`
- Scrim: opacity `0` → `1`, `base`, `standard`
- Underlying page: scale `1.0` → `0.985` and corner radius `0` → `radius.lg`,
  `slow`, `emphasized` — the page recedes rather than being covered
- Dismiss: reverse at `quick` with `curve.exit`; drag-to-dismiss uses
  `curve.spring` and hands velocity to the settle animation

### T3 — Push / pop

Settings and other secondary screens.

- Incoming: X `+24pt` → `0`, opacity `0` → `1`, `base`, `enter`
- Outgoing: X `0` → `−12pt`, opacity `1` → `0.6`, `base`, `standard`
- Pop reverses at `quick`
- Deliberately a **short slide**, not a full-width iOS push — the shorter travel
  reads as faster and less mechanical

### T4 — List choreography

On first paint of the home list, and after a filter change.

- Each row: opacity `0` → `1`, Y `+8pt` → `0`
- Duration `base`, curve `enter`
- Stagger **24ms** per row, capped at **6 rows** — rows 7+ share row 6's timing
- Runs **once per app session**, not on every rebuild or scroll

### T5 — Row insert / remove / reorder

- Insert: height `0` → natural + opacity `0` → `1`, `base`, `enter`
- Remove: opacity → 0 over `quick`, then height → 0 over `base`, `exit`
- Reorder (dates changing group): position animates over `base`, `standard`

### T6 — Value morph

A number or word changing in place — the countdown ticking from `in 3` to
`in 2`, or an age incrementing.

- Old value: opacity → 0, Y `−6pt`, `quick`, `exit`
- New value: opacity → 1, Y `+6pt` → `0`, `quick` @ 60ms delay, `enter`
- Width animates over `quick` so the column never jumps

### T7 — Press feedback

- Scale `1.0` → `0.97` **anchored at the touch point**, `instant`, `standard`
- Release: back to `1.0` over `quick` with `curve.spring`
- Surface tint darkens 4% simultaneously
- One `HapticFeedback.selectionClick()` on **commit**, never on press-down

### T8 — Photo viewer

- Tap photo on person screen → full-bleed viewer
- `Hero` from `avatar.lg` to full width, `slow`, `emphasized`
- Background canvas fades to `scrim` over `base`
- Drag-to-dismiss: photo follows the finger 1:1 with `curve.spring`, scrim
  opacity tracks drag distance, release below 120pt snaps back

### T9 — The birthday moment

The single expressive animation in the product. Shown when the person screen is
opened on their birthday, and on the dedicated Today screen.

Sequence, total 520ms:

| Time | Event |
|---|---|
| 0ms | Canvas warms to `accentWash` over `deliberate`, `standard` |
| 60ms | Name scales `0.96` → `1.0`, opacity `0` → `1`, `slow`, `emphasized` |
| 180ms | Age numeral counts up from `age − 1` to `age` over 340ms, `standard` |
| 240ms | A single hairline arc sweeps beneath the name, 0° → 360°, `deliberate`, `standard` |
| 300ms | One remembered detail fades in, `base`, `enter` |

No confetti. No particles. No sound. It plays **once per person per day** —
guarded by a persisted `lastCelebratedAt` — and never on a rebuild.

---

## 4. Choreography rules

1. **Never animate more than three properties at once** on a single element.
2. **Never run two competing transitions simultaneously.** Sheets and page
   pushes are mutually exclusive; a queued navigation waits.
3. **Stagger caps at 6.** Longer staggers make the last item feel broken.
4. **Delays never exceed 120ms.** Beyond that the app feels unresponsive.
5. **Everything is interruptible.** Every controller is driven so that a reverse
   mid-flight starts from the current value, not from the endpoint. No
   `await`-ing an animation before accepting input.
6. **Nothing loops.** Zero infinite animations, including loading indicators on
   the home screen (there are none).
7. **Scroll is never hijacked.** No scroll-linked parallax, no collapsing hero
   header, no snap. Platform scroll physics, untouched.

---

## 5. Reduce Motion

When `MediaQuery.disableAnimations` is true:

| Normally | Becomes |
|---|---|
| T1 shared element | Crossfade, `quick` |
| T2 sheet slide | Fade + scrim, `quick`; no page recede |
| T3 push slide | Crossfade, `quick` |
| T4 stagger | All rows appear at once, no offset |
| T6 value morph | Instant text swap, no fade |
| T7 press scale | Tint change only, no scale |
| T9 birthday moment | Static composition, no count-up, no arc sweep |

The shared `QuietMotion.of(context)` resolver returns zeroed movement durations
and identity transforms. Feature transitions must consume it when they are
implemented. `QArc` still needs reduced-motion treatment before it is used in a
production flow.

## 6. Haptics

Deliberately sparse. The complete inventory:

| Event | Haptic |
|---|---|
| Commit an action (save, add, delete) | `selectionClick` |
| Drag-to-dismiss passes the threshold | `selectionClick` |
| Destructive action executes | `mediumImpact` |
| Birthday moment opens | `lightImpact` |

Nothing on: navigation, scrolling, press-down, typing, tab changes, or toggles.

## 7. Performance budget

| Metric | Budget |
|---|---|
| Home list scroll | 0 dropped frames at 120Hz, profile mode, 200 people |
| T1 shared element | ≤ 2 frames over budget on a mid-tier Android device |
| Cold start to first meaningful paint | < 400ms |
| Any animation frame | < 8ms build + raster at 120Hz |

Enforced by `flutter drive` performance traces on the home list and the person
transition, run in CI on every PR touching `design/` or `features/people/`.
