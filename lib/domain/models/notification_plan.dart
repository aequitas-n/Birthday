import 'package:kin/domain/models/reminder_rule.dart';
import 'package:meta/meta.dart';

enum NotificationPlanKind { birthdayToday, birthdayUpcoming }

@immutable
class NotificationPayload {
  const NotificationPayload({
    required this.version,
    required this.personId,
    required this.ruleKind,
    required this.occurrenceYear,
  });

  final int version;
  final String personId;
  final ReminderRuleKind ruleKind;
  final int occurrenceYear;

  @override
  bool operator ==(Object other) {
    return other is NotificationPayload &&
        other.version == version &&
        other.personId == personId &&
        other.ruleKind == ruleKind &&
        other.occurrenceYear == occurrenceYear;
  }

  @override
  int get hashCode => Object.hash(version, personId, ruleKind, occurrenceYear);
}

@immutable
class LocalScheduledMoment {
  const LocalScheduledMoment({
    required this.timeZone,
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
    this.second = 0,
  });

  final String timeZone;
  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;
  final int second;

  @override
  bool operator ==(Object other) {
    return other is LocalScheduledMoment &&
        other.timeZone == timeZone &&
        other.year == year &&
        other.month == month &&
        other.day == day &&
        other.hour == hour &&
        other.minute == minute &&
        other.second == second;
  }

  @override
  int get hashCode =>
      Object.hash(timeZone, year, month, day, hour, minute, second);
}

@immutable
class NotificationPlan {
  const NotificationPlan({
    required this.stableId,
    required this.personId,
    required this.ruleId,
    required this.occurrenceYear,
    required this.fireAtUtc,
    required this.targetLocalInstant,
    required this.kind,
    required this.payload,
    required this.title,
    required this.body,
    required this.hidesSensitivePreview,
  });

  final int stableId;
  final String personId;
  final String ruleId;
  final int occurrenceYear;
  final DateTime fireAtUtc;
  final LocalScheduledMoment targetLocalInstant;
  final NotificationPlanKind kind;
  final NotificationPayload payload;
  final String title;
  final String body;
  final bool hidesSensitivePreview;

  NotificationPlan copyWith({
    int? stableId,
    String? personId,
    String? ruleId,
    int? occurrenceYear,
    DateTime? fireAtUtc,
    LocalScheduledMoment? targetLocalInstant,
    NotificationPlanKind? kind,
    NotificationPayload? payload,
    String? title,
    String? body,
    bool? hidesSensitivePreview,
  }) {
    return NotificationPlan(
      stableId: stableId ?? this.stableId,
      personId: personId ?? this.personId,
      ruleId: ruleId ?? this.ruleId,
      occurrenceYear: occurrenceYear ?? this.occurrenceYear,
      fireAtUtc: fireAtUtc ?? this.fireAtUtc,
      targetLocalInstant: targetLocalInstant ?? this.targetLocalInstant,
      kind: kind ?? this.kind,
      payload: payload ?? this.payload,
      title: title ?? this.title,
      body: body ?? this.body,
      hidesSensitivePreview:
          hidesSensitivePreview ?? this.hidesSensitivePreview,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationPlan &&
        other.stableId == stableId &&
        other.personId == personId &&
        other.ruleId == ruleId &&
        other.occurrenceYear == occurrenceYear &&
        other.fireAtUtc == fireAtUtc &&
        other.targetLocalInstant == targetLocalInstant &&
        other.kind == kind &&
        other.payload == payload &&
        other.title == title &&
        other.body == body &&
        other.hidesSensitivePreview == hidesSensitivePreview;
  }

  @override
  int get hashCode => Object.hash(
    stableId,
    personId,
    ruleId,
    occurrenceYear,
    fireAtUtc,
    targetLocalInstant,
    kind,
    payload,
    title,
    body,
    hidesSensitivePreview,
  );
}

@immutable
class NotificationPlanReconciliation {
  const NotificationPlanReconciliation({
    required this.toAdd,
    required this.toUpdate,
    required this.toRemove,
    required this.unchanged,
  });

  final List<NotificationPlan> toAdd;
  final List<NotificationPlan> toUpdate;
  final List<NotificationPlan> toRemove;
  final List<NotificationPlan> unchanged;
}
