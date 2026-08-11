# 11 — Notification Architecture

Notifications are where Kin actually delivers value. Most interactions happen on
a lock screen. This subsystem gets the most engineering rigour in the product.

> **Architecture freeze:** Notifications remain person-centric. Payload and
> scheduling keys use `personId`. Profile notes may enrich copy when present;
> absence of a profile must never block scheduling. See
> [`ARCHITECTURE_FREEZE.md`](ARCHITECTURE_FREEZE.md).

> **Implementation status:** Layers 1–3 of the notification stack are
> implemented. Platform integration continues to use `personId`.

---

## 1. The timezone problem, stated precisely

> A birthday is not an instant. It is a **day label** that becomes an instant
> only when combined with a place.

Priya's birthday is 4 March. She lives in Chennai. Her birthday *begins* at
`2027-03-04 00:00 Asia/Kolkata`. That instant is `2027-03-03 18:30 UTC`. For a
user in Dallas, that is `2027-03-03 12:30 America/Chicago` — the afternoon
before, on the previous calendar day.

The requirement in the brief is exactly this: when the birthday begins where the
person is, notify the user at the equivalent moment where the user is.

### The three-step resolution

```
1. LABEL      PartialDate(month: 3, day: 4)  +  Person tz "Asia/Kolkata"
                              ↓
2. INSTANT    TZDateTime(kolkata, 2027, 3, 4, 0, 0)
              .toUtc()  →  2027-03-03T18:30:00Z
                              ↓
3. DELIVERY   TZDateTime.from(instantUtc, deviceTz)
              →  2027-03-03 12:30 America/Chicago
              →  handed to zonedSchedule()
```

The UTC instant is the invariant. Both the person's timezone and the device's
timezone are just projections of it.

---

## 2. Domain services

### `OccurrenceCalculator`

```dart
Occurrence next({
  required PartialDate date,
  required String? personTz,   // null → device tz
  required DateTime nowUtc,
  required String deviceTz,
});
```

Responsibilities:

- Choose the correct **year**: this year if the anchor instant is still in the
  future, otherwise next year
- Resolve **29 February** in a non-leap year to **28 February** (documented
  choice; the stored date is never mutated)
- Construct the anchor as `TZDateTime(personLocation, year, month, day)` — the
  `timezone` package resolves DST correctly for the target year
- Handle the **nonexistent local time** case: if a jurisdiction skips midnight
  during a DST transition (this happens, e.g. historically in parts of Brazil
  and Cuba), advance to the first existing instant of that day
- Return `Occurrence { anchorUtc, personLocalDate, ageTurning? }`

### `ReminderPlanner`

```dart
List<PlannedNotification> plan({
  required Person person,
  required Occurrence occurrence,
  required List<ReminderRule> rules,
  required String deviceTz,
});
```

Maps each rule to a delivery instant:

| Rule | Delivery instant |
|---|---|
| `at_their_midnight` | `occurrence.anchorUtc` exactly |
| `days_before N` | `09:00` **device local** on the day `N` days before the person's local birthday date |
| `morning_of` | `09:00` **device local** on the device-local day containing the anchor |

The asymmetry is deliberate and is the product insight: the *"it's starting now"*
notification respects **their** clock; the *planning* notifications respect
**yours**, because 09:00 in Chennai is useless to someone asleep in Dallas.

Plans in the past are dropped. Plans within 60 seconds of another plan for the
same person are collapsed, keeping the more specific one.

### `NotificationComposer`

Turns a plan plus the person's notes into copy. See §5.

---

## 3. Scheduling engine

### Desired state vs actual state

`scheduled_notifications` (doc 10) is the **desired state**. The OS pending list
is the **actual state**. `ScheduleReconciler` diffs them.

```
reconcile():
  desired = planner.planAll(people, rules, deviceTz)
             |> horizon.trim()
  actual  = plugin.pendingNotificationRequests()

  toCancel   = actual  \ desired      (by os_id + content hash)
  toSchedule = desired \ actual

  for each toCancel   → plugin.cancel(id);  mark stale
  for each toSchedule → plugin.zonedSchedule(...); mark registered
```

Reconciliation is **idempotent**. Running it twice changes nothing. This is what
makes it safe to run on every resume.

### Triggers

| Trigger | Why |
|---|---|
| App resume | Cheapest reliable hook; catches everything else |
| Person / note / rule changed | Content or timing may have changed |
| **Device timezone changed** | Every delivery instant shifts |
| Device reboot | Android clears alarms; boot receiver re-arms |
| Notification fired | Frees a slot; schedule the next horizon item |
| Daily background refresh | Extends the rolling horizon |
| Permission granted | First-ever scheduling pass |

Timezone-change detection: `settings.device_timezone_cache` is compared against
the live device timezone on every resume. A mismatch forces a full
reconciliation and updates the cache.

### The horizon and the platform budget

**iOS allows at most 64 pending local notifications per app.** Exceeding it
silently drops the newest. This is the single most common way birthday apps
fail.

Horizon policy:

| Platform | Budget | Strategy |
|---|---|---|
| iOS | 64 hard limit | Reserve 4 as headroom; schedule the nearest **60** by `fire_at_utc` |
| Android | No hard limit, but exact alarms are a scarce resource | Schedule the nearest **120**, or 400 days ahead, whichever is smaller |

With the default 3 rules per person, 60 slots covers roughly the next 20 people
— comfortably more than a year of lead time for a typical list. The horizon is
extended every time a notification fires and on the daily refresh.

The `Recently removed` and disabled-person cases free their slots immediately.

### Platform configuration

**Android**

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>

<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
  <intent-filter>
    <action android:name="android.intent.action.BOOT_COMPLETED"/>
    <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
    <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
    <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
  </intent-filter>
</receiver>
```

- `SCHEDULE_EXACT_ALARM` (requested at runtime via
  `requestExactAlarmsPermission()`) rather than `USE_EXACT_ALARM`, because the
  latter invites store review scrutiny for a non-alarm-clock app
- `androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle` so Doze does not
  defer a midnight delivery
- If exact alarms are denied, fall back to inexact scheduling and quietly
  degrade the `at_their_midnight` rule to a windowed delivery. The app keeps
  working; it just loses precision.

**Channels** (Android 8+), created at first schedule:

| Channel | Importance | Use |
|---|---|---|
| `birthday_today` | High | The day itself |
| `birthday_upcoming` | Default | 7-day and 1-day heads-up |

Two channels, not one, so users can silence the planning reminders while keeping
the day-of ones.

**iOS**

- `DarwinInitializationSettings` with `requestAlertPermission: false` at init —
  permission is requested contextually later
- Time-sensitive interruption level for `birthday_today` only
- `UNUserNotificationCenter` delegate handles foreground presentation

---

## 4. Deep linking

Payload is typed JSON, not a bare string:

```json
{ "v": 1, "personId": "018f...", "ruleKind": "at_their_midnight", "year": 2027 }
```

Handling:

- **Warm tap** → `router.push('/person/:id')` with T1 disabled (there is no
  source element to morph from; a fade is used instead)
- **Cold tap** → `getNotificationAppLaunchDetails()` is read during bootstrap,
  the initial route stack is built as `['/', '/person/:id']`, so back always
  returns to Home
- **Person deleted since scheduling** → route to Home, show nothing. Never an
  error.
- Payload version `v` allows the format to change without breaking notifications
  already sitting in the OS queue from an older build.

---

## 5. Notification copywriting

The brief asks that notifications reference saved notes naturally. This is the
loop-closing moment, and it is a design problem, not a string-concatenation
problem.

### Structure

```
Title:  <who + what>
Body:   <when>  ·  optionally one remembered detail
```

### Templates

| Rule | Title | Body |
|---|---|---|
| `days_before 7` | `Priya turns 29 next Sunday.` | `A week to think of something.` |
| `days_before 7` + note | `Priya turns 29 next Sunday.` | `She loves peonies, the pale ones.` |
| `days_before 1` | `Priya turns 29 tomorrow.` | `It begins at 12:30 pm your time.` |
| `at_their_midnight` | `It's Priya's birthday in Chennai.` | `She's 29 today.` |
| `at_their_midnight`, no year | `It's Priya's birthday in Chennai.` | `Her day has just begun.` |
| `morning_of` | `Priya turns 29 today.` | `Peonies, if you're still deciding.` |

### Selection rules for the woven detail

1. Include a detail **only** in the 7-day and morning-of notifications. The
   midnight one is about the moment, not about shopping.
2. Eligible kinds: `flower`, `dessert`, `coffee`, `food`, `movie`, `colour`,
   `gift_idea`. **Never `free`** — free-form notes are private and may contain
   anything.
3. Never more than one detail per notification.
4. Rotate: `note_id_used` is recorded, and the composer prefers a note not used
   for that person in the last two occurrences.
5. Retired gift ideas are excluded.
6. If `settings.show_details_on_lock_screen` is false, no detail is ever
   included, and Android uses `VISIBILITY_PRIVATE`.
7. Details are rendered as sentences, not fragments: "She loves peonies", not
   "Favourite flower: peonies".

### Pronouns

Kin does not ask for gender. Copy is written to avoid pronouns where possible
("Peonies, if you're still deciding") and uses the person's **name** where a
subject is needed ("Priya loves peonies"). No pronoun is ever guessed.

### Composition timing

Copy is composed **at schedule time**, not at fire time, and stored in
`scheduled_notifications.title/body`. Reasons: the OS needs the text upfront,
and storing it lets the reconciler detect content drift (a note changed → the
notification is rescheduled with fresh copy).

---

## 6. Permission strategy

Permission is **never requested at launch**. The sequence:

```
1. User completes onboarding                → no prompt
2. User adds their first person             → no prompt
3. On the success of that first add, an
   inline explanation appears on Home:

      "Want a reminder before Priya's birthday?"
      [ Not now ]            [ Turn on reminders ]

4. Only when "Turn on reminders" is tapped  → OS prompt
5. Android 14+: if exact alarms are denied,
   a second contextual explanation offers
   the settings deep link                   → optional
```

If declined, the app remains fully functional and the prompt is not shown again
for 30 days, and never more than three times total.

---

## 7. Reliability hazards and mitigations

| Hazard | Mitigation |
|---|---|
| iOS 64-notification cap | Rolling horizon of 60 with reserved headroom (§3) |
| Android OEM battery killers (Xiaomi, Oppo, Huawei) | Detect known manufacturers; offer a one-time "allow background activity" explainer with a settings deep link |
| Doze deferring midnight delivery | `exactAllowWhileIdle` |
| Reboot clearing alarms | Boot receiver + reconcile on next launch |
| User travels across timezones | Timezone-change detection on resume → full reconcile |
| DST shift between schedule and fire | `TZDateTime` recomputation on every reconcile; the reconciler compares `device_tz` recorded at schedule time |
| Device clock manually changed | Reconcile on resume detects the drift and reschedules |
| App never opened for months | Daily background refresh (`BGTaskScheduler` / `WorkManager`) extends the horizon |
| Notification fires while app is foregrounded | Suppressed as a banner; the Home screen updates in place instead |

---

## 8. Testability

The scheduling engine is pure and fully unit-testable because:

- `Clock` is injected — no call to `DateTime.now()` exists in `domain/`
- Device timezone is a **parameter**, not an ambient read
- `OccurrenceCalculator` and `ReminderPlanner` return values; they perform no I/O
- Only `NotificationService` touches the plugin, and it is behind an interface
  with a `FakeNotificationService` that records calls

The timezone test matrix from doc 09 §7 runs against these pure functions, so
correctness is verified without a device, an emulator, or a clock change.

### The scheduling inspector (dev flavour only)

A hidden Settings screen listing every row in `scheduled_notifications` with its
UTC instant, device-local instant, person-local instant, rule, state, and the
exact composed copy. This is the difference between debugging notifications in
minutes and debugging them over days.
