import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/data/local/database/kin_database.dart';

void main() {
  group('KinDatabase', () {
    late KinDatabase database;

    setUp(() {
      database = KinDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    test('seeds the single settings row and default reminder rules', () async {
      final settings = await database.select(database.settings).getSingle();
      final rules =
          await (database.select(database.reminderRules)
                ..where((tbl) => tbl.personId.isNull())
                ..where((tbl) => tbl.deletedAt.isNull()))
              .get();

      expect(settings.id, 0);
      expect(settings.themeMode, 'system');
      expect(settings.amoled, isFalse);
      expect(settings.productTheme, 'default');
      expect(
        rules.map((row) => row.id),
        containsAll(const [
          'default-days-7',
          'default-days-1',
          'default-at-midnight',
        ]),
      );
    });

    test('schema v9 includes product theme', () async {
      expect(database.schemaVersion, 9);
      expect(database.journalDays, isNotNull);
      expect(database.journalEntries, isNotNull);
      expect(database.journalEntryPhotos, isNotNull);
      expect(database.journalEntryFragments, isNotNull);
      expect(database.personalReminders, isNotNull);
      expect(database.scheduledNotifications, isNotNull);
    });
  });
}
