import HangulClockCore
import SwiftUI
import XCTest
@testable import HangulClockUI

@MainActor
final class FinalReviewUITests: XCTestCase {
    /// 최종 검토(올린 Important): VoiceOver 는 위젯에서도 문장 전체를 읽는다.
    func testWidgetsExposeSentenceToVoiceOver() {
        let t = ClockTime(hour: 18, minute: 45)
        let w = ClockWords.at(t)
        XCTAssertEqual(GridSmallView(time: t, palette: Palettes.palette(.daylight, .glass)).accessibilityText, "저녁 여섯 시 사십오 분")
        XCTAssertEqual(CircularClockView(time: t, words: w).accessibilityText, "저녁 여섯 시 사십오 분")
        let noon = ClockTime(hour: 12, minute: 0)
        XCTAssertEqual(CircularClockView(time: noon, words: ClockWords.at(noon)).accessibilityText, "정오")
    }

    /// 최종 검토(올린 Important): 유리는 어두운 화면 모드, 백자 · 직물은 밝은 화면 모드(상태 표시줄 글자가 보이게).
    func testPreferredSchemeMatchesMaterial() {
        XCTAssertEqual(ClockScreenContent.preferredScheme(for: .glass), .dark)
        XCTAssertEqual(ClockScreenContent.preferredScheme(for: .porcelain), .light)
        XCTAssertEqual(ClockScreenContent.preferredScheme(for: .fabric), .light)
    }
}
