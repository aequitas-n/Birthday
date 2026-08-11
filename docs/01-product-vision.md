# 01 — Product Vision

> **Implementation status:** This is the enduring product vision. The current
> repository implements only Phases 0–1: the Flutter foundation and Quiet
> design system. No birthday-management, reminder, memory, or backup workflow
> exists in the runtime app yet.

## The one sentence

**Kin helps you remember the people you love, and the small things that make
them feel known.**

## The problem, honestly stated

Birthday apps exist. Almost all of them fail for the same three reasons:

1. **They are contact dumps.** They import 400 people from a phone book, and
   the 8 people you actually care about drown.
2. **They notify you too late to matter.** A push at 9am on the day is not
   enough time to do anything thoughtful.
3. **They remember the date but not the person.** Knowing it is Priya's birthday
   is trivia. Knowing she loves peonies and hates surprises is the actual gift.

Kin is built for the third problem. The date is the trigger. The *memory* is the
product.

## Who this is for

A person with somewhere between 5 and 40 people who matter. They are not trying
to be more productive. They are trying to be a better friend, child, partner, or
sibling. They feel a small, recurring guilt about forgetting.

They are not a "power user." They will open this app roughly once a week for
fifteen seconds.

**Design consequence:** the app must be instantly re-orientable. There is no
learning curve budget. Every screen must be readable by someone who last opened
it 31 days ago.

## What Kin is

- A quiet list of the people who matter, ordered by who is coming up next
- A place to keep the specific, small, useful details about each of them
- A reminder system that understands that people live in different places
- A private, local-first archive that works forever with no account

## What Kin will never be

These are permanent product boundaries, not a backlog.

| Never | Because |
|---|---|
| A social network | No feeds, no friends, no profiles others can see |
| A CRM | No pipelines, no "last contacted," no follow-up tasks |
| A productivity suite | No todos, no projects, no tags-as-a-system |
| A gift marketplace | No affiliate links, no commerce, no recommendations |
| An analytics dashboard | No streaks, no "relationship health scores," no charts |
| A contact importer | People are added deliberately, one at a time |
| An AI assistant | No generated messages. The words should be yours |

If a proposed feature makes the app more *capable* but less *calm*, it loses.

## The emotional target

The feeling on opening Kin should be the feeling of opening a well-made
notebook: quiet, personal, uncluttered, slightly warm. Not the feeling of
opening a tool.

Three emotional beats the product must land:

1. **Relief** — "I don't have to hold this in my head anymore."
2. **Warmth** — seeing a person's name and face in a space that respects them.
3. **Readiness** — being reminded early enough that you can actually act.

## The core loop

```
        ┌────────────────────────────────────────┐
        │                                        │
        ▼                                        │
  Add someone  ──▶  Notice a detail  ──▶  Save the detail
        │                                        ▲
        │                                        │
        ▼                                        │
  Reminder arrives, carrying the detail  ────────┘
        │
        ▼
  Do something thoughtful
```

The loop closes when the reminder *hands the detail back*. This is the single
most important interaction in the product. Everything else supports it.

## Success, defined

Kin succeeds if:

- A user adds a person in **under 25 seconds** without feeling rushed
- A user recalls a saved detail **because the notification surfaced it**
- The app is opened **voluntarily**, not only when notified
- A user can uninstall and reinstall from backup with **zero data anxiety**
- A user never sees a loading spinner on the home screen — **ever**

Kin fails if it becomes something a person has to maintain.

## Positioning against the references

We study these products for principles, and take none of their layouts.

| Product | What we take | What we reject |
|---|---|---|
| Things 3 | Restraint, list typography, generous whitespace | Its complexity ceiling |
| Linear | Speed as a feature, keyboard-grade precision | Its density and coldness |
| Arc Browser | Playful, confident motion with a purpose | Its novelty-seeking |
| Craft | Editorial typography, documents that feel written | Its feature surface |
| Notion Calendar | Clarity of temporal information | Its integrations model |
| Apple (system) | Legibility, hierarchy, honesty of feedback | Material/Cupertino defaults |

The synthesis: **editorial warmth with utility-grade restraint.**

## Non-goals for v1

Explicitly deferred, not rejected:

- Widgets (home screen)
- Watch app
- Multi-device realtime sync (backup only in v1)
- Anniversaries and non-birthday dates
- Shared/family lists
- Localization beyond English

## Naming

`Kin` is the working name. Alternatives considered and held in reserve:
**Fond**, **Almanac**, **Nook**. Final naming decision is required before the
first release build, not before implementation.
