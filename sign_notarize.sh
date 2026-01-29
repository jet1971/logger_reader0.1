#!/usr/bin/env bash
set -euo pipefail

# ==== configure (YOUR values) ====
TEAMID="M8WDKS4RM5"
APPLE_ID="jay@jtmc.co.uk"
KEYCHAIN_PROFILE="JT-Notary"              # notarytool profile nickname (one-time setup)
APP_NAME="ble1"                           # .app name without .app
CERT_NAME="Developer ID Application: Jason Taylor (M8WDKS4RM5)"
ENTS_PATH="macos/Runner/Release.entitlements"
APP_PATH="build/macos/Build/Products/Release/${APP_NAME}.app"
# ==================================

# --- bump build number in pubspec.yaml ---
echo "👉 Bumping build number in pubspec.yaml…"
CURRENT_LINE="$(grep -E '^version:' pubspec.yaml | head -n1 || true)"
if [[ -z "$CURRENT_LINE" ]]; then
  echo "❌ Could not find a 'version:' line in pubspec.yaml"; exit 1
fi
CURRENT_VER="${CURRENT_LINE#version: }"

BASE_VER="${CURRENT_VER%%+*}"        # part before '+'
if [[ "$CURRENT_VER" == *"+"* ]]; then
  BUILD="${CURRENT_VER#*+}"
  if ! [[ "$BUILD" =~ ^[0-9]+$ ]]; then
    echo "⚠️  Non-numeric build '$BUILD' — resetting to +1"; BUILD=0
  fi
else
  BUILD=0
fi
NEW_BUILD=$((BUILD + 1))
NEW_VER="${BASE_VER}+${NEW_BUILD}"

# in-place edit (portable)
perl -0777 -pe "s/^version:\s*.*/version: ${NEW_VER}/m" -i pubspec.yaml

echo "   version: ${CURRENT_VER}  ➜  ${NEW_VER}"

# --- build release ---
echo "👉 Building Release…"
flutter build macos --release

# sanity: entitlements present
[ -f "$ENTS_PATH" ] || { echo "❌ Missing $ENTS_PATH"; exit 1; }

# --- sign with Developer ID + Hardened Runtime ---
echo "👉 Codesigning with Developer ID + Hardened Runtime…"
codesign --deep --force --options runtime --timestamp \
  --entitlements "$ENTS_PATH" \
  --sign "$CERT_NAME" \
  "$APP_PATH"

echo "👉 Verifying signature…"
codesign --verify --deep --strict --verbose=2 "$APP_PATH"
spctl -a -vv "$APP_PATH" || true

# --- zip and name with version ---
ZIP_NAME="${APP_NAME}_${NEW_VER}.zip"
echo "👉 Zipping for notarization: ${ZIP_NAME}"
rm -f "$ZIP_NAME"
ditto -c -k --keepParent "$APP_PATH" "$ZIP_NAME"

# --- notarize ---
if ! xcrun notarytool history --keychain-profile "$KEYCHAIN_PROFILE" >/dev/null 2>&1; then
  echo "ℹ️  First-time notary credentials setup needed."
  echo "   Get an app-specific password from https://appleid.apple.com"
  xcrun notarytool store-credentials "$KEYCHAIN_PROFILE" \
    --apple-id "$APPLE_ID" \
    --team-id "$TEAMID" \
    --password "hsyh-lbev-knfs-ifjg"   # app-specific password
fi

echo "👉 Submitting to Apple notarization (please wait)…"
xcrun notarytool submit "$ZIP_NAME" --keychain-profile "$KEYCHAIN_PROFILE" --wait

# --- staple ---
echo "👉 Stapling notarization ticket…"
xcrun stapler staple "$APP_PATH"
xcrun stapler validate "$APP_PATH"

echo "✅ Done!"
echo "   App: $APP_PATH"
echo "   Zip: $ZIP_NAME"
