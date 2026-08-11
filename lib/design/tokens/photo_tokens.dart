import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:kin/design/tokens/color_tokens.dart';

/// How the product treats photography.
///
/// These values are identical in every theme and every collection, on
/// purpose. A photograph is the one colour the app does not own: it is not
/// lighter in light mode, and the ink that sits on it cannot be a theme role
/// or it would become illegible the moment someone picks a pale portrait.
///
/// Specified in docs/06-color.md §3 and docs/04-design-system.md §9.
@immutable
final class QuietPhotography {
  const QuietPhotography();

  /// A name embedded in a hero.
  Color get onImagePrimary => ColorTokens.onImagePrimary;

  /// A relationship or a date embedded in a hero.
  Color get onImageSecondary => ColorTokens.onImageSecondary;

  /// Cast beneath embedded type, so a blown-out sky cannot swallow it.
  Color get onImageShadow => ColorTokens.onImageShadow;

  /// The scrim beneath embedded type, top of the image to its base.
  ///
  /// Four stops rather than two. A straight linear ramp reads as a grey band
  /// laid across the middle of the picture; this holds the image clear for its
  /// top half, then falls away quickly under the words.
  List<Color> get heroScrim => const <Color>[
    ColorTokens.imageScrimClear,
    ColorTokens.imageScrimSoft,
    ColorTokens.imageScrimMid,
    ColorTokens.imageScrimDeep,
  ];

  /// Stop positions for [heroScrim].
  List<double> get heroScrimStops => const <double>[0, 0.42, 0.72, 1];

  /// The collection's own light, laid into the base of a hero.
  ///
  /// The one place a theme is allowed to touch a photograph, and only where the
  /// scrim is already deep: it is what keeps the foot of a hero reading as
  /// warm dusk or cold night rather than as neutral grey. Above the first stop
  /// it contributes nothing, so the picture itself is never tinted.
  List<Color> heroTintGradient(Color tint) => <Color>[
    tint.withValues(alpha: 0),
    tint.withValues(alpha: 0.42),
  ];

  /// Stop positions for [heroTintGradient].
  List<double> get heroTintStops => const <double>[0.55, 1];

  /// A shorter scrim for a gallery card, whose metadata sits closer to the
  /// bottom edge than a full hero's does.
  List<Color> get cardScrim => const <Color>[
    ColorTokens.imageScrimClear,
    ColorTokens.imageScrimMid,
    ColorTokens.imageScrimDeep,
  ];

  /// Stop positions for [cardScrim].
  List<double> get cardScrimStops => const <double>[0.4, 0.76, 1];

  /// A wash laid over an image behind small type, where a directional scrim
  /// would look like a mistake.
  Color get flatScrim => ColorTokens.imageScrimMid;
}
