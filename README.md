# Kin

Kin is an offline-first birthday reminder and relationship-memory companion.
It brings birthdays, people, personal reminders, and a daily journal together,
with local SQLite storage and timezone-aware reminder planning.

## Run locally

```bash
flutter pub get
flutter devices
flutter run -d <device-id>
```

The Android app runs on a connected device or emulator. Its current persistence
and file-storage implementation uses native APIs.

## Build and share

See [the Windows APK and iOS build instructions](docs/BUILD_AND_SHARE.md).
The tested SDK is Flutter 3.47.7 / Dart 3.13.5. Windows users can pull `main`,
run `flutter pub get`, then `flutter build apk --release`.
On macOS, `./tool/build_ios_unsigned.sh` creates a release archive and unsigned IPA.
The iOS package requires signing before it can be installed on an iPhone.

## Illustrated themes

Open **Settings → Theme** to choose an appearance. Default keeps the original
quiet paper design. Seven illustrated collections each have their own palette,
paper surfaces, navigation treatment, animated character, and ambient scene:

- **Vintage Diary:** pressed flowers, burgundy, a rabbit, and steaming tea.
- **Neon Arcade:** matte violet, candy details, a robot, and a cassette player.
- **Retro Postcard:** airmail edges, a traveling fox, and a looping paper plane.
- **Sunday Comics:** butter-yellow panels, bold ink, a pigeon, and dancing mail.
- **Botanical Sketchbook:** sage field notes, a garden frog, and visiting butterflies.
- **Seaside Watercolor:** sea-glass washes, a puffin, and a rocking sailboat.
- **Midnight Storybook:** ink-blue skies, a watchful owl, and a swaying lantern.

Artwork floats through the date area, journal, calendar, and empty states.
Cards grow with live content; controls and writing stay independent of the art.
Animations pause for reduced motion, hidden tabs, and background apps.

Open [the offline artwork gallery](artwork/index.html) in a browser to compare
screens and view the 70 GIF loops and 42 reusable surface PNGs. Source atlases
and backdrops live in `assets/themes/Illustrated/`. The complete generation
prompt set is in [the artwork record](docs/ILLUSTRATED_THEMES_ART.md).

```bash
# Rebuild shareable GIF loops and stills from the bundled atlases.
dart run tool/export_illustrated_gifs.dart

# Refresh screen captures and reusable surface exports from Flutter.
flutter test test/design/illustrated_theme_preview_test.dart \
  --dart-define=EXPORT_THEME_ART=true
```

## Checks

```bash
flutter analyze lib --no-fatal-infos
dart run tool/check_architecture.dart
flutter test --exclude-tags golden
```

The test suite includes theme persistence, navigation, large-text layouts,
contrast, image decoding, journal flows, and reminder behavior. Existing golden
baselines are platform-sensitive and use the Ubuntu CI reference environment.

The original scaffold record is [IMPLEMENTATION_PHASES_0_1.md](IMPLEMENTATION_PHASES_0_1.md).
The broader product and architecture specifications are indexed in
[docs/README.md](docs/README.md).

The [complete screen theme review](artwork/screens/index.html) covers all app routes and feature sheets across the seven illustrated themes. See [the audit record](docs/ALL_SCREEN_THEME_AUDIT.md) for coverage and reproduction commands.

The [typography gallery](artwork/typography/index.html) compares the seven heading/journal pairs and the shared DM Sans / DM Mono UI. See [the type system](docs/THEME_TYPOGRAPHY.md) for roles, metrics, and bundled font sources.
