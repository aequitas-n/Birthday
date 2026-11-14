#!/usr/bin/env bash
# Build a release archive and an unsigned IPA for later signing on macOS.
set -euo pipefail

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
flutter_bin="${FLUTTER_BIN:-flutter}"
cd "$project_root"
build_name="$(sed -nE 's/^version:[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+).*$/\1/p' pubspec.yaml)"
if [[ -z "$build_name" ]]; then
  printf '%s\n' 'Cannot read the numeric iOS version from pubspec.yaml.' >&2
  exit 1
fi

# Apple requires a numeric marketing version; do not turn 1.0.0-rc1 into 1.0.01.
"$flutter_bin" build ipa --release --no-codesign --build-name="$build_name" "$@"
app_path="$project_root/build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app"
if [[ ! -d "$app_path" ]]; then
  printf '%s\n' 'Runner.app was not found in the release archive.' >&2
  exit 1
fi

output_dir="$project_root/build/ios/unsigned"
mkdir -p "$output_dir"
stage_dir="$(mktemp -d "$output_dir/package.XXXXXX")"
trap 'rm -rf -- "$stage_dir"' EXIT
mkdir -p "$stage_dir/Payload"
ditto "$app_path" "$stage_dir/Payload/Runner.app"
ipa_name="Kin-${build_name}-unsigned.ipa"
ditto -c -k --keepParent "$stage_dir/Payload" "$output_dir/$ipa_name"
(
  cd "$output_dir"
  shasum -a 256 "$ipa_name" > "$ipa_name.sha256"
)
printf '\n%s\n' "Unsigned IPA: $output_dir/$ipa_name"
printf '%s\n' 'This file requires signing before installation on an iPhone.'
