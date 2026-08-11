// Riverpod family providers — explicit types omitted per project convention.
// ignore_for_file: specify_nonobvious_property_types

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/domain/models/journal_day.dart';
import 'package:kin/domain/models/journal_entry.dart';
import 'package:kin/domain/models/journal_entry_photo.dart';
import 'package:kin/domain/models/journal_fragment.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/domain/repositories/journal_repository.dart';

final journalTodayProvider = Provider<LocalCalendarDate>((ref) {
  final now = ref.watch(clockProvider).now().toLocal();
  return LocalCalendarDate.fromLocalDateTime(now);
});

final journalMonthMarkersProvider =
    StreamProvider.family<List<JournalDayMarker>, (int, int)>((ref, key) {
      final (year, month) = key;
      return ref
          .watch(journalRepositoryProvider)
          .watchMonthMarkers(
            year: year,
            month: month,
          );
    });

final journalDayProvider = StreamProvider.family<JournalDay?, String>((
  ref,
  dateKey,
) {
  final date = LocalCalendarDate.parseStorage(dateKey);
  return ref.watch(journalRepositoryProvider).watchDay(date);
});

final journalEntriesProvider =
    StreamProvider.family<List<JournalEntry>, String>(
      (ref, dateKey) {
        final date = LocalCalendarDate.parseStorage(dateKey);
        return ref.watch(journalRepositoryProvider).watchEntriesForDay(date);
      },
    );

final journalEntryProvider = StreamProvider.family<JournalEntry?, String>((
  ref,
  entryId,
) {
  return ref.watch(journalRepositoryProvider).watchEntry(entryId);
});

final journalEntryPhotosProvider =
    StreamProvider.family<List<JournalEntryPhoto>, String>((ref, entryId) {
      return ref.watch(journalRepositoryProvider).watchPhotosForEntry(entryId);
    });

final journalEntryFragmentsProvider =
    StreamProvider.family<List<JournalFragment>, String>((ref, entryId) {
      return ref
          .watch(journalRepositoryProvider)
          .watchFragmentsForEntry(entryId);
    });

/// Resolves a shared `photos` row for Journal display.
///
/// Separate from relationship profile photo providers — same storage, different
/// domain concept.
final journalPhotoProvider = FutureProvider.family<ImageProvider?, String>((
  ref,
  photoId,
) async {
  if (photoId.isEmpty) return null;
  final database = ref.watch(kinDatabaseProvider);
  final row =
      await (database.select(database.photos)
            ..where((tbl) => tbl.id.equals(photoId) & tbl.deletedAt.isNull()))
          .getSingleOrNull();
  if (row == null) return null;
  final file = await ref.watch(imageStoreProvider).resolve(row.relPath);
  return FileImage(File(file.path));
});
