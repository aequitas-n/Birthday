import 'package:kin/design/theme/app_theme_surface_layout.dart';
import 'package:kin/design/tokens/vintage_portrait_geometry.dart';

/// Asset paths for the Vintage Diary product theme.
///
/// Spec: assets/themes/Vintage-Diary/vintage_diary_app_visual_design_system.txt
abstract final class VintageDiaryAssets {
  static const background = 'assets/themes/Vintage-Diary/vintage-bg.webp';
  static const journalCard = 'assets/themes/Vintage-Diary/Journal-Card.webp';
  static const calendar = 'assets/themes/Vintage-Diary/Calendar.webp';
  static const chromeStrip = 'assets/themes/Vintage-Diary/bottom-navbar.webp';

  /// Intrinsic width / height of [journalCard] (1402×1122) — same plate as Neon.
  /// Locks Today/home cards to a standard size so short copy does not collapse
  /// the parchment under the mood peek.
  static const double journalCardAspectRatio = 1402 / 1122;

  /// Softens square parchment plate corners without reading as a Material card.
  static const double journalCardCornerRadius = 6;

  /// Intrinsic width / height of [chromeStrip] (2172×724).
  static const chromeStripAspectRatio = 2172 / 724;

  /// Opaque parchment band as a fraction of [chromeStrip] height.
  /// Measured from alpha: ~22%–78% → transparent head/foot for the torn edge.
  static const chromeStripOpaqueFraction = 0.56;

  static const userStrip = 'assets/themes/Vintage-Diary/user-strip.webp';
  static const search = 'assets/themes/Vintage-Diary/search.webp';
  static const profileCard = 'assets/themes/Vintage-Diary/profile_card.webp';

  /// Presentation plate — wider than the tall source PNG so [BoxFit.cover]
  /// fills a readable People card (not a skinny contain letterbox).
  static const profileLayout = AppThemeProfileLayout(
    aspectRatio: ProfileCardGeometry.aspectRatio,
    photoLeft: ProfileCardGeometry.photoLeft,
    photoRight: ProfileCardGeometry.photoRight,
    photoTop: ProfileCardGeometry.photoTop,
    photoBottom: ProfileCardGeometry.photoBottom,
    textLeft: ProfileCardGeometry.textLeft,
    textRight: ProfileCardGeometry.textRight,
    textBottom: ProfileCardGeometry.textBottom,
    textBandFraction: ProfileCardGeometry.textBandFraction,
    clipPlateCorners: true,
    cornerRadius: 6,
  );

  /// Near-full pane with a slight side inset; [galleryCardMaxWidth] stops the
  /// plate from ballooning on tablet.
  static const galleryCardWidthFraction = 0.96;
  static const galleryCardHeightFraction = 0.96;
  static const galleryCardMaxHeight = 900.0;
  static const galleryCardMaxWidth = 420.0;

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
