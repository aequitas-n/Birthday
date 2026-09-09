import 'dart:ui';

import 'package:kin/design/tokens/color_tokens.dart';

/// Journal mood wash colours — keyed by storage id, no domain import.
///
/// Used for subtle calendar chips and legacy accents. Card personality comes
/// from Vintage mood illustration assets, not these washes.
abstract final class JournalMoodColors {
  static (Color fill, Color foreground) resolve(
    String moodId, {
    required bool dark,
  }) {
    final foreground = dark
        ? ColorTokens.moodInkOnDark
        : ColorTokens.moodInkOnLight;
    final fill = switch (moodId) {
      'joyful' =>
        dark ? ColorTokens.moodJoyfulDark : ColorTokens.moodJoyfulLight,
      'calm' => dark ? ColorTokens.moodCalmDark : ColorTokens.moodCalmLight,
      'sad' => dark ? ColorTokens.moodSadDark : ColorTokens.moodSadLight,
      'affection' =>
        dark ? ColorTokens.moodNostalgicDark : ColorTokens.moodNostalgicLight,
      'anxious' =>
        dark ? ColorTokens.moodAnxiousDark : ColorTokens.moodAnxiousLight,
      'frustrated' =>
        dark ? ColorTokens.moodExcitedDark : ColorTokens.moodExcitedLight,
      'surprised' =>
        dark ? ColorTokens.moodGratefulDark : ColorTokens.moodGratefulLight,
      _ => dark ? ColorTokens.moodNeutralDark : ColorTokens.moodNeutralLight,
    };
    return (fill, foreground);
  }
}
