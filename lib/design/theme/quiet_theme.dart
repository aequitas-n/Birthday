import 'package:flutter/material.dart' show ThemeExtension;
import 'package:flutter/widgets.dart';
import 'package:kin/design/theme/quiet_collection.dart';
import 'package:kin/design/theme/quiet_colors.dart';
import 'package:kin/design/theme/quiet_interactive.dart';
import 'package:kin/design/theme/quiet_journal.dart';
import 'package:kin/design/theme/quiet_navigation.dart';
import 'package:kin/design/tokens/elevation_tokens.dart';
import 'package:kin/design/tokens/motion_tokens.dart';
import 'package:kin/design/tokens/photo_tokens.dart';
import 'package:kin/design/tokens/radius_tokens.dart';
import 'package:kin/design/tokens/space_tokens.dart';
import 'package:kin/design/tokens/type_tokens.dart';

export 'package:kin/design/theme/quiet_collection.dart' show QuietBrightness;

/// The complete Quiet design language, carried on the element tree as a
/// [ThemeExtension].
///
/// Widgets read this and nothing else. They never touch `ColorScheme`, never
/// touch `TextTheme`, and never import the raw token files.
///
/// [lerp] is implemented across every sub-token so a theme change animates
/// rather than snapping. See docs/06-color.md §4.
@immutable
final class QuietTheme extends ThemeExtension<QuietTheme> {
  const QuietTheme({
    required this.mode,
    required this.color,
    required this.elevation,
    this.journal = const QuietJournal.light(),
    this.interactive = const QuietInteractive.light(),
    this.navigation = const QuietNavigation.light(),
    this.text = const QuietTypography(),
    this.space = const QuietSpace(),
    this.layout = const QuietLayout(),
    this.radius = const QuietRadius(),
    this.motion = const QuietMotionTokens(),
    this.photo = const QuietPhotography(),
  });

  const QuietTheme.light()
    : mode = QuietBrightness.light,
      color = const QuietColors.light(),
      elevation = const QuietElevation.light(),
      journal = const QuietJournal.light(),
      interactive = const QuietInteractive.light(),
      navigation = const QuietNavigation.light(),
      text = const QuietTypography(),
      space = const QuietSpace(),
      layout = const QuietLayout(),
      radius = const QuietRadius(),
      motion = const QuietMotionTokens(),
      photo = const QuietPhotography();

  const QuietTheme.dark()
    : mode = QuietBrightness.dark,
      color = const QuietColors.dark(),
      elevation = const QuietElevation.dark(),
      journal = const QuietJournal.dark(),
      interactive = const QuietInteractive.dark(),
      navigation = const QuietNavigation.dark(),
      text = const QuietTypography(),
      space = const QuietSpace(),
      layout = const QuietLayout(),
      radius = const QuietRadius(),
      motion = const QuietMotionTokens(),
      photo = const QuietPhotography();

  const QuietTheme.amoled()
    : mode = QuietBrightness.amoled,
      color = const QuietColors.amoled(),
      elevation = const QuietElevation.amoled(),
      journal = const QuietJournal.amoled(),
      interactive = const QuietInteractive.amoled(),
      navigation = const QuietNavigation.amoled(),
      text = const QuietTypography(),
      space = const QuietSpace(),
      layout = const QuietLayout(),
      radius = const QuietRadius(),
      motion = const QuietMotionTokens(),
      photo = const QuietPhotography();

  /// Resolves a collection and a brightness into a complete theme.
  ///
  /// The metrics — space, layout, radius, motion, typography — are identical
  /// across every collection. A collection changes the light in the room, not
  /// the architecture of it.
  factory QuietTheme.of(
    QuietCollection collection, {
    required bool dark,
    bool amoled = false,
  }) {
    final mode = !dark
        ? QuietBrightness.light
        : (amoled ? QuietBrightness.amoled : QuietBrightness.dark);
    return QuietTheme(
      mode: mode,
      color: QuietColors.of(collection, dark: dark, amoled: amoled),
      elevation: switch (mode) {
        QuietBrightness.light => const QuietElevation.light(),
        QuietBrightness.dark => const QuietElevation.dark(),
        QuietBrightness.amoled => const QuietElevation.amoled(),
      },
      journal: QuietJournal.of(collection, mode: mode),
      interactive: QuietInteractive.of(dark: dark, amoled: amoled),
      navigation: QuietNavigation.of(dark: dark, amoled: amoled),
    );
  }

  final QuietBrightness mode;
  final QuietColors color;
  final QuietElevation elevation;

  /// Journal archive paper / ink / tape roles.
  final QuietJournal journal;

  /// Interactive surfaces — CTAs, sheets, inputs, toggles.
  final QuietInteractive interactive;

  /// Bottom navigation strip — distinct from canvas and parchment cards.
  final QuietNavigation navigation;

  /// Typography. Named `text` rather than `type` because [ThemeExtension]
  /// already declares a `type` getter, and it is the key `ThemeData.extensions`
  /// is looked up by — shadowing it silently breaks `context.quiet`.
  final QuietTypography text;

  final QuietSpace space;
  final QuietLayout layout;
  final QuietRadius radius;
  final QuietMotionTokens motion;

  /// How type and scrims behave over photographs. Constant across themes,
  /// because the app does not own the photograph.
  final QuietPhotography photo;

  bool get isDark => color.brightness == Brightness.dark;

  /// The active collection.
  QuietCollection get collection => color.collection;

  @override
  QuietTheme copyWith({
    QuietBrightness? mode,
    QuietColors? color,
    QuietElevation? elevation,
    QuietJournal? journal,
    QuietInteractive? interactive,
    QuietNavigation? navigation,
    QuietTypography? text,
    QuietSpace? space,
    QuietLayout? layout,
    QuietRadius? radius,
    QuietMotionTokens? motion,
    QuietPhotography? photo,
  }) {
    return QuietTheme(
      mode: mode ?? this.mode,
      color: color ?? this.color,
      elevation: elevation ?? this.elevation,
      journal: journal ?? this.journal,
      interactive: interactive ?? this.interactive,
      navigation: navigation ?? this.navigation,
      text: text ?? this.text,
      space: space ?? this.space,
      layout: layout ?? this.layout,
      radius: radius ?? this.radius,
      motion: motion ?? this.motion,
      photo: photo ?? this.photo,
    );
  }

  @override
  QuietTheme lerp(covariant QuietTheme? other, double t) {
    if (other == null) return this;
    return QuietTheme(
      mode: t < 0.5 ? mode : other.mode,
      color: QuietColors.lerp(color, other.color, t),
      elevation: QuietElevation.lerp(elevation, other.elevation, t),
      journal: journal.lerp(other.journal, t),
      interactive: QuietInteractive.lerp(interactive, other.interactive, t),
      navigation: QuietNavigation.lerp(navigation, other.navigation, t),
      text: other.text,
      space: other.space,
      layout: other.layout,
      radius: other.radius,
      motion: other.motion,
      photo: other.photo,
    );
  }
}
