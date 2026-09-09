import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/design/theme/vintage_diary_empty_invite.dart';

/// Peeks [VintageDiaryEmptyInvite] over the Today empty Journal Card corner.
///
/// Absolute overlay only — zero layout height impact. Sized as a fraction of
/// the card width; ~50% hangs above the paper; slight right bias clamped so
/// the character never leaves the phone viewport.
class QTodayEmptyJournalInvite extends StatelessWidget {
  const QTodayEmptyJournalInvite({
    required this.child,
    super.key,
  });

  final Widget child;

  /// Same composition recipe as Today first-memory mood peeks.
  static const _widthOfCard = 0.46;
  static const _hangAbove = 0.50;
  static const _rightOfArt = 0.08;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final width = cardWidth * _widthOfCard;
        final height = width / VintageDiaryEmptyInvite.aspectRatio;
        final rightOverflow = math.min(
          width * _rightOfArt,
          context.gutter,
        );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            Positioned(
              top: -height * _hangAbove,
              right: -rightOverflow,
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: Image.asset(
                    VintageDiaryEmptyInvite.asset,
                    width: width,
                    height: height,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
