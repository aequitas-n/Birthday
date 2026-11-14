import 'package:meta/meta.dart';

enum ReminderRuleKind {
  daysBefore,
  atTheirMidnight,
  morningOf;

  static ReminderRuleKind fromStorage(String value) {
    return switch (value) {
      'days_before' => ReminderRuleKind.daysBefore,
      'at_their_midnight' => ReminderRuleKind.atTheirMidnight,
      'morning_of' => ReminderRuleKind.morningOf,
      _ => throw ArgumentError.value(value, 'value', 'Unknown reminder rule.'),
    };
  }

  String get storageValue => switch (this) {
    ReminderRuleKind.daysBefore => 'days_before',
    ReminderRuleKind.atTheirMidnight => 'at_their_midnight',
    ReminderRuleKind.morningOf => 'morning_of',
  };
}

@immutable
class ReminderRule {
  const ReminderRule({
    required this.id,
    required this.kind,
    required this.enabled,
    required this.updatedAt,
    this.personId,
    this.offsetDays,
    this.localTime,
    this.deletedAt,
    this.syncRev = 0,
  });

  final String id;
  final String? personId;
  final ReminderRuleKind kind;
  final int? offsetDays;
  final String? localTime;
  final bool enabled;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncRev;

  bool get isGlobalDefault => personId == null;

  ReminderRule copyWith({
    String? id,
    Object? personId = _sentinel,
    ReminderRuleKind? kind,
    Object? offsetDays = _sentinel,
    Object? localTime = _sentinel,
    bool? enabled,
    DateTime? updatedAt,
    Object? deletedAt = _sentinel,
    int? syncRev,
  }) {
    return ReminderRule(
      id: id ?? this.id,
      personId: personId == _sentinel ? this.personId : personId as String?,
      kind: kind ?? this.kind,
      offsetDays: offsetDays == _sentinel
          ? this.offsetDays
          : offsetDays as int?,
      localTime: localTime == _sentinel ? this.localTime : localTime as String?,
      enabled: enabled ?? this.enabled,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt == _sentinel
          ? this.deletedAt
          : deletedAt as DateTime?,
      syncRev: syncRev ?? this.syncRev,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ReminderRule &&
        other.id == id &&
        other.personId == personId &&
        other.kind == kind &&
        other.offsetDays == offsetDays &&
        other.localTime == localTime &&
        other.enabled == enabled &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt &&
        other.syncRev == syncRev;
  }

  @override
  int get hashCode => Object.hash(
    id,
    personId,
    kind,
    offsetDays,
    localTime,
    enabled,
    updatedAt,
    deletedAt,
    syncRev,
  );
}

const _sentinel = Object();
