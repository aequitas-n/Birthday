import 'package:flutter/widgets.dart';
import 'package:kin/design/components/media/q_photo.dart';
import 'package:kin/design/components/surfaces/q_surface.dart';
import 'package:kin/design/components/text/q_voice.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// The image is the page.
///
/// A hero portrait occupies the top ~44% of the viewport, bleeds to both edges
/// and under the status bar, rounds only its bottom corners, and carries the
/// identity of the person inside it: relationship, name, and the one number
/// that matters. Nothing is announced twice below.
///
/// Three things make it read as photography rather than as a header image:
///
///  * The scrim is a four-stop ramp, not a linear one. A linear gradient over
///    a portrait looks like a grey band laid across the middle of the face.
///  * The scrim's deepest stop is tinted with the collection's hero tint, so
///    the image sits in the theme's light instead of under neutral grey.
///  * The image drifts against the scroll at a fraction of its speed. The
///    parallax is small enough to be felt and not seen; without it the picture
///    reads as pasted on, and with more it reads as a parallax demo.
class QHeroPortrait extends StatelessWidget {
  const QHeroPortrait({
    required this.displayName,
    required this.seed,
    required this.title,
    this.photo,
    this.kicker,
    this.metric,
    this.support,
    this.height,
    this.scrollOffset = 0,
    this.heroTag,
    this.leading,
    this.trailing,
    this.semanticLabel,
    super.key,
  });

  final String displayName;
  final String seed;
  final ImageProvider? photo;

  /// The name, set in the Voice at display size.
  final String title;

  /// A quiet line above the name: the relationship.
  final String? kicker;

  /// The countdown. Large, tabular, and never punctuated with a unit it does
  /// not need.
  final String? metric;

  /// One line beneath the metric: what the date actually means.
  final String? support;

  /// Defaults to `context.heroHeight`.
  final double? height;

  /// Current scroll offset of the page the hero sits at the top of.
  final double scrollOffset;

  final Object? heroTag;

  /// Overlay controls, drawn above the scrim inside the safe inset.
  final Widget? leading;
  final Widget? trailing;

  /// Read in place of the embedded lines, which would otherwise be announced
  /// as four disconnected fragments.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final resolvedHeight = height ?? context.heroHeight;
    final topInset = MediaQuery.paddingOf(context).top;

    // Only downward scroll parallaxes. Overscrolling upward already stretches
    // the image via the scroll physics, and doubling that reads as a glitch.
    final drift = scrollOffset <= 0
        ? 0.0
        : scrollOffset * q.layout.heroParallaxFactor;

    final Widget image = QPhoto(
      displayName: displayName,
      seed: seed,
      photo: photo,
    );

    return SizedBox(
      height: resolvedHeight,
      width: double.infinity,
      child: QClip(
        radius: q.radius.xxl,
        bottomCornersOnly: true,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Overdrawn by the drift distance so the crop never exposes the
            // canvas beneath as the image travels.
            Positioned(
              top: -drift,
              left: 0,
              right: 0,
              height: resolvedHeight + drift,
              child: RepaintBoundary(
                child: heroTag == null
                    ? image
                    : Hero(tag: heroTag!, child: image),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: q.photo.heroScrim,
                      stops: q.photo.heroScrimStops,
                    ),
                  ),
                ),
              ),
            ),
            // The collection's light, laid in only where the scrim is already
            // deep.
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: q.photo.heroTintGradient(q.color.heroTint),
                      stops: q.photo.heroTintStops,
                    ),
                  ),
                ),
              ),
            ),
            if (leading != null || trailing != null)
              Positioned(
                top: topInset + q.space.xs,
                left: q.space.sm,
                right: q.space.sm,
                child: Row(
                  children: [
                    if (leading != null) leading!,
                    const Spacer(),
                    if (trailing != null) trailing!,
                  ],
                ),
              ),
            Positioned(
              left: context.gutter,
              right: context.gutter,
              bottom: q.space.xl,
              child: _HeroCaption(
                title: title,
                kicker: kicker,
                metric: metric,
                support: support,
                semanticLabel: semanticLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCaption extends StatelessWidget {
  const _HeroCaption({
    required this.title,
    required this.kicker,
    required this.metric,
    required this.support,
    required this.semanticLabel,
  });

  final String title;
  final String? kicker;
  final String? metric;
  final String? support;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final scaler = context.heroTextScaler;

    final caption = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (kicker != null && kicker!.isNotEmpty) ...[
          Text(
            kicker!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textScaler: scaler,
            style: context.onImage(q.text.relationship, secondary: true),
          ),
          SizedBox(height: q.space.sm),
        ],
        QVoice(
          title,
          maxLines: 2,
          textScaler: scaler,
          textHeightBehavior: q.text.displayHeightBehavior,
          style: context.onImage(q.text.voiceXxl),
        ),
        if (metric != null) ...[
          SizedBox(height: q.space.lg),
          QVoice(
            metric!,
            maxLines: 1,
            textScaler: scaler,
            textHeightBehavior: q.text.displayHeightBehavior,
            style: context.onImage(q.text.numeralXl),
          ),
        ],
        if (support != null && support!.isNotEmpty) ...[
          SizedBox(height: q.space.sm),
          Text(
            support!,
            maxLines: 2,
            textScaler: scaler,
            style: context.onImage(q.text.bodyLg, secondary: true),
          ),
        ],
      ],
    );

    if (semanticLabel == null) return caption;
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: caption,
    );
  }
}
