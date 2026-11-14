import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:kin/design/components/journal/q_animated_illustration.dart';
import 'package:kin/design/media/quiet_display_image.dart';
import 'package:kin/design/theme/app_theme_assets.dart' show AppThemeMoodAssets;
import 'package:kin/design/theme/mood_illustration_metrics.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Peeks the theme empty-invite character over the Today empty Journal Card.
///
/// When [AppThemeMoodAssets.emptyInvite] is null, only [child] is shown.
/// Absolute overlay only — hang overflows above the card without adding
/// layout gap under the section title.
class QTodayEmptyJournalInvite extends StatelessWidget {
  const QTodayEmptyJournalInvite({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final art = context.appTheme.art;
    if (art != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(padding: const EdgeInsets.only(top: 48), child: child),
          Positioned(
            top: 0,
            right: 12,
            child: QAnimatedIllustration(asset: art.atlas, size: 96),
          ),
        ],
      );
    }
    final inviteAsset = context.appTheme.assets.mood.emptyInvite;
    if (inviteAsset == null) return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final journalAspect =
            context.appTheme.assets.layout.journalCardAspectRatio;
        final width = TodayJournalMoodPeek.artWidthFor(
          cardWidth: cardWidth,
          journalCardAspectRatio: journalAspect,
        );
        final height = width / TodayJournalMoodPeek.aspectRatio;
        final hang = TodayJournalMoodPeek.hangForArtWidth(width);
        final rightOverflow = math.min(
          width * TodayJournalMoodPeek.rightOfArt,
          context.gutter,
        );
        final cache = QuietDisplayImage.cacheSize(
          context,
          Size(width, height),
          fit: BoxFit.contain,
        );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            Positioned(
              top: -hang,
              right: -rightOverflow,
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: Image.asset(
                    inviteAsset,
                    width: width,
                    height: height,
                    cacheWidth: cache.$1,
                    cacheHeight: cache.$2,
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
