import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/domain/models/local_clock_time.dart';
import 'package:kin/domain/models/reminder_day_part.dart';
import 'package:meta/meta.dart';

/// App-owned personal reminder — independent of Person / Birthday / Journal.
@immutable
class PersonalReminder {
  const PersonalReminder({
    required this.id,
    required this.localDate,
    required this.localTime,
    required this.dayPart,
    required this.text,
    required this.timezone,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final LocalCalendarDate localDate;
  final LocalClockTime localTime;
  final ReminderDayPart dayPart;
  final String text;

  /// IANA zone used when this row was last written.
  ///
  /// Scheduling uses the current Settings reminder timezone; this field tracks
  /// the zone preference at write time and is updated on timezone change.
  final String timezone;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  PersonalReminder copyWith({
    String? id,
    LocalCalendarDate? localDate,
    LocalClockTime? localTime,
    ReminderDayPart? dayPart,
    String? text,
    String? timezone,
    int? position,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _sentinel,
  }) {
    return PersonalReminder(
      id: id ?? this.id,
      localDate: localDate ?? this.localDate,
      localTime: localTime ?? this.localTime,
      dayPart: dayPart ?? this.dayPart,
      text: text ?? this.text,
      timezone: timezone ?? this.timezone,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt == _sentinel
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PersonalReminder &&
        other.id == id &&
        other.localDate == localDate &&
        other.localTime == localTime &&
        other.dayPart == dayPart &&
        other.text == text &&
        other.timezone == timezone &&
        other.position == position &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    localDate,
    localTime,
    dayPart,
    text,
    timezone,
    position,
    createdAt,
    updatedAt,
    deletedAt,
  );
}

const _sentinel = Object();
