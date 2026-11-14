# Build and share Kin

The current source and dependency lockfile are tested with **Flutter 3.47.7 / Dart 3.13.5**. The lockfile requires Flutter 3.47 or newer. Fonts and artwork are bundled locally.

## Windows: pull and build an APK

With Flutter and the Android SDK configured, open PowerShell in your Birthday checkout:

```powershell
git switch main
git pull --ff-only origin main
flutter pub get
flutter build apk --release
```

The APK is written to:

```text
build\app\outputs\flutter-apk\app-release.apk
```

For smaller per-architecture APKs:

```powershell
flutter build apk --release --split-per-abi
```

Current RC1 Android release builds use the debug signing configuration for sideload testing. A production Play Store release needs your release keystore. Keep signing keys and local SDK paths outside Git.

## macOS: unsigned iOS archive and IPA

No Apple account is needed to compile an unsigned release. Run:

```bash
flutter pub get
./tool/build_ios_unsigned.sh
```

If Flutter is not on PATH, set its executable for the command:

```bash
FLUTTER_BIN=/path/to/flutter/bin/flutter ./tool/build_ios_unsigned.sh
```

Outputs:

- `build/ios/archive/Runner.xcarchive`: Xcode release archive.
- `build/ios/unsigned/Kin-1.0.0-unsigned.ipa`: package for later signing.
- The adjacent `.sha256` file verifies the IPA download.

The script reads the numeric marketing version from `pubspec.yaml`, preserving the build number. The current RC version therefore becomes iOS **1.0.0 (4)**. The current iOS minimum is **15.0**. Xcode resolves Flutter plugins through Swift Package Manager.

**Unsigned does not mean directly installable:** this IPA can be transferred to someone who will sign it, but cannot simply be installed on a normal iPhone. For TestFlight distribution, configure the Apple Developer team and upload a signed build. For Ad Hoc distribution, Apple requires a distribution certificate and a provisioning profile containing the registered test devices. See Apple's [TestFlight guide](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/) and [Ad Hoc profile requirements](https://developer.apple.com/help/account/provisioning-profiles/create-an-ad-hoc-provisioning-profile/).

For a signed build, open `ios/Runner.xcworkspace` in Xcode, choose your team under Runner → Signing & Capabilities, and build/export using the intended distribution method. Signing credentials are intentionally not part of this repository.

Build outputs stay under the ignored `build/` directory; source, font licenses, review galleries, and build scripts are in Git.

## Visual test baselines

The normal CI workflow compares golden images on Ubuntu. After intentional visual changes, the manually dispatched **Refresh golden baselines** workflow renders replacement PNGs on that same reference platform and uploads them as the `golden-baselines` artifact. Review and commit those PNGs; the normal comparison remains unchanged.

The generated-source CI check formats the generator output with the project SDK before comparing it with the checked-in Dart files, so generated code and the formatting check use the same conventions.
