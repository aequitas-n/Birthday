import 'package:flutter/widgets.dart';
import 'package:kin/design/theme/quiet_collection.dart';
import 'package:kin/design/theme/quiet_colors.dart';
import 'package:kin/design/theme/quiet_interactive.dart';
import 'package:kin/design/theme/quiet_journal.dart';
import 'package:kin/design/theme/quiet_navigation.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/design/tokens/elevation_tokens.dart';
import 'package:kin/design/tokens/illustrated_colors.dart';
import 'package:kin/design/tokens/type_tokens.dart';

/// Art direction, independent of screen layout or stored product identifiers.
enum IllustrationStyle {
  vintage,
  arcade,
  postcard,
  comic,
  botanical,
  seaside,
  storybook,
}

@immutable
class IllustratedTheme {
  const IllustratedTheme({
    required this.style,
    required this.folder,
    required this.description,
    required this.invitation,
    required this.eyebrow,
    required this.canvas,
    required this.paper,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.accentInk,
    required this.secondary,
    this.dark = false,
  });

  final IllustrationStyle style;
  final String folder;
  final String description;
  final String invitation;
  final String eyebrow;
  final Color canvas;
  final Color paper;
  final Color ink;
  final Color muted;
  final Color accent;
  final Color accentInk;
  final Color secondary;
  final bool dark;

  String get atlas => 'assets/themes/Illustrated/$folder/moods.png';
  String get scene => 'assets/themes/Illustrated/$folder/scene.png';
  String get background => 'assets/themes/Illustrated/$folder/background.png';
  double get corner => switch (style) {
    IllustrationStyle.comic => 4,
    IllustrationStyle.postcard || IllustrationStyle.vintage => 8,
    IllustrationStyle.botanical => 14,
    IllustrationStyle.arcade => 20,
    IllustrationStyle.seaside || IllustrationStyle.storybook => 28,
  };

  QuietTheme buildQuiet({
    QuietCollection collection = QuietCollection.quietDefault,
  }) {
    final edge = Color.lerp(paper, ink, 0.20)!;
    final wash = Color.lerp(paper, accent, 0.13)!;
    final sunken = Color.lerp(paper, canvas, 0.48)!;
    final pressed = Color.lerp(accent, ink, 0.18)!;
    final shadow = ink.withValues(alpha: dark ? 0.30 : 0.10);
    return QuietTheme(
      mode: dark ? QuietBrightness.dark : QuietBrightness.light,
      elevation: dark
          ? const QuietElevation.dark()
          : const QuietElevation.light(),
      text: switch (style) {
        IllustrationStyle.vintage => ThemeTypography.vintage,
        IllustrationStyle.arcade => ThemeTypography.arcade,
        IllustrationStyle.postcard => ThemeTypography.postcard,
        IllustrationStyle.comic => ThemeTypography.comic,
        IllustrationStyle.botanical => ThemeTypography.botanical,
        IllustrationStyle.seaside => ThemeTypography.seaside,
        IllustrationStyle.storybook => ThemeTypography.storybook,
      },
      color: QuietColors(
        brightness: dark ? Brightness.dark : Brightness.light,
        collection: collection,
        heroTint: accent,
        canvas: canvas,
        surface: paper,
        raised: paper,
        sunken: sunken,
        hairline: edge,
        hairlineStrong: muted,
        textPrimary: ink,
        textSecondary: muted,
        textTertiary: muted,
        textInverse: accentInk,
        accent: accent,
        accentPressed: pressed,
        accentWash: wash,
        danger: dark
            ? IllustratedColors.cffffa9a1
            : IllustratedColors.cff9b302f,
        dangerWash: dark
            ? IllustratedColors.cff452c40
            : IllustratedColors.cfff8dfd8,
        scrim: IllustratedColors.c99141622,
        selection: wash,
        monogramTints: [wash, sunken, Color.lerp(paper, secondary, 0.18)!],
        transparent: IllustratedColors.c00000000,
      ),
      journal: QuietJournal(
        desk: canvas,
        paper: paper,
        paperSunken: sunken,
        ink: ink,
        inkMuted: muted,
        edge: edge,
        rule: edge.withValues(alpha: 0.65),
        tape: secondary.withValues(alpha: 0.45),
        clip: muted,
        photoMat: paper,
        shadow: shadow,
        washStrength: 0.20,
      ),
      interactive: QuietInteractive(
        primaryAction: accent,
        primaryActionPressed: pressed,
        primaryActionInk: accentInk,
        secondaryAction: paper,
        secondaryActionBorder: edge,
        secondaryActionInk: ink,
        sheet: paper,
        sheetElevated: paper,
        sheetBorder: edge,
        sheetGrabber: muted,
        ink: ink,
        inkSecondary: muted,
        inkMuted: muted,
        inkDisabled: muted.withValues(alpha: 0.55),
        accent: accent,
        selectedSurface: wash,
        selectedInk: ink,
        input: sunken,
        inputFocused: paper,
        inputBorder: edge,
        toggleTrackOff: edge,
        toggleTrackOn: accent,
        toggleThumbOff: paper,
        toggleThumbOn: accentInk,
        disabledSurface: sunken,
      ),
      navigation: QuietNavigation(
        surface: paper,
        border: edge,
        inkActive: accent,
        inkInactive: muted,
        indicator: accent,
      ),
    );
  }

  static const vintage = IllustratedTheme(
    style: IllustrationStyle.vintage,
    folder: 'vintage',
    description:
        'Pressed flowers, pencilled margins, a rabbit keeping you company.',
    invitation: 'Keep a little of today.',
    eyebrow: 'A PAGE TO KEEP',
    canvas: IllustratedColors.cffede2d0,
    paper: IllustratedColors.cfffff9ea,
    ink: IllustratedColors.cff3b302c,
    muted: IllustratedColors.cff706057,
    accent: IllustratedColors.cff874a4b,
    accentInk: IllustratedColors.cfffff9ea,
    secondary: IllustratedColors.cffa0a47e,
  );
  static const arcade = IllustratedTheme(
    style: IllustrationStyle.arcade,
    folder: 'neon',
    description: 'After-hours violet, candy keys, and a friendly little robot.',
    invitation: 'Save a good moment.',
    eyebrow: 'TODAY’S SAVE POINT',
    canvas: IllustratedColors.cff1c1932,
    paper: IllustratedColors.cff2b2545,
    ink: IllustratedColors.cfffff2e4,
    muted: IllustratedColors.cffc8bedb,
    accent: IllustratedColors.cff8ee3d2,
    accentInk: IllustratedColors.cff202038,
    secondary: IllustratedColors.cfff8a7c5,
    dark: true,
  );
  static const postcard = IllustratedTheme(
    style: IllustrationStyle.postcard,
    folder: 'retro',
    description: 'Sun-faded postcards, airmail edges, and a wandering fox.',
    invitation: 'Wish you could bottle today?',
    eyebrow: 'POSTMARKED TODAY',
    canvas: IllustratedColors.cfff2e6d0,
    paper: IllustratedColors.cfffff8e8,
    ink: IllustratedColors.cff303d3d,
    muted: IllustratedColors.cff636154,
    accent: IllustratedColors.cffa34531,
    accentInk: IllustratedColors.cfffff8e8,
    secondary: IllustratedColors.cff457c79,
  );
  static const comic = IllustratedTheme(
    style: IllustrationStyle.comic,
    folder: 'comic',
    description:
        'Bold ink, butter-yellow panels, and one very expressive pigeon.',
    invitation: 'Every day has a story.',
    eyebrow: 'YOUR DAILY EDITION',
    canvas: IllustratedColors.cfffff1ba,
    paper: IllustratedColors.cfffffdf2,
    ink: IllustratedColors.cff222d3e,
    muted: IllustratedColors.cff566173,
    accent: IllustratedColors.cffb33f38,
    accentInk: IllustratedColors.cfffffdf2,
    secondary: IllustratedColors.cff75b7d0,
  );
  static const botanical = IllustratedTheme(
    style: IllustrationStyle.botanical,
    folder: 'botanical',
    description:
        'Sage sketchbook pages, washi tape, and a small garden friend.',
    invitation: 'Let a small memory grow.',
    eyebrow: 'NOTES FROM YOUR DAY',
    canvas: IllustratedColors.cffe6ebdb,
    paper: IllustratedColors.cfffbfaed,
    ink: IllustratedColors.cff2d4437,
    muted: IllustratedColors.cff596b55,
    accent: IllustratedColors.cff426749,
    accentInk: IllustratedColors.cfffffdf0,
    secondary: IllustratedColors.cffc3a65b,
  );
  static const seaside = IllustratedTheme(
    style: IllustrationStyle.seaside,
    folder: 'seaside',
    description:
        'Sea-glass washes, rippling edges, and a notebook-toting puffin.',
    invitation: 'Something worth holding on to.',
    eyebrow: 'A MOMENT, WASHED ASHORE',
    canvas: IllustratedColors.cffe3f0ef,
    paper: IllustratedColors.cfffffcf2,
    ink: IllustratedColors.cff294c58,
    muted: IllustratedColors.cff587079,
    accent: IllustratedColors.cff276575,
    accentInk: IllustratedColors.cfffffcf2,
    secondary: IllustratedColors.cffda9a7c,
  );
  static const storybook = IllustratedTheme(
    style: IllustrationStyle.storybook,
    folder: 'midnight',
    description:
        'Ink-blue skies, golden constellations, and a watchful little owl.',
    invitation: 'A little light from today.',
    eyebrow: 'UNDER THE SAME STARS',
    canvas: IllustratedColors.cff202b42,
    paper: IllustratedColors.cff303d57,
    ink: IllustratedColors.cfffff3dd,
    muted: IllustratedColors.cffccc9d2,
    accent: IllustratedColors.cfff3cd83,
    accentInk: IllustratedColors.cff263047,
    secondary: IllustratedColors.cffa8adc9,
    dark: true,
  );
}
