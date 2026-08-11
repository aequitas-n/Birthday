import 'package:flutter_test/flutter_test.dart';
import 'package:kin/domain/models/local_calendar_date.dart';

void main() {
  group('LocalCalendarDate', () {
    test('storage key is YYYY-MM-DD', () {
      const date = LocalCalendarDate(year: 2026, month: 3, day: 4);
      expect(date.storageKey, '2026-03-04');
    });

    test('parseStorage round-trips without DateTime.parse', () {
      const original = LocalCalendarDate(year: 2026, month: 10, day: 15);
      final parsed = LocalCalendarDate.parseStorage('2026-10-15');
      expect(parsed, original);
    });

    test('fromLocalDateTime uses calendar components only', () {
      final local = DateTime(2026, 7, 28, 23, 59);
      final date = LocalCalendarDate.fromLocalDateTime(local);
      expect(date.year, 2026);
      expect(date.month, 7);
      expect(date.day, 28);
    });

    test('compareTo orders chronologically', () {
      const a = LocalCalendarDate(year: 2026, month: 1, day: 1);
      const b = LocalCalendarDate(year: 2026, month: 1, day: 2);
      expect(a.compareTo(b), lessThan(0));
    });
  });
}
