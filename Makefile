APP_RESOURCES = app/Sources/WhisperDiarize/Resources

.PHONY: sync-app-resources test test-ui

sync-app-resources:
	cp transcribe.py   $(APP_RESOURCES)/transcribe.py
	cp pyproject.toml  $(APP_RESOURCES)/pyproject.toml
	cp uv.lock         $(APP_RESOURCES)/uv.lock
	@echo "✅ App resources synced"

# Run unit tests (no Xcode required)
test:
	cd app && swift test --filter WhisperDiarizeTests

# Run UI tests (requires: open app/Package.swift in Xcode once to generate schemes)
test-ui:
	cd app && xcodebuild test \
		-scheme WhisperDiarize \
		-destination 'platform=macOS,arch=arm64' \
		-only-testing:WhisperDiarizeUITests \
		2>&1 | grep -E 'Test Case|passed|failed|error'
