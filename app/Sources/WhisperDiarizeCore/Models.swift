import Foundation

// MARK: - Models

public struct TranscriptLine: Identifiable, Sendable {
    public let id: UUID
    public let timestamp: String
    public let speaker: String
    public let text: String
    public let speakerIndex: Int

    public init(timestamp: String, speaker: String, text: String, speakerIndex: Int) {
        self.id = UUID()
        self.timestamp = timestamp
        self.speaker = speaker
        self.text = text
        self.speakerIndex = speakerIndex
    }
}

public enum RunnerState: Equatable, Sendable {
    case idle
    case running(phase: String)
    case done
    case failed(String)
}
