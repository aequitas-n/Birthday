import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:kin/design/theme/mood_illustration_metrics.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Peeks the theme empty-invite character over the Today empty Journal Card.
///
/// When [AppThemeMoodAssets.emptyInvite] is null, only [child] is shown.
/// Absolute overlay only — zero layout height impact.
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
    final inviteAsset = context.appTheme.assets.mood.emptyInvite;
    if (inviteAsset == null) return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final width = cardWidth * _widthOfCard;
        final height = width / MoodIllustrationMetrics.aspectRatio;
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
                    inviteAsset,
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
