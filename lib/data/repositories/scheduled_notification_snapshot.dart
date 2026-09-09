import 'dart:convert';

import 'package:kin/domain/models/notification_plan.dart';
import 'package:kin/domain/models/reminder_rule.dart';

String encodeScheduleSnapshot(NotificationPlan plan) {
  return jsonEncode(<String, Object?>{
    'kind': plan.kind.name,
    'source': plan.source.storageValue,
    'payload': <String, Object?>{
      'version': plan.payload.version,
      'source': plan.payload.source.storageValue,
      if (plan.payload.personId != null) 'personId': plan.payload.personId,
      if (plan.payload.reminderId != null)
        'reminderId': plan.payload.reminderId,
      if (plan.payload.ruleKind != null)
        'ruleKind': plan.payload.ruleKind!.storageValue,
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
    if (plan.reminderId != null) 'reminderId': plan.reminderId,
  });
}

NotificationPlanKind decodePlanKind(String value) {
  return NotificationPlanKind.fromStorage(value);
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
  final occurrenceYear = json['occurrenceYear'];
  if (version is! int || occurrenceYear is! int) {
    throw const FormatException('Payload snapshot is missing required fields.');
  }

  final sourceRaw = json['source'];
  final source = sourceRaw is String
      ? NotificationPlanSource.fromStorage(sourceRaw)
      : (json['reminderId'] is String
            ? NotificationPlanSource.personal
            : NotificationPlanSource.birthday);

  if (source == NotificationPlanSource.personal) {
    final reminderId = json['reminderId'];
    if (reminderId is! String) {
      throw const FormatException(
        'Personal payload snapshot requires reminderId.',
      );
    }
    return NotificationPayload.personal(
      reminderId: reminderId,
      occurrenceYear: occurrenceYear,
      version: version,
    );
  }

  final personId = json['personId'];
  final ruleKind = json['ruleKind'];
  if (personId is! String || ruleKind is! String) {
    throw const FormatException(
      'Birthday payload snapshot is missing required fields.',
    );
  }

  return NotificationPayload.birthday(
    personId: personId,
    ruleKind: ReminderRuleKind.fromStorage(ruleKind),
    occurrenceYear: occurrenceYear,
    version: version,
  );
}

Map<String, dynamic> decodeScheduleSnapshot(String snapshotJson) {
  final decoded = jsonDecode(snapshotJson);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Schedule snapshot must be a JSON object.');
  }
  return decoded;
}
