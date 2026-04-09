#!/bin/bash

set -e

APP_NAME="ble1"
TEAM_ID="M8WDKS4RM5"
CERT_NAME="Developer ID Application: Jason Taylor ($TEAM_ID)"
NOTARY_PROFILE="notary-profile"

echo "🔨 Building macOS release..."
flutter clean
flutter build macos --release

cd build/macos/Build/Products/Release

echo "🧹 Removing old signatures..."
codesign --remove-signature "$APP_NAME.app" || true

echo "🔐 Signing frameworks..."
for f in "$APP_NAME.app"/Contents/Frameworks/*.framework; do
  [ -e "$f" ] || continue
  codesign -s "$CERT_NAME" --force --options runtime --timestamp "$f"
done

echo "🔐 Signing dylibs..."
for f in "$APP_NAME.app"/Contents/Frameworks/*.dylib; do
  [ -e "$f" ] || continue
  codesign -s "$CERT_NAME" --force --options runtime --timestamp "$f"
done

echo "🔐 Signing main executable..."
codesign -s "$CERT_NAME" --force --options runtime --timestamp \
"$APP_NAME.app/Contents/MacOS/$APP_NAME"

echo "🔐 Signing app bundle..."
codesign -s "$CERT_NAME" --force --options runtime --timestamp "$APP_NAME.app"

echo "🔎 Verifying local signature..."
codesign --verify --deep --strict --verbose=2 "$APP_NAME.app"

echo "📦 Creating zip..."
ditto -c -k --keepParent "$APP_NAME.app" "$APP_NAME.zip"

echo "☁️ Submitting for notarization..."
xcrun notarytool submit "$APP_NAME.zip" \
--keychain-profile "$NOTARY_PROFILE" \
--wait

echo "📎 Stapling..."
xcrun stapler staple "$APP_NAME.app"

echo "🔎 Final Gatekeeper check..."
spctl -a -t exec -vv "$APP_NAME.app"

echo ""
echo "✅ DONE — Ready for distribution"
