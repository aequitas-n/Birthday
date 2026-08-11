import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/core/id.dart';
import 'package:kin/data/local/database/kin_database.dart'
    show KinDatabase, PeopleCompanion, ProfilesCompanion;
import 'package:kin/data/repositories/note_repository_drift.dart';
import 'package:kin/domain/models/note.dart';

void main() {
  group('DriftNoteRepository', () {
    late KinDatabase database;
    late DriftNoteRepository repository;

    setUp(() async {
      database = KinDatabase(NativeDatabase.memory());
      await database
          .into(database.people)
          .insert(
            PeopleCompanion.insert(
              id: 'person-1',
              displayName: 'Priya Raman',
              birthMonth: 7,
              birthDay: 28,
              sortKey: 'priya raman',
              createdAt: DateTime.utc(2026).millisecondsSinceEpoch,
              updatedAt: DateTime.utc(2026).millisecondsSinceEpoch,
            ),
          );
      await database
          .into(database.profiles)
          .insert(
            ProfilesCompanion.insert(
              id: 'profile-1',
              personId: 'person-1',
              createdAt: DateTime.utc(2026).millisecondsSinceEpoch,
              updatedAt: DateTime.utc(2026).millisecondsSinceEpoch,
            ),
          );
      repository = DriftNoteRepository(
        database,
        const _FixedIdGenerator('note-001'),
        const _FixedClock(),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('saves and restores custom labels on a profile', () async {
      final saved = await repository.save(
        Note(
          id: '',
          profileId: 'profile-1',
          kind: NoteKind.custom,
          label: 'Favorite Scent',
          value: 'Sandalwood soap',
          position: 0,
          createdAt: DateTime.utc(2026, 7, 28),
          updatedAt: DateTime.utc(2026, 7, 28),
        ),
      );

      final notes = await repository.watchForPerson('person-1').first;

      expect(saved.label, 'Favorite Scent');
      expect(notes.single.kind, NoteKind.custom);
      expect(notes.single.profileId, 'profile-1');
      expect(notes.single.label, 'Favorite Scent');
      expect(notes.single.value, 'Sandalwood soap');
    });

    test('round-trips a plan note kind', () async {
      final saved = await repository.save(
        Note(
          id: '',
          profileId: 'profile-1',
          kind: NoteKind.plan,
          value: 'Surprise trip to Kerala',
          position: 0,
          createdAt: DateTime.utc(2026, 7, 28),
          updatedAt: DateTime.utc(2026, 7, 28),
        ),
      );

      final notes = await repository.watchForPerson('person-1').first;

      expect(saved.kind, NoteKind.plan);
      expect(notes.single.kind, NoteKind.plan);
      expect(notes.single.value, 'Surprise trip to Kerala');
      expect(NoteKind.fromStorage('plan'), NoteKind.plan);
    });

    test('maps legacy coffee storage to drink and round-trips place', () {
      expect(NoteKind.fromStorage('coffee'), NoteKind.drink);
      expect(NoteKind.place.storageValue, 'place');
      expect(NoteKind.fromStorage('place'), NoteKind.place);
    });

    test('saves a photo memory with photo id in value', () async {
      final saved = await repository.save(
        Note(
          id: '',
          profileId: 'profile-1',
          kind: NoteKind.photo,
          label: 'Diwali dinner',
          value: 'abc123photo',
          position: 0,
          createdAt: DateTime.utc(2026, 7, 28),
          updatedAt: DateTime.utc(2026, 7, 28),
        ),
      );

      final notes = await repository.watchForPerson('person-1').first;

      expect(saved.isPhotoMemory, isTrue);
      expect(saved.photoId, 'abc123photo');
      expect(saved.caption, 'Diwali dinner');
      expect(notes.single.kind, NoteKind.photo);
      expect(notes.single.value, 'abc123photo');
      expect(notes.single.label, 'Diwali dinner');
    });
  });
}

class _FixedClock extends Clock {
  const _FixedClock();

  @override
  DateTime now() => DateTime.utc(2026, 7, 28, 12);
}

class _FixedIdGenerator extends IdGenerator {
  const _FixedIdGenerator(this.value);

  final String value;

  @override
  String next() => value;
}
