import 'package:kin/design/tokens/vintage_diary_tokens.dart';

/// Today empty Journal Card invite — **not** part of the mood illustration set.
///
/// Uses [VintageDiaryAssets.excitedHome] only when the day has no memories.
/// Size/position are card-relative via `QTodayEmptyJournalInvite`.
abstract final class VintageDiaryEmptyInvite {
  static const String asset = VintageDiaryAssets.excitedHome;

  /// Same intrinsic ratio as the mood illustrations (1230∶1278).
  static const double aspectRatio = 1230 / 1278;
}
