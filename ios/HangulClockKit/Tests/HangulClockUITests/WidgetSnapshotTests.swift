import HangulClockCore
import SwiftUI
import XCTest
@testable import HangulClockUI

/// 위젯 화면 6종(스펙 7.2 · 7.3 · 7.4). 크기(pt): 한 줄 200×20, 직사각형 160×72, 동그라미 72×72, 작은 170×170, 큰 364×382
@MainActor
final class WidgetSnapshotTests: XCTestCase {
    private let palette = Palettes.palette(.daylight, .glass)
    private let times = [ClockTime(hour: 18, minute: 45), ClockTime(hour: 18, minute: 0),
                         ClockTime(hour: 12, minute: 0), ClockTime(hour: 1, minute: 5)]

    override func setUp() {
        super.setUp()
        HangulFonts.registerAll()
    }

    private func name(_ kind: String, _ t: ClockTime) -> String {
        String(format: "w-%@-%02d%02d", kind, t.hour, t.minute)
    }

    func testAllWidgetsAtFourTimes() throws {
        let lockBG = Color(white: 0.18)
        let homeBG = Color(palette.background[1])
        for t in times {
            let w = ClockWords.at(t)
            let shots: [(String, AnyView, CGSize)] = [
                ("inline", AnyView(InlineClockView(words: w).background(lockBG)), CGSize(width: 200, height: 20)),
                ("rect", AnyView(RectangularClockView(time: t, words: w).background(lockBG)), CGSize(width: 160, height: 72)),
                ("circle", AnyView(CircularClockView(time: t, words: w).background(lockBG)), CGSize(width: 72, height: 72)),
                ("gridsmall", AnyView(GridSmallView(time: t, palette: palette).padding(12).background(homeBG)), CGSize(width: 170, height: 170)),
                ("sentence", AnyView(SentenceSmallView(words: w, palette: palette).padding(16).background(homeBG)), CGSize(width: 170, height: 170)),
                ("large", AnyView(LargeClockView(time: t, words: w, palette: palette).padding(16).background(homeBG)), CGSize(width: 364, height: 382)),
            ]
            for (kind, view, size) in shots {
                let img = try XCTUnwrap(Snapshot.render(view, size: size), "\(kind) \(t)")
                XCTAssertEqual(img.width, Int(size.width * Snapshot.scale))
                Snapshot.save(img, name: name(kind, t))
            }
        }
    }

    func testCircularShowsHourAndMinuteRing() {
        let t = ClockTime(hour: 18, minute: 45)
        let v = CircularClockView(time: t, words: ClockWords.at(t))
        XCTAssertEqual(v.centerText, "여섯")
        XCTAssertEqual(v.ringFraction, 0.75, accuracy: 0.0001)
    }

    func testCircularNoonShowsJeongo() {
        let t = ClockTime(hour: 12, minute: 0)
        let v = CircularClockView(time: t, words: ClockWords.at(t))
        XCTAssertEqual(v.centerText, "정오")
        XCTAssertEqual(v.ringFraction, 0)
    }

    /// Review Focus 4: 손쉬운 사용에서 글자를 키워도 위젯 글자는 고정 크기라 그림이 같다.
    func testDynamicTypeDoesNotChangeWidgetRendering() throws {
        let t = ClockTime(hour: 18, minute: 45)
        let view = SentenceSmallView(words: ClockWords.at(t), palette: palette).padding(16).background(Color.black)
        let size = CGSize(width: 170, height: 170)
        let normal = try XCTUnwrap(Snapshot.render(view, size: size, dynamicType: .large))
        let huge = try XCTUnwrap(Snapshot.render(view, size: size, dynamicType: .accessibility3))
        XCTAssertTrue(Snapshot.samePixels(normal, huge))
    }
}
