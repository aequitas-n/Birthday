import 'dart:convert';

import 'package:kin/domain/models/notification_plan.dart';
import 'package:kin/domain/models/reminder_rule.dart';

String encodeScheduleSnapshot(NotificationPlan plan) {
  return jsonEncode(<String, Object?>{
    'kind': plan.kind.name,
    'payload': <String, Object?>{
      'version': plan.payload.version,
      'personId': plan.payload.personId,
      'ruleKind': plan.payload.ruleKind.storageValue,
      'occurrenceYear': plan.payload.occurrenceYear,
    },
    'targetLocalInstant': <String, Object?>{
      'timeZone': plan.targetLocalInstant.timeZone,
      'year': plan.targetLocalInstant.year,
      'month': plan.targetLocalInstant.month,
      'day': plan.targetLocalInstant.day,
      'hour': plan.targetLocalInstant.hour,
      'minute': plan.targetLocalInstant.minute,
      'second': plan.targetLocalInstant.second,
    },
    'hidesSensitivePreview': plan.hidesSensitivePreview,
  });
}

NotificationPlanKind decodePlanKind(String value) {
  return NotificationPlanKind.values.firstWhere(
    (kind) => kind.name == value,
    orElse: () =>
        throw FormatException('Unknown notification plan kind: $value'),
  );
}

LocalScheduledMoment decodeTargetLocalInstant(Map<String, dynamic> json) {
  final timeZone = json['timeZone'];
  final year = json['year'];
  final month = json['month'];
  final day = json['day'];
  final hour = json['hour'];
  final minute = json['minute'];
  final second = json['second'];

  if (timeZone is! String ||
      year is! int ||
      month is! int ||
      day is! int ||
      hour is! int ||
      minute is! int) {
    throw const FormatException(
      'Target local instant is missing required fields.',
    );
  }

  return LocalScheduledMoment(
    timeZone: timeZone,
    year: year,
    month: month,
    day: day,
    hour: hour,
    minute: minute,
    second: second is int ? second : 0,
  );
}

NotificationPayload decodePayloadMap(Map<String, dynamic> json) {
  final version = json['version'];
  final personId = json['personId'];
  final ruleKind = json['ruleKind'];
  final occurrenceYear = json['occurrenceYear'];

  if (version is! int ||
      personId is! String ||
      ruleKind is! String ||
      occurrenceYear is! int) {
    throw const FormatException('Payload snapshot is missing required fields.');
  }

  return NotificationPayload(
    version: version,
    personId: personId,
    ruleKind: ReminderRuleKind.fromStorage(ruleKind),
    occurrenceYear: occurrenceYear,
  );
}

Map<String, dynamic> decodeScheduleSnapshot(String snapshotJson) {
  final decoded = jsonDecode(snapshotJson);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Schedule snapshot must be a JSON object.');
  }
  return decoded;
}
