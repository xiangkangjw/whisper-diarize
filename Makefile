APP_RESOURCES = app/Sources/WhisperDiarize/Resources

.PHONY: sync-app-resources test test-ui

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
