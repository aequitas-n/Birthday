import 'package:kin/domain/models/reminder_rule.dart';
import 'package:meta/meta.dart';

enum NotificationPlanSource {
  birthday,
  personal;

  static NotificationPlanSource fromStorage(String value) {
    return values.firstWhere(
      (entry) => entry.name == value,
      orElse: () => NotificationPlanSource.birthday,
    );
  }

  String get storageValue => name;
}

enum NotificationPlanKind {
  birthdayToday,
  birthdayUpcoming,
  personalReminder;

  static NotificationPlanKind fromStorage(String value) {
    return values.firstWhere(
      (kind) => kind.name == value,
      orElse: () =>
          throw FormatException('Unknown notification plan kind: $value'),
    );
  }
}

@immutable
class NotificationPayload {
  const NotificationPayload({
    required this.version,
    required this.source,
    required this.occurrenceYear,
    this.personId,
    this.reminderId,
    this.ruleKind,
  }) : assert(
         (source == NotificationPlanSource.birthday &&
                 personId != null &&
                 ruleKind != null) ||
             (source == NotificationPlanSource.personal && reminderId != null),
         'Payload fields must match source.',
       );

  factory NotificationPayload.birthday({
    required String personId,
    required ReminderRuleKind ruleKind,
    required int occurrenceYear,
    int version = 1,
  }) {
    return NotificationPayload(
      version: version,
      source: NotificationPlanSource.birthday,
      personId: personId,
      ruleKind: ruleKind,
      occurrenceYear: occurrenceYear,
    );
  }

  factory NotificationPayload.personal({
    required String reminderId,
    required int occurrenceYear,
    int version = 1,
  }) {
    return NotificationPayload(
      version: version,
      source: NotificationPlanSource.personal,
      reminderId: reminderId,
      occurrenceYear: occurrenceYear,
    );
  }

  final int version;
  final NotificationPlanSource source;
  final String? personId;
  final String? reminderId;
  final ReminderRuleKind? ruleKind;
  final int occurrenceYear;

  @override
  bool operator ==(Object other) {
    return other is NotificationPayload &&
        other.version == version &&
        other.source == source &&
        other.personId == personId &&
        other.reminderId == reminderId &&
        other.ruleKind == ruleKind &&
        other.occurrenceYear == occurrenceYear;
  }

  @override
  int get hashCode => Object.hash(
    version,
    source,
    personId,
    reminderId,
    ruleKind,
    occurrenceYear,
  );
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
    required this.source,
    required this.occurrenceYear,
    required this.fireAtUtc,
    required this.targetLocalInstant,
    required this.kind,
    required this.payload,
    required this.title,
    required this.body,
    required this.hidesSensitivePreview,
    this.personId,
    this.ruleId,
    this.reminderId,
  });

  final int stableId;
  final NotificationPlanSource source;
  final String? personId;
  final String? ruleId;
  final String? reminderId;
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
    NotificationPlanSource? source,
    Object? personId = _sentinel,
    Object? ruleId = _sentinel,
    Object? reminderId = _sentinel,
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
      source: source ?? this.source,
      personId: personId == _sentinel ? this.personId : personId as String?,
      ruleId: ruleId == _sentinel ? this.ruleId : ruleId as String?,
      reminderId: reminderId == _sentinel
          ? this.reminderId
          : reminderId as String?,
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
        other.source == source &&
        other.personId == personId &&
        other.ruleId == ruleId &&
        other.reminderId == reminderId &&
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
    source,
    personId,
    ruleId,
    reminderId,
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

const _sentinel = Object();
