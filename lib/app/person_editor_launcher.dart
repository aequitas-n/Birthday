import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/features/person_editor/presentation/add_person_sheet.dart';

export 'package:kin/features/person_editor/presentation/add_person_sheet.dart'
    show BirthdayCreationMode;

Future<Person?> showAddPersonFlow(
  BuildContext context,
  WidgetRef ref, {
  BirthdayCreationMode mode = BirthdayCreationMode.birthdayOnly,
}) {
  return showAddPersonSheet(context, ref, mode: mode);
}
