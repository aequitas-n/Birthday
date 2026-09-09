# Journal Architecture — Composition V3.1

**Status:** Hardened (composition integrity + audio lifecycle)  
**Scope:** Personal life journal — independent from Kin relationship profiles/notes.  
**Product shell:** See [PRODUCT_ARCHITECTURE.md](PRODUCT_ARCHITECTURE.md).

---

## 1. Product hierarchy

```
                 TODAY
              /         \
           KIN          JOURNAL
        /       \          |
   Birthdays   People     Month
                           ↓
                          Day
                           ↓
                         Memory
                           ↓
               Writing / List / Photo / Audio
```

Bottom nav peers: **Today | Kin | Journal**.  
Month → Day → Memory are contextual levels, not peer tabs.

Person / Profile / Birthday / Notification architecture is untouched.

---

## 2. Composition model

```
Memory
├── title
├── mood (memory feeling)
└── ordered fragments   ← authoritative content
      ├── Writing
      ├── List
      ├── Photograph
      └── Audio
```

**Source of truth**

| Field | Role |
|---|---|
| `JournalFragment[]` | Authoritative memory content and order |
| `JournalEntry.body` | Derived preview only (writing + list text) |
| `JournalEntryPhoto` | Compatibility mirror of photograph fragments |

The editor never independently persists `body` apart from fragments.  
`saveMemory` always regenerates `body` via `JournalFragment.previewBodyFrom`.  
`saveEntry` regenerates `body` from live fragments when any exist.

**Closed vocabulary** — do not add heading/quote/table/markdown/nested blocks.

---

## 3. Mood semantics

| Concept | Meaning |
|---|---|
| `JournalDay.mood` | How the **whole day** felt (calendar wash) |
| `JournalEntry.mood` | How **this memory** felt |

They are independent. Saving a memory mood must not overwrite the day mood.  
`_ensureDayExists` creates day rows without copying entry mood.

---

## 4. Fragment ordering

Order is meaning. Positions are dense `0..n-1`.

Domain helpers: `JournalFragmentOps` (`normalizePositions`, `moveUp`/`moveDown`/`moveTo`, `insertAt`, `removeAt`).

Repository:

- `saveMemory` — replace-all + normalize + preview + legacy photo sync + audio purge
- `moveFragment` — persist reorder for a live memory
- `softDeleteFragment` — soft-delete, purge audio file, renumber, sync photos, refresh body

UI draft reordering is fine; persistence always normalizes through the repository.

---

## 5. Media ownership

### Photographs

- Shared `photos` table + `LocalImageStore` (`photos/<hash>.jpg`)
- Journal photographs: `photos.personId == null`
- Profile photographs: `photos.personId` set
- Composition: photograph **fragment** holds `photoId`
- `journal_entry_photos` kept in sync only inside `saveMemory` / fragment delete — not an independent composition timeline

### Audio

- Files: `LocalAudioStore` under `journal_audio/<hash>.m4a` (data layer)
- Metadata on the audio fragment: `audioRelPath`, `audioDurationMs`, optional `caption`
- Lifecycle: record → preview → accept/discard → persist → play/pause → delete
- Soft-delete of fragment/entry purges the audio file
- Cancelled recordings delete temp files
- Missing file: archival “no longer on this device” state (no crash)

Audio module UI: `lib/features/journal/audio/` — first-class, intentional.

---

## 6. Migration (v6 → v7)

1. Create `journal_entry_fragments`
2. Non-empty `body` → writing fragment
3. Live `journal_entry_photos` → photograph fragments
4. Titles, moods, photos preserved

Drift schema **v7**.

---

## 7. Universal Today

Calm doorway — not a dashboard:

1. Today / date identity  
2. Today’s journal (empty invite or previews)  
3. Birthday today (when relevant)  
4. Coming up  

Typography: Caveat for expressive headings, Fraunces for titles/names,
Courier Prime for archive/metadata/controls.

---

## 8. Files

| Area | Path |
|---|---|
| Fragment model / ops | `lib/domain/models/journal_fragment.dart`, `journal_fragment_ops.dart` |
| Repository | `lib/domain/repositories/journal_repository.dart`, `…/journal_repository_drift.dart` |
| Audio store | `lib/data/local/files/audio_store.dart` |
| Audio UI | `lib/features/journal/audio/` |
| Composer | `lib/features/journal/presentation/journal_memory_editor.dart` |
| Reading | `lib/features/journal/presentation/journal_entry_screen.dart` |
| Docs | `docs/JOURNAL_ARCHITECTURE.md` |

---

## 9. Later candidates (not done)

- Search / export  
- Autosave  
- Drag-and-drop reorder  
- Person tags on memories  
- Orphan JPEG sweep job for soft-deleted photos  
