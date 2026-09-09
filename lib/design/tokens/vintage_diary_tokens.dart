/// Asset paths for the Vintage Diary product theme.
///
/// Spec: assets/themes/Vintage-Diary/vintage_diary_app_visual_design_system.txt
abstract final class VintageDiaryAssets {
  static const background = 'assets/themes/Vintage-Diary/vintage-bg.webp';
  static const journalCard = 'assets/themes/Vintage-Diary/Journal-Card.webp';
  static const calendar = 'assets/themes/Vintage-Diary/Calendar.webp';
  static const chromeStrip = 'assets/themes/Vintage-Diary/bottom-navbar.webp';
  static const userStrip = 'assets/themes/Vintage-Diary/user-strip.webp';
  static const search = 'assets/themes/Vintage-Diary/search.webp';
  static const profileCard = 'assets/themes/Vintage-Diary/profile_card.webp';

  static const _moodDir = 'assets/themes/Vintage-Diary/Mood-Illustrations';

  /// Picker / card mood art. Does **not** include [excitedHome].
  static String? moodIllustration(String moodId) => switch (moodId) {
    'joyful' => '$_moodDir/Joyful-Mood.webp',
    'calm' => '$_moodDir/Calm-Mood.webp',
    'sad' => '$_moodDir/Sad-Mood.webp',
    'affection' => '$_moodDir/Affection-Mood.webp',
    'anxious' => '$_moodDir/Anxious-Mood.webp',
    'frustrated' => '$_moodDir/Frustrated-Mood.webp',
    'surprised' => '$_moodDir/Surprised-Mood.webp',
    'neutral' => '$_moodDir/Neutral-Mood.webp',
    _ => null,
  };

  /// Reserved for the Today empty Journal Card invite only —
  /// never the mood picker, day mood, or memory mood chrome.
  static const excitedHome = '$_moodDir/Excited-home.webp';
}
