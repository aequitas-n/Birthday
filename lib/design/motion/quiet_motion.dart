import 'package:flutter/widgets.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/design/tokens/motion_tokens.dart';

/// Motion, resolved against the user's accessibility preference.
///
/// Individual widgets never check `disableAnimations` themselves. They ask
/// this resolver for a duration, an offset or a scale, and it returns the
/// reduced-motion equivalent when appropriate: positional and scale animation
/// collapse to an opacity crossfade, and nothing is lost but the movement.
///
/// Specified in docs/07-motion.md §5.
@immutable
final class QuietMotion {
  const QuietMotion({required this.tokens, required this.reduced});

  factory QuietMotion.of(BuildContext context) => QuietMotion(
    tokens: context.quiet.motion,
    reduced: context.prefersReducedMotion,
  );

  final QuietMotionTokens tokens;
  final bool reduced;

  /// A crossfade. Always animates — opacity is the one channel reduced motion
  /// keeps.
  Duration get fade => tokens.quick;

  /// A duration for anything that moves, scales or morphs.
  Duration move(Duration normal) => reduced ? Duration.zero : normal;

  /// A translation offset, flattened when motion is reduced.
  Offset offset(Offset normal) => reduced ? Offset.zero : normal;

  /// A scale factor, neutralised when motion is reduced.
  double scale(double normal) => reduced ? 1 : normal;

  /// Per-item stagger delay, capped so the last item never feels broken.
  Duration staggerFor(int index) {
    if (reduced) return Duration.zero;
    final capped = index > tokens.staggerCap ? tokens.staggerCap : index;
    return tokens.stagger * capped;
  }

  /// Entrances decelerate.
  Curve get enter => tokens.enter;

  /// Exits accelerate. Leaving is always faster than arriving.
  Curve get exit => tokens.exit;

  Curve get standard => tokens.standard;

  Curve get emphasized => tokens.emphasized;
}
