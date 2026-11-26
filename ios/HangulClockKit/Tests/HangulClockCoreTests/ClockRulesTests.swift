import XCTest
@testable import HangulClockCore

/// Swift 규칙이 JS 정본(preview/clock-core.js)과 같은지 본다.
/// 정답표는 tools/gen_tables.js 가 Golden/ 에 만든다(git 제외).
final class ClockRulesTests: XCTestCase {
    private func resource(_ name: String) throws -> String {
        let url = try XCTUnwrap(
            Bundle.module.url(forResource: name, withExtension: "txt", subdirectory: "Golden"),
            "정답표가 없다. tools/ios.sh gen 을 먼저 돈다"
        )
        return try String(contentsOf: url, encoding: .utf8)
    }

    func testGoldenTableMatchesForAllSettings() throws {
        // 한 줄: "아침 낮 저녁 밤 정오 h m cell:kind,cell:kind,..."
        let text = try resource("golden")
        var checkedRows = 0
        var mismatches = 0
        for line in text.split(separator: "\n") {
            let f = line.split(separator: " ")
            guard f.count == 8, let n = Optional(f[0..<7].compactMap { Int($0) }), n.count == 7 else {
                XCTFail("정답표 줄 형식이 이상하다: \(line)")
                continue
            }
            let bounds = Bounds(morning: n[0], day: n[1], evening: n[2], night: n[3], noon: n[4] == 1)
            let got = ClockRules.lit(hour: n[5], minute: n[6], bounds: bounds)
                .map { "\($0.cell):\($0.kind.rawValue)" }
                .joined(separator: ",")
            checkedRows += 1
            if got != String(f[7]) {
                mismatches += 1
                if mismatches <= 3 { print("틀림: \(line) / Swift: \(got)") }
            }
        }
        XCTAssertEqual(checkedRows, 25_920)
        XCTAssertEqual(mismatches, 0)
    }

    func testStandardBounds() {
        XCTAssertEqual(Bounds.standard, Bounds(morning: 5, day: 11, evening: 18, night: 21, noon: true))
    }

    func test1845() {
        XCTAssertEqual(ClockRules.lit(hour: 18, minute: 45).map(\.cell), [3, 4, 12, 13, 19, 23, 25, 30, 35])
    }
}
