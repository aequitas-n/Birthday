import 'package:kin/domain/models/journal_fragment.dart';
import 'package:kin/domain/models/journal_fragment_choice.dart';

/// Optional Journal audio composition support.
///
/// To remove audio later:
/// 1. Set [enabled] to false (or delete this folder).
/// 2. Remove `record` / `just_audio` from pubspec.
/// 3. Drop microphone permissions.
/// 4. Existing `audio` fragment rows remain readable as placeholders.
abstract final class JournalAudioModule {
  /// Flip to false to hide audio from the composer without deleting code.
  static const enabled = true;

  static List<JournalFragmentChoice> get choices {
    if (!enabled) return const [];
    return const [
      JournalFragmentChoice(
        kind: JournalFragmentKind.audio,
        title: 'Audio',
        support: 'Keep a moment in sound',
      ),
    ];
  }
}
