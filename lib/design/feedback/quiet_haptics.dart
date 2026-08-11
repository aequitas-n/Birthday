import 'package:flutter/services.dart';

/// Light, tasteful haptic feedback for product moments.
///
/// One tick on commit. A softer tap when opening something. Never on
/// press-down — only when the action completes or a surface opens.
abstract final class QuietHaptics {
  static void commit() {
    HapticFeedback.selectionClick();
  }

  static void open() {
    HapticFeedback.lightImpact();
  }
}
