import XCTest
@testable import WhisperDiarizeCore

final class TranscriptParserTests: XCTestCase {

    // MARK: - parseTranscript

    func testParsesValidLine() {
        let content = "[00:01.20 → 00:05.44]  SPEAKER_00: Hello world"
        let lines = parseTranscript(content)
        XCTAssertEqual(lines.count, 1)
        XCTAssertEqual(lines[0].timestamp, "00:01.20 → 00:05.44")
        XCTAssertEqual(lines[0].speaker, "SPEAKER_00")
        XCTAssertEqual(lines[0].text, "Hello world")
        XCTAssertEqual(lines[0].speakerIndex, 0)
    }

    func testAssignsSpeakerIndicesInOrder() {
        let content = """
        [00:01.00 → 00:02.00]  SPEAKER_00: First
        [00:02.00 → 00:03.00]  SPEAKER_01: Second
        [00:03.00 → 00:04.00]  SPEAKER_00: Third
        """
        let lines = parseTranscript(content)
        XCTAssertEqual(lines.count, 3)
        XCTAssertEqual(lines[0].speakerIndex, 0)
        XCTAssertEqual(lines[1].speakerIndex, 1)
        XCTAssertEqual(lines[2].speakerIndex, 0) // same speaker, same index
    }

    func testSkipsBlankLines() {
        let content = """
        [00:01.00 → 00:02.00]  SPEAKER_00: Hello

        [00:03.00 → 00:04.00]  SPEAKER_01: World
        """
        let lines = parseTranscript(content)
        XCTAssertEqual(lines.count, 2)
    }

    func testSkipsMalformedLines() {
        let content = """
        [00:01.00 → 00:02.00]  SPEAKER_00: Valid line
        this line has no timestamp
        also bad
        [00:05.00 → 00:06.00]  SPEAKER_01: Also valid
        """
        let lines = parseTranscript(content)
        XCTAssertEqual(lines.count, 2)
    }

    func testEmptyInputReturnsEmpty() {
        XCTAssertEqual(parseTranscript("").count, 0)
    }

    func testChineseText() {
        let content = "[00:01.32 → 00:02.28]  SPEAKER_03: 喽哈喽"
        let lines = parseTranscript(content)
        XCTAssertEqual(lines.count, 1)
        XCTAssertEqual(lines[0].text, "喽哈喽")
    }

    func testUnknownSpeaker() {
        let content = "[00:00.72 → 00:01.32]  UNKNOWN: 哈"
        let lines = parseTranscript(content)
        XCTAssertEqual(lines[0].speaker, "UNKNOWN")
    }

    // MARK: - formatTime

    func testFormatTimeUnderOneHour() {
        XCTAssertEqual(formatTime(0), "00:00.00")
        XCTAssertEqual(formatTime(61.5), "01:01.50")
        XCTAssertEqual(formatTime(3599.99), "59:59.99")
    }

    func testFormatTimeOverOneHour() {
        let result = formatTime(3661.0)
        XCTAssertTrue(result.hasPrefix("01:01:"), "Expected HH:MM:SS format, got \(result)")
    }

    func testFormatTimeRoundTrip() {
        // 5 minutes 30.25 seconds
        XCTAssertEqual(formatTime(330.25), "05:30.25")
    }
}
