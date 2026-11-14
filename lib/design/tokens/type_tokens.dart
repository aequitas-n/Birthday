import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Theme-owned typeface expression for shared semantic roles.
///
/// Themes supply **primary** (personal / journal voice) and **secondary**
/// (editorial / interface). They do **not** own the universal archive face —
/// that is product-owned; current themes use DM Sans and DM Mono for utility UI.
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
/// Current product themes share UI roles and behavior while [QuietTypeMetrics]
/// tunes heading scale, weight, tracking, and journal leading to each typeface.
@immutable
final class QuietTypography {
  const QuietTypography({
    this.expression = const QuietTypeExpression.vintageDiary(),
    this.metrics,
    this.sharedUi = false,
  });

  const QuietTypography.quietDefault()
    : expression = const QuietTypeExpression.quietDefault(),
      metrics = null,
      sharedUi = false;

  const QuietTypography.vintageDiary()
    : expression = const QuietTypeExpression.vintageDiary(),
      metrics = null,
      sharedUi = false;

  const QuietTypography.neonArcade()
    : expression = const QuietTypeExpression.neonArcade(),
      metrics = null,
      sharedUi = false;

  final QuietTypeExpression expression;
  final QuietTypeMetrics? metrics;
  final bool sharedUi;

  /// Stable interface families used by every current product theme.
  static const sharedUiFamily = 'DMSans';
  static const sharedMetaFamily = 'DMMono';
  String get uiFamily => _universal;
  String get metadataFamily => _meta;
  String get headingFamily => _secondary;
  String get journalFamily => _primary;

  /// Legacy archive face retained for Default personal writing and old callers.
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
  String get _universal => sharedUi ? sharedUiFamily : universalFamily;
  List<String> get _universalFb =>
      sharedUi ? const ['sans-serif'] : universalFallback;
  String get _meta => sharedUi ? sharedMetaFamily : universalFamily;
  List<String> get _metaFb =>
      sharedUi ? const ['monospace'] : universalFallback;
  List<FontVariation>? _editorialAxes({
    required double opsz,
    required double soft,
    required double wght,
  }) => _secondary == 'Fraunces'
      ? _fraunces(opsz: opsz, soft: soft, wght: wght)
      : null;

  // ═══════════════════════════════════════════════════════════════════════
  // SHARED UI — DM Sans / DM Mono (legacy callers retain Courier Prime)
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
    fontSize: metrics?.sectionSize ?? 22,
    height: metrics?.headingHeight ?? 28 / 22,
    fontWeight: metrics?.headingWeight ?? FontWeight.w500,
    letterSpacing: metrics?.headingTracking ?? -0.18,
    fontVariations: _editorialAxes(opsz: 18, soft: 12, wght: 500),
  );

  /// Nested heading under a section (sheets, profile blocks).
  TextStyle get subsectionTitle => voiceMd;

  TextStyle get emptyStateTitle => sectionTitle;

  TextStyle get personName => voiceSm;
  TextStyle get memoryTitle => voiceSm;
  TextStyle get journalTitle => voiceSm;

  /// Invitation copy keeps each display face's optical scale and leading.
  TextStyle get invitationTitle => pageTitle.copyWith(
    fontSize: (metrics?.pageSize ?? 32) * 0.9,
    height: metrics?.headingHeight ?? 1.12,
  );

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
    fontSize: metrics?.journalSize ?? 20,
    height: metrics?.journalHeight ?? 30 / 20,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
  );

  // ═══════════════════════════════════════════════════════════════════════
  // SHARED body / chrome (DM Sans; DM Mono for dates and metadata)
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
    fontFamily: _meta,
    fontFamilyFallback: _metaFb,
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
    fontVariations: _editorialAxes(opsz: 144, soft: 50, wght: 400),
  );

  TextStyle get voiceXl => TextStyle(
    inherit: false,
    fontFamily: _secondary,
    fontFamilyFallback: _secondaryFb,
    fontSize: metrics?.displaySize ?? 44,
    height: metrics?.headingHeight ?? 48 / 44,
    fontWeight: metrics?.headingWeight ?? FontWeight.w400,
    letterSpacing: metrics?.headingTracking ?? -0.88,
    fontVariations: _editorialAxes(opsz: 72, soft: 40, wght: 400),
  );

  TextStyle get voiceLg => TextStyle(
    inherit: false,
    fontFamily: _secondary,
    fontFamilyFallback: _secondaryFb,
    fontSize: metrics?.pageSize ?? 32,
    height: metrics?.headingHeight ?? 38 / 32,
    fontWeight: metrics?.headingWeight ?? FontWeight.w400,
    letterSpacing: metrics?.headingTracking ?? -0.48,
    fontVariations: _editorialAxes(opsz: 36, soft: 30, wght: 400),
  );

  TextStyle get voiceMd => TextStyle(
    inherit: false,
    fontFamily: _secondary,
    fontFamilyFallback: _secondaryFb,
    fontSize: metrics?.sectionSize ?? 24,
    height: metrics?.headingHeight ?? 30 / 24,
    fontWeight: metrics?.headingWeight ?? FontWeight.w400,
    letterSpacing: metrics?.headingTracking ?? -0.24,
    fontVariations: _editorialAxes(opsz: 24, soft: 20, wght: 400),
  );

  TextStyle get voiceSm => TextStyle(
    inherit: false,
    fontFamily: _secondary,
    fontFamilyFallback: _secondaryFb,
    fontSize: metrics?.nameSize ?? 17,
    height: metrics?.headingHeight ?? 24 / 17,
    fontWeight: metrics?.headingWeight ?? FontWeight.w500,
    fontVariations: _editorialAxes(opsz: 14, soft: 10, wght: 500),
  );

  TextStyle get voiceSmEmphasis => TextStyle(
    inherit: false,
    fontFamily: _secondary,
    fontFamilyFallback: _secondaryFb,
    fontSize: metrics?.nameSize ?? 17,
    height: metrics?.headingHeight ?? 24 / 17,
    fontWeight: FontWeight.w600,
    fontVariations: _editorialAxes(opsz: 14, soft: 10, wght: 600),
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
    fontSize: sharedUi ? 16 : 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.12,
  );

  TextStyle get label => TextStyle(
    inherit: false,
    fontFamily: _universal,
    fontFamilyFallback: _universalFb,
    fontSize: sharedUi ? 14 : 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
  );

  TextStyle get caption => TextStyle(
    inherit: false,
    fontFamily: _universal,
    fontFamilyFallback: _universalFb,
    fontSize: sharedUi ? 13 : 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.24,
  );

  TextStyle get metadata => TextStyle(
    inherit: false,
    fontFamily: _meta,
    fontFamilyFallback: _metaFb,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.24,
  );

  TextStyle get tiny => TextStyle(
    inherit: false,
    fontFamily: _meta,
    fontFamilyFallback: _metaFb,
    fontSize: 10,
    height: 13 / 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
    fontFeatures: _numericFeatures,
  );

  TextStyle get eyebrow => TextStyle(
    inherit: false,
    fontFamily: _meta,
    fontFamilyFallback: _metaFb,
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
    fontVariations: _editorialAxes(opsz: 144, soft: 40, wght: 300),
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
    fontVariations: _editorialAxes(opsz: 72, soft: 30, wght: 400),
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
    fontVariations: _editorialAxes(opsz: 28, soft: 20, wght: 500),
    fontFeatures: _numericFeatures,
  );

  TextStyle get numeralMd => TextStyle(
    inherit: false,
    fontFamily: _meta,
    fontFamilyFallback: _metaFb,
    fontSize: 17,
    height: 22 / 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.08,
    fontFeatures: _numericFeatures,
  );

  TextStyle get numeralSm => TextStyle(
    inherit: false,
    fontFamily: _meta,
    fontFamilyFallback: _metaFb,
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
    fontSize: sharedUi ? 14 : 13,
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
    fontFamily: _meta,
    fontFamilyFallback: _metaFb,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.48,
  );

  TextStyle get archiveCaption => TextStyle(
    inherit: false,
    fontFamily: _meta,
    fontFamilyFallback: _metaFb,
    fontSize: 11,
    height: 15 / 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.22,
  );

  TextStyle get archiveLabel => TextStyle(
    inherit: false,
    fontFamily: _meta,
    fontFamilyFallback: _metaFb,
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
    fontSize: metrics?.promptSize ?? 22,
    height: metrics?.journalHeight ?? 28 / 22,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.18,
  );

  TextStyle get handwrittenSm => TextStyle(
    inherit: false,
    fontFamily: _primary,
    fontFamilyFallback: _primaryFb,
    fontSize: (metrics?.journalSize ?? 20) * 0.85,
    height: metrics?.journalHeight ?? 24 / 17,
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

/// Optical adjustments for theme fonts; independent of navigation and behavior.
@immutable
final class QuietTypeMetrics {
  const QuietTypeMetrics({
    this.pageSize = 32,
    this.sectionSize = 23,
    this.displaySize = 44,
    this.nameSize = 19,
    this.headingHeight = 1.22,
    this.headingTracking = -0.2,
    this.headingWeight = FontWeight.w500,
    this.journalSize = 21,
    this.journalHeight = 1.5,
    this.promptSize = 23,
  });
  final double pageSize;
  final double sectionSize;
  final double displaySize;
  final double nameSize;
  final double headingHeight;
  final double headingTracking;
  final FontWeight headingWeight;
  final double journalSize;
  final double journalHeight;
  final double promptSize;
}

/// Current product typography: shared interface, individual editorial voices.
abstract final class ThemeTypography {
  static const plain = QuietTypography(
    expression: QuietTypeExpression.quietDefault(),
    sharedUi: true,
    metrics: QuietTypeMetrics(journalSize: 18, promptSize: 20),
  );
  static const vintage = QuietTypography(
    expression: QuietTypeExpression(
      primaryFamily: 'Caveat',
      secondaryFamily: 'CormorantGaramond',
    ),
    sharedUi: true,
    metrics: QuietTypeMetrics(
      pageSize: 36,
      sectionSize: 26,
      nameSize: 21,
      headingWeight: FontWeight.w600,
      journalSize: 23,
      promptSize: 25,
      journalHeight: 1.4,
    ),
  );
  static const arcade = QuietTypography(
    expression: QuietTypeExpression(
      primaryFamily: 'SpaceMono',
      secondaryFamily: 'ChakraPetch',
      primaryFallback: ['monospace'],
      secondaryFallback: ['sans-serif'],
    ),
    sharedUi: true,
    metrics: QuietTypeMetrics(
      pageSize: 30,
      sectionSize: 22,
      nameSize: 18,
      headingTracking: 0.1,
      headingWeight: FontWeight.w600,
      journalSize: 17,
      promptSize: 18,
      journalHeight: 1.65,
    ),
  );
  static const postcard = QuietTypography(
    expression: QuietTypeExpression(
      primaryFamily: 'SpecialElite',
      secondaryFamily: 'DMSerifDisplay',
      primaryFallback: ['monospace'],
    ),
    sharedUi: true,
    metrics: QuietTypeMetrics(
      pageSize: 33,
      headingWeight: FontWeight.w400,
      journalSize: 18,
      promptSize: 20,
      journalHeight: 1.65,
    ),
  );
  static const comic = QuietTypography(
    expression: QuietTypeExpression(
      primaryFamily: 'ComicNeue',
      secondaryFamily: 'Bangers',
      primaryFallback: ['sans-serif'],
      secondaryFallback: ['sans-serif'],
    ),
    sharedUi: true,
    metrics: QuietTypeMetrics(
      pageSize: 38,
      sectionSize: 28,
      displaySize: 48,
      nameSize: 23,
      headingTracking: 0.6,
      headingHeight: 1.12,
      headingWeight: FontWeight.w400,
      journalHeight: 1.4,
    ),
  );
  static const botanical = QuietTypography(
    expression: QuietTypeExpression(
      primaryFamily: 'Kalam',
      secondaryFamily: 'Lora',
    ),
    sharedUi: true,
    metrics: QuietTypeMetrics(
      pageSize: 30,
      sectionSize: 22,
      nameSize: 18,
      journalSize: 20,
      promptSize: 22,
      journalHeight: 1.55,
    ),
  );
  static const seaside = QuietTypography(
    expression: QuietTypeExpression(
      primaryFamily: 'PatrickHand',
      secondaryFamily: 'BreeSerif',
    ),
    sharedUi: true,
    metrics: QuietTypeMetrics(
      headingWeight: FontWeight.w400,
      journalSize: 23,
      promptSize: 24,
      journalHeight: 1.4,
    ),
  );
  static const storybook = QuietTypography(
    expression: QuietTypeExpression(
      primaryFamily: 'CrimsonPro',
      secondaryFamily: 'Cinzel',
      primaryFallback: ['serif'],
    ),
    sharedUi: true,
    metrics: QuietTypeMetrics(
      pageSize: 29,
      sectionSize: 21,
      nameSize: 17,
      headingTracking: 0.1,
      headingHeight: 1.3,
      journalSize: 22,
    ),
  );
}
