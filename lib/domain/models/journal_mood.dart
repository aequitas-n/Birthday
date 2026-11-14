/// Restrained mood vocabulary for journal days and entries.
///
/// Vintage Diary ships exactly eight moods with matching illustrations.
enum JournalMood {
  joyful,
  calm,
  sad,
  affection,
  anxious,
  frustrated,
  surprised,
  neutral;

  /// Resolves a stored mood id. Retired vocabulary is mapped to the closest
  /// current mood so older rows remain coherent without inventing UI aliases.
  static JournalMood? fromStorage(String? value) {
    if (value == null || value.isEmpty) return null;
    switch (value) {
      case 'reflective':
        return JournalMood.calm;
      case 'nostalgic':
      case 'grateful':
        return JournalMood.affection;
      case 'excited':
        return JournalMood.joyful;
    }
    for (final entry in values) {
      if (entry.name == value) return entry;
    }
    return JournalMood.neutral;
  }

  String get storageValue => name;

  String get displayName => switch (this) {
    JournalMood.joyful => 'Joyful',
    JournalMood.calm => 'Calm',
    JournalMood.sad => 'Sad',
    JournalMood.affection => 'Affection',
    JournalMood.anxious => 'Anxious',
    JournalMood.frustrated => 'Frustrated',
    JournalMood.surprised => 'Surprised',
    JournalMood.neutral => 'Neutral',
  };
}
