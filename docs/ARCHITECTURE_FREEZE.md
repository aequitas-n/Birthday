# Architecture Freeze — Kin Version 1

This document is the canonical Version 1 architecture decision.

It supersedes earlier proposals that would have introduced `BirthdayReminder`
as a new root entity or split identity across multiple roots.

**Status:** FROZEN for Version 1.  
Future work must extend this architecture rather than replace it.

---

## 1. Root identity

**Person is the only durable root identity** throughout the application.

- Deep links use `personId`
- Notification payloads use `personId`
- Reminder rules and scheduled notifications use `personId`
- Soft delete and sync tombstones center on Person

Do **not** introduce new root entities such as `BirthdayReminder`.

---

## 2. Capabilities

```
Person (Identity)
│
├── Birthday Capability (Required, 1:1)
│     • displayName
│     • birthday (partial date)
│     • location
│     • IANA timezone
│     • reminder rules (global defaults + optional per-person overrides)
│
└── Profile Capability (Optional, 0:1)
      • nickname
      • relationship
      • photo
      • notes / favorites / gift ideas / memories / custom categories
```

### Rules

1. Every Person **MUST** have exactly one Birthday capability.
2. Every Person **MAY** have zero or one Profile capability.
3. Profile existence must never be required for scheduling or notifications.
4. Notes belong to Profile only.
5. Scheduling belongs to Birthday / Person identity only.

---

## 3. Physical schema (V1)

Birthday is physically inlined on `people` because it is mandatory 1:1.

| Table | Owns |
|---|---|
| `people` | Identity + birthday fields (`display_name`, date, place, timezone) |
| `profiles` | Optional profile (`person_id` unique FK) |
| `notes` | Profile notes (`profile_id`) |
| `photos` | Image blobs (avatar via profile) |
| `reminder_rules` | `person_id` (null = global default) |
| `scheduled_notifications` | `person_id` |
| `settings` | App preferences |

Domain code exposes Birthday as a capability object even when storage is inlined.

---

## 4. Notification architecture

Layers 1–3 remain person-centric and unchanged in responsibility:

1. **Occurrence Calculator** — pure birthday math
2. **Reminder Planner** — plan generation + reconciliation
3. **Platform Scheduler** — executes reconciliation

Inputs continue to use `personId`. Profile notes may enrich copy when present;
absence of a profile must never block scheduling.

---

## 5. UX contract

### Birthday creation (fast path)

Only:

- Name
- Birthday
- Location

Target: under 10 seconds. No nickname, relationship, photo, or notes.

### After save

Return to Home. The Person exists with Birthday only.

### Birthday Detail

Shows birthday information and reminder context.

- If no profile → Quiet CTA: **Create Relationship Profile**
- If profile exists → show summary and allow open/edit

### Profile creation / editing

Separate from birthday editing. Must never edit birthday fields.

---

## 6. Extension policy

Allowed:

- Additional note kinds
- Per-person reminder overrides
- Profile presentation refinements

Not allowed without a new architecture decision:

- New root entities
- Making Profile required for notifications
- Moving birthday identity off Person
- Replacing `personId` in payloads

---

## 7. Related documents

- `docs/01-product-vision.md` — product intent
- `docs/09-architecture.md` — layering
- `docs/10-data-model.md` — schema detail
- `docs/11-notifications.md` — scheduling
- `docs/12-screens-and-flows.md` — UX surfaces
