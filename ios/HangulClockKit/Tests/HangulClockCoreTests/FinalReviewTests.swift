import XCTest
@testable import HangulClockCore

/// 최종 검토 Important 1: 마지막 항목까지 기다리지 않고 10개를 남기고 새 시간표를 받는다.
final class FinalReviewTests: XCTestCase {
    func testReloadDateLeavesTenEntries() {
        let seoul = TimeZone(identifier: "Asia/Seoul")!
        let now = ISO8601DateFormatter().date(from: "2026-11-26T18:44:30+09:00")!
        let plan = EntryPlan.plan(now: now, timeZone: seoul, light: .daylight)
        XCTAssertEqual(EntryPlan.reloadDate(for: plan), plan[50].date)
        XCTAssertEqual(EntryPlan.reloadDate(for: Array(plan.prefix(3))), plan[0].date)
        XCTAssertNil(EntryPlan.reloadDate(for: []))
    }
}
