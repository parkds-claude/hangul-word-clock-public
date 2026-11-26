import SwiftUI
import XCTest
@testable import HangulClockUI

/// 판 글자 30자 글꼴 4개(스펙 I4).
@MainActor
final class HangulFontsTests: XCTestCase {
    func testAllFacesRegister() {
        let result = HangulFonts.registerAll()
        XCTAssertEqual(result.values.filter { $0 }.count, 4)
        for face in HangulFonts.Face.allCases {
            XCTAssertTrue(HangulFonts.isAvailable(face), face.rawValue)
        }
        #if canImport(UIKit)
        XCTAssertNotNil(UIFont(name: "HCSans-Medium", size: 20))
        #endif
    }

    func testRegisteringTwiceIsStillSuccess() {
        HangulFonts.registerAll()
        XCTAssertEqual(HangulFonts.registerAll().values.filter { $0 }.count, 4)
    }

    /// Review Focus 5: 위젯 확장에서 글꼴 파일을 못 찾아도 멈추지 않고 시스템 글꼴로 그린다.
    func testMissingFontFallsBackToSystem() {
        XCTAssertFalse(HangulFonts.register(url: URL(fileURLWithPath: "/nonexistent/HCMissing.ttf")))
        let font = HangulFonts.font(postScriptName: "HCMissing-Regular", size: 24, weight: .regular)
        let image = ImageRenderer(content: Text("저녁").font(font)).cgImage
        XCTAssertNotNil(image)
    }
}
