import 'package:kin/domain/models/journal_fragment.dart';

/// One choice in the “what comes next?” composer.
class JournalFragmentChoice {
  const JournalFragmentChoice({
    required this.kind,
    required this.title,
    required this.support,
  });

  final JournalFragmentKind kind;
  final String title;
  final String support;
}
