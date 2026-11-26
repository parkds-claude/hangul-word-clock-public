import XCTest
@testable import HangulClockCore

/// 위젯 시간표(I6). 첫 항목은 지금, 나머지는 stepMinutes 배수의 분 경계(초 0).
final class TimelineStepsTests: XCTestCase {
    private let seoul = TimeZone(identifier: "Asia/Seoul")!

    private func d(_ iso: String) -> Date {
        ISO8601DateFormatter().date(from: iso)!
    }

    func testConstants() {
        XCTAssertEqual(TimelineSteps.widgetStepMinutes, 1)
        XCTAssertEqual(TimelineSteps.entryCount, 60)
    }

    func testOneMinuteSteps() {
        let now = d("2026-11-26T18:44:30+09:00")
        let ds = TimelineSteps.dates(from: now, stepMinutes: 1, count: 60, timeZone: seoul)
        XCTAssertEqual(ds.count, 60)
        XCTAssertEqual(ds[0], now)
        XCTAssertEqual(ds[1], d("2026-11-26T18:45:00+09:00"))
        XCTAssertEqual(ds[59], d("2026-11-26T19:43:00+09:00"))
    }

    func testFiveMinuteSteps() {
        let ds = TimelineSteps.dates(from: d("2026-11-26T18:44:30+09:00"), stepMinutes: 5, count: 3, timeZone: seoul)
        XCTAssertEqual(ds[1], d("2026-11-26T18:45:00+09:00"))
        XCTAssertEqual(ds[2], d("2026-11-26T18:50:00+09:00"))
    }

    /// Review Focus 1: 서머타임이 시작하는 날 뉴욕은 01:59 다음이 03:00 이다. 02:xx 가 나오면 안 된다.
    func testDSTSpringForward() {
        let ny = TimeZone(identifier: "America/New_York")!
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = ny
        let start = cal.date(from: DateComponents(year: 2027, month: 3, day: 14, hour: 1, minute: 58, second: 10))!
        let ds = TimelineSteps.dates(from: start, stepMinutes: 1, count: 5, timeZone: ny)
        let shown = ds.map { date -> String in
            let c = cal.dateComponents([.hour, .minute], from: date)
            return String(format: "%02d:%02d", c.hour!, c.minute!)
        }
        XCTAssertEqual(shown, ["01:58", "01:59", "03:00", "03:01", "03:02"])
    }
}
