APP_RESOURCES = app/Sources/WhisperDiarize/Resources

.PHONY: sync-app-resources test test-ui run package

# Build a proper .app bundle, ad-hoc sign it, and launch
run:
	cd app && swift build
	@mkdir -p app/.build/WhisperDiarize.app/Contents/MacOS
	@mkdir -p app/.build/WhisperDiarize.app/Contents/Resources
	cp app/.build/debug/WhisperDiarize app/.build/WhisperDiarize.app/Contents/MacOS/
	cp app/Sources/WhisperDiarize/Info.plist app/.build/WhisperDiarize.app/Contents/
	@cp -r app/.build/debug/WhisperDiarize_WhisperDiarize.bundle app/.build/WhisperDiarize.app/Contents/Resources/ 2>/dev/null || true
	codesign --force --deep --sign - app/.build/WhisperDiarize.app
	open app/.build/WhisperDiarize.app

# Build dist/WhisperDiarize.app and dist/WhisperDiarize-macos-arm64.zip.
# By default this embeds a relocatable Python environment and dependencies.
package:
	scripts/package-macos.sh

sync-app-resources:
	cp transcribe.py   $(APP_RESOURCES)/transcribe.py
	cp pyproject.toml  $(APP_RESOURCES)/pyproject.toml
	cp uv.lock         $(APP_RESOURCES)/uv.lock
	@echo "✅ App resources synced"

# Run unit tests (no Xcode required, CI-friendly)
test:
	cd app && swift test --filter WhisperDiarizeTests

# Run UI tests — requires opening app/Package.swift in Xcode first, then ⌘U
# xcodebuild cannot produce a .app bundle from a Swift Package without Xcode's scheme
test-ui:
	@echo "ℹ️  Open app/Package.swift in Xcode and press ⌘U to run UI tests"
