#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/app"
DIST_DIR="$ROOT_DIR/dist"
APP_NAME="WhisperDiarize"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
ZIP_PATH="$DIST_DIR/$APP_NAME-macos-arm64.zip"
CONFIGURATION="${CONFIGURATION:-release}"
PYTHON_VERSION="${PYTHON_VERSION:-3.11}"
CODESIGN_IDENTITY="${CODESIGN_IDENTITY:--}"
BUNDLE_PYTHON="${BUNDLE_PYTHON:-1}"

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "error: required tool '$1' was not found" >&2
    exit 1
  fi
}

require_tool swift
require_tool codesign
require_tool ditto

if [[ "$BUNDLE_PYTHON" == "1" ]]; then
  require_tool uv
fi

rm -rf "$DIST_DIR"
mkdir -p "$APP_BUNDLE/Contents/MacOS" "$APP_BUNDLE/Contents/Resources"

echo "==> Building Swift app ($CONFIGURATION)"
pushd "$APP_DIR" >/dev/null
swift build -c "$CONFIGURATION"
BIN_DIR="$(swift build -c "$CONFIGURATION" --show-bin-path)"
popd >/dev/null

echo "==> Creating app bundle"
cp "$BIN_DIR/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
cp "$APP_DIR/Sources/WhisperDiarize/Info.plist" "$APP_BUNDLE/Contents/Info.plist"
cp "$APP_DIR/Sources/WhisperDiarize/Resources/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/AppIcon.icns"

RESOURCE_BUNDLE="$BIN_DIR/${APP_NAME}_WhisperDiarize.bundle"
if [[ ! -d "$RESOURCE_BUNDLE" ]]; then
  RESOURCE_BUNDLE="$BIN_DIR/${APP_NAME}_${APP_NAME}.bundle"
fi

if [[ ! -d "$RESOURCE_BUNDLE" ]]; then
  echo "error: SwiftPM resource bundle was not found in $BIN_DIR" >&2
  exit 1
fi

cp -R "$RESOURCE_BUNDLE" "$APP_BUNDLE/Contents/Resources/"
cp -R "$RESOURCE_BUNDLE" "$APP_BUNDLE/"

if [[ "$BUNDLE_PYTHON" == "1" ]]; then
  PYTHON_ENV="$APP_BUNDLE/Contents/Resources/Python"
  REQUIREMENTS_FILE="$DIST_DIR/requirements.txt"

  echo "==> Exporting locked Python dependencies"
  uv export \
    --project "$ROOT_DIR" \
    --frozen \
    --no-dev \
    --no-emit-project \
    --format requirements.txt \
    --output-file "$REQUIREMENTS_FILE" \
    >/dev/null

  echo "==> Creating bundled Python runtime ($PYTHON_VERSION)"
  uv venv \
    --clear \
    --relocatable \
    --managed-python \
    --python "$PYTHON_VERSION" \
    "$PYTHON_ENV"

  echo "==> Installing Python dependencies into app bundle"
  uv pip install \
    --python "$PYTHON_ENV/bin/python" \
    --requirements "$REQUIREMENTS_FILE" \
    --link-mode copy \
    --compile-bytecode

  "$PYTHON_ENV/bin/python" - <<'PY'
import platform
import sys
print(f"Bundled Python: {sys.version.split()[0]} ({platform.machine()})")
PY
fi

echo "==> Codesigning app bundle"
codesign --force --deep --options runtime --sign "$CODESIGN_IDENTITY" "$APP_BUNDLE"

echo "==> Creating ZIP artifact"
rm -f "$ZIP_PATH"
ditto -c -k --keepParent "$APP_BUNDLE" "$ZIP_PATH"

echo "Packaged:"
echo "  $APP_BUNDLE"
echo "  $ZIP_PATH"
