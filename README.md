# whisper-diarize

Fast audio transcription with **speaker diarization**, optimized for Apple Silicon (M1/M2/M3/M4).

- 🖥️ **Native macOS app** — drag, drop, transcribe, search, copy, and save
- 🎙️ **Transcription** via [`mlx-whisper`](https://github.com/ml-explore/mlx-examples/tree/main/whisper) — runs on Apple Silicon GPU via MLX
- 👥 **Diarization** via [`pyannote.audio`](https://github.com/pyannote/pyannote-audio) — runs on Metal (MPS)
- ⚡ **Fast** — both models run natively on Apple Silicon, no GPU server needed
- 💾 **Cached** — transcription is cached to `.whisper.json` so retries are instant
- 🌍 **Multilingual** — auto-detects language via Whisper

**Output:**
```
[00:01.20 → 00:05.44]  SPEAKER_00: Hello, welcome to the meeting.
[00:05.45 → 00:12.10]  SPEAKER_01: Thanks for having me, let's get started.
```

---

## Requirements

- macOS with Apple Silicon (M1/M2/M3/M4)
- Python 3.11+
- [`uv`](https://docs.astral.sh/uv/) — for dependency management
- A free [HuggingFace](https://huggingface.co/settings/tokens) account and token
- Xcode 16+ if building the native app

---

## Native macOS App

The SwiftUI app lives in [`app/`](app/). It provides:

- drag and drop audio/video input
- model, language, speaker count, token, and polish settings
- live processing state and logs
- searchable speaker-labeled transcript
- copy and save actions

Run from Xcode:

```bash
open app/Package.swift
```

Then use **Product -> Run**.

Or build from the command line:

```bash
cd app
swift build
```

The app bundles `transcribe.py`, `pyproject.toml`, `uv.lock`, and app icon resources. On first use it copies the Python worker files into:

```text
~/Library/Application Support/WhisperDiarize/
```

Development builds still fall back to `uv` if no bundled Python runtime is present. Packaged builds include a bundled Python runtime and the locked Python dependencies.

---

## Packaging

Build a distributable `.app` and ZIP artifact:

```bash
make package
```

This creates:

```text
dist/WhisperDiarize.app
dist/WhisperDiarize-macos-arm64.zip
```

The package script:

1. Builds the Swift app in release mode
2. Creates a macOS `.app` bundle
3. Copies the app binary, `Info.plist`, app icon, and SwiftPM resources
4. Creates a relocatable uv-managed Python 3.11 environment in `Contents/Resources/Python`
5. Installs the locked Python dependencies into the app bundle
6. Ad-hoc signs the app by default
7. Creates `dist/WhisperDiarize-macos-arm64.zip`

Long term, a dedicated Xcode macOS app target would make archive, signing, icons, and notarization cleaner than manually wrapping a SwiftPM executable.

Important: packaged builds bundle Python and Python dependencies, but Whisper, pyannote, and LLM model weights are still downloaded on first use.

### GitHub Builds

GitHub Actions builds the packaged macOS app on pushes to `main`, manual workflow runs, and published GitHub releases:

- workflow: `.github/workflows/macos-app.yml`
- artifact: `WhisperDiarize-macos-arm64.zip`
- release asset: attached automatically when a GitHub Release is published

Release builds are ad-hoc signed by default. Use a Developer ID certificate and notarization for broad distribution outside your own machines.

---

## CLI Setup

**1. Clone and install dependencies**

```bash
git clone https://github.com/xiangkangjw/whisper-diarize.git
cd whisper-diarize
uv sync
```

**2. Create your `.env` file**

```bash
cp .env.example .env
```

Then open `.env` and paste your HuggingFace token:

```
HF_TOKEN=hf_xxxxxxxxxxxxxxxx
```

Get a free token at: https://huggingface.co/settings/tokens

**3. Accept model terms on HuggingFace** *(one-time, takes 30 seconds)*

- https://huggingface.co/pyannote/speaker-diarization-3.1
- https://huggingface.co/pyannote/segmentation-3.0
- https://huggingface.co/pyannote/speaker-diarization-community-1

---

## Usage

```bash
# Basic — auto-detects language and number of speakers
uv run transcribe.py path/to/audio.wav

# Faster — specify number of speakers if you know it
uv run transcribe.py path/to/audio.wav --speakers 2

# Specify language (skips auto-detection)
uv run transcribe.py path/to/audio.wav --language en

# Custom output path
uv run transcribe.py path/to/audio.wav --output my_transcript.txt

# Pass HF token directly instead of .env
uv run transcribe.py path/to/audio.wav --hf-token hf_xxxx
```

Supported audio formats: `wav`, `mp3`, `m4a`, `mp4`, `flac`, `ogg`, and more.

---

## Options

| Flag | Default | Description |
|------|---------|-------------|
| `--model` | `mlx-community/whisper-large-v3-mlx` | MLX Whisper model to use |
| `--language` | auto-detect | Language code (`en`, `zh`, `es`, …) |
| `--speakers` | auto-detect | Number of speakers in the audio |
| `--output` | `<audio>_transcript.txt` | Output file path |
| `--hf-token` | reads `HF_TOKEN` from `.env` | HuggingFace token |

**Available models** (faster → more accurate):

| Model | HuggingFace repo |
|-------|-----------------|
| tiny | `mlx-community/whisper-tiny-mlx` |
| base | `mlx-community/whisper-base-mlx` |
| small | `mlx-community/whisper-small-mlx` |
| medium | `mlx-community/whisper-medium-mlx` |
| large-v3 *(default)* | `mlx-community/whisper-large-v3-mlx` |
| large-v3-turbo | `mlx-community/whisper-large-v3-turbo` |

---

## How it works

```
Audio file
    │
    ▼
mlx-whisper ──► word-level timestamps + text   (Apple Silicon GPU / MLX)
    │
    ├──► cached to <audio>.whisper.json
    │
pyannote ────► speaker segments (who spoke when)   (Metal / MPS)
    │
    ▼
merge: assign each word to a speaker
    │
    ▼
transcript with timestamps + speaker labels
```

---

## License

MIT
