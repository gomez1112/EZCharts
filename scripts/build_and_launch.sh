#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$ROOT_DIR/Examples/EZChartsDemo/EZChartsDemo.xcodeproj"
SCHEME="${SCHEME:-EZChartsDemo}"
CONFIGURATION="${CONFIGURATION:-Debug}"
SIMULATOR_NAME="${SIMULATOR_NAME:-iPhone 17}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-${TMPDIR:-/tmp}/EZChartsDemo-DerivedData}"
BUNDLE_ID="${BUNDLE_ID:-com.example.EZChartsDemo}"
SCREENSHOT_PATH="$ROOT_DIR/Examples/EZChartsDemo/Screenshots/latest.png"
SCREENSHOT_DELAY="${SCREENSHOT_DELAY:-4}"

mkdir -p "$(dirname "$SCREENSHOT_PATH")"

xcrun simctl boot "$SIMULATOR_NAME" 2>/dev/null || true
xcrun simctl bootstatus "$SIMULATOR_NAME" -b

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination "generic/platform=iOS Simulator" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  build

APP_PATH="$DERIVED_DATA_PATH/Build/Products/$CONFIGURATION-iphonesimulator/$SCHEME.app"

xcrun simctl install booted "$APP_PATH"
xcrun simctl launch booted "$BUNDLE_ID"
sleep "$SCREENSHOT_DELAY"
xcrun simctl io booted screenshot "$SCREENSHOT_PATH"

echo "Launched $SCHEME on $SIMULATOR_NAME"
echo "Screenshot: $SCREENSHOT_PATH"
