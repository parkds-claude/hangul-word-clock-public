import HangulClockCore
import SwiftUI
import XCTest
@testable import HangulClockUI

/// 앱 첫 화면(스펙 7.1). 18:45 서울.
@MainActor
final class ClockScreenContentTests: XCTestCase {
    private let seoul = TimeZone(identifier: "Asia/Seoul")!
    private let at1845 = ISO8601DateFormatter().date(from: "2026-11-26T18:45:10+09:00")!

    override func setUp() {
        super.setUp()
        HangulFonts.registerAll()
    }

    func testScreensForBothColors() throws {
        for light in LightColor.allCases {
            let view = ClockScreenContent(now: at1845, timeZone: seoul, light: .constant(light), material: .constant(.glass))
            let img = try XCTUnwrap(Snapshot.render(view, size: CGSize(width: 390, height: 844)), "\(light)")
            XCTAssertEqual(img.width, 1170)
            Snapshot.save(img, name: "screen-\(light.rawValue)")
        }
    }

    func testOtherMaterialsRender() throws {
        for material in [SlabMaterial.porcelain, .fabric] {
            let view = ClockScreenContent(now: at1845, timeZone: seoul, light: .constant(.bulb), material: .constant(material))
            let img = try XCTUnwrap(Snapshot.render(view, size: CGSize(width: 390, height: 844)), "\(material)")
            Snapshot.save(img, name: "screen-bulb-\(material.rawValue)")
        }
    }

    /// 판은 VoiceOver 에서 숨기고 문장을 읽는다(판의 accessibilityHidden 은 GridView 에 있다).
    func testAccessibilityReadsSentence() {
        let view = ClockScreenContent(now: at1845, timeZone: seoul, light: .constant(.daylight), material: .constant(.glass))
        XCTAssertEqual(view.sentence, "저녁 여섯 시 사십오 분")
        XCTAssertEqual(view.dateText, "11월 26일 목요일")
    }
}
