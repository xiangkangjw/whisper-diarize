import SwiftUI
import WhisperDiarizeCore

// Palette — one color per speaker index
private let speakerPalette: [Color] = [
    .blue, .green, .orange, .purple, .pink, .teal, .indigo, .cyan
]

struct TranscriptView: View {
    @EnvironmentObject private var runner: TranscriptionRunner
    @State private var searchText = ""
    @State private var selectedSpeaker: String? = nil

    private var speakers: [String] {
        Array(Set(runner.transcript.map(\.speaker))).sorted()
    }

    private var filtered: [TranscriptLine] {
        runner.transcript.filter { line in
            let matchesSpeaker = selectedSpeaker == nil || line.speaker == selectedSpeaker
            let matchesSearch = searchText.isEmpty ||
                line.text.localizedCaseInsensitiveContains(searchText) ||
                line.speaker.localizedCaseInsensitiveContains(searchText)
            return matchesSpeaker && matchesSearch
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Stats + filter bar
            HStack(spacing: 12) {
                Label("\(runner.transcript.count) lines", systemImage: "text.alignleft")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Label("\(speakers.count) speakers", systemImage: "person.2")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Divider().frame(height: 16)

                // Speaker filter pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        FilterPill(label: "All", isSelected: selectedSpeaker == nil) {
                            selectedSpeaker = nil
                        }
                        ForEach(Array(speakers.enumerated()), id: \.element) { i, spk in
                            FilterPill(
                                label: spk,
                                color: speakerPalette[i % speakerPalette.count],
                                isSelected: selectedSpeaker == spk
                            ) {
                                selectedSpeaker = selectedSpeaker == spk ? nil : spk
                            }
                        }
                    }
                }

                Spacer()

                // Search
                HStack {
                    Image(systemName: "magnifyingglass").foregroundStyle(.secondary).font(.caption)
                    TextField("Search…", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.caption)
                        .frame(width: 140)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.regularMaterial)

            Divider()

            // Transcript lines
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(filtered) { line in
                        TranscriptLineRow(line: line)
                        Divider().padding(.leading, 56)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
}

struct TranscriptLineRow: View {
    let line: TranscriptLine

    private var color: Color {
        speakerPalette[line.speakerIndex % speakerPalette.count]
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Speaker avatar
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)
                Text(line.speaker.replacingOccurrences(of: "SPEAKER_", with: ""))
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(line.speaker)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(color)
                    Text(line.timestamp)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .monospacedDigit()
                }
                Text(line.text)
                    .font(.body)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}

struct FilterPill: View {
    let label: String
    var color: Color = .secondary
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(isSelected ? color.opacity(0.2) : Color.secondary.opacity(0.1),
                            in: Capsule())
                .foregroundStyle(isSelected ? color : .secondary)
        }
        .buttonStyle(.plain)
    }
}
