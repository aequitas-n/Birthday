import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/core/id.dart';
import 'package:kin/data/local/database/kin_database.dart';
import 'package:kin/data/repositories/person_repository_drift.dart';
import 'package:kin/data/repositories/profile_repository_drift.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/domain/models/profile.dart';

void main() {
  group('DriftPersonRepository', () {
    late KinDatabase database;
    late DriftPersonRepository repository;

    setUp(() {
      database = KinDatabase(NativeDatabase.memory());
      repository = DriftPersonRepository(
        database,
        const _FixedIdGenerator('person-001'),
        const _FixedClock(),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('saves, streams, and searches active people', () async {
      final saved = await repository.save(
        Person(
          id: '',
          displayName: 'Ananya Rao',
          birthday: const PartialDate(month: 3, day: 4),
          location: const LocationModel(
            label: 'Chennai, India',
            timezone: TimezoneModel('Asia/Kolkata'),
          ),
          sortKey: '',
          createdAt: DateTime.utc(2026, 7, 28),
          updatedAt: DateTime.utc(2026, 7, 28),
        ),
      );

      final streamed = await repository.watchById(saved.id).first;
      final results = await repository.search('chennai');

      expect(saved.id, 'person-001');
      expect(streamed?.displayName, 'Ananya Rao');
      expect(results.single.id, saved.id);
      expect(results.single.location?.timezone?.ianaName, 'Asia/Kolkata');
    });

    test('soft deleted people disappear from search results', () async {
      final saved = await repository.save(
        Person(
          id: '',
          displayName: 'Iris Bloom',
          birthday: const PartialDate(month: 9, day: 12),
          sortKey: '',
          createdAt: DateTime.utc(2026, 7, 28),
          updatedAt: DateTime.utc(2026, 7, 28),
        ),
      );

      await repository.softDelete(saved.id);

      final results = await repository.search('iris');

      expect(results, isEmpty);
    });

    test('soft delete cascades to profile and notes', () async {
      final person = await repository.save(
        Person(
          id: '',
          displayName: 'Cascade Test',
          birthday: const PartialDate(month: 5, day: 10),
          sortKey: '',
          createdAt: DateTime.utc(2026, 7, 28),
          updatedAt: DateTime.utc(2026, 7, 28),
        ),
      );

      final profileRepo = DriftProfileRepository(
        database,
        const _FixedIdGenerator('profile-001'),
        const _FixedClock(),
      );
      final profile = await profileRepo.save(
        RelationshipProfile(
          id: '',
          personId: person.id,
          nickname: 'Cas',
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
      );

      await database
          .into(database.notes)
          .insert(
            NotesCompanion.insert(
              id: 'note-1',
              profileId: profile.id,
              kind: 'free',
              value: 'A note',
              position: 0,
              createdAt: DateTime.utc(2026).millisecondsSinceEpoch,
              updatedAt: DateTime.utc(2026).millisecondsSinceEpoch,
            ),
          );

      await repository.softDelete(person.id);

      final profileRow = await (database.select(
        database.profiles,
      )..where((tbl) => tbl.id.equals(profile.id))).getSingle();
      final noteRow = await (database.select(
        database.notes,
      )..where((tbl) => tbl.id.equals('note-1'))).getSingle();

      expect(profileRow.deletedAt, isNotNull);
      expect(noteRow.deletedAt, isNotNull);
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
