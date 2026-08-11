import 'package:meta/meta.dart';

/// A calendar day in the user's local timezone — not an instant.
///
/// Journal identity is always `YYYY-MM-DD`. Never convert through UTC for
/// storage or lookup; that can shift the day boundary.
@immutable
class LocalCalendarDate implements Comparable<LocalCalendarDate> {
  const LocalCalendarDate({
    required this.year,
    required this.month,
    required this.day,
  }) : assert(month >= 1 && month <= 12, 'Month must be 1–12.'),
       assert(day >= 1 && day <= 31, 'Day must be 1–31.');

  /// Parses [storageKey] without [DateTime.parse] (domain TIME-02).
  factory LocalCalendarDate.parseStorage(String storageKey) {
    final parts = storageKey.split('-');
    if (parts.length != 3) {
      throw FormatException('Expected YYYY-MM-DD, got $storageKey');
    }
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    return LocalCalendarDate(year: year, month: month, day: day);
  }

  /// From a local [DateTime]'s calendar components only — ignores time-of-day.
  factory LocalCalendarDate.fromLocalDateTime(DateTime local) {
    return LocalCalendarDate(
      year: local.year,
      month: local.month,
      day: local.day,
    );
  }

  final int year;
  final int month;
  final int day;

  /// Canonical storage key: `YYYY-MM-DD`.
  String get storageKey {
    final y = year.toString().padLeft(4, '0');
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  LocalCalendarDate copyWith({int? year, int? month, int? day}) {
    return LocalCalendarDate(
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
    );
  }

  /// Previous calendar month (clamped to valid month length when needed).
  LocalCalendarDate previousMonth() {
    if (month == 1) {
      return LocalCalendarDate(year: year - 1, month: 12, day: day);
    }
    return LocalCalendarDate(year: year, month: month - 1, day: day);
  }

  LocalCalendarDate nextMonth() {
    if (month == 12) {
      return LocalCalendarDate(year: year + 1, month: 1, day: day);
    }
    return LocalCalendarDate(year: year, month: month + 1, day: day);
  }

  @override
  int compareTo(LocalCalendarDate other) {
    final byYear = year.compareTo(other.year);
    if (byYear != 0) return byYear;
    final byMonth = month.compareTo(other.month);
    if (byMonth != 0) return byMonth;
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalCalendarDate &&
        other.year == year &&
        other.month == month &&
        other.day == day;
  }

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => storageKey;
}
