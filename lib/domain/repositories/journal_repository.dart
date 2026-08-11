import 'package:kin/domain/models/journal_day.dart';
import 'package:kin/domain/models/journal_entry.dart';
import 'package:kin/domain/models/journal_entry_photo.dart';
import 'package:kin/domain/models/journal_fragment.dart';
import 'package:kin/domain/models/journal_mood.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:meta/meta.dart';

/// Calendar month summary for marking days that have journal content.
@immutable
class JournalDayMarker {
  const JournalDayMarker({
    required this.localDate,
    required this.entryCount,
    this.dayMood,
    this.hasEntries = false,
  });

  final LocalCalendarDate localDate;
  final int entryCount;
  final bool hasEntries;

  /// Overall mood for the day, if set on [JournalDay].
  final JournalMood? dayMood;

  bool get hasContent => hasEntries || dayMood != null;
}

abstract interface class JournalRepository {
  Stream<JournalDay?> watchDay(LocalCalendarDate date);

  Stream<List<JournalDayMarker>> watchMonthMarkers({
    required int year,
    required int month,
  });

  Future<JournalDay> upsertDay(JournalDay day);

  Stream<List<JournalEntry>> watchEntriesForDay(LocalCalendarDate date);

  Stream<JournalEntry?> watchEntry(String id);

  /// Persist entry shell metadata.
  ///
  /// When the entry already has live fragments, [JournalEntry.body] is ignored
  /// and regenerated from those fragments (preview cache only).
  Future<JournalEntry> saveEntry(JournalEntry entry);

  Future<void> softDeleteEntry(String id);

  /// Legacy photo rows kept in sync from photograph fragments.
  ///
  /// Prefer [saveMemory] / photograph [JournalFragment]s. Direct writes are for
  /// repository-internal sync and tests only.
  Stream<List<JournalEntryPhoto>> watchPhotosForEntry(String entryId);

  Future<JournalEntryPhoto> saveEntryPhoto(JournalEntryPhoto photo);

  Future<void> softDeleteEntryPhoto(String id);

  Stream<List<JournalFragment>> watchFragmentsForEntry(String entryId);

  Future<JournalFragment> saveFragment(JournalFragment fragment);

  /// Soft-deletes a fragment, purges its audio file when present, renumbers
  /// siblings, refreshes preview body, and syncs legacy photo rows.
  Future<void> softDeleteFragment(String id);

  /// Persist entry metadata + ordered fragments as one memory.
  ///
  /// [JournalFragment] order is authoritative. [JournalEntry.body] is always
  /// overwritten from [JournalFragment.previewBodyFrom].
  Future<JournalEntry> saveMemory({
    required JournalEntry entry,
    required List<JournalFragment> fragments,
  });

  /// Move a live fragment within its memory and persist normalized order.
  Future<JournalEntry> moveFragment({
    required String entryId,
    required int fromIndex,
    required int toIndex,
  });
}
