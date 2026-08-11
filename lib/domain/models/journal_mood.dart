/// Restrained mood vocabulary for journal days and entries.
enum JournalMood {
  joyful,
  calm,
  sad,
  reflective,
  nostalgic,
  anxious,
  grateful,
  excited,
  neutral
  ;

  static JournalMood? fromStorage(String? value) {
    if (value == null || value.isEmpty) return null;
    return values.firstWhere(
      (entry) => entry.name == value,
      orElse: () => JournalMood.neutral,
    );
  }

  String get storageValue => name;

  String get displayName => switch (this) {
    JournalMood.joyful => 'Joyful',
    JournalMood.calm => 'Calm',
    JournalMood.sad => 'Sad',
    JournalMood.reflective => 'Reflective',
    JournalMood.nostalgic => 'Nostalgic',
    JournalMood.anxious => 'Anxious',
    JournalMood.grateful => 'Grateful',
    JournalMood.excited => 'Excited',
    JournalMood.neutral => 'Neutral',
  };
}
