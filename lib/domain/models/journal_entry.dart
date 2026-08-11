import 'package:kin/domain/models/journal_mood.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:meta/meta.dart';

/// One incident or memory on a journal day.
@immutable
class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.localDate,
    required this.title,
    required this.body,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    this.mood,
    this.deletedAt,
  });

  final String id;
  final LocalCalendarDate localDate;
  final String title;
  final String body;
  final JournalMood? mood;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  JournalEntry copyWith({
    String? id,
    LocalCalendarDate? localDate,
    String? title,
    String? body,
    Object? mood = _sentinel,
    int? position,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _sentinel,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      localDate: localDate ?? this.localDate,
      title: title ?? this.title,
      body: body ?? this.body,
      mood: mood == _sentinel ? this.mood : mood as JournalMood?,
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
    return other is JournalEntry &&
        other.id == id &&
        other.localDate == localDate &&
        other.title == title &&
        other.body == body &&
        other.mood == mood &&
        other.position == position &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    localDate,
    title,
    body,
    mood,
    position,
    createdAt,
    updatedAt,
    deletedAt,
  );
}

const _sentinel = Object();
