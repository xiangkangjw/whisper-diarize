# WhisperDiarize — macOS App

Native macOS app for the whisper-diarize pipeline. Drag, drop, transcribe, and review speaker-labeled transcripts.

<img width="860" alt="WhisperDiarize screenshot" src="../docs/app-screenshot.png">

## Features

- 🖱️ **Drag & drop** audio files onto the window
- 📊 **Live progress** for transcription, speaker detection, alignment, saving, and polish
- 🎨 **Speaker-colored** transcript with per-speaker filtering
- 🔍 **Search** through the transcript
- 📋 **Copy** to clipboard or **Save** as `.txt`
- ⚙️ **Settings panel** — token, model, language, speaker count, and polish model
- 🧩 **Shared design system** in `AppDesign.swift`
- 🖼️ **Bundled macOS app icon**

## Requirements

- macOS 14+
- Xcode 16+
- `uv` installed for development builds and packaging ([astral.sh/uv](https://docs.astral.sh/uv/))
- HuggingFace token with diarization model access

## Build & Run

```bash
# Open in Xcode
open app/Package.swift

# Or from the app/ directory
cd app
open Package.swift
```

Then **Product → Run** (`⌘R`).

From the command line:

```bash
cd app
swift build
.build/debug/WhisperDiarize
```

Note: SwiftPM builds a raw executable, not a fully packaged `.app`. For Dock/Finder behavior, wrap the executable in an app bundle as described below.

## First Launch

1. Open **Settings** (`⌘,`) and paste your HuggingFace token
2. Make sure you've accepted the model terms:
   - https://huggingface.co/pyannote/speaker-diarization-3.1
   - https://huggingface.co/pyannote/segmentation-3.0
   - https://huggingface.co/pyannote/speaker-diarization-community-1
3. Drag an audio file onto the window

The Python environment is set up automatically on first use (installs into `~/Library/Application Support/WhisperDiarize/`).

Development builds fall back to `uv` when no bundled Python runtime is present. Packaged builds include a bundled Python runtime and locked Python dependencies.

## Packaging

Current packaging flow:

```bash
make package
```

This creates:

```text
dist/WhisperDiarize.app
dist/WhisperDiarize-macos-arm64.zip
```

The packaged app includes:

- release Swift binary
- `Info.plist`
- app icon
- SwiftPM resource bundle
- relocatable uv-managed Python 3.11 runtime at `Contents/Resources/Python`
- locked Python dependencies from `uv.lock`

For distribution outside your own machine, codesign and notarize the `.app` or `.dmg`.

Long term, prefer a dedicated Xcode macOS app target for cleaner archive/sign/notarize workflows.

## GitHub Artifacts

`.github/workflows/macos-app.yml` packages the app on:

- pushes to `main`
- manual workflow runs
- published GitHub releases

The workflow uploads `WhisperDiarize-macos-arm64.zip` as a GitHub Actions artifact. When a GitHub Release is published, the ZIP is attached to that release automatically.

## Architecture

```
App.swift                   @main entry point
ContentView.swift           Root — switches between 4 states
├── AppDesign.swift         design system tokens and shared components
├── DropZoneView.swift      idle: drag & drop + session settings
├── ProcessingView.swift    running: progress + live log stream
├── TranscriptView.swift    done: speaker-colored, searchable transcript
├── ErrorView.swift         failed: error + retry
├── SettingsView.swift      Settings window (⌘,)
└── TranscriptionRunner.swift  ObservableObject — manages subprocess
```

The app bundles `transcribe.py`, `pyproject.toml`, and `uv.lock` as resources, copies them to Application Support on first launch, and runs the Python pipeline as a subprocess via `uv run`.

## Keeping Resources in Sync

When the Python script is updated in the repo root, sync it to the app bundle:

```bash
make sync-app-resources   # from repo root
```
