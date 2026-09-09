import 'package:kin/design/tokens/vintage_diary_tokens.dart';

/// Semantic sizes for transparent mood character art.
enum MoodIllustrationSize {
  /// Grid cell in the mood picker sheet.
  picker,

  /// Top-right pin on a memory card in the day deck.
  memoryCard,

  /// Legacy day-card pin size (kept for metrics continuity).
  dayCard,

  /// Day mood beside “Change day mood” on Journal of the Day.
  dayFooter,

  /// Today journal preview placements.
  todayPreview,
}

/// Layout recipe for attaching a mood character to a paper card.
enum MoodCardPlacement {
  /// Top-right, ~50% overlapping the card, mirrored to face inward.
  memoryTopRightOverlap,

  /// Day mood — top-right pin over the day card/deck, mirrored.
  dayTopRightOverlap,

  /// Today first memory — top-right overlap, mirrored.
  todayFirstOverlap,

  /// Today second memory — bottom-right, fully on the card, original facing.
  todaySecondInset,
}

/// Theme metrics for mood illustrations — shared by picker and card chrome.
abstract final class VintageMoodTheme {
  static double extent(MoodIllustrationSize size) => switch (size) {
    MoodIllustrationSize.picker => 56,
    MoodIllustrationSize.memoryCard => 96,
    MoodIllustrationSize.dayCard => 88,
    // 1.5× [dayCard] — footer companion to “Change day mood”.
    MoodIllustrationSize.dayFooter => 132,
    // Today journal preview — generous peek characters (2× prior 72).
    MoodIllustrationSize.todayPreview => 144,
  };

  /// Intrinsic asset ratio (mood WebPs keep the original 1230∶1278 proportions).
  static const double aspectRatio = 1230 / 1278;

  static String? assetFor(String moodId) =>
      VintageDiaryAssets.moodIllustration(moodId);

  static double widthFor(MoodIllustrationSize size) =>
      extent(size) * aspectRatio;
}
