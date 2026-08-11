import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/surfaces/q_surface.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// What a card is for, which decides how it looks.
///
/// Before this existed, every card on every screen was the same rectangle at
/// the same radius with the same hairline, so a gift idea and a relationship
/// profile carried identical visual weight. The reader had to parse the text to
/// find out which mattered. Tone is the fix: the shape states the role before
/// a word is read.
enum QCardTone {
  /// Facts about a person: where they live, when they were born. Recessed and
  /// borderless — it is the page talking, not an object on it.
  context,

  /// A remembered detail. Paper on paper: a hairline, no shadow, the quietest
  /// card there is.
  memory,

  /// The next journey. Lifted, roomier, and the only card tone that carries a
  /// shadow at rest.
  invitation,

  /// Something the user can throw sideways. Floating, deeply rounded.
  gallery,

  /// Supporting content that must be grouped but must not compete.
  secondary,
}

/// A grouped region of content.
///
/// Kin's containers are space, then type weight, then a hairline — in that
/// order. A card is the last resort, so each tone has to justify itself.
class QCard extends StatelessWidget {
  const QCard({
    required this.child,
    this.tone = QCardTone.memory,
    this.onTap,
    this.semanticLabel,
    this.padding,
    super.key,
  });

  final Widget child;
  final QCardTone tone;
  final VoidCallback? onTap;
  final String? semanticLabel;

  /// Overrides the tone's own padding. Used by cards whose content bleeds to
  /// the edge, such as a portrait.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    final radius = switch (tone) {
      QCardTone.context => q.radius.lg,
      QCardTone.memory => q.radius.md,
      QCardTone.invitation => q.radius.lg,
      QCardTone.gallery => q.radius.xxl,
      QCardTone.secondary => q.radius.md,
    };

    final level = switch (tone) {
      QCardTone.context => QuietLevel.sunken,
      QCardTone.memory => QuietLevel.surface,
      QCardTone.invitation => QuietLevel.surface,
      QCardTone.gallery => QuietLevel.surface,
      QCardTone.secondary => QuietLevel.surface,
    };

    final elevation = switch (tone) {
      // Recessed regions read as recessed because of the fill. A border would
      // make them read as raised, which is the opposite of the intent.
      QCardTone.context => QuietElevationLevel.flat,
      QCardTone.memory => QuietElevationLevel.hairline,
      QCardTone.invitation => QuietElevationLevel.lift,
      QCardTone.gallery => QuietElevationLevel.float,
      QCardTone.secondary => QuietElevationLevel.hairline,
    };

    final resolvedPadding =
        padding ??
        switch (tone) {
          QCardTone.context => EdgeInsets.symmetric(
            horizontal: q.space.lg,
            vertical: q.space.base,
          ),
          QCardTone.memory => EdgeInsets.all(q.space.base),
          QCardTone.invitation => EdgeInsets.all(q.space.xl),
          QCardTone.gallery => EdgeInsets.zero,
          QCardTone.secondary => EdgeInsets.all(q.space.md),
        };

    final surface = QSurface(
      level: level,
      elevation: elevation,
      radius: radius,
      padding: resolvedPadding,
      child: child,
    );

    if (onTap == null) return surface;
    return QPressable(
      onTap: onTap,
      radius: radius,
      semanticLabel: semanticLabel,
      child: surface,
    );
  }
}
