import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/core/id.dart';
import 'package:kin/data/local/database/kin_database.dart';
import 'package:kin/data/local/files/image_store.dart';
import 'package:kin/data/repositories/person_repository_drift.dart';
import 'package:kin/data/timezone/city_dataset.dart';
import 'package:kin/features/person_editor/application/person_editor_notifier.dart';

void main() {
  group('PersonEditorNotifier', () {
    late KinDatabase database;
    late ProviderContainer container;

    setUp(() {
      database = KinDatabase(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [
          kinDatabaseProvider.overrideWithValue(database),
          personRepositoryProvider.overrideWithValue(
            DriftPersonRepository(
              database,
              const _FixedIdGenerator('person-001'),
              const _FixedClock(),
            ),
          ),
          imageStoreProvider.overrideWithValue(const _NoopImageStore()),
          idGeneratorProvider.overrideWithValue(
            const _FixedIdGenerator('draft-001'),
          ),
          clockProvider.overrideWithValue(const _FixedClock()),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await database.close();
    });

    test('validates required birthday fields gently', () async {
      final notifier = container.read(personEditorProvider.notifier);

      final saved = await notifier.save();
      final state = container.read(personEditorProvider);

      expect(saved, isNull);
      expect(state.nameError, 'Add a name.');
      expect(state.birthdayError, 'Pick a birthday.');
      expect(state.locationError, 'Choose where they live.');
    });

    test('saves a birthday-only person', () async {
      final notifier = container.read(personEditorProvider.notifier)
        ..setName('Priya Raman')
        ..setBirthDay('28')
        ..setBirthMonth(7)
        ..setBirthYear('1997')
        ..setLocation(cityDataset.firstWhere((city) => city.city == 'Chennai'));

      final saved = await notifier.save();
      final people = await container
          .read(personRepositoryProvider)
          .watchAll()
          .first;
      final profiles = await database.select(database.profiles).get();

      expect(saved, isNotNull);
      expect(saved!.displayName, 'Priya Raman');
      expect(saved.birthday.year, 1997);
      expect(saved.location?.label, 'Chennai, Tamil Nadu, India');
      expect(saved.location?.timezone?.ianaName, 'Asia/Kolkata');
      expect(people.single.displayName, 'Priya Raman');
      expect(profiles, isEmpty);
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

class _NoopImageStore implements ImageStore {
  const _NoopImageStore();

  @override
  Future<void> delete(String relativePath) async {}

  @override
  Future<void> deleteOrphans(Set<String> retainedRelativePaths) async {}

  @override
  Future<StoredImageWrite> putJpeg(Uint8List bytes) {
    throw UnimplementedError();
  }

  @override
  Future<File> resolve(String relativePath) {
    throw UnimplementedError();
  }
}
