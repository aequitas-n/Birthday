import 'dart:convert';

import 'package:kin/domain/models/notification_plan.dart';
import 'package:kin/domain/models/reminder_rule.dart';

String encodeNotificationPayload(NotificationPayload payload) {
  return jsonEncode(<String, Object?>{
    'v': payload.version,
    'personId': payload.personId,
    'ruleKind': payload.ruleKind.storageValue,
    'year': payload.occurrenceYear,
  });
}

NotificationPayload decodeNotificationPayload(String payload) {
  final decoded = jsonDecode(payload);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Notification payload must be a JSON object.');
  }

  final version = decoded['v'];
  final personId = decoded['personId'];
  final ruleKind = decoded['ruleKind'];
  final year = decoded['year'];

  if (version is! int ||
      personId is! String ||
      ruleKind is! String ||
      year is! int) {
    throw const FormatException(
      'Notification payload is missing required fields.',
    );
  }

  return NotificationPayload(
    version: version,
    personId: personId,
    ruleKind: ReminderRuleKind.fromStorage(ruleKind),
    occurrenceYear: year,
  );
}
