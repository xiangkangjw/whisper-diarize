import SwiftUI

private struct Step {
    let icon: String
    let title: String
    let subtitle: String
}

private let steps: [Step] = [
    Step(icon: "waveform",              title: "Transcribing",        subtitle: "mlx-whisper · Apple Silicon GPU"),
    Step(icon: "person.2.wave.2.fill",  title: "Identifying Speakers", subtitle: "pyannote · Metal"),
    Step(icon: "arrow.triangle.merge",  title: "Merging",             subtitle: "Aligning words with speakers"),
    Step(icon: "doc.text.fill",         title: "Saving",              subtitle: "Writing transcript file"),
]

struct ProcessingView: View {
    @EnvironmentObject private var runner: TranscriptionRunner
    @State private var elapsed: TimeInterval = 0
    @State private var showLog = false
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 0) {

            // ── Header ────────────────────────────────────────────────────
            VStack(spacing: 6) {
                Text(headerTitle)
                    .font(.title3.weight(.semibold))
                    .contentTransition(.numericText())
                    .animation(.easeInOut, value: headerTitle)

                Text(elapsedString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(.regularMaterial)

            Divider()

            // ── Step cards ────────────────────────────────────────────────
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { i, step in
                        StepCard(
                            step: step,
                            index: i,
                            currentStep: runner.currentStep,
                            detail: runner.stepDetails[i],
                            progress: runner.stepProgress[i]
                        )
                    }
                }
                .padding(24)

                // ── Collapsible log ───────────────────────────────────────
                VStack(spacing: 0) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { showLog.toggle() }
                    } label: {
                        HStack {
                            Image(systemName: showLog ? "chevron.down" : "chevron.right")
                                .font(.caption)
                            Text("Show log")
                                .font(.caption)
                            Spacer()
                            Text("\(runner.logLines.count) lines")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)

                    if showLog {
                        LogView()
                            .frame(height: 180)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
            }
        }
        .onAppear(perform: startTimer)
        .onDisappear(perform: stopTimer)
    }

    // MARK: - Helpers

    private var headerTitle: String {
        if case .running(let p) = runner.state, !p.isEmpty { return p }
        return "Processing\u{2026}"
    }

    private var elapsedString: String {
        guard elapsed > 0 else { return "Starting\u{2026}" }
        let m = Int(elapsed) / 60
        let s = Int(elapsed) % 60
        return m > 0 ? "\(m)m \(s)s elapsed" : "\(s)s elapsed"
    }

    private func startTimer() {
        elapsed = runner.startTime.map { Date().timeIntervalSince($0) } ?? 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsed = runner.startTime.map { Date().timeIntervalSince($0) } ?? elapsed + 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Step Card

private struct StepCard: View {
    let step: Step
    let index: Int
    let currentStep: Int
    let detail: String?
    let progress: Double?

    private var status: StepStatus {
        if index < currentStep { return .done }
        if index == currentStep { return .active }
        return .pending
    }

    var body: some View {
        HStack(spacing: 16) {
            // Icon / status badge
            ZStack {
                Circle()
                    .fill(status.bgColor)
                    .frame(width: 44, height: 44)
                if status == .active && progress == nil {
                    ProgressView().scaleEffect(0.7).tint(.white)
                } else if status == .done {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Image(systemName: step.icon)
                        .font(.system(size: 16))
                        .foregroundStyle(status.iconColor)
                }
            }
            .animation(.easeInOut, value: status)

            // Title + subtitle + progress bar inline
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(step.title)
                        .font(.body.weight(status == .active ? .semibold : .regular))
                        .foregroundStyle(status == .pending ? .secondary : .primary)
                    Spacer()
                    // Status badge
                    if status == .active {
                        if let p = progress {
                            Text("\(Int(p * 100))%")
                                .font(.caption.weight(.semibold).monospacedDigit())
                                .foregroundStyle(Color.accentColor)
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(Color.accentColor.opacity(0.12), in: Capsule())
                        } else {
                            Text("In progress")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(Color.accentColor)
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(Color.accentColor.opacity(0.12), in: Capsule())
                        }
                    } else if status == .done {
                        Text("Done")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.green)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Color.green.opacity(0.12), in: Capsule())
                    }
                }

                Text(detail ?? step.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Progress bar — shown when active or done with known progress
                if let p = progress {
                    ProgressView(value: p)
                        .tint(status == .done ? .green : Color.accentColor)
                        .animation(.linear(duration: 0.25), value: p)
                } else if status == .active {
                    ProgressView()
                        .tint(Color.accentColor)
                }
            }
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(status == .active ? Color.accentColor.opacity(0.4) : .clear, lineWidth: 1.5)
        )
        .shadow(color: .black.opacity(status == .active ? 0.06 : 0.02), radius: status == .active ? 8 : 2, y: 2)
        .animation(.easeInOut, value: status)
    }
}

// MARK: - Log View

private struct LogView: View {
    @EnvironmentObject private var runner: TranscriptionRunner

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 1) {
                    ForEach(Array(runner.logLines.enumerated()), id: \.offset) { i, line in
                        Text(line)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(logColor(for: line))
                            .textSelection(.enabled)
                            .id(i)
                    }
                    Color.clear.frame(height: 1).id("bottom")
                }
                .padding(10)
            }
            .background(Color(nsColor: .textBackgroundColor))
            .onChange(of: runner.logLines.count) { _, _ in
                proxy.scrollTo("bottom")
            }
        }
    }

    private func logColor(for line: String) -> Color {
        if line.hasPrefix("✅") { return .green }
        if line.hasPrefix("❌") || line.lowercased().contains("error") { return .red }
        if line.hasPrefix("🎙️") || line.hasPrefix("👥") || line.hasPrefix("🔀") ||
           line.hasPrefix("💾") || line.hasPrefix("💨") { return Color.accentColor }
        return .secondary
    }
}

// MARK: - Step Status

private enum StepStatus: Equatable {
    case pending, active, done

    var bgColor: Color {
        switch self {
        case .pending: return Color.secondary.opacity(0.2)
        case .active:  return Color.accentColor
        case .done:    return Color.green
        }
    }

    var iconColor: Color {
        switch self {
        case .pending: return Color(nsColor: .tertiaryLabelColor)
        case .active:  return .white
        case .done:    return .white
        }
    }
}
