import 'package:flutter/widgets.dart';
import 'package:kin/design/components/journal/q_animated_illustration.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// A little moving part of the theme's world: post, flowers, tides, or stars.
/// It is decorative scenery and never intercepts a touch or a screen reader.
class QAmbientScene extends StatelessWidget {
  const QAmbientScene({this.width = 140, super.key});
  final double width;

  @override
  Widget build(BuildContext context) {
    final art = context.appTheme.art;
    if (art == null) return const SizedBox.shrink();
    return QAnimatedIllustration(
      asset: art.scene,
      scene: true,
      size: width,
      aspectRatio: 1.5,
    );
  }
}
