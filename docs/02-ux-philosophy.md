# 02 — UX Philosophy

> **Implementation status:** These are target UX laws for the product screens
> and flows. The current app is a component gallery only; navigation, person
> management, undo, search, onboarding, and notification interactions are not
> implemented yet.

## The governing law

> **The user should never have to think about the app. Only about the person.**

Every decision below descends from that sentence.

---

## The eight laws

### 1. One idea per screen

A screen answers exactly one question. If a screen answers two, it is two
screens, or it is a screen and a sheet.

| Screen | The single question it answers |
|---|---|
| Home | Who is coming up? |
| Person | Who is this, and what do I know about them? |
| Add | Who am I adding? |
| Notes | What do I know about them? |
| Settings | How does this app behave? |

### 2. Progressive disclosure over configuration

The app ships with correct defaults. Options appear only when a user
demonstrates they need them.

- Reminders default to **7 days before**, **1 day before**, and **at their
  midnight**. No user configures this on first use.
- Timezone is **derived**, never asked. The user types a city; we resolve the
  rest silently.
- The birth *year* is optional and visually secondary. Many people know the day
  but not the year, and asking for it as a required field is a small cruelty.

### 3. Typing is the last resort

Ranked by preference for every input:

1. Already known (derive it)
2. Pick from a short list
3. Pick from a searchable list
4. Type free text

Relationship, favourite colour, and location all resolve to (2) or (3).
Only names, notes, and gift ideas reach (4).

### 4. Destructive actions are reversible, not confirmed

We do not show "Are you sure?" dialogs. Dialogs punish the 99% of correct
actions to protect the 1% of mistakes.

Instead: the action happens immediately, and a quiet **undo affordance** appears
for 6 seconds. Deleting a person soft-deletes for 30 days and is recoverable
from Settings → Recently removed.

Exception: permanently erasing all data. That one gets a real confirmation,
because it is genuinely irreversible.

### 5. The empty state is a first-class screen

An empty Kin is the state most users see first and the state they see if they
ever clear it. It gets the same design attention as a full one. It is never a
grey illustration with "No items yet."

### 6. Latency is a design element

- No skeleton loaders on the home screen. Local reads from SQLite are sub-frame;
  the list renders with data on the first frame.
- Any operation that could exceed **120ms** must show state. Any operation under
  it must show nothing at all — a flashed spinner is worse than no spinner.
- Optimistic writes everywhere. The UI updates first; persistence follows.

### 7. Notifications are the product's front door

Most interactions with Kin will happen on a lock screen, not in the app. A
notification is therefore not a marketing surface — it is a **product screen
with 2 lines of type**.

Rules:
- Never notify without new information
- Never notify twice for the same event
- One notification carries at most one remembered detail
- Tapping always lands on the person, never the home screen

### 8. Silence is a feature

The app has no badge counts, no "you haven't opened this in a while," no
re-engagement pushes, no streaks. It speaks only when a person's date is
approaching.

---

## Information architecture

The structure is deliberately two levels deep. There is no third level.

```
Home (the year ahead)
├── Person
│   ├── Notes (inline, not a subscreen)
│   ├── Photo (sheet)
│   └── Edit (sheet)
├── Add person (sheet)
├── Search (overlay)
└── Settings
    ├── Reminders
    ├── Appearance
    ├── Backup
    └── Recently removed
```

**Navigation model:** a single stack. No bottom tab bar, no drawer, no nested
navigators. Home is always one back-gesture away from anywhere.

Rationale: with 5–40 people and 6 features, a tab bar would be permanent
furniture advertising emptiness. The list *is* the navigation.

## The home screen thesis

The home screen is not a grid of cards. It is a **typographic timeline**.

People are grouped by temporal proximity, not alphabetically:

```
TODAY
  Priya Raman                                    turns 29

THIS WEEK
  Arjun Mehta                                        in 3
  Sara Lindqvist                                     in 6

THIS MONTH
  Daniel Cole                                       in 14
  ...

LATER
  ...
```

Why this works:
- The most urgent information is at the top and requires no interpretation
- The numeral column is scannable in one saccade
- No card chrome means the *names* carry the visual weight, which is correct —
  the names are the content
- It degrades gracefully from 1 person to 200

## Interaction inventory

The complete set of gestures in the app. Anything not listed does not exist.

| Gesture | Where | Result |
|---|---|---|
| Tap | Person row | Open person (shared-element) |
| Tap | Add affordance | Add sheet rises |
| Long-press | Person row | Quick actions sheet |
| Swipe left | Person row | Reveal remove (with undo) |
| Pull down | Home | Reveal search |
| Swipe down | Any sheet | Dismiss |
| Back gesture | Any screen | Pop |

No: double-tap, 3D touch, pinch, multi-finger, shake, or custom edge gestures.

## Accessibility as a design constraint

Not an afterthought or a checklist — it changes the design.

- **Dynamic Type**: the type scale is defined in logical points and responds to
  `TextScaler`. Layouts use intrinsic sizing, never fixed heights for text
  containers. Clamped at 1.6× for structural labels, unclamped for content.
- **Reduce Motion**: when `MediaQuery.disableAnimations` is true, all positional
  and scale animation collapses to a 160ms opacity crossfade. Nothing is lost;
  only the movement is.
- **Contrast**: all text meets WCAG AA (4.5:1 body, 3:1 for ≥24pt). The accent
  colour is never the only carrier of meaning.
- **Semantics**: every row announces name, relationship, and time-to-birthday as
  one coherent label, not three fragments.
- **Touch targets**: 44×44 minimum, always, including the visually small ones.
  Hit area and visual area are decoupled.

## Copy voice

The app speaks in **plain, warm, lowercase-hearted English**. It never uses
exclamation marks, emoji, or the word "awesome."

| Instead of | Write |
|---|---|
| "No birthdays added yet!" | "No one here yet." |
| "Successfully saved!" | *(say nothing — the UI already changed)* |
| "Are you sure you want to delete?" | *(don't ask — offer undo)* |
| "Priya's birthday is in 3 days!" | "Priya turns 29 on Sunday." |
| "Add your first contact" | "Add someone you'd hate to forget." |

Numbers are written as numerals. Dates are written the way a person would say
them out loud: "Sunday," "next Tuesday," "12 March."
