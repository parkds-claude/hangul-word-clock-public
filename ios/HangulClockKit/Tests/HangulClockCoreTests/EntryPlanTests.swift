import XCTest
@testable import HangulClockCore

/// 위젯 시간표 항목(I6). 위젯 확장의 ClockProvider 가 이 목록을 그대로 쓴다.
final class EntryPlanTests: XCTestCase {
    private let seoul = TimeZone(identifier: "Asia/Seoul")!
    private func d(_ iso: String) -> Date { ISO8601DateFormatter().date(from: iso)! }

    func testPlanHas60EntriesWithMatchingTimes() {
        let plan = EntryPlan.plan(now: d("2026-11-26T18:44:30+09:00"), timeZone: seoul, light: .bulb)
        XCTAssertEqual(plan.count, 60)
        XCTAssertEqual(plan[0].time, ClockTime(hour: 18, minute: 44))
        XCTAssertEqual(plan[1].date, d("2026-11-26T18:45:00+09:00"))
        XCTAssertEqual(plan[1].time, ClockTime(hour: 18, minute: 45))
        XCTAssertTrue(plan.allSatisfy { $0.light == .bulb })
    }

    func testPlanFiveMinuteStepFloors() {
        let plan = EntryPlan.plan(now: d("2026-11-26T18:44:30+09:00"), timeZone: seoul, light: .daylight, step: 5)
        XCTAssertEqual(plan[0].time, ClockTime(hour: 18, minute: 40))
        XCTAssertEqual(plan[1].date, d("2026-11-26T18:45:00+09:00"))
        XCTAssertEqual(plan[1].time, ClockTime(hour: 18, minute: 45))
        XCTAssertEqual(plan[2].time, ClockTime(hour: 18, minute: 50))
    }
}
