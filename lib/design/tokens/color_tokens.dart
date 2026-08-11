import 'dart:ui';

/// Raw colour ramps for the Quiet design language.
///
/// These are values, not meanings. Nothing outside `design/theme/` may read
/// them — widgets consume the semantic roles on `QuietColors` instead. The
/// architecture guard (`tool/check_architecture.dart`, rule ARCH-04) enforces
/// this.
///
/// Specified in docs/06-color.md.
abstract final class ColorTokens {
  // ── Ember: the single accent ──────────────────────────────────────────
  // Terracotta. The colour of candlelight and baked earth. Chosen partly
  // because it sits nowhere near the indigo that identifies a default
  // Material seed palette.
  static const ember50 = Color(0xFFFDF5F1);
  static const ember100 = Color(0xFFF9E5DB);
  static const ember200 = Color(0xFFF0C9B4);
  static const ember300 = Color(0xFFE4A585);
  static const ember400 = Color(0xFFD4805C);
  static const ember500 = Color(0xFFBF6039);
  static const ember600 = Color(0xFFA24E2D);
  static const ember700 = Color(0xFF7E3C23);

  // ── Light: warm paper ─────────────────────────────────────────────────
  static const paperCanvas = Color(0xFFFBFAF8);
  static const paperSurface = Color(0xFFFFFFFF);
  static const paperSunken = Color(0xFFF4F2EE);
  static const paperHairline = Color(0xFFE7E3DC);
  static const paperHairlineStrong = Color(0xFFD5CFC5);
  static const paperInkPrimary = Color(0xFF1A1815);
  static const paperInkSecondary = Color(0xFF6B6560);
  static const paperInkTertiary = Color(0xFF948D85);

  // ── Dark: warm charcoal ───────────────────────────────────────────────
  // Deliberately not #121212. A neutral dark next to warm type reads blue.
  static const charcoalCanvas = Color(0xFF141311);
  static const charcoalSurface = Color(0xFF1C1B18);
  static const charcoalRaised = Color(0xFF242220);
  static const charcoalSunken = Color(0xFF0E0D0C);
  static const charcoalHairline = Color(0xFF2E2C28);
  static const charcoalHairlineStrong = Color(0xFF403D38);
  static const charcoalInkPrimary = Color(0xFFF5F3F0);
  static const charcoalInkSecondary = Color(0xFFA6A099);
  static const charcoalInkTertiary = Color(0xFF6F6A64);

  // ── AMOLED: true black ────────────────────────────────────────────────
  // Canvas and surface are identical, so hairlines carry the entire visual
  // structure. Any screen that collapses here was leaning on background
  // fills instead of typography.
  static const voidCanvas = Color(0xFF000000);
  static const voidRaised = Color(0xFF0C0B0A);
  // Stronger than the dark-mode equivalents: with canvas and surface both
  // black, these are the only structural device available.
  static const voidHairline = Color(0xFF272522);
  static const voidHairlineStrong = Color(0xFF3D3B37);
  static const voidInkPrimary = Color(0xFFF2F0ED);
  static const voidInkSecondary = Color(0xFF9C968F);
  static const voidInkTertiary = Color(0xFF66615C);

  // ── Cool: mist and slate ──────────────────────────────────────────────
  // The neutral family behind the cool collections. Blue-shifted rather than
  // grey: a genuinely neutral grey beside a cool accent reads as dirt.
  static const mistCanvas = Color(0xFFF8F9FB);
  // Not pure white. A card here is the coolest thing on the page, and pure
  // white against a blue-shifted canvas reads as a hole rather than as paper.
  static const mistSurface = Color(0xFFFDFEFF);
  static const mistSunken = Color(0xFFEDF0F3);
  static const mistHairline = Color(0xFFE0E5EA);
  static const mistHairlineStrong = Color(0xFFC8D0D7);
  static const mistInkPrimary = Color(0xFF14181C);
  static const mistInkSecondary = Color(0xFF5C656D);
  static const mistInkTertiary = Color(0xFF8A939B);

  static const slateCanvas = Color(0xFF101315);
  static const slateSurface = Color(0xFF171B1E);
  static const slateRaised = Color(0xFF1F2428);
  static const slateSunken = Color(0xFF0A0C0D);
  static const slateHairline = Color(0xFF262C31);
  static const slateHairlineStrong = Color(0xFF373E44);
  static const slateInkPrimary = Color(0xFFEFF3F5);
  static const slateInkSecondary = Color(0xFF9AA4AB);
  static const slateInkTertiary = Color(0xFF656D74);

  // ── Verdant: field and pine ───────────────────────────────────────────
  static const fieldCanvas = Color(0xFFF8FAF7);
  static const fieldSurface = Color(0xFFFCFEFC);
  static const fieldSunken = Color(0xFFEFF2EC);
  static const fieldHairline = Color(0xFFE2E7DD);
  static const fieldHairlineStrong = Color(0xFFCAD2C3);
  static const fieldInkPrimary = Color(0xFF161A14);
  static const fieldInkSecondary = Color(0xFF5E665A);
  static const fieldInkTertiary = Color(0xFF8C9487);

  static const pineCanvas = Color(0xFF111310);
  static const pineSurface = Color(0xFF181B16);
  static const pineRaised = Color(0xFF20241D);
  static const pineSunken = Color(0xFF0B0C0A);
  static const pineHairline = Color(0xFF272B22);
  static const pineHairlineStrong = Color(0xFF383D32);
  static const pineInkPrimary = Color(0xFFF0F4EE);
  static const pineInkSecondary = Color(0xFF9BA395);
  static const pineInkTertiary = Color(0xFF666D61);

  // ── Collection accents ────────────────────────────────────────────────
  // Two steps per brightness: the accent and its pressed state. Every other
  // accent-derived role — washes, selection, hero tints — is computed from
  // these in `design/theme/`, so a new collection is four values and a name.
  //
  // Each is chosen to survive as text on its own canvas at body size, which
  // rules out the bright mid-tones that a seeded palette would produce.

  static const dawnLight = Color(0xFFC1566A);
  static const dawnLightPressed = Color(0xFFA34457);
  static const dawnDark = Color(0xFFE7A2AE);
  static const dawnDarkPressed = Color(0xFFD9838F);

  static const rosewoodLight = Color(0xFF9B3B4E);
  static const rosewoodLightPressed = Color(0xFF7F2E3E);
  static const rosewoodDark = Color(0xFFD98A99);
  static const rosewoodDarkPressed = Color(0xFFC96E80);

  static const oceanLight = Color(0xFF16706E);
  static const oceanLightPressed = Color(0xFF105857);
  static const oceanDark = Color(0xFF7FC4C1);
  static const oceanDarkPressed = Color(0xFF5FADAA);

  static const midnightLight = Color(0xFF32508F);
  static const midnightLightPressed = Color(0xFF264073);
  static const midnightDark = Color(0xFF97AEE0);
  static const midnightDarkPressed = Color(0xFF7A94CE);

  static const frostLight = Color(0xFF4A6A7E);
  static const frostLightPressed = Color(0xFF3A5566);
  static const frostDark = Color(0xFFA8C4D4);
  static const frostDarkPressed = Color(0xFF8BAEC2);

  static const mossLight = Color(0xFF4A6B3F);
  static const mossLightPressed = Color(0xFF3A5531);
  static const mossDark = Color(0xFFA6C398);
  static const mossDarkPressed = Color(0xFF8AAE7A);

  static const nightLight = Color(0xFF5B5580);
  static const nightLightPressed = Color(0xFF474266);
  static const nightDark = Color(0xFFB0A9D6);
  static const nightDarkPressed = Color(0xFF958DC4);

  // ── Photography ───────────────────────────────────────────────────────
  // Type over a photograph is the one place the app cannot control contrast,
  // because it does not own the image. These are fixed across every theme:
  // a photograph is not lighter in light mode.

  /// Names and countdowns set over an image.
  static const onImagePrimary = Color(0xFFFFFFFF);

  /// Relationships and dates set over an image. Warm rather than grey, so it
  /// reads as ink on the same page as the primary.
  static const onImageSecondary = Color(0xFFE6E1DB);

  /// The scrim beneath embedded type, from the top of a hero to its base.
  /// Three stops rather than two: a linear ramp leaves a visible band across
  /// the middle of the picture.
  static const imageScrimClear = Color(0x00000000);
  static const imageScrimSoft = Color(0x1F000000);
  static const imageScrimMid = Color(0x70000000);
  static const imageScrimDeep = Color(0xD6000000);

  /// Cast beneath type sitting on an image, so a light photograph cannot
  /// swallow a white glyph.
  static const onImageShadow = Color(0x8A000000);

  // ── Danger ────────────────────────────────────────────────────────────
  // Cool-shifted so it stays legible as "wrong" beside a warm accent.
  static const dangerLight = Color(0xFF8F2F2F);
  static const dangerWashLight = Color(0xFFF9EDEC);
  static const dangerDark = Color(0xFFE08A82);
  static const dangerWashDark = Color(0xFF2C1D1C);

  // ── Accent washes ─────────────────────────────────────────────────────
  static const accentWashDark = Color(0xFF2A211C);
  static const accentWashVoid = Color(0xFF241C18);

  // ── Text selection ────────────────────────────────────────────────────
  static const selectionLight = Color(0x33BF6039);
  static const selectionDark = Color(0x33E4A585);

  // ── Utility ───────────────────────────────────────────────────────────
  static const transparent = Color(0x00000000);

  // ── Scrims and shadows ────────────────────────────────────────────────
  // Shadows are warm brown-black. Neutral black over a warm canvas reads
  // grey and dirty.
  static const scrimLight = Color(0x52141210);
  static const scrimDark = Color(0x8F000000);
  static const scrimVoid = Color(0xB8000000);
  static const shadowLight = Color(0x0D261E16);
  static const shadowLiftLight = Color(0x14261E16);
  static const shadowDark = Color(0x70000000);
  static const shadowVoid = Color(0x99000000);

  // A card the user can flick sideways sits further off the page than an undo
  // bar does, so it casts a wider and softer shadow.
  static const shadowFloatLight = Color(0x1F261E16);
  static const shadowFloatDark = Color(0x8A000000);
  static const shadowFloatVoid = Color(0xB3000000);

  // ── Monogram tints ────────────────────────────────────────────────────
  // Six warm neutrals for people without a photo. Low chroma on purpose:
  // they should read as paper stock, not as colour-coding.
  static const monogramLight = <Color>[
    Color(0xFFEDE7DF),
    Color(0xFFE9E5DC),
    Color(0xFFEFE6E1),
    Color(0xFFE6E7E1),
    Color(0xFFEEE8E4),
    Color(0xFFE8E4E4),
  ];

  static const monogramDark = <Color>[
    Color(0xFF2B2723),
    Color(0xFF282622),
    Color(0xFF2C2724),
    Color(0xFF262825),
    Color(0xFF2A2725),
    Color(0xFF272525),
  ];
}
