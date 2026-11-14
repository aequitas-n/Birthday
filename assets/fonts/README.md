# Bundled typefaces

`catalog.json` maps registered Flutter family names to local files. See `docs/THEME_TYPOGRAPHY.md` for the product pairings and roles.

`licenses/` contains each newly selected family's upstream license. `sources.json` records the pinned Google Fonts source revision, original URLs, hashes, and sizes. The existing Fraunces, Courier Prime, and Caveat binaries were retained from this repository; Caveat's source record points to the corresponding upstream family while its hash describes the retained local binary.

All runtime font files are registered in `pubspec.yaml`. Tests load these same files instead of relying on system font substitution.

`THIRD_PARTY_LICENSES.txt` consolidates the upstream licenses and is included as an application asset.
