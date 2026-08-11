import 'package:kin/domain/models/journal_fragment.dart';
import 'package:kin/domain/models/journal_fragment_choice.dart';
// ignore: always_use_package_imports -- ARCH-03: modular audio beside Journal
import '../audio/journal_audio_module.dart';

export 'package:kin/domain/models/journal_fragment_choice.dart';

/// Ordered fragment types offered when composing a memory.
///
/// Audio is appended from [JournalAudioModule] so that module can be deleted
/// without rewriting the core composer catalog.
List<JournalFragmentChoice> journalFragmentChoices() {
  return [
    const JournalFragmentChoice(
      kind: JournalFragmentKind.writing,
      title: 'Writing',
      support: 'Write something down',
    ),
    const JournalFragmentChoice(
      kind: JournalFragmentKind.list,
      title: 'List',
      support: 'Remember it piece by piece',
    ),
    const JournalFragmentChoice(
      kind: JournalFragmentKind.photograph,
      title: 'Photograph',
      support: 'Keep a moment visually',
    ),
    ...JournalAudioModule.choices,
  ];
}
