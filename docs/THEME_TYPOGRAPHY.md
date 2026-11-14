# Seven voices, one familiar app

All current themes, including Default, use **DM Sans** for buttons, navigation, form controls, and ordinary interface copy, and **DM Mono** for dates, counts, timestamps, and small metadata. Their labels, actions, navigation order, accessibility behavior, and control sizes are shared.

Each illustrated theme has an individual heading and journal pair. The primary theme face defines headings and identity; the secondary theme face defines personal writing and journal prompts.

| Theme | Primary theme face: headings | Secondary theme face: journal | Treatment |
| --- | --- | --- | --- |
| Vintage Diary | Cormorant Garamond | Caveat | Bookish, heavier editorial headings; generous handwritten text |
| Neon Arcade | Chakra Petch | Space Mono | Angular semibold headings; smaller monospace prose with extra leading |
| Retro Postcard | DM Serif Display | Special Elite | Rounded editorial titles; loose typewritten memories |
| Sunday Comics | Bangers | Comic Neue | Large, slightly tracked comic headings; relaxed reading text |
| Botanical Sketchbook | Lora | Kalam | Measured field-guide headings; informal pencilled writing |
| Seaside Watercolor | Bree Serif | Patrick Hand | Soft rounded serif headings; open handwritten prose |
| Midnight Storybook | Cinzel | Crimson Pro | Restrained storybook headings; larger literary reading text |

Default retains Fraunces headings and Courier Prime personal writing, with the same DM Sans / DM Mono functional UI as the illustrated collections.

The [interactive type gallery](../artwork/typography/index.html) shows the bundled faces, editable samples, and actual Flutter screens. The [screen review](../artwork/screens/index.html) includes all 336 captures.

## Implementation

- `QuietTypography` exposes semantic roles so screens consume the active type system consistently.
- `ThemeTypography` defines the current pairings and their optical sizes, weights, tracking, and leading. Headings range from 29px for wide Cinzel to 38px for compact Bangers. Journal text ranges from 17px Space Mono to 23px handwriting; UI controls remain consistent.
- Fraunces-specific optical axes are applied only to Fraunces. Other fonts use their registered family and weight.
- Invitations use the active optical scale instead of overriding every theme to the same size and leading. Theme previews show both expressive faces.
- Fonts are local assets registered in `pubspec.yaml`; no runtime font downloads or external font dependency is used. `assets/fonts/catalog.json` is also used by tests to load the same real fonts as the app.
- The internal legacy `QuietTypeExpression.primaryFamily` name still identifies the personal/journal face and `secondaryFamily` the editorial face. Current code can use the explicit `headingFamily` and `journalFamily` getters instead.

## Sources and validation

New fonts and their licenses were downloaded from the [official Google Fonts repository](https://github.com/google/fonts). `assets/fonts/sources.json` records the pinned revision, download URLs, file sizes, and SHA-256 hashes; licenses are kept in `assets/fonts/licenses/`. Existing bundled font binaries were retained.

Typography tests assert distinct heading pairs, shared functional UI, local asset availability, reading sizes, tabular numeric features, and appropriate variable-font axes. The full screen audit renders actual feature widgets at normal size and at 320 × 640 with enlarged text; it includes sheets, fields, keyboard insets, and lower sections. Platform-specific golden baselines are separate.

Validation after the update: **333 non-golden tests pass**, including the complete screen/viewport matrix and typography contract checks. The architecture guard passes across 210 files. The full-project strict analyzer passes with no findings.
