import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/design/feedback/quiet_haptics.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/domain/models/profile.dart';
import 'package:kin/features/person/presentation/profile_sheet.dart';

Future<void> showProfileFlow({
  required BuildContext context,
  required WidgetRef ref,
  required Person person,
  RelationshipProfile? profile,
}) {
  QuietHaptics.open();
  return showProfileSheet(
    context: context,
    ref: ref,
    person: person,
    profile: profile,
  );
}
