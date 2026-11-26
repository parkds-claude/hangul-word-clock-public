import HangulClockCore
import SwiftUI
import XCTest
@testable import HangulClockUI

/// 작업 10 독립 검토(Codex · Gemini)에서 받은 지적의 시험.
@MainActor
final class ReviewFixTests: XCTestCase {
    private let seoul = TimeZone(identifier: "Asia/Seoul")!
    private let at1845 = ISO8601DateFormatter().date(from: "2026-11-26T18:45:10+09:00")!

    override func setUp() {
        super.setUp()
        HangulFonts.registerAll()
    }

    /// Codex 1: 홈 화면 위젯 바탕은 시안(v2 .wl)처럼 앱 바탕보다 밝은 유리판이다(#2A2E35 → #171A1E → #1D2025).
    func testWidgetGlassBackgroundIsLighterPanel() throws {
        let img = try XCTUnwrap(Snapshot.render(WidgetGlassBackground(light: .daylight), size: CGSize(width: 170, height: 170)))
        Snapshot.save(img, name: "widget-bg-daylight")
        // 앱 바탕의 가장 밝은 색 #20242A(밝기 0.138)보다 밝아야 한다. 모서리 30pt 는 대각선 그러데이션이라 #2A2E35(0.179)보다 낮게 나온다.
        XCTAssertGreaterThan(Snapshot.meanLuma(img, rect: CGRect(x: 4, y: 4, width: 30, height: 30)), 0.15)
    }

    /// Codex 2: 시안의 판 위치(화면 맨 위에서 176pt)는 상태 표시줄 영역을 포함한 값이다.
    func testSlabTopAccountsForSafeArea() {
        XCTAssertEqual(ClockScreenContent.slabTop(safeTop: 0), 176)
        XCTAssertEqual(ClockScreenContent.slabTop(safeTop: 47), 129)
        XCTAssertEqual(ClockScreenContent.slabTop(safeTop: 300), 0)
    }

    /// Gemini 1: 유리판 안쪽이 바탕보다 밝은 정도가 시안(+20.6/255)에 가깝다. 구현 전에는 +16.7 이었다.
    func testGlassSlabBrightnessMatchesMockup() throws {
        let view = ClockScreenContent(now: at1845, timeZone: seoul, light: .constant(.daylight), material: .constant(.glass))
        let img = try XCTUnwrap(Snapshot.render(view, size: CGSize(width: 390, height: 844)))
        let inside = Snapshot.meanLuma(img, rect: CGRect(x: 80, y: 180, width: 220, height: 16))
        let outside = Snapshot.meanLuma(img, rect: CGRect(x: 80, y: 140, width: 220, height: 28))
        XCTAssertGreaterThanOrEqual((inside - outside) * 255, 19)
    }
}
