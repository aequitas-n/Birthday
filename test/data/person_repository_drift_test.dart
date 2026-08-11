import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/core/id.dart';
import 'package:kin/data/local/database/kin_database.dart';
import 'package:kin/data/repositories/person_repository_drift.dart';
import 'package:kin/domain/models/person.dart';

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
