// 빛 색 2 × 재질 3 의 색 값(스펙 7.1). 유리 값은 스펙 표, 백자 전구색은 v1 시안(docs/iphone/mockups/v1-materials.html).
// 백자 주광색 · 직물 두 색은 만드는 사람이 정한 값이다(기록장 Ruling). 시뮬레이터 그림으로 사용자에게 보인다.

/// 글자 빛 색. 주광색(차가운 흰빛), 전구색(따뜻한 호박빛).
public enum LightColor: String, CaseIterable, Sendable {
    case daylight, bulb
}

/// 판 재질. 유리가 기본이다.
public enum SlabMaterial: String, CaseIterable, Sendable {
    case glass, porcelain, fabric
}

public struct RGB: Equatable, Sendable {
    public let r: UInt8
    public let g: UInt8
    public let b: UInt8

    public init(hex: UInt32) {
        r = UInt8((hex >> 16) & 0xFF)
        g = UInt8((hex >> 8) & 0xFF)
        b = UInt8(hex & 0xFF)
    }
}

public struct Palette: Equatable, Sendable {
    /// 켜진 숫자 · 시 · 분 글자
    public let lit: RGB
    /// 켜진 때 글자(아침 · 낮 · 저녁 · 밤 · 정오)
    public let period: RGB
    /// 꺼진 글자
    public let unlit: RGB
    /// 켜진 글자의 빛 번짐(pt)
    public let glowRadius: Double
    /// 화면 바탕(가운데 → 바깥)
    public let background: [RGB]
}

public enum Palettes {
    private static let glassDaylightBG = [RGB(hex: 0x20242A), RGB(hex: 0x171A1E), RGB(hex: 0x121417)]
    private static let glassBulbBG = [RGB(hex: 0x2A241E), RGB(hex: 0x1C1814), RGB(hex: 0x141210)]
    private static let porcelainBG = [RGB(hex: 0xF6F3EE), RGB(hex: 0xE6E0D6), RGB(hex: 0xD9D2C6)]
    private static let fabricBG = [RGB(hex: 0xD8D1C5), RGB(hex: 0xCDC4B6)]

    public static func palette(_ light: LightColor, _ material: SlabMaterial) -> Palette {
        switch (material, light) {
        case (.glass, .daylight):
            return Palette(lit: RGB(hex: 0xF4F7FB), period: RGB(hex: 0xCFE0FF), unlit: RGB(hex: 0x50545A),
                           glowRadius: 3, background: glassDaylightBG)
        case (.glass, .bulb):
            return Palette(lit: RGB(hex: 0xFFD9A6), period: RGB(hex: 0xFFB070), unlit: RGB(hex: 0x5A534B),
                           glowRadius: 3, background: glassBulbBG)
        case (.porcelain, .bulb):
            return Palette(lit: RGB(hex: 0xE98F37), period: RGB(hex: 0xE2694C), unlit: RGB(hex: 0xDFD7CA),
                           glowRadius: 3, background: porcelainBG)
        case (.porcelain, .daylight):
            // 흰 도자기 위의 차가운 푸른빛(만드는 사람이 정함)
            return Palette(lit: RGB(hex: 0x4A7CC2), period: RGB(hex: 0x2E5FA8), unlit: RGB(hex: 0xDFD7CA),
                           glowRadius: 3, background: porcelainBG)
        case (.fabric, .daylight):
            // 직물 꺼짐: 바탕 #3C3E41 위 흰색 12%(v1 의 5% 는 두 검토가 안 보인다고 함)
            return Palette(lit: RGB(hex: 0xF4F7FB), period: RGB(hex: 0xCFE0FF), unlit: RGB(hex: 0x535558),
                           glowRadius: 3, background: fabricBG)
        case (.fabric, .bulb):
            return Palette(lit: RGB(hex: 0xFFE6C4), period: RGB(hex: 0xFFC993), unlit: RGB(hex: 0x535558),
                           glowRadius: 3, background: fabricBG)
        }
    }
}
