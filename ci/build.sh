#!/usr/bin/env bash
set -euo pipefail

# This script replaces export presets only in a disposable Actions checkout.
if [[ "${GITHUB_ACTIONS:-}" != "true" ]]; then
  echo "Run this script through the GitHub Actions build workflow." >&2
  exit 1
fi

: "${RUNNER_TEMP:?Missing runner temporary directory}"
: "${JAVA_HOME:?Missing Java SDK}"
: "${ANDROID_HOME:?Missing Android SDK}"
: "${XDG_CONFIG_HOME:?Missing isolated Godot settings directory}"
: "${GODOT_VERSION:?Missing Godot version}"

cd "$(dirname "${BASH_SOURCE[0]}")/.."
cp ci/export-presets.cfg export_presets.cfg
mkdir -p build/windows build/android "$XDG_CONFIG_HOME/godot"

# Always create a new debug key on the runner, outside the exported project.
key_directory="$(mktemp -d "$RUNNER_TEMP/bladegamblers-signing.XXXXXX")"
export GODOT_ANDROID_KEYSTORE_DEBUG_PATH="$key_directory/debug.keystore"
export GODOT_ANDROID_KEYSTORE_DEBUG_USER="androiddebugkey"
export GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD="android"
keytool -genkeypair -noprompt -storetype JKS \
  -keystore "$GODOT_ANDROID_KEYSTORE_DEBUG_PATH" \
  -alias "$GODOT_ANDROID_KEYSTORE_DEBUG_USER" \
  -storepass "$GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD" \
  -keypass "$GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD" \
  -dname "CN=Android Debug,O=Android,C=US" \
  -keyalg RSA -keysize 2048 -validity 10000

IFS='.' read -r godot_major godot_minor godot_patch <<< "$GODOT_VERSION"
cat > "$XDG_CONFIG_HOME/godot/editor_settings-${godot_major}.${godot_minor}.tres" <<EOF
[gd_resource type="EditorSettings" format=3]

[resource]
export/android/java_sdk_path = "$JAVA_HOME"
export/android/android_sdk_path = "$ANDROID_HOME"
EOF

# Import first so a clean checkout has textures and a populated UID cache.
godot --headless --path . --editor --import
godot --headless --path . --export-release "Windows Desktop" build/windows/BladeGamblers.exe
godot --headless --path . --export-debug "Android" build/android/BladeGamblers-debug.apk

test -s build/windows/BladeGamblers.exe
test -s build/android/BladeGamblers-debug.apk
"$ANDROID_HOME/build-tools/35.0.1/apksigner" verify build/android/BladeGamblers-debug.apk
