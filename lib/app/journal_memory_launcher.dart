import 'package:flutter/widgets.dart';
import 'package:kin/domain/models/journal_entry.dart';
import 'package:kin/domain/models/journal_fragment.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/features/journal/presentation/journal_memory_editor.dart';

/// Cross-feature entry to the Journal memory editor (ARCH-03).
Future<JournalEntry?> openJournalMemoryEditorFlow({
  required BuildContext context,
  required LocalCalendarDate date,
  required int position,
  JournalEntry? existing,
  List<JournalFragment> existingFragments = const [],
}) {
  return openJournalMemoryEditor(
    context: context,
    date: date,
    position: position,
    existing: existing,
    existingFragments: existingFragments,
  );
}
