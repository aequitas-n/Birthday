import 'package:flutter_test/flutter_test.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/domain/services/occurrence_calculator.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(tzdata.initializeTimeZones);

  group('OccurrenceCalculator', () {
    const calculator = OccurrenceCalculator();

    test('resolves India midnight to Texas afternoon the previous day', () {
      final occurrence = calculator.next(
        date: const PartialDate(month: 3, day: 4, year: 1998),
        personTimeZone: 'Asia/Kolkata',
        nowUtc: DateTime.utc(2027, 2, 20),
        deviceTimeZone: 'America/Chicago',
      );

      expect(occurrence.anchorUtc, DateTime.utc(2027, 3, 3, 18, 30));
      expect(occurrence.deviceLocalEquivalent.year, 2027);
      expect(occurrence.deviceLocalEquivalent.month, 3);
      expect(occurrence.deviceLocalEquivalent.day, 3);
      expect(occurrence.ageTurning, 29);
    });

    test('uses the next year after the birthday anchor passes', () {
      final occurrence = calculator.next(
        date: const PartialDate(month: 1, day: 2),
        personTimeZone: 'Europe/London',
        nowUtc: DateTime.utc(2027, 1, 3),
        deviceTimeZone: 'Europe/London',
      );

      expect(occurrence.occurrenceYear, 2028);
      expect(occurrence.anchorUtc, DateTime.utc(2028, 1, 2));
    });

    test('resolves february 29 to february 28 in non leap years', () {
      final occurrence = calculator.next(
        date: const PartialDate(month: 2, day: 29, year: 2000),
        personTimeZone: 'Europe/London',
        nowUtc: DateTime.utc(2027, 1, 10),
        deviceTimeZone: 'Europe/London',
      );

      expect(occurrence.occurrenceYear, 2027);
      expect(occurrence.anchorUtc, DateTime.utc(2027, 2, 28));
      expect(occurrence.ageTurning, 27);
    });

    test('keeps february 29 in leap years', () {
      final occurrence = calculator.next(
        date: const PartialDate(month: 2, day: 29),
        personTimeZone: 'Europe/London',
        nowUtc: DateTime.utc(2028, 1, 10),
        deviceTimeZone: 'Europe/London',
      );

      expect(occurrence.anchorUtc, DateTime.utc(2028, 2, 29));
    });

    test(
      'handles new york DST start year without changing the birthday date',
      () {
        final occurrence = calculator.next(
          date: const PartialDate(month: 3, day: 9),
          personTimeZone: 'America/New_York',
          nowUtc: DateTime.utc(2025),
          deviceTimeZone: 'America/New_York',
        );

        final local = tz.TZDateTime.from(
          occurrence.anchorUtc,
          tz.getLocation('America/New_York'),
        );
        expect(local.year, 2025);
        expect(local.month, 3);
        expect(local.day, 9);
      },
    );

    test(
      'handles new york DST end year without changing the birthday date',
      () {
        final occurrence = calculator.next(
          date: const PartialDate(month: 11, day: 2),
          personTimeZone: 'America/New_York',
          nowUtc: DateTime.utc(2025),
          deviceTimeZone: 'America/New_York',
        );

        final local = tz.TZDateTime.from(
          occurrence.anchorUtc,
          tz.getLocation('America/New_York'),
        );
        expect(local.year, 2025);
        expect(local.month, 11);
        expect(local.day, 2);
      },
    );

    test('handles UTC+14 against UTC-12 across the date line', () {
      final occurrence = calculator.next(
        date: const PartialDate(month: 1, day: 1),
        personTimeZone: 'Pacific/Kiritimati',
        nowUtc: DateTime.utc(2026, 12, 20),
        deviceTimeZone: 'Etc/GMT+12',
      );

      expect(occurrence.anchorUtc, DateTime.utc(2026, 12, 31, 10));
      expect(occurrence.deviceLocalEquivalent.year, 2026);
      expect(occurrence.deviceLocalEquivalent.month, 12);
      expect(occurrence.deviceLocalEquivalent.day, 30);
    });

    test('handles Sydney timezone correctly', () {
      final occurrence = calculator.next(
        date: const PartialDate(month: 7, day: 28),
        personTimeZone: 'Australia/Sydney',
        nowUtc: DateTime.utc(2026, 6),
        deviceTimeZone: 'Europe/London',
      );

      final sydney = tz.TZDateTime.from(
        occurrence.anchorUtc,
        tz.getLocation('Australia/Sydney'),
      );
      expect(sydney.day, 28);
      expect(sydney.month, 7);
      expect(sydney.hour, 0);
    });

    test(
      'falls back to the device timezone when the person timezone is absent',
      () {
        final occurrence = calculator.next(
          date: const PartialDate(month: 4, day: 3),
          personTimeZone: null,
          nowUtc: DateTime.utc(2026),
          deviceTimeZone: 'Asia/Kolkata',
        );

        expect(occurrence.personTimeZone, 'Asia/Kolkata');
        expect(occurrence.deviceTimeZone, 'Asia/Kolkata');
      },
    );

    test('rejects impossible calendar dates', () {
      expect(
        () => calculator.next(
          date: const PartialDate(month: 4, day: 31),
          personTimeZone: 'Europe/London',
          nowUtc: DateTime.utc(2026),
          deviceTimeZone: 'Europe/London',
        ),
        throwsArgumentError,
      );
    });
  });
}
