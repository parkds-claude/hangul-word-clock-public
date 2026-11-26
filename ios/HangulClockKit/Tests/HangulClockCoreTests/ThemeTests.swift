import XCTest
@testable import HangulClockCore

/// 빛 색 2 × 재질 3 의 색 값(스펙 7.1)과 설정 저장.
final class ThemeTests: XCTestCase {
    private func freshDefaults() -> UserDefaults {
        let name = "hc-test-\(UUID().uuidString)"
        let d = UserDefaults(suiteName: name)!
        d.removePersistentDomain(forName: name)
        return d
    }

    func testGlassPalettesMatchSpec() {
        let d = Palettes.palette(.daylight, .glass)
        XCTAssertEqual(d.lit, RGB(hex: 0xF4F7FB))
        XCTAssertEqual(d.period, RGB(hex: 0xCFE0FF))
        XCTAssertEqual(d.unlit, RGB(hex: 0x50545A))
        XCTAssertEqual(d.glowRadius, 3)
        XCTAssertEqual(d.background, [RGB(hex: 0x20242A), RGB(hex: 0x171A1E), RGB(hex: 0x121417)])

        let b = Palettes.palette(.bulb, .glass)
        XCTAssertEqual(b.lit, RGB(hex: 0xFFD9A6))
        XCTAssertEqual(b.period, RGB(hex: 0xFFB070))
        XCTAssertEqual(b.unlit, RGB(hex: 0x5A534B))
        XCTAssertEqual(b.background, [RGB(hex: 0x2A241E), RGB(hex: 0x1C1814), RGB(hex: 0x141210)])
    }

    func testPorcelainBulbIsV1Amber() {
        let p = Palettes.palette(.bulb, .porcelain)
        XCTAssertEqual(p.lit, RGB(hex: 0xE98F37))
        XCTAssertEqual(p.period, RGB(hex: 0xE2694C))
    }

    func testAllSixPalettesExist() {
        for light in LightColor.allCases {
            for material in SlabMaterial.allCases {
                let p = Palettes.palette(light, material)
                XCTAssertNotEqual(p.lit, p.unlit, "\(light) \(material)")
                XCTAssertNotEqual(p.period, p.unlit, "\(light) \(material)")
                XCTAssertFalse(p.background.isEmpty, "\(light) \(material)")
            }
        }
    }

    func testDefaultsAreDaylightGlass() {
        let store = ThemeStore(defaults: freshDefaults())
        XCTAssertEqual(store.light, .daylight)
        XCTAssertEqual(store.material, .glass)
    }

    func testRoundTrip() {
        let defaults = freshDefaults()
        let a = ThemeStore(defaults: defaults)
        a.light = .bulb
        a.material = .fabric
        let b = ThemeStore(defaults: defaults)
        XCTAssertEqual(b.light, .bulb)
        XCTAssertEqual(b.material, .fabric)
    }

    /// Review Focus 3: 깨졌거나 옛 판의 값이면 주광색 · 유리로 돌아간다.
    func testUnknownStoredValuesFallBackToDefaults() {
        let defaults = freshDefaults()
        defaults.set("neon", forKey: "hc.light")
        defaults.set(42, forKey: "hc.material")
        let store = ThemeStore(defaults: defaults)
        XCTAssertEqual(store.light, .daylight)
        XCTAssertEqual(store.material, .glass)
    }

    func testSharedWithoutAppGroupUsesStandard() {
        XCTAssertNotNil(ThemeStore.shared(appGroupID: nil))
    }
}
