import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Theme-owned typeface expression for shared semantic roles.
///
/// Themes supply **primary** (personal / journal voice) and **secondary**
/// (editorial / interface). They do **not** own the universal archive face —
/// that is product constant [QuietTypography.universalFamily] (Courier Prime).
///
/// Roles stay shared in [QuietTypography]; only these families swap per theme.
@immutable
final class QuietTypeExpression {
  const QuietTypeExpression({
    required this.primaryFamily,
    required this.secondaryFamily,
    this.primaryFallback = const <String>['cursive'],
    this.secondaryFallback = const <String>['Georgia', 'serif'],
  });

  /// Vintage Diary — Caveat personal writing, Fraunces editorial chrome.
  const QuietTypeExpression.vintageDiary()
    : primaryFamily = 'Caveat',
      secondaryFamily = 'Fraunces',
      primaryFallback = const <String>['cursive'],
      secondaryFallback = const <String>['Georgia', 'serif'];

  /// Default — coherent quiet system: Courier Prime for personal/journal voice,
  /// Fraunces for editorial titles. Never Caveat (Vintage-only handwriting).
  const QuietTypeExpression.quietDefault()
    : primaryFamily = QuietTypography.universalFamily,
      secondaryFamily = 'Fraunces',
      primaryFallback = QuietTypography.universalFallback,
      secondaryFallback = const <String>['Georgia', 'serif'];

  /// Neon Arcade — digital HUD voice throughout. Artwork is CRT/pixel/neon;
  /// CourierPrime matches that language for both journal writing and titles.
  /// Never Caveat or Fraunces (those are Vintage/Default editorial).
  const QuietTypeExpression.neonArcade()
    : primaryFamily = QuietTypography.universalFamily,
      secondaryFamily = QuietTypography.universalFamily,
      primaryFallback = QuietTypography.universalFallback,
      secondaryFallback = QuietTypography.universalFallback;

  /// Personal / journal voice (Caveat in Vintage; Courier Prime in Default).
  final String primaryFamily;

  /// Editorial / application interface (Fraunces in both current themes).
  final String secondaryFamily;

  final List<String> primaryFallback;
  final List<String> secondaryFallback;

  /// Legacy alias — prefer [primaryFamily].
  String get displayFamily => primaryFamily;

  /// Legacy alias — prefer [secondaryFamily].
  String get literaryFamily => secondaryFamily;

  /// Legacy alias — universal is product-owned; kept for call-site migration.
  String get archiveFamily => QuietTypography.universalFamily;

  List<String> get displayFallback => primaryFallback;
  List<String> get literaryFallback => secondaryFallback;
  List<String> get archiveFallback => QuietTypography.universalFallback;
}

/// Semantic typography — three voices; families come from [expression].
///
/// ```text
/// APP / INTERFACE  → secondary  (theme expression)
/// PERSONAL / JOURNAL → primary  (theme expression)
/// METADATA / UI    → universal  (Courier Prime, product-owned)
/// ```
///
/// Styles carry no colour — apply via surface ink (`q.inked`).
/// Metrics (size / weight / height / tracking) are shared across product themes;
/// only [QuietTypeExpression] families may differ.
@immutable
final class QuietTypography {
  const QuietTypography({
    this.expression = const QuietTypeExpression.vintageDiary(),
  });

  const QuietTypography.quietDefault()
    : expression = const QuietTypeExpression.quietDefault();

  const QuietTypography.vintageDiary()
    : expression = const QuietTypeExpression.vintageDiary();

  const QuietTypography.neonArcade()
    : expression = const QuietTypeExpression.neonArcade();

  final QuietTypeExpression expression;

  /// Product-owned universal archive / utility face — never theme-swapped.
  static const universalFamily = 'CourierPrime';

  static const universalFallback = <String>[
    'Courier New',
    'Courier',
    'monospace',
  ];

  static const _numericFeatures = <FontFeature>[
    FontFeature.tabularFigures(),
    FontFeature.liningFigures(),
  ];

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

  // ── Semantic aliases (theme-configurable mapping) ─────────────────────

  String get _primary => expression.primaryFamily;
  List<String> get _primaryFb => expression.primaryFallback;
  String get _secondary => expression.secondaryFamily;
  List<String> get _secondaryFb => expression.secondaryFallback;
  String get _universal => universalFamily;
  List<String> get _universalFb => universalFallback;

  // ═══════════════════════════════════════════════════════════════════════
  // UNIVERSAL — Courier Prime (product)
  // ═══════════════════════════════════════════════════════════════════════

  TextStyle get uiButton => buttonLabel;
  TextStyle get uiNavigation => label;
  TextStyle get uiLabel => label;
  TextStyle get uiBody => body;
  TextStyle get uiBodySmall => caption;
  TextStyle get uiInput => body;
  TextStyle get uiPlaceholder => metadata;
  TextStyle get uiMetadata => metadata;
  TextStyle get uiCaption => caption;
  TextStyle get uiTimestamp =>
      metadata.copyWith(fontFeatures: _numericFeatures);
  TextStyle get uiDate => metadata.copyWith(fontFeatures: _numericFeatures);
  TextStyle get uiCount => numeralSm;
  TextStyle get uiControl => label;

  // ═══════════════════════════════════════════════════════════════════════
  // SECONDARY — editorial / application interface (theme expression)
  // ═══════════════════════════════════════════════════════════════════════

  /// Brand / welcome hero — strongest editorial presence.
  TextStyle get appTitle => displayTitle;

  TextStyle get displayTitle => voiceXl;

  TextStyle get pageTitle => voiceLg;

  TextStyle get sectionTitle => TextStyle(
    inherit: false,
    fontFamily: _secondary,
    fontFamilyFallback: _secondaryFb,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.18,
    fontVariations: _fraunces(opsz: 18, soft: 12, wght: 500),
  );

  /// Nested heading under a section (sheets, profile blocks).
  TextStyle get subsectionTitle => voiceMd;

  TextStyle get emptyStateTitle => sectionTitle;

  TextStyle get personName => voiceSm;
  TextStyle get memoryTitle => voiceSm;
  TextStyle get journalTitle => voiceSm;

  /// Editorial day numbers / quoted literary scale (e.g. card “26”).
  TextStyle get editorialBody => voiceLg;

  TextStyle get bodyEmphasis => voiceSmEmphasis;

  // ═══════════════════════════════════════════════════════════════════════
  // PRIMARY — personal / journal voice (theme expression)
  // ═══════════════════════════════════════════════════════════════════════

  TextStyle get emotionalBody => handwrittenMd;

  TextStyle get annotation => handwrittenSm;
  TextStyle get diaryNote => handwrittenMd;

  /// Empty-journal / invite lines in the theme's personal voice.
  TextStyle get journalPrompt => diaryNote;

  /// Memory body and user writing on paper.
  TextStyle get journalWriting => TextStyle(
    inherit: false,
    fontFamily: _primary,
    fontFamilyFallback: _primaryFb,
    fontSize: 20,
    height: 30 / 20,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
  );

  // ═══════════════════════════════════════════════════════════════════════
  // UNIVERSAL body / chrome (Courier Prime)
  // ═══════════════════════════════════════════════════════════════════════

  TextStyle get emptyStateBody => uiBody;
  TextStyle get decorativeLabel => archiveLabel;

  /// Quiet supporting copy under controls and empty states.
  TextStyle get supportingText => uiMetadata;

  /// Tab / bottom-nav label (selected and unselected share metrics).
  TextStyle get tab => uiNavigation;

  /// Compact countdown stamp on birthday strips.
  TextStyle get stampLabel => TextStyle(
    inherit: false,
    fontFamily: _universal,
    fontFamilyFallback: _universalFb,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    fontFeatures: _numericFeatures,
  );

  /// Single-line mood name under an illustration chip.
  TextStyle get moodLabel => TextStyle(
    inherit: false,
    fontFamily: _universal,
    fontFamilyFallback: _universalFb,
    fontSize: 12,
    height: 1.1,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  // ── Scale tokens ──────────────────────────────────────────────────────

  TextStyle get voiceXxl => TextStyle(
    inherit: false,
    fontFamily: _secondary,
    fontFamilyFallback: _secondaryFb,
    fontSize: 56,
    height: 1,
    fontWeight: FontWeight.w400,
    letterSpacing: -1.568,
    fontVariations: _fraunces(opsz: 144, soft: 50, wght: 400),
  );

  TextStyle get voiceXl => TextStyle(
    inherit: false,
    fontFamily: _secondary,
    fontFamilyFallback: _secondaryFb,
    fontSize: 44,
    height: 48 / 44,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.88,
    fontVariations: _fraunces(opsz: 72, soft: 40, wght: 400),
  );

  TextStyle get voiceLg => TextStyle(
    inherit: false,
    fontFamily: _secondary,
    fontFamilyFallback: _secondaryFb,
    fontSize: 32,
    height: 38 / 32,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.48,
    fontVariations: _fraunces(opsz: 36, soft: 30, wght: 400),
  );

  TextStyle get voiceMd => TextStyle(
    inherit: false,
    fontFamily: _secondary,
    fontFamilyFallback: _secondaryFb,
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    fontVariations: _fraunces(opsz: 24, soft: 20, wght: 400),
  );

  TextStyle get voiceSm => TextStyle(
    inherit: false,
    fontFamily: _secondary,
    fontFamilyFallback: _secondaryFb,
    fontSize: 17,
    height: 24 / 17,
    fontWeight: FontWeight.w500,
    fontVariations: _fraunces(opsz: 14, soft: 10, wght: 500),
  );

  TextStyle get voiceSmEmphasis => TextStyle(
    inherit: false,
    fontFamily: _secondary,
    fontFamilyFallback: _secondaryFb,
    fontSize: 17,
    height: 24 / 17,
    fontWeight: FontWeight.w600,
    fontVariations: _fraunces(opsz: 14, soft: 10, wght: 600),
  );

  TextStyle get titleLg => TextStyle(
    inherit: false,
    fontFamily: _universal,
    fontFamilyFallback: _universalFb,
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.12,
  );

  TextStyle get title => TextStyle(
    inherit: false,
    fontFamily: _universal,
    fontFamilyFallback: _universalFb,
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
  );

  /// Subsection heading on a screen or parchment plate.
  TextStyle get headline => voiceSm;

  TextStyle get bodyLg => TextStyle(
    inherit: false,
    fontFamily: _universal,
    fontFamilyFallback: _universalFb,
    fontSize: 17,
    height: 26 / 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.12,
  );

  TextStyle get body => TextStyle(
    inherit: false,
    fontFamily: _universal,
    fontFamilyFallback: _universalFb,
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.12,
  );

  TextStyle get label => TextStyle(
    inherit: false,
    fontFamily: _universal,
    fontFamilyFallback: _universalFb,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
  );

  TextStyle get caption => TextStyle(
    inherit: false,
    fontFamily: _universal,
    fontFamilyFallback: _universalFb,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.24,
  );

  TextStyle get metadata => TextStyle(
    inherit: false,
    fontFamily: _universal,
    fontFamilyFallback: _universalFb,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.24,
  );

  TextStyle get tiny => TextStyle(
    inherit: false,
    fontFamily: _universal,
    fontFamilyFallback: _universalFb,
    fontSize: 10,
    height: 13 / 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
    fontFeatures: _numericFeatures,
  );

  TextStyle get eyebrow => TextStyle(
    inherit: false,
    fontFamily: _universal,
    fontFamilyFallback: _universalFb,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.66,
  );

  /// Large editorial numerals use secondary expression — e.g. day "26".
  TextStyle get numeralXl => TextStyle(
    inherit: false,
    fontFamily: _secondary,
    fontFamilyFallback: _secondaryFb,
    fontSize: 76,
    height: 68 / 76,
    fontWeight: FontWeight.w300,
    letterSpacing: -2.66,
    fontVariations: _fraunces(opsz: 144, soft: 40, wght: 300),
    fontFeatures: _numericFeatures,
  );

  TextStyle get numeralHero => TextStyle(
    inherit: false,
    fontFamily: _secondary,
    fontFamilyFallback: _secondaryFb,
    fontSize: 64,
    height: 1,
    fontWeight: FontWeight.w400,
    letterSpacing: -1.92,
    fontVariations: _fraunces(opsz: 72, soft: 30, wght: 400),
    fontFeatures: _numericFeatures,
  );

  TextStyle get numeralLg => TextStyle(
    inherit: false,
    fontFamily: _secondary,
    fontFamilyFallback: _secondaryFb,
    fontSize: 28,
    height: 32 / 28,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.56,
    fontVariations: _fraunces(opsz: 28, soft: 20, wght: 500),
    fontFeatures: _numericFeatures,
  );

  TextStyle get numeralMd => TextStyle(
    inherit: false,
    fontFamily: _universal,
    fontFamilyFallback: _universalFb,
    fontSize: 17,
    height: 22 / 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.08,
    fontFeatures: _numericFeatures,
  );

  TextStyle get numeralSm => TextStyle(
    inherit: false,
    fontFamily: _universal,
    fontFamilyFallback: _universalFb,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFeatures: _numericFeatures,
  );

  TextStyle get relationship => label.copyWith(letterSpacing: 0.78);

  TextStyle get dateLine => body.copyWith(fontFeatures: _numericFeatures);

  TextStyle get buttonLabel => TextStyle(
    inherit: false,
    fontFamily: _universal,
    fontFamilyFallback: _universalFb,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
  );

  TextStyle get chipLabel => label;

  TextStyle get archiveBodyLarge => TextStyle(
    inherit: false,
    fontFamily: _universal,
    fontFamilyFallback: _universalFb,
    fontSize: 18,
    height: 28 / 18,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.18,
  );

  TextStyle get archiveBody => TextStyle(
    inherit: false,
    fontFamily: _universal,
    fontFamilyFallback: _universalFb,
    fontSize: 16,
    height: 26 / 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.16,
  );

  TextStyle get archiveTitle => TextStyle(
    inherit: false,
    fontFamily: _universal,
    fontFamilyFallback: _universalFb,
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
  );

  TextStyle get archiveMeta => TextStyle(
    inherit: false,
    fontFamily: _universal,
    fontFamilyFallback: _universalFb,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.48,
  );

  TextStyle get archiveCaption => TextStyle(
    inherit: false,
    fontFamily: _universal,
    fontFamilyFallback: _universalFb,
    fontSize: 11,
    height: 15 / 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.22,
  );

  TextStyle get archiveLabel => TextStyle(
    inherit: false,
    fontFamily: _universal,
    fontFamilyFallback: _universalFb,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.66,
  );

  TextStyle get archiveTypewriter => archiveBody;

  TextStyle get handwrittenMd => TextStyle(
    inherit: false,
    fontFamily: _primary,
    fontFamilyFallback: _primaryFb,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.18,
  );

  TextStyle get handwrittenSm => TextStyle(
    inherit: false,
    fontFamily: _primary,
    fontFamilyFallback: _primaryFb,
    fontSize: 17,
    height: 24 / 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.14,
  );

  TextStyle get handwrittenLabel => TextStyle(
    inherit: false,
    fontFamily: _primary,
    fontFamilyFallback: _primaryFb,
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
  );

  TextStyle overImage(TextStyle style, Color shadow) => style.copyWith(
    shadows: <Shadow>[
      Shadow(color: shadow, blurRadius: 18, offset: const Offset(0, 1)),
    ],
  );

  TextHeightBehavior get displayHeightBehavior => const TextHeightBehavior(
    applyHeightToFirstAscent: false,
    applyHeightToLastDescent: false,
  );

  double sideBearingFor(double fontSize) {
    if (fontSize >= 52) return -1.5;
    if (fontSize >= 40) return -1;
    if (fontSize >= 28) return -0.5;
    return 0;
  }

  double get nameScaleCap => 1.4;
  double get heroScaleCap => 1.2;
  double get structuralScaleCap => 1.3;
}
