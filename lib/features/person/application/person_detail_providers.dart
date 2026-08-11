import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/domain/models/note.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/domain/models/profile.dart';

// Riverpod's family factory returns a complex generic provider type that reads
// less clearly than the provider declaration itself here.
// ignore: specify_nonobvious_property_types
final personStreamProvider = StreamProvider.family<Person?, String>((
  ref,
  personId,
) {
  return ref.watch(personRepositoryProvider).watchById(personId);
});

// Riverpod's family factory returns a complex generic provider type that reads
// less clearly than the provider declaration itself here.
// ignore: specify_nonobvious_property_types
final personProfileProvider =
    StreamProvider.family<RelationshipProfile?, String>((ref, personId) {
      return ref.watch(profileRepositoryProvider).watchForPerson(personId);
    });

// Riverpod's family factory returns a complex generic provider type that reads
// less clearly than the provider declaration itself here.
// ignore: specify_nonobvious_property_types
final personNotesProvider = StreamProvider.family<List<Note>, String>((
  ref,
  personId,
) {
  return ref.watch(noteRepositoryProvider).watchForPerson(personId);
});

// Riverpod's family factory returns a complex generic provider type that reads
// less clearly than the provider declaration itself here.
// ignore: specify_nonobvious_property_types
final personPhotoProvider = FutureProvider.family<ImageProvider?, String?>((
  ref,
  photoId,
) async {
  if (photoId == null || photoId.isEmpty) return null;
  final database = ref.watch(kinDatabaseProvider);
  final row =
      await (database.select(database.photos)
            ..where((tbl) => tbl.id.equals(photoId) & tbl.deletedAt.isNull()))
          .getSingleOrNull();
  if (row == null) return null;
  final file = await ref.watch(imageStoreProvider).resolve(row.relPath);
  return FileImage(File(file.path));
});

// Riverpod's family factory returns a complex generic provider type that reads
// less clearly than the provider declaration itself here.
// ignore: specify_nonobvious_property_types
final personSummaryProvider = Provider.family<PersonSummary?, String>((
  ref,
  personId,
) {
  final person = ref.watch(personStreamProvider(personId)).asData?.value;
  if (person == null) return null;
  final profile = ref.watch(personProfileProvider(personId)).asData?.value;
  final now = ref.watch(clockProvider).now().toLocal();
  final nextDate = _nextOccurrence(person.birthday, now);
  return PersonSummary(
    person: person,
    profile: profile,
    nextBirthday: nextDate,
    daysUntilBirthday: nextDate
        .difference(DateTime(now.year, now.month, now.day))
        .inDays,
    turningAge: person.birthday.year == null
        ? null
        : (nextDate.year - person.birthday.year!),
  );
});

class PersonSummary {
  const PersonSummary({
    required this.person,
    required this.nextBirthday,
    required this.daysUntilBirthday,
    required this.turningAge,
    this.profile,
  });

  final Person person;
  final RelationshipProfile? profile;
  final DateTime nextBirthday;
  final int daysUntilBirthday;
  final int? turningAge;

  bool get hasProfile => profile != null;

  String get relationshipLabel => profile?.relationshipDisplayLabel ?? '';
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
