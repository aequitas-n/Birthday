import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/domain/models/note.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/domain/models/profile.dart';
import 'package:kin/features/home/application/home_providers.dart';
// ignore: always_use_package_imports -- ARCH-03: relative within a feature
import 'gallery_memory.dart';

/// A profile card in the relationship gallery.
class GalleryEntry {
  const GalleryEntry({
    required this.person,
    required this.profile,
    required this.daysUntil,
    required this.turningAge,
  });

  final Person person;
  final RelationshipProfile profile;
  final int daysUntil;
  final int? turningAge;

  String get displayName => person.displayName;

  bool get isPinned => profile.isPinned;

  String? get relationshipLabel {
    final label = profile.relationshipDisplayLabel.trim();
    return label.isEmpty ? null : label;
  }

  /// Nickname when set, otherwise the legal name — used for search + card title.
  String get primaryName {
    final nickname = profile.nickname?.trim();
    if (nickname != null && nickname.isNotEmpty) return nickname;
    return person.displayName;
  }

  String countdownLabel() {
    return switch (daysUntil) {
      0 => 'Today',
      1 => 'Tomorrow',
      _ => 'In $daysUntil days',
    };
  }

  bool matchesQuery(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    bool hit(String? value) =>
        value != null && value.toLowerCase().contains(needle);
    return hit(person.displayName) ||
        hit(person.sortKey) ||
        hit(profile.nickname) ||
        hit(relationshipLabel) ||
        hit(person.location?.label);
  }
}

final galleryEntriesProvider = Provider<List<GalleryEntry>>((ref) {
  final people =
      ref.watch(peopleStreamProvider).asData?.value ?? const <Person>[];
  final profiles =
      ref.watch(profilesStreamProvider).asData?.value ??
      const <RelationshipProfile>[];
  if (profiles.isEmpty) return const [];

  final peopleById = {for (final person in people) person.id: person};
  final now = ref.watch(clockProvider).now().toLocal();
  final entries = <GalleryEntry>[];

  for (final profile in profiles) {
    final person = peopleById[profile.personId];
    if (person == null) continue;
    final nextDate = _nextOccurrence(person.birthday, now);
    entries.add(
      GalleryEntry(
        person: person,
        profile: profile,
        daysUntil: nextDate
            .difference(DateTime(now.year, now.month, now.day))
            .inDays,
        turningAge: person.birthday.year == null
            ? null
            : (nextDate.year - person.birthday.year!),
      ),
    );
  }

  entries.sort(_compareGalleryEntries);
  return entries;
});

/// Memory counts and latest previews keyed by profile id.
final galleryMemorySummariesProvider =
    StreamProvider<Map<String, GalleryMemorySummary>>((ref) {
      final database = ref.watch(kinDatabaseProvider);
      final query = database.select(database.notes)
        ..where((tbl) => tbl.deletedAt.isNull());
      return query.watch().map((rows) {
        final grouped = <String, List<Note>>{};
        for (final row in rows) {
          final note = Note(
            id: row.id,
            profileId: row.profileId,
            kind: NoteKind.fromStorage(row.kind),
            label: row.kindLabel,
            value: row.value,
            isRetired: row.isRetired,
            position: row.position,
            createdAt: DateTime.fromMillisecondsSinceEpoch(
              row.createdAt,
              isUtc: true,
            ),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(
              row.updatedAt,
              isUtc: true,
            ),
            deletedAt: row.deletedAt == null
                ? null
                : DateTime.fromMillisecondsSinceEpoch(
                    row.deletedAt!,
                    isUtc: true,
                  ),
            syncRev: row.syncRev,
          );
          grouped.putIfAbsent(note.profileId, () => []).add(note);
        }
        return grouped.map(
          (profileId, notes) =>
              MapEntry(profileId, GalleryMemorySummary.fromNotes(notes)),
        );
      });
    });

/// Birthdays that do not yet have a relationship profile.
final unlinkedBirthdaysProvider = Provider<List<Person>>((ref) {
  final people =
      ref.watch(peopleStreamProvider).asData?.value ?? const <Person>[];
  final profiles =
      ref.watch(profilesStreamProvider).asData?.value ??
      const <RelationshipProfile>[];
  final linkedIds = {for (final profile in profiles) profile.personId};
  return people
      .where((person) => !linkedIds.contains(person.id))
      .toList(growable: false);
});

int _compareGalleryEntries(GalleryEntry a, GalleryEntry b) {
  // Pinned first; within each group, soonest birthday leads the deck.
  if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
  final byDays = a.daysUntil.compareTo(b.daysUntil);
  if (byDays != 0) return byDays;
  final bySortKey = a.person.sortKey.compareTo(b.person.sortKey);
  if (bySortKey != 0) return bySortKey;
  return a.person.displayName.toLowerCase().compareTo(
    b.person.displayName.toLowerCase(),
  );
}

DateTime _nextOccurrence(PartialDate birthday, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final thisYear = _safeDate(now.year, birthday.month, birthday.day);
  if (!thisYear.isBefore(today)) return thisYear;
  return _safeDate(now.year + 1, birthday.month, birthday.day);
}

DateTime _safeDate(int year, int month, int day) {
  final lastDay = DateTime(year, month + 1, 0).day;
  final clampedDay = day > lastDay ? lastDay : day;
  return DateTime(year, month, clampedDay);
}
