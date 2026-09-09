# Reminder Architecture — Personal Reminders

**Status:** Implemented (V1.1 capability)  
**Decisions:** Identity 1A · Navigation 2B

Personal reminders are an **app-owned** capability. They are **not** Person-owned and are independent of Birthday, Profile, Journal, and relationship notes.

```
Kin
├── Person → Birthday → birthday notification plans
├── Journal → memories / fragments
└── Personal Reminders → personal notification plans
         ↓
   shared PlatformScheduler / OS
```

---

## 1. Domain model

`PersonalReminder` (`lib/domain/models/personal_reminder.dart`):

| Field | Type | Notes |
|---|---|---|
| id | String | UUID v7 |
| localDate | `LocalCalendarDate` | YYYY-MM-DD planner day |
| localTime | `LocalClockTime` | HH:mm exact fire clock |
| dayPart | `ReminderDayPart` | anytime / morning / afternoon / evening |
| text | String | notification body |
| timezone | String | IANA at last write (kept in sync with Settings) |
| position | int | order within day-part |
| createdAt / updatedAt / deletedAt | DateTime | soft delete |

Day-part is organizational. Exact time is authoritative.

---

## 2. Timezone semantics

- Settings stores `reminder_timezone` (IANA), e.g. `Asia/Kolkata`.
- Scheduling uses `resolveReminderIana(settings, deviceIana)`.
- Changing Settings timezone **does not** change stored local date/time.
- On timezone change: update live rows’ `timezone` field → `NotificationCoordinator.synchronize()`.

---

## 3. Exact timing (Android)

Personal reminders are clock times the user cares about to the minute.

| Exact-alarm permission | Schedule mode | Behavior |
|---|---|---|
| Granted / not required | `AndroidScheduleMode.alarmClock` | `AlarmManager.setAlarmClock` — fires at the exact local minute |
| Denied | `AndroidScheduleMode.inexactAllowWhileIdle` | OS may batch; typically a few minutes early or late |

Settings → **Exact reminder timing** opens the system exact-alarm screen. Saving a reminder also requests this permission before synchronize.

Without exact alarms, drifts of ~2–3 minutes are expected Android behavior, not a planner math bug.

---

## 4. Persistence (schema v8)

Table `personal_reminders` — no `person_id`.

`scheduled_notifications` extended with `source`, nullable `person_id` / `rule_id`, and `reminder_id`.

Settings: `reminder_timezone` nullable text.

---

## 5. Notification architecture

Two plan sources merge in `NotificationCoordinator._desiredPlans`:

1. Birthday — existing `ReminderPlanner`
2. Personal — `PersonalReminderPlanner`

Both feed reconcile + `PlatformScheduler`.

Personal stable OS ids: `personal|{reminderId}|{YYYY-MM-DD}` hashed.

Channel: `personal_reminder`. Past reminders stay visible but are not scheduled.

---

## 6. Navigation (2B)

Primary tabs unchanged: **Today | Kin | Journal**.

Contextual route: `/reminders`. Discoverability via Journal bell + Today Reminders preview.

---

## 7. Boundaries

- Do not attach personal reminders to Person / Profile / Journal fragments.
- Do not invent fake Person rows for scheduling.
- Do not replace the birthday notification stack.
