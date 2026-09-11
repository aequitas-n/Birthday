import 'package:kin/design/theme/app_theme_surface_layout.dart';

/// Asset paths for the Neon Arcade product theme.
///
/// Derived from forensic inspection of `assets/themes/Neon-Arcade/`.
abstract final class NeonArcadeAssets {
  static const background = 'assets/themes/Neon-Arcade/arcade-bg.webp';
  static const journalCard = 'assets/themes/Neon-Arcade/Journal-card.webp';
  static const calendar = 'assets/themes/Neon-Arcade/Calendar.webp';
  static const chromeStrip = 'assets/themes/Neon-Arcade/bottom-navbar.webp';
  static const userStrip = 'assets/themes/Neon-Arcade/user-strip.webp';

  /// Intrinsic width / height of [chromeStrip] (2172×724).
  static const double chromeStripAspectRatio = 2172 / 724;

  /// Opaque HUD band as a fraction of [chromeStrip] height.
  /// Measured from alpha: opaque rows ~88–602 of 724 → ≈0.71.
  static const chromeStripOpaqueFraction = 0.71;

  static const profileCard = 'assets/themes/Neon-Arcade/profile_card.webp';

  // ── Composition metrics (normalized to asset canvas) ─────────────────
  // Measured from decoded WebP pixels — not device coordinates.

  /// Journal-card.webp 1402×1122 — inner CRT past neon tubes/stars/pixels.
  static const journalCardContent = AppThemeContentRect(
    left: 0.14,
    top: 0.24,
    right: 0.86,
    bottom: 0.76,
  );

  /// Intrinsic width / height of [journalCard].
  static const double journalCardAspectRatio = 1402 / 1122;

  /// Soft clip on the HUD plate — same minimal radius as Vintage parchment.
  static const double journalCardCornerRadius = 6;

  /// profile_card.webp 941×1672 — photo fills the dark CRT window; name sits
  /// in the lower band above the bottom neon star cluster.
  ///
  /// Avatar sits a touch down/right in the CRT and reads larger than Default.
  static const profileLayout = AppThemeProfileLayout(
    aspectRatio: 941 / 1672,
    photoLeft: 0.12,
    photoRight: 0.88,
    photoTop: 0.095,
    photoBottom: 0.70,
    textLeft: 0.14,
    textRight: 0.86,
    textBottom: 0.11,
    textBandFraction: 0.18,
    clipPlateCorners: false,
    avatarDiameterFraction: 0.34,
    avatarInsetLeft: 0.06,
    avatarInsetTop: 0.045,
  );

  /// Use nearly the full People pane — Neon plate is designed to read large.
  static const galleryCardWidthFraction = 1.0;

  /// Fill the pane height (Vintage keeps 0.76 breathing room).
  static const galleryCardHeightFraction = 1.0;

  /// Lift the Vintage 540 cap so tall CRT plates can use phone height.
  static const galleryCardMaxHeight = 900.0;

  static const _moodDir = 'assets/themes/Neon-Arcade/Mood-Illustrations';

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

  /// Today empty Journal Card invite only — never the mood picker.
  static const excitedHome = '$_moodDir/Excited-home.webp';
}
