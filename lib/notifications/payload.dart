import 'dart:convert';

import 'package:kin/domain/models/notification_plan.dart';
import 'package:kin/domain/models/reminder_rule.dart';

String encodeNotificationPayload(NotificationPayload payload) {
  return jsonEncode(<String, Object?>{
    'v': payload.version,
    'source': payload.source.storageValue,
    if (payload.personId != null) 'personId': payload.personId,
    if (payload.reminderId != null) 'reminderId': payload.reminderId,
    if (payload.ruleKind != null) 'ruleKind': payload.ruleKind!.storageValue,
    'year': payload.occurrenceYear,
  });
}

NotificationPayload decodeNotificationPayload(String payload) {
  final decoded = jsonDecode(payload);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Notification payload must be a JSON object.');
  }

  final version = decoded['v'];
  final year = decoded['year'];
  if (version is! int || year is! int) {
    throw const FormatException(
      'Notification payload is missing required fields.',
    );
  }

  final sourceRaw = decoded['source'];
  final source = sourceRaw is String
      ? NotificationPlanSource.fromStorage(sourceRaw)
      : (decoded['reminderId'] is String
            ? NotificationPlanSource.personal
            : NotificationPlanSource.birthday);

  if (source == NotificationPlanSource.personal) {
    final reminderId = decoded['reminderId'];
    if (reminderId is! String) {
      throw const FormatException(
        'Personal notification payload requires reminderId.',
      );
    }
    return NotificationPayload.personal(
      reminderId: reminderId,
      occurrenceYear: year,
      version: version,
    );
  }

  final personId = decoded['personId'];
  final ruleKind = decoded['ruleKind'];
  if (personId is! String || ruleKind is! String) {
    throw const FormatException(
      'Birthday notification payload is missing required fields.',
    );
  }

  return NotificationPayload.birthday(
    personId: personId,
    ruleKind: ReminderRuleKind.fromStorage(ruleKind),
    occurrenceYear: year,
    version: version,
  );
}
