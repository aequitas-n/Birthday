import 'package:kin/domain/models/journal_mood.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:meta/meta.dart';

/// One calendar day in the user's personal journal.
@immutable
class JournalDay {
  const JournalDay({
    required this.localDate,
    required this.createdAt,
    required this.updatedAt,
    this.mood,
    this.deletedAt,
  });

  final LocalCalendarDate localDate;
  final JournalMood? mood;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  JournalDay copyWith({
    LocalCalendarDate? localDate,
    Object? mood = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _sentinel,
  }) {
    return JournalDay(
      localDate: localDate ?? this.localDate,
      mood: mood == _sentinel ? this.mood : mood as JournalMood?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt == _sentinel
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is JournalDay &&
        other.localDate == localDate &&
        other.mood == mood &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode =>
      Object.hash(localDate, mood, createdAt, updatedAt, deletedAt);
}

const _sentinel = Object();
