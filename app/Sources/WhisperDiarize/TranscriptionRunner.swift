import Foundation
import SwiftUI
import WhisperDiarizeCore

// Models are now in WhisperDiarizeCore (TranscriptLine, RunnerState)

// MARK: - Runner

@MainActor
final class TranscriptionRunner: ObservableObject {
    @Published var state: RunnerState = .idle
    @Published var logLines: [String] = []
    @Published var transcript: [TranscriptLine] = []
    @Published var currentStep: Int = 0          // 0=transcribe 1=diarize 2=merge 3=save
    @Published var stepDetails: [Int: String] = [:] // extra info per step (e.g. language)
    @Published var stepProgress: [Int: Double] = [:] // 0.0–1.0 per step
    @Published var startTime: Date? = nil

    private var process: Process?

    // MARK: - Public API

    func transcribe(audioURL: URL, hfToken: String, model: String, language: String, speakers: Int?) async {
        state = .running(phase: "Preparing…")
        logLines = []
        transcript = []
        currentStep = 0
        stepDetails = [:]
        stepProgress = [:]
        startTime = Date()

        guard let uvPath = findUV() else {
            state = .failed("uv not found.\nInstall it from https://docs.astral.sh/uv/ and relaunch the app.")
            return
        }

        guard let workDir = prepareWorkDir() else {
            state = .failed("Could not set up working directory in Application Support.")
            return
        }

        let scriptPath = workDir.appendingPathComponent("transcribe.py").path
        let outputURL = workDir
            .appendingPathComponent(audioURL.deletingPathExtension().lastPathComponent + "_transcript.txt")

        var args: [String] = [
            "run", "--project", workDir.path,
            scriptPath,
            audioURL.path,
            "--output", outputURL.path,
            "--model", model,
        ]
        if !hfToken.isEmpty   { args += ["--hf-token", hfToken] }
        if !language.isEmpty  { args += ["--language", language] }
        if let n = speakers   { args += ["--speakers", String(n)] }

        let p = Process()
        p.executableURL = URL(fileURLWithPath: uvPath)
        p.arguments = args
        p.currentDirectoryURL = workDir
        p.environment = enrichedEnv()

        let outPipe = Pipe()
        let errPipe = Pipe()
        p.standardOutput = outPipe
        p.standardError = errPipe

        for pipe in [outPipe, errPipe] {
            pipe.fileHandleForReading.readabilityHandler = { [weak self] fh in
                let data = fh.availableData
                guard !data.isEmpty, let text = String(data: data, encoding: .utf8) else { return }
                let lines = text
                    .components(separatedBy: CharacterSet(charactersIn: "\n\r"))
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
                Task { @MainActor [weak self] in self?.ingest(lines) }
            }
        }

        self.process = p

        await withCheckedContinuation { cont in
            p.terminationHandler = { [weak self] proc in
                Task { @MainActor [weak self] in
                    outPipe.fileHandleForReading.readabilityHandler = nil
                    errPipe.fileHandleForReading.readabilityHandler = nil
                    if proc.terminationStatus == 0 {
                        self?.loadTranscript(from: outputURL)
                        self?.state = .done
                    } else {
                        self?.state = .failed("Process exited with code \(proc.terminationStatus).\nCheck the log above for details.")
                    }
                    cont.resume()
                }
            }
            do {
                try p.run()
            } catch {
                Task { @MainActor [weak self] in
                    self?.state = .failed(error.localizedDescription)
                    cont.resume()
                }
            }
        }
    }

    func cancel() {
        process?.terminate()
        process = nil
        state = .idle
        currentStep = 0
        stepDetails = [:]
        stepProgress = [:]
        startTime = nil
    }

    func reset() {
        process = nil
        state = .idle
        logLines = []
        transcript = []
        currentStep = 0
        stepDetails = [:]
        stepProgress = [:]
        startTime = nil
    }

    // MARK: - Log ingestion

    private func ingest(_ lines: [String]) {
        for line in lines {
            logLines.append(line)

            // Structured progress from Python: "APP_PROGRESS step=0 pct=45"
            if line.hasPrefix("APP_PROGRESS") {
                let parts = line.split(separator: " ")
                if let stepPart = parts.first(where: { $0.hasPrefix("step=") }),
                   let pctPart  = parts.first(where: { $0.hasPrefix("pct=")  }),
                   let step = Int(stepPart.dropFirst(5)),
                   let pct  = Double(pctPart.dropFirst(4)) {
                    stepProgress[step] = pct / 100.0
                    if pct >= 100 && step < 3 { currentStep = step + 1 }
                }
                continue
            }

            if line.contains("Transcribing") {
                currentStep = 0
                state = .running(phase: "Transcribing audio…")
            } else if line.contains("cached transcription") {
                stepProgress[0] = 1.0
                stepDetails[0] = "Loaded from cache"
                currentStep = 1
                state = .running(phase: "Identifying speakers…")
            } else if line.contains("Detected language") {
                if let lang = line.components(separatedBy: ":").last?.trimmingCharacters(in: .whitespaces) {
                    stepDetails[0] = "Language: \(lang)"
                }
            } else if line.contains("diarization") || line.contains("Diarization") {
                currentStep = 1
                state = .running(phase: "Identifying speakers…")
            } else if line.contains("Merging") {
                currentStep = 2
                state = .running(phase: "Merging results…")
            } else if line.contains("Saved to") {
                state = .running(phase: "Saving…")
            }
        }
    }

    // MARK: - Transcript parsing

    private func loadTranscript(from url: URL) {
        guard let content = try? String(contentsOf: url, encoding: .utf8) else { return }
        transcript = parseTranscript(content)
    }

    // MARK: - Setup helpers

    private func prepareWorkDir() -> URL? {
        guard let appSupport = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return nil }
        let dir = appSupport.appendingPathComponent("WhisperDiarize")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        // Copy bundled resources on first launch (or if missing)
        for (name, ext) in [("transcribe", "py"), ("pyproject", "toml"), ("uv", "lock")] {
            let dst = dir.appendingPathComponent("\(name).\(ext)")
            guard !FileManager.default.fileExists(atPath: dst.path) else { continue }
            if let src = Bundle.module.url(forResource: name, withExtension: ext) {
                try? FileManager.default.copyItem(at: src, to: dst)
            }
        }
        return dir
    }

    private func findUV() -> String? {
        [
            "/opt/homebrew/bin/uv",
            "/usr/local/bin/uv",
            "\(NSHomeDirectory())/.local/bin/uv",
            "\(NSHomeDirectory())/.cargo/bin/uv",
        ].first { FileManager.default.isExecutableFile(atPath: $0) }
    }

    private func enrichedEnv() -> [String: String] {
        var env = ProcessInfo.processInfo.environment
        let extra = "/opt/homebrew/bin:/usr/local/bin:\(NSHomeDirectory())/.local/bin:\(NSHomeDirectory())/.cargo/bin"
        env["PATH"] = extra + ":" + (env["PATH"] ?? "/usr/bin:/bin")
        env["PYTHONUNBUFFERED"] = "1"   // force unbuffered output so lines stream immediately
        return env
    }
}
