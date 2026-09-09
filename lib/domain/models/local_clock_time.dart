import 'package:meta/meta.dart';

/// Clock time on a calendar day — not an instant and not timezone-aware.
///
/// Stored as `HH:mm` (24-hour). Pair with LocalCalendarDate + IANA zone
/// when scheduling.
@immutable
class LocalClockTime implements Comparable<LocalClockTime> {
  const LocalClockTime({required this.hour, required this.minute})
    : assert(hour >= 0 && hour <= 23, 'Hour must be 0–23.'),
      assert(minute >= 0 && minute <= 59, 'Minute must be 0–59.');

  /// Parses `HH:mm` without [DateTime.parse] (domain TIME-02).
  factory LocalClockTime.parseStorage(String value) {
    final parts = value.split(':');
    if (parts.length != 2) {
      throw FormatException('Expected HH:mm, got $value');
    }
    return LocalClockTime(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  final int hour;
  final int minute;

  String get storageValue {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Quiet display: `7:30 PM`.
  String get displayLabel {
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    return '$hour12:$m $period';
  }

  LocalClockTime copyWith({int? hour, int? minute}) {
    return LocalClockTime(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  @override
  int compareTo(LocalClockTime other) {
    final byHour = hour.compareTo(other.hour);
    if (byHour != 0) return byHour;
    return minute.compareTo(other.minute);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalClockTime &&
        other.hour == hour &&
        other.minute == minute;
  }

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => storageValue;
}
