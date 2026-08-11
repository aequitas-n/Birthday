import 'package:kin/domain/models/notification_plan.dart';
import 'package:meta/meta.dart';

enum ScheduledNotificationState {
  planned,
  registered,
  fired,
  stale
  ;

  static ScheduledNotificationState fromStorage(String value) {
    return switch (value) {
      'planned' => ScheduledNotificationState.planned,
      'registered' => ScheduledNotificationState.registered,
      'fired' => ScheduledNotificationState.fired,
      'stale' => ScheduledNotificationState.stale,
      _ => throw ArgumentError.value(
        value,
        'value',
        'Unknown scheduled notification state.',
      ),
    };
  }

  String get storageValue => name;
}

@immutable
class ScheduledNotificationRecord {
  const ScheduledNotificationRecord({
    required this.osId,
    required this.personId,
    required this.ruleId,
    required this.occurrenceYear,
    required this.fireAtUtc,
    required this.targetLocalInstant,
    required this.deviceTimeZone,
    required this.kind,
    required this.payload,
    required this.title,
    required this.body,
    required this.hidesSensitivePreview,
    required this.state,
    required this.createdAt,
    this.noteIdUsed,
  });

  factory ScheduledNotificationRecord.fromPlan({
    required NotificationPlan plan,
    required String deviceTimeZone,
    required DateTime createdAt,
    ScheduledNotificationState state = ScheduledNotificationState.registered,
    String? noteIdUsed,
  }) {
    return ScheduledNotificationRecord(
      osId: plan.stableId,
      personId: plan.personId,
      ruleId: plan.ruleId,
      occurrenceYear: plan.occurrenceYear,
      fireAtUtc: plan.fireAtUtc.toUtc(),
      targetLocalInstant: plan.targetLocalInstant,
      deviceTimeZone: deviceTimeZone,
      kind: plan.kind,
      payload: plan.payload,
      title: plan.title,
      body: plan.body,
      hidesSensitivePreview: plan.hidesSensitivePreview,
      state: state,
      createdAt: createdAt.toUtc(),
      noteIdUsed: noteIdUsed,
    );
  }

  final int osId;
  final String personId;
  final String ruleId;
  final int occurrenceYear;
  final DateTime fireAtUtc;
  final LocalScheduledMoment targetLocalInstant;
  final String deviceTimeZone;
  final NotificationPlanKind kind;
  final NotificationPayload payload;
  final String title;
  final String body;
  final bool hidesSensitivePreview;
  final ScheduledNotificationState state;
  final DateTime createdAt;
  final String? noteIdUsed;

  NotificationPlan toPlan() {
    return NotificationPlan(
      stableId: osId,
      personId: personId,
      ruleId: ruleId,
      occurrenceYear: occurrenceYear,
      fireAtUtc: fireAtUtc,
      targetLocalInstant: targetLocalInstant,
      kind: kind,
      payload: payload,
      title: title,
      body: body,
      hidesSensitivePreview: hidesSensitivePreview,
    );
  }

  ScheduledNotificationRecord copyWith({ScheduledNotificationState? state}) {
    return ScheduledNotificationRecord(
      osId: osId,
      personId: personId,
      ruleId: ruleId,
      occurrenceYear: occurrenceYear,
      fireAtUtc: fireAtUtc,
      targetLocalInstant: targetLocalInstant,
      deviceTimeZone: deviceTimeZone,
      kind: kind,
      payload: payload,
      title: title,
      body: body,
      hidesSensitivePreview: hidesSensitivePreview,
      state: state ?? this.state,
      createdAt: createdAt,
      noteIdUsed: noteIdUsed,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ScheduledNotificationRecord &&
        other.osId == osId &&
        other.personId == personId &&
        other.ruleId == ruleId &&
        other.occurrenceYear == occurrenceYear &&
        other.fireAtUtc == fireAtUtc &&
        other.targetLocalInstant == targetLocalInstant &&
        other.deviceTimeZone == deviceTimeZone &&
        other.kind == kind &&
        other.payload == payload &&
        other.title == title &&
        other.body == body &&
        other.hidesSensitivePreview == hidesSensitivePreview &&
        other.state == state &&
        other.createdAt == createdAt &&
        other.noteIdUsed == noteIdUsed;
  }

  @override
  int get hashCode => Object.hash(
    osId,
    personId,
    ruleId,
    occurrenceYear,
    fireAtUtc,
    targetLocalInstant,
    deviceTimeZone,
    kind,
    payload,
    title,
    body,
    hidesSensitivePreview,
    state,
    createdAt,
    noteIdUsed,
  );
}
