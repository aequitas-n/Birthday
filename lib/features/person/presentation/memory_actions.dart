import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/design/components/sheets/q_choice_sheet.dart';
import 'package:kin/domain/models/note.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/domain/models/profile.dart';
// ignore: always_use_package_imports -- ARCH-03: relative within a feature
import 'photo_memory_flow.dart';
// ignore: always_use_package_imports -- ARCH-03: relative within a feature
import 'profile_sheet.dart';

/// Ensures a profile exists, then opens the text detail editor (favorites etc.).
///
/// Pass [note] only when editing/removing an existing detail. For create,
/// omit [note] and optionally pass [initialKind] (e.g. from a tapped row).
Future<void> addDetailMemory({
  required BuildContext context,
  required WidgetRef ref,
  required Person person,
  required int nextPosition,
  RelationshipProfile? profile,
  Note? note,
  NoteKind? initialKind,
}) async {
  final ensured = await ensureProfileForPerson(ref, person, profile);
  if (!context.mounted) return;
  await showNoteEditorSheet(
    context: context,
    profileId: ensured.id,
    position: nextPosition,
    note: note,
    initialKind: initialKind,
  );
}

/// Choose between saving a photo moment or writing a detail (flower, gift…).
Future<void> showAddMemoryChooser({
  required BuildContext context,
  required WidgetRef ref,
  required Person person,
  required int nextPosition,
  RelationshipProfile? profile,
}) async {
  final choice = await showQChoiceSheet(
    context: context,
    title: 'Add a memory',
    choices: const [
      QChoice('Save a photo', support: 'A moment you want to keep.'),
      QChoice(
        'Write a detail',
        support: 'Favorites, gift ideas, or a plan for them…',
      ),
    ],
  );
  if (choice == null || !context.mounted) return;

  switch (choice) {
    case 0:
      await addPhotoMemory(
        context: context,
        ref: ref,
        person: person,
        profile: profile,
        nextPosition: nextPosition,
      );
    case 1:
      await addDetailMemory(
        context: context,
        ref: ref,
        person: person,
        profile: profile,
        nextPosition: nextPosition,
      );
  }
}
