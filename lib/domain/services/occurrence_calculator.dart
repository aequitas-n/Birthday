import 'package:kin/domain/models/birthday_occurrence.dart';
import 'package:kin/domain/models/person.dart';
import 'package:timezone/timezone.dart' as tz;

class OccurrenceCalculator {
  const OccurrenceCalculator();

  BirthdayOccurrence next({
    required PartialDate date,
    required String? personTimeZone,
    required DateTime nowUtc,
    required String deviceTimeZone,
  }) {
    _validateDate(date);

    final resolvedPersonTimeZone = personTimeZone ?? deviceTimeZone;
    final personLocation = tz.getLocation(resolvedPersonTimeZone);
    final deviceLocation = tz.getLocation(deviceTimeZone);
    final now = nowUtc.toUtc();

    final currentYear = tz.TZDateTime.from(now, personLocation).year;
    final thisYearStart = _firstMomentOfBirthday(
      location: personLocation,
      year: currentYear,
      date: date,
    );
    final personLocalStart =
        thisYearStart.toUtc().isAfter(now) ||
            thisYearStart.toUtc().isAtSameMomentAs(now)
        ? thisYearStart
        : _firstMomentOfBirthday(
            location: personLocation,
            year: currentYear + 1,
            date: date,
          );

    final anchorUtc = personLocalStart.toUtc();
    final deviceLocalEquivalent = tz.TZDateTime.from(anchorUtc, deviceLocation);

    return BirthdayOccurrence(
      occurrenceYear: personLocalStart.year,
      anchorUtc: anchorUtc,
      personLocalStart: DateTime.utc(
        personLocalStart.year,
        personLocalStart.month,
        personLocalStart.day,
        personLocalStart.hour,
        personLocalStart.minute,
        personLocalStart.second,
      ),
      deviceLocalEquivalent: DateTime.utc(
        deviceLocalEquivalent.year,
        deviceLocalEquivalent.month,
        deviceLocalEquivalent.day,
        deviceLocalEquivalent.hour,
        deviceLocalEquivalent.minute,
        deviceLocalEquivalent.second,
      ),
      personTimeZone: resolvedPersonTimeZone,
      deviceTimeZone: deviceTimeZone,
      ageTurning: date.year == null ? null : personLocalStart.year - date.year!,
    );
  }

  tz.TZDateTime _firstMomentOfBirthday({
    required tz.Location location,
    required int year,
    required PartialDate date,
  }) {
    final resolvedDay = date.month == 2 && date.day == 29 && !_isLeapYear(year)
        ? 28
        : date.day;

    for (var minute = 0; minute < 180; minute++) {
      final hour = minute ~/ 60;
      final minuteOfHour = minute % 60;
      final candidate = tz.TZDateTime(
        location,
        year,
        date.month,
        resolvedDay,
        hour,
        minuteOfHour,
      );
      if (candidate.year == year &&
          candidate.month == date.month &&
          candidate.day == resolvedDay) {
        return candidate;
      }
    }

    throw StateError(
      'Could not resolve the first valid instant of '
      '$resolvedDay/${date.month}/$year in ${location.name}.',
    );
  }

  void _validateDate(PartialDate date) {
    final maxDay = switch (date.month) {
      1 || 3 || 5 || 7 || 8 || 10 || 12 => 31,
      4 || 6 || 9 || 11 => 30,
      2 => 29,
      _ => throw ArgumentError.value(date.month, 'month', 'Invalid month.'),
    };
    if (date.day > maxDay) {
      throw ArgumentError.value(
        date.day,
        'day',
        'Invalid day for month ${date.month}.',
      );
    }
  }
}

bool _isLeapYear(int year) {
  if (year % 400 == 0) return true;
  if (year % 100 == 0) return false;
  return year % 4 == 0;
}
