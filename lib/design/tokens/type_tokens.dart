import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// The typography scale.
///
/// Two families, never a third. Styles carry no colour — colour is a semantic
/// role applied at the use site via `TextStyle.tinted`.
///
/// Letter spacing is a function of size, never a constant. Flutter's default
/// of zero at every size is a large part of why untouched Flutter type reads
/// as flat. Each value below is annotated with the em ratio it came from.
///
/// Every style sets `inherit: false`. A design token must be complete: with
/// inheritance on, a style merges with whatever ambient `DefaultTextStyle`
/// happens to be in scope — including the framework's yellow-underlined
/// "you forgot a text style" fallback, which appears whenever there is no
/// `Scaffold` in the tree. Kin has no `Scaffold` anywhere.
///
/// Specified in docs/05-typography.md.
@immutable
final class QuietTypography {
  const QuietTypography();

  static const _voice = 'Fraunces';
  static const _text = 'Inter';

  /// Tabular, lining figures. Applied everywhere numbers must align.
  static const _numericFeatures = <FontFeature>[
    FontFeature.tabularFigures(),
    FontFeature.liningFigures(),
  ];

  /// Contextual alternates that pull Inter away from its most familiar
  /// default shapes: `cv05` gives the lowercase l a tail, `ss03` a curved r.
  static const _interAlternates = <FontFeature>[
    FontFeature.enable('cv05'),
    FontFeature.enable('ss03'),
  ];

  /// For the handful of styles that carry both words and aligned figures.
  static const _interNumericFeatures = <FontFeature>[
    ..._interAlternates,
    ..._numericFeatures,
  ];

  /// Fraunces axes.
  ///
  /// `wght` is set explicitly rather than left to [TextStyle.fontWeight]. The
  /// two do the same job, but being explicit here keeps the intended weight
  /// visible next to the optical size it was tuned against — and Fraunces
  /// gains apparent weight as `opsz` climbs, so the pairing matters.
  ///
  /// WONK stays at zero. The wonky variants are charming once and irritating
  /// thereafter.
  static List<FontVariation> _fraunces({
    required double opsz,
    required double soft,
    required double wght,
  }) => <FontVariation>[
    FontVariation('opsz', opsz),
    FontVariation('SOFT', soft),
    FontVariation('wght', wght),
    const FontVariation('WONK', 0),
  ];

  static List<FontVariation> _inter({
    required double opsz,
    required double wght,
  }) => <FontVariation>[
    FontVariation('opsz', opsz),
    FontVariation('wght', wght),
  ];

  // ── Voice: Fraunces. Human content. ───────────────────────────────────

  /// 56/56. A person's name embedded in their hero photograph.
  ///
  /// The largest type in the product, and it appears exactly once per screen.
  /// Leading is set below the point size because a display line this large
  /// needs to read as a single object rather than as a paragraph.
  TextStyle get voiceXxl => TextStyle(
    inherit: false,
    fontFamily: _voice,
    fontSize: 56,
    height: 56 / 56,
    fontWeight: FontWeight.w400,
    letterSpacing: -1.568, // -0.028em
    fontVariations: _fraunces(opsz: 144, soft: 50, wght: 400),
  );

  /// 44/48. The birthday moment, and a person's name on their own screen.
  TextStyle get voiceXl => TextStyle(
    inherit: false,
    fontFamily: _voice,
    fontSize: 44,
    height: 48 / 44,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.88, // -0.020em
    fontVariations: _fraunces(opsz: 96, soft: 40, wght: 400),
  );

  /// 32/38. Screen titles.
  TextStyle get voiceLg => TextStyle(
    inherit: false,
    fontFamily: _voice,
    fontSize: 32,
    height: 38 / 32,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.448, // -0.014em
    fontVariations: _fraunces(opsz: 72, soft: 30, wght: 400),
  );

  /// 24/31. Section moments, quoted notes.
  TextStyle get voiceMd => TextStyle(
    inherit: false,
    fontFamily: _voice,
    fontSize: 24,
    height: 31 / 24,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.192, // -0.008em
    fontVariations: _fraunces(opsz: 36, soft: 20, wght: 400),
  );

  /// 17/24. Note values, names in lists. The serif appears at list scale to
  /// establish the voice, and reaches full size only on the person screen.
  TextStyle get voiceSm => TextStyle(
    inherit: false,
    fontFamily: _voice,
    fontSize: 17,
    height: 24 / 17,
    fontWeight: FontWeight.w500,
    fontVariations: _fraunces(opsz: 14, soft: 10, wght: 500),
  );

  // ── Text: Inter. Functional content. ──────────────────────────────────

  /// 24/30. The title of a sheet that opens as a full experience rather than
  /// as a prompt — the memory book, the profile.
  TextStyle get titleLg => TextStyle(
    inherit: false,
    fontFamily: _text,
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.36, // -0.015em
    fontVariations: _inter(opsz: 24, wght: 600),
    fontFeatures: _interAlternates,
  );

  /// 20/26. Sheet titles, group headers.
  TextStyle get title => TextStyle(
    inherit: false,
    fontFamily: _text,
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.22, // -0.011em
    fontVariations: _inter(opsz: 20, wght: 600),
    fontFeatures: _interAlternates,
  );

  /// 17/23. The title of a card or a region. Semibold at reading size, which
  /// separates a heading from the body beneath it by weight rather than by
  /// size — the distinction a section eyebrow used to make with capitals.
  TextStyle get headline => TextStyle(
    inherit: false,
    fontFamily: _text,
    fontSize: 17,
    height: 23 / 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.153, // -0.009em
    fontVariations: _inter(opsz: 17, wght: 600),
    fontFeatures: _interAlternates,
  );

  /// 17/25. Primary reading text and note bodies. Larger than typical,
  /// because typing and reading here should feel unhurried.
  TextStyle get bodyLg => TextStyle(
    inherit: false,
    fontFamily: _text,
    fontSize: 17,
    height: 25 / 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.034, // -0.002em
    fontVariations: _inter(opsz: 17, wght: 400),
    fontFeatures: _interAlternates,
  );

  /// 15/22. Default UI text, row subtitles.
  TextStyle get body => TextStyle(
    inherit: false,
    fontFamily: _text,
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
    fontVariations: _inter(opsz: 15, wght: 400),
    fontFeatures: _interAlternates,
  );

  /// 13/18. Buttons, field labels, metadata.
  TextStyle get label => TextStyle(
    inherit: false,
    fontFamily: _text,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.052, // +0.004em
    fontVariations: _inter(opsz: 14, wght: 500),
    fontFeatures: _interAlternates,
  );

  /// 12/16. Helper text, errors, timestamps.
  TextStyle get caption => TextStyle(
    inherit: false,
    fontFamily: _text,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.12, // +0.010em
    fontVariations: _inter(opsz: 14, wght: 500),
    fontFeatures: _interAlternates,
  );

  /// 12/16. Supporting metadata: a place, a date, a count beneath a name.
  ///
  /// Deliberately lighter than [caption]. Caption is a label that instructs;
  /// metadata is information that recedes, and the two should not look alike.
  TextStyle get metadata => TextStyle(
    inherit: false,
    fontFamily: _text,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.024, // +0.002em
    fontVariations: _inter(opsz: 14, wght: 400),
    fontFeatures: _interAlternates,
  );

  /// 10/13. Counts inside a badge. The smallest type in the product, and it
  /// only ever carries a number or a single word.
  TextStyle get tiny => TextStyle(
    inherit: false,
    fontFamily: _text,
    fontSize: 10,
    height: 13 / 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3, // +0.030em
    fontVariations: _inter(opsz: 14, wght: 600),
    fontFeatures: _interNumericFeatures,
  );

  /// 11/14, uppercase. Section eyebrows. The only style permitted to be
  /// uppercased.
  TextStyle get eyebrow => TextStyle(
    inherit: false,
    fontFamily: _text,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.825, // +0.075em
    fontVariations: _inter(opsz: 14, wght: 600),
    fontFeatures: _interAlternates,
  );

  // ── Numerals: Inter, tabular. ─────────────────────────────────────────

  /// 76/68. The countdown, embedded in a hero photograph.
  ///
  /// Light weight at this size: a large number in medium reads as a price tag,
  /// and this number is meant to read as a held breath.
  TextStyle get numeralXl => TextStyle(
    inherit: false,
    fontFamily: _text,
    fontSize: 76,
    height: 68 / 76,
    fontWeight: FontWeight.w300,
    letterSpacing: -2.66, // -0.035em
    fontVariations: _inter(opsz: 32, wght: 300),
    fontFeatures: _numericFeatures,
  );

  /// 64/64. Days-until on the birthday moment.
  TextStyle get numeralHero => TextStyle(
    inherit: false,
    fontFamily: _text,
    fontSize: 64,
    height: 1,
    fontWeight: FontWeight.w400,
    letterSpacing: -1.92, // -0.030em
    fontVariations: _inter(opsz: 32, wght: 400),
    fontFeatures: _numericFeatures,
  );

  /// 28/32. Age on the person screen.
  TextStyle get numeralLg => TextStyle(
    inherit: false,
    fontFamily: _text,
    fontSize: 28,
    height: 32 / 28,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.56, // -0.020em
    fontVariations: _inter(opsz: 28, wght: 500),
    fontFeatures: _numericFeatures,
  );

  /// 17/22. The countdown column on the home list. Tabular so the column
  /// never jitters between 9 and 10.
  TextStyle get numeralMd => TextStyle(
    inherit: false,
    fontFamily: _text,
    fontSize: 17,
    height: 22 / 17,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.17, // -0.010em
    fontVariations: _inter(opsz: 17, wght: 500),
    fontFeatures: _numericFeatures,
  );

  /// 13/18. A count or a date sitting in a column beside other counts.
  TextStyle get numeralSm => TextStyle(
    inherit: false,
    fontFamily: _text,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0, // tabular figures set their own rhythm
    fontVariations: _inter(opsz: 14, wght: 500),
    fontFeatures: _numericFeatures,
  );

  // ── Content styles ────────────────────────────────────────────────────
  // Named for what they carry rather than for how big they are. Each one
  // composes from the scale above; none introduces a new size. A screen that
  // reads `q.text.relationship` instead of `q.text.label` states its intent,
  // and the intent is what stays consistent as the scale is tuned.

  /// Emphasis on a name in a list, for the person whose day it is.
  ///
  /// A separate token rather than `voiceSm.copyWith(fontWeight:)`, because both
  /// typefaces here are variable: the `wght` axis in `fontVariations` decides
  /// what is actually rasterised, and a `fontWeight` set without it changes
  /// nothing on screen. Every weight variant in this file therefore states both.
  TextStyle get voiceSmEmphasis => TextStyle(
    inherit: false,
    fontFamily: _voice,
    fontSize: 17,
    height: 24 / 17,
    fontWeight: FontWeight.w600,
    fontVariations: _fraunces(opsz: 14, soft: 10, wght: 600),
  );

  /// The relationship above a name — "Sister", "Oldest friend".
  ///
  /// Tracked open and left in sentence case. Capitals would turn a human
  /// relationship into a database field, which is the one thing this product
  /// must never do.
  TextStyle get relationship => label.copyWith(letterSpacing: 0.78);

  /// An editorial section title: "Their year", "Memories".
  ///
  /// The serif, at a size that sits between body and title. Sections are
  /// chapters in a person's story, so they speak in the Voice.
  TextStyle get sectionTitle => TextStyle(
    inherit: false,
    fontFamily: _voice,
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.16, // -0.008em
    fontVariations: _fraunces(opsz: 24, soft: 16, wght: 500),
  );

  /// A date read as prose — "28 July 1997". Tabular so a column of dates
  /// aligns on the digits.
  TextStyle get dateLine => body.copyWith(fontFeatures: _numericFeatures);

  /// The label inside a button, and on the one action a card offers.
  TextStyle get buttonLabel => TextStyle(
    inherit: false,
    fontFamily: _text,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.052, // +0.004em
    fontVariations: _inter(opsz: 14, wght: 600),
    fontFeatures: _interAlternates,
  );

  /// The label inside a chip or a pill.
  TextStyle get chipLabel => label;

  /// Type set over a photograph.
  ///
  /// A soft shadow rather than a heavier weight or a darker scrim: the
  /// photograph stays a photograph, and the words stay legible over whatever
  /// happens to be behind them.
  TextStyle overImage(TextStyle style, Color shadow) => style.copyWith(
    shadows: <Shadow>[
      Shadow(color: shadow, blurRadius: 18, offset: const Offset(0, 1)),
    ],
  );

  // ── Optical corrections ───────────────────────────────────────────────

  /// Line-height padding above the first line and below the last creates
  /// phantom space around display type. Trimmed for anything Voice.
  TextHeightBehavior get displayHeightBehavior => const TextHeightBehavior(
    applyHeightToFirstAscent: false,
    applyHeightToLastDescent: false,
  );

  /// Large Voice type is nudged left so the glyph edge — not the bounding
  /// box — aligns to the gutter.
  double sideBearingFor(double fontSize) {
    if (fontSize >= 52) return -1.5;
    if (fontSize >= 40) return -1;
    if (fontSize >= 28) return -0.5;
    return 0;
  }

  // ── Dynamic Type clamps ───────────────────────────────────────────────
  // Content scales freely; chrome does not outgrow it.

  /// Names stop growing here, past which they dominate the layout.
  double get nameScaleCap => 1.4;

  /// Type embedded in a hero photograph.
  ///
  /// Tighter than [nameScaleCap], because the hero is a fixed fraction of the
  /// viewport: type that grows past this stops fitting over the image and
  /// starts covering the face.
  double get heroScaleCap => 1.2;

  /// Structural labels, numerals and icons.
  double get structuralScaleCap => 1.3;
}
