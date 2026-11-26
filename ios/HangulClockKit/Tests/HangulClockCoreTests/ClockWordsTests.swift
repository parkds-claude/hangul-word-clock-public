import XCTest
@testable import HangulClockCore

/// 시각을 말로 바꾸기. 값은 스펙 7.4 표와 preview/clock-core.js 의 sentence().
final class ClockWordsTests: XCTestCase {
    private let seoul = TimeZone(identifier: "Asia/Seoul")!

    private func d(_ iso: String) -> Date {
        ISO8601DateFormatter().date(from: iso)!
    }

    func testSentencesMatchJSForAllMinutes() throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "golden_sentences", withExtension: "txt", subdirectory: "Golden"))
        let text = try String(contentsOf: url, encoding: .utf8)
        var checked = 0
        var mismatches = 0
        for line in text.split(separator: "\n") {
            let f = line.split(separator: " ", maxSplits: 2)
            guard f.count == 3, let h = Int(f[0]), let m = Int(f[1]) else {
                XCTFail("문장 정답표 줄 형식이 이상하다: \(line)")
                continue
            }
            checked += 1
            let got = ClockWords.at(ClockTime(hour: h, minute: m)).sentence
            if got != String(f[2]) {
                mismatches += 1
                if mismatches <= 3 { print("틀림: \(line) / Swift: \(got)") }
            }
        }
        XCTAssertEqual(checked, 1_440)
        XCTAssertEqual(mismatches, 0)
    }

    func test1845() {
        let w = ClockWords.at(ClockTime(hour: 18, minute: 45))
        XCTAssertEqual(w.sentence, "저녁 여섯 시 사십오 분")
        XCTAssertEqual(w.inline, "저녁 여섯 시")
        XCTAssertEqual(w.hourWord, "여섯")
        XCTAssertEqual(w.sentenceLines, ["저녁", "여섯 시", "사십오 분"])
        XCTAssertEqual(w.rectangularLines, ["저녁 여섯 시", "사십오 분"])
    }

    func testMinuteZero() {
        let w = ClockWords.at(ClockTime(hour: 18, minute: 0))
        XCTAssertNil(w.minuteWords)
        XCTAssertEqual(w.sentenceLines, ["저녁", "여섯 시"])
        XCTAssertEqual(w.rectangularLines, ["저녁 여섯 시"])
    }

    func testNoon() {
        let w = ClockWords.at(ClockTime(hour: 12, minute: 0))
        XCTAssertTrue(w.isNoon)
        XCTAssertEqual(w.sentence, "정오")
        XCTAssertEqual(w.inline, "정오")
        XCTAssertEqual(w.hourWord, "정오")
        XCTAssertEqual(w.sentenceLines, ["정오"])
        XCTAssertEqual(w.rectangularLines, ["정오"])
    }

    func testMidnight() {
        XCTAssertEqual(ClockWords.at(ClockTime(hour: 0, minute: 0)).sentence, "밤 열두 시")
    }

    func testStepFloorsMinute() {
        XCTAssertEqual(ClockTime.from(d("2026-11-26T18:47:59+09:00"), timeZone: seoul, stepMinutes: 5),
                       ClockTime(hour: 18, minute: 45))
        XCTAssertEqual(ClockTime.from(d("2026-11-26T18:47:59+09:00"), timeZone: seoul),
                       ClockTime(hour: 18, minute: 47))
    }

    /// Review Focus 2: 아이폰 달력이 불기 · 일본력이어도 시와 분은 양력 0~23시로 읽는다.
    /// 시와 분은 달력과 상관이 없으므로, 양력이 아닌 달력으로 읽은 값과 같아야 한다.
    func testNonGregorianCalendarDoesNotChangeWords() {
        let date = d("2026-11-26T18:45:30+09:00")
        for id in [Calendar.Identifier.buddhist, .japanese] {
            var cal = Calendar(identifier: id)
            cal.timeZone = seoul
            let c = cal.dateComponents([.hour, .minute], from: date)
            XCTAssertEqual(ClockTime.from(date, timeZone: seoul), ClockTime(hour: c.hour!, minute: c.minute!))
        }
        XCTAssertEqual(ClockWords.at(ClockTime.from(date, timeZone: seoul)).sentence, "저녁 여섯 시 사십오 분")
    }
}
