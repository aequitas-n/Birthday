# Kin artwork library

Open `index.html` in a browser for the interactive offline gallery.

- `screens/index.html`: full app review by theme and screen, including sheets, editors, empty states, and scrolled sections.
- `previews/`: seven captures of the real Flutter Today screen.
- `animated/<theme>/`: nine four-frame character loops and one four-frame ambient scene per theme; 70 transparent GIFs in total.
- `stills/<theme>/`: PNG first poses for paused previews.
- `surfaces/<theme>/`: card, calendar, navigation, search, profile, and birthday-tag PNGs, rendered from the actual Flutter surface painters.

The app renders the original PNG sprite atlases with full alpha and explicit pause behavior. GIF exports use the same four poses and timing; GIF transparency is binary by format.

Original generated backgrounds, characters, and scenes are bundled under `assets/themes/Illustrated/`. Surfaces are resolution-independent Flutter drawings. Typography and controls remain live widgets.

Regenerate exports with the commands in the root README. Art directions and exact prompts are recorded in `docs/ILLUSTRATED_THEMES_ART.md`.

Screen coverage and audit corrections are recorded in `docs/ALL_SCREEN_THEME_AUDIT.md`. Regenerate the app captures with `flutter test test/design/all_screens_theme_audit_test.dart --dart-define=EXPORT_THEME_AUDIT=true`.

- `typography/index.html`: interactive specimens for each theme pair, with editable journal samples and actual Flutter screen captures.
