import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/core/id.dart';
import 'package:kin/data/local/database/kin_database.dart';
import 'package:kin/data/repositories/profile_repository_drift.dart';
import 'package:kin/domain/models/profile.dart';

void main() {
  group('DriftProfileRepository', () {
    late KinDatabase database;
    late DriftProfileRepository repository;

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
      repository = DriftProfileRepository(
        database,
        const _FixedIdGenerator('profile-001'),
        const _FixedClock(),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('creates an optional profile for a person', () async {
      final saved = await repository.save(
        RelationshipProfile(
          id: '',
          personId: 'person-1',
          nickname: 'Priya',
          relationship: RelationshipKind.family,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
      );

      final watched = await repository.watchForPerson('person-1').first;

      expect(saved.id, 'profile-001');
      expect(watched?.nickname, 'Priya');
      expect(watched?.relationship, RelationshipKind.family);
    });

    test('persists pin state across reads', () async {
      final saved = await repository.save(
        RelationshipProfile(
          id: '',
          personId: 'person-1',
          nickname: 'Priya',
          isPinned: true,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
      );

      expect(saved.isPinned, isTrue);

      final reloaded = await repository.readForPerson('person-1');
      expect(reloaded?.isPinned, isTrue);

      final freshRepo = DriftProfileRepository(
        database,
        const _FixedIdGenerator('profile-002'),
        const _FixedClock(),
      );
      final cold = await freshRepo.readForPerson('person-1');
      expect(cold?.isPinned, isTrue);

      await repository.save(
        saved.copyWith(isPinned: false, updatedAt: DateTime.utc(2026, 8)),
      );
      final unpinned = await freshRepo.readForPerson('person-1');
      expect(unpinned?.isPinned, isFalse);
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
