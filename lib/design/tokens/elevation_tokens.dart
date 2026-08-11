import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:kin/design/tokens/color_tokens.dart';

/// Elevation recipes.
///
/// Kin does not use Material elevation. On light, levels differ by lightness
/// plus a hairline and a warm shadow — warm because a neutral black shadow
/// over a warm canvas reads grey and dirty. On dark and AMOLED, shadows are
/// close to invisible, so separation is carried by surface lightness and
/// hairlines instead.
///
/// Specified in docs/04-design-system.md §4.
@immutable
final class QuietElevation {
  const QuietElevation({
    required this.lift,
    required this.overlay,
    required this.float,
  });

  const QuietElevation.light()
    : lift = const <BoxShadow>[
        BoxShadow(
          color: ColorTokens.shadowLight,
          offset: Offset(0, 2),
          blurRadius: 8,
        ),
      ],
      overlay = const <BoxShadow>[
        BoxShadow(
          color: ColorTokens.shadowLiftLight,
          offset: Offset(0, -2),
          blurRadius: 32,
        ),
      ],
      float = const <BoxShadow>[
        BoxShadow(
          color: ColorTokens.shadowFloatLight,
          offset: Offset(0, 12),
          blurRadius: 32,
          spreadRadius: -8,
        ),
      ];

  const QuietElevation.dark()
    : lift = const <BoxShadow>[
        BoxShadow(
          color: ColorTokens.shadowDark,
          offset: Offset(0, 2),
          blurRadius: 8,
        ),
      ],
      overlay = const <BoxShadow>[
        BoxShadow(
          color: ColorTokens.shadowDark,
          offset: Offset(0, -2),
          blurRadius: 32,
        ),
      ],
      float = const <BoxShadow>[
        BoxShadow(
          color: ColorTokens.shadowFloatDark,
          offset: Offset(0, 12),
          blurRadius: 32,
          spreadRadius: -8,
        ),
      ];

  const QuietElevation.amoled()
    : lift = const <BoxShadow>[
        BoxShadow(
          color: ColorTokens.shadowVoid,
          offset: Offset(0, 2),
          blurRadius: 8,
        ),
      ],
      overlay = const <BoxShadow>[
        BoxShadow(
          color: ColorTokens.shadowVoid,
          offset: Offset(0, -2),
          blurRadius: 32,
        ),
      ],
      float = const <BoxShadow>[
        BoxShadow(
          color: ColorTokens.shadowFloatVoid,
          offset: Offset(0, 12),
          blurRadius: 32,
          spreadRadius: -8,
        ),
      ];

  factory QuietElevation.lerp(QuietElevation a, QuietElevation b, double t) {
    return QuietElevation(
      lift: BoxShadow.lerpList(a.lift, b.lift, t) ?? b.lift,
      overlay: BoxShadow.lerpList(a.overlay, b.overlay, t) ?? b.overlay,
      float: BoxShadow.lerpList(a.float, b.float, t) ?? b.float,
    );
  }

  /// Something resting just above the page: an undo bar, a selected segment.
  final List<BoxShadow> lift;

  /// Sheets and menus.
  final List<BoxShadow> overlay;

  /// A card the user can throw sideways. Negative spread keeps the shadow
  /// under the card rather than haloing around it.
  final List<BoxShadow> float;

  /// Nothing is above the page.
  static const List<BoxShadow> flat = <BoxShadow>[];
}
