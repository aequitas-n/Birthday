import 'dart:ui';

import 'package:kin/design/tokens/color_tokens.dart';

/// Journal mood colours — keyed by storage id, no domain import.
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
      'reflective' =>
        dark ? ColorTokens.moodReflectiveDark : ColorTokens.moodReflectiveLight,
      'nostalgic' =>
        dark ? ColorTokens.moodNostalgicDark : ColorTokens.moodNostalgicLight,
      'anxious' =>
        dark ? ColorTokens.moodAnxiousDark : ColorTokens.moodAnxiousLight,
      'grateful' =>
        dark ? ColorTokens.moodGratefulDark : ColorTokens.moodGratefulLight,
      'excited' =>
        dark ? ColorTokens.moodExcitedDark : ColorTokens.moodExcitedLight,
      _ => dark ? ColorTokens.moodNeutralDark : ColorTokens.moodNeutralLight,
    };
    return (fill, foreground);
  }
}
