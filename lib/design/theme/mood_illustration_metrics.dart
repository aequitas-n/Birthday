import 'package:kin/design/theme/app_theme_assets.dart';

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

/// Layout metrics for mood illustrations — shared by picker and card chrome.
///
/// Asset paths come from [AppThemeMoodAssets], never hard-coded here.
abstract final class MoodIllustrationMetrics {
  static double extent(MoodIllustrationSize size) => switch (size) {
    MoodIllustrationSize.picker => 56,
    MoodIllustrationSize.memoryCard => 96,
    MoodIllustrationSize.dayCard => 88,
    // 1.5× [dayCard] — footer companion to “Change day mood”.
    MoodIllustrationSize.dayFooter => 132,
    // Today journal preview — generous peek characters (2× prior 72).
    MoodIllustrationSize.todayPreview => 144,
  };

  /// Mood WebP aspect (Vintage + Neon moods share the 1230∶1278 proportions;
  /// sources are display-budgeted at max edge 768).
  static const double aspectRatio = 1230 / 1278;

  static double widthFor(MoodIllustrationSize size) =>
      extent(size) * aspectRatio;
}

/// Today home journal card peek — shared by empty-invite and first-mood chrome.
///
/// Hang is paint-only overflow (`clipBehavior: Clip.none`) — it must not add
/// top padding under the section title. Art is capped vs card height when the
/// theme locks a journal aspect ratio so the peek stays clear of the heading.
abstract final class TodayJournalMoodPeek {
  /// Art width as a fraction of card width.
  static const widthOfCard = 0.40;

  /// Fraction of art height that peeks above the card top edge.
  static const hangAbove = 0.36;

  /// Desired right overflow as a fraction of art width (clamped to gutter).
  static const rightOfArt = 0.08;

  /// Max art height as a fraction of the standard journal card height.
  static const maxHeightOfCard = 0.52;

  static double artWidthFor({
    required double cardWidth,
    double? journalCardAspectRatio,
  }) {
    var width = cardWidth * widthOfCard;
    if (journalCardAspectRatio != null &&
        journalCardAspectRatio > 0 &&
        cardWidth > 0) {
      final cardHeight = cardWidth / journalCardAspectRatio;
      final maxArtHeight = cardHeight * maxHeightOfCard;
      final artHeight = width / aspectRatio;
      if (artHeight > maxArtHeight) {
        width = maxArtHeight * aspectRatio;
      }
    }
    return width;
  }

  static double hangForArtWidth(double artWidth) =>
      (artWidth / aspectRatio) * hangAbove;

  static double get aspectRatio => MoodIllustrationMetrics.aspectRatio;
}
