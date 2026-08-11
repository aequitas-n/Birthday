# 03 — Design Philosophy

> **Implementation status:** Phase 1 translates the Quiet visual thesis into
> tokens, themes, glyphs, core components, a gallery, and golden baselines.
> This document remains the target standard for future product screens, which
> have not been built yet.

The design language is named **Quiet**.

## The thesis

> **Type is the interface. Everything else is a surface for type to sit on.**

Kin has almost no imagery, no illustration, no iconography beyond a handful of
glyphs, and one accent colour used sparingly. What is left is words, space, and
the boundaries between them. That constraint is the design.

## Five principles

### I. Content is chrome

There is no header bar, no toolbar, no card frame competing with content. A
person's name at 32pt in a warm serif *is* the header. A hairline is the only
container we allow ourselves.

**Consequence:** we do not use `AppBar`, `Card`, `ListTile`, `Divider`,
`FloatingActionButton`, `Chip`, `AlertDialog`, or `BottomNavigationBar`. Not
"styled versions of them" — we do not use them. Every surface is composed from
primitives: `Container`, `CustomPaint`, `Text`, `Padding`, `Stack`, `Sliver*`.

### II. Warmth without decoration

Warmth comes from three sources only: the temperature of the neutrals, the
softness of the corner geometry, and the humanity of the serif. Never from
gradients, glows, shadows-as-style, blur-as-style, or illustration.

Every neutral in the palette is warm-tinted. There is no pure `#000000` outside
AMOLED and no pure `#FFFFFF` on the light canvas. Pure grey reads as *software*;
warm grey reads as *paper*.

### III. Hierarchy through weight and space, not boxes

When two things need separating, the first tool is **space**, the second is
**type weight or size**, the third is a **hairline**, and the fourth — rarely —
is a **surface elevation change**. Boxes are the last resort, not the first.

```
Bad:   [ card ] [ card ] [ card ]      ← three boxes, one idea
Good:  Name          in 3              ← hairline, air, done
       Name          in 6
```

### IV. Motion is grammar

Animation exists to answer one of three questions: *Where did this come from?*,
*Where did it go?*, or *Did that work?* Motion that answers none of these is
deleted. There are no looping animations, no parallax for its own sake, no
confetti, no bouncing, no shimmer.

The single exception is the **birthday moment** — the one screen per year, per
person, where a restrained celebratory reveal is emotionally correct. Even there
it lasts 520ms and never repeats.

### V. Everything has a resting state

Nothing pulses, breathes, blinks, or waits for attention. When the user is not
touching the app, the app is completely still. A calm product is one that is
still by default.

## The corner geometry decision

Standard rounded rectangles have a visible curvature discontinuity where the
straight edge meets the arc. At the radii we use (14–28pt) this reads as
slightly cheap.

Kin uses **rounded superellipses** (Apple-style squircles) for all significant
surfaces — sheets, panels, avatars, photo frames, and pressed states. Flutter
provides this natively via `ClipRSuperellipse` and the corresponding border
shape, so this is a token-level choice, not a custom painter.

Small elements (≤10pt radius) use ordinary rounded rectangles, where the
difference is imperceptible and the cheaper clip is preferable.

## The photograph rule

Photos are the only colour the app does not control. Therefore:

- Photos are always clipped to a superellipse or a circle, never a plain rect
- Photos always sit on the canvas, never on a coloured surface
- Photos are never the background of text
- A person without a photo gets a **monogram** in a tinted neutral — never a
  generic person icon, and never a coloured "avatar chip"
- The monogram tint is derived deterministically from the person's ID, drawn
  from a set of six warm neutrals — not from the accent, and not random

## Density

Kin is a **low-density** application. On a 390pt-wide phone:

- Home rows are 64pt tall with 20pt horizontal gutters
- No screen shows more than ~9 primary rows without scrolling
- The person screen uses a 560pt max content width, centred on tablets
- Vertical rhythm is generous: section gaps are 40pt, not 16pt

We are optimising for a fifteen-second weekly visit, not for information
throughput.

## What "premium" actually means here

Premium is not gradients and glass. Operationally, in this codebase, premium
means these seven measurable things:

1. **Optical alignment** — text is aligned by its visual edge, not its bounding
   box. Left-side bearing is compensated on large type.
2. **Tabular numerals everywhere numbers align** — the countdown column never
   jitters between 9 and 10.
3. **Correct tracking per size** — large type is tracked tighter, small type
   looser. Never one tracking value for the whole app.
4. **Hairlines that are actually hairlines** — `1 / devicePixelRatio`, not 1.0
   logical pixel.
5. **60/120fps with no jank** on the home list, verified in profile mode.
6. **Interruptible animations** — every transition can be reversed mid-flight.
   Nothing locks the UI while it plays.
7. **Haptics that mean something** — one selection tick on commit, nothing on
   navigation, nothing on scroll.

## Anti-patterns — explicitly forbidden

| Forbidden | Why |
|---|---|
| Material elevation shadows | Reads as Android system UI |
| `FloatingActionButton` | The most recognisable Flutter tell |
| Purple / indigo seed colours | The default `ColorScheme.fromSeed` look |
| Roboto or the default `TextTheme` | Instantly identifies the framework |
| Full-width filled primary buttons stacked at screen bottom | Generic app-template look |
| Icon + label bottom navigation | Unnecessary at this app's size |
| Gradients on buttons or headers | Decoration without meaning |
| Glassmorphism / heavy backdrop blur | Fashion, not function; expensive to render |
| Bouncing or springy list overscroll beyond platform default | Draws attention to itself |
| Emoji as UI iconography | Undermines the typographic voice |
| Skeleton shimmer on local data | Dishonest — the data is already there |

## The one-screenshot test

Before any screen is accepted, it must pass this test:

> Take a screenshot. Show it to someone who builds apps. If their first guess is
> "that's Flutter" or "that's Material," the screen is rejected.

The intended first guess is "what app is that?"
