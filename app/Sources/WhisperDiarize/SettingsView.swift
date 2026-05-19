import SwiftUI

struct SettingsView: View {
    @AppStorage("hfToken")   private var hfToken = ""
    @AppStorage("model")     private var model = "mlx-community/whisper-large-v3-mlx"
    @AppStorage("language")  private var language = ""
    @AppStorage("speakers")  private var speakersRaw = 0
    @AppStorage("polish")    private var polish = false
    @AppStorage("polishModel") private var polishModel = "mlx-community/Qwen2.5-1.5B-Instruct-4bit"

    var body: some View {
        Form {
            Section {
                LabeledContent("HuggingFace Token") {
                    SecureField("hf_xxxxxxxxxxxxxxxx", text: $hfToken)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 280)
                }

                LabeledContent("") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Required for speaker diarization.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Link("Get a free token →",
                             destination: URL(string: "https://huggingface.co/settings/tokens")!)
                            .font(.caption)
                        Link("Accept diarization model terms →",
                             destination: URL(string: "https://huggingface.co/pyannote/speaker-diarization-3.1")!)
                            .font(.caption)
                    }
                }
            } header: {
                Text("Authentication")
            }

            Section {
                Picker("Whisper Model", selection: $model) {
                    Group {
                        Text("── Multilingual (99+ languages) ──").disabled(true)
                        Text("large-v3 (best multilingual, ~3GB)")
                            .tag("mlx-community/whisper-large-v3-mlx")
                        Text("large-v3-turbo (2× faster, ~1.5GB)")
                            .tag("mlx-community/whisper-large-v3-turbo")
                        Text("medium (~1.5GB)")
                            .tag("mlx-community/whisper-medium-mlx")
                        Text("small (fastest, ~500MB)")
                            .tag("mlx-community/whisper-small-mlx")
                    }
                    Group {
                        Text("── Chinese-Optimised ──").disabled(true)
                        Text("Breeze-ASR-25 — Chinese-English code-switching")
                            .tag("Kenji8000/Breeze-ASR-25-mlx")
                    }
                }

                LabeledContent("Language") {
                    HStack {
                        TextField("Auto-detect", text: $language)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                        Text("e.g. en, zh, es, fr")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                LabeledContent("Speakers") {
                    HStack {
                        Picker("", selection: $speakersRaw) {
                            Text("Auto-detect").tag(0)
                            ForEach(1...8, id: \.self) { n in
                                Text("\(n)").tag(n)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 120)
                        Text("Providing a count improves accuracy")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Transcription")
            }

            Section {
                Toggle(isOn: $polish) {
                    Label("Polish with LLM", systemImage: "sparkles")
                }
                if polish {
                    Picker("LLM Model", selection: $polishModel) {
                        Text("Qwen2.5-1.5B (fast, ~1GB)").tag("mlx-community/Qwen2.5-1.5B-Instruct-4bit")
                        Text("Qwen2.5-3B (better, ~2GB)").tag("mlx-community/Qwen2.5-3B-Instruct-4bit")
                        Text("Qwen2.5-7B (best, ~4GB)").tag("mlx-community/Qwen2.5-7B-Instruct-4bit")
                    }
                    LabeledContent("") {
                        Text("Adds punctuation and cleans up the final transcript using a local LLM. First run downloads the model.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Polish (LLM Post-processing)")
            }

            Section {
                LabeledContent("uv") {
                    Text(findUV() ?? "Not found — install from astral.sh/uv")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(findUV() == nil ? .red : .secondary)
                }
            } header: {
                Text("Environment")
            }
        }
        .formStyle(.grouped)
        .frame(width: 520)
        .padding()
    }

    private func findUV() -> String? {
        let candidates = [
            "/opt/homebrew/bin/uv",
            "/usr/local/bin/uv",
            "\(NSHomeDirectory())/.local/bin/uv",
            "\(NSHomeDirectory())/.cargo/bin/uv",
        ]
        return candidates.first { FileManager.default.isExecutableFile(atPath: $0) }
    }
}
