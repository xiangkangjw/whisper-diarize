import Foundation

/// Parse a raw transcript string into structured lines.
/// Each line has the format: `[HH:MM:SS.ss → HH:MM:SS.ss]  SPEAKER_00: text`
public func parseTranscript(_ content: String) -> [TranscriptLine] {
    var speakerIndex: [String: Int] = [:]
    var idx = 0
    let pattern = #"^\[(.+?)\]\s+(\S+?):\s+(.+)$"#
    guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }

    return content
        .components(separatedBy: .newlines)
        .filter { !$0.isEmpty }
        .compactMap { line -> TranscriptLine? in
            let range = NSRange(line.startIndex..., in: line)
            guard let m = regex.firstMatch(in: line, range: range),
                  let tsRange = Range(m.range(at: 1), in: line),
                  let spRange = Range(m.range(at: 2), in: line),
                  let txRange = Range(m.range(at: 3), in: line) else { return nil }
            let speaker = String(line[spRange])
            if speakerIndex[speaker] == nil { speakerIndex[speaker] = idx; idx += 1 }
            return TranscriptLine(
                timestamp: String(line[tsRange]),
                speaker: speaker,
                text: String(line[txRange]),
                speakerIndex: speakerIndex[speaker]!
            )
        }
}

/// Format seconds as `MM:SS.ss` or `HH:MM:SS.ss`
public func formatTime(_ seconds: Double) -> String {
    let h = Int(seconds / 3600)
    let m = Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60)
    let s = seconds.truncatingRemainder(dividingBy: 60)
    return h > 0
        ? String(format: "%02d:%02d:%05.2f", h, m, s)
        : String(format: "%02d:%05.2f", m, s)
}
