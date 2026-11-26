// 판 글자 30자 글꼴 4개를 등록하고 쓴다(스펙 I4). 글꼴은 tools/subset_fonts.py 가 만든다.
// 앱과 위젯 확장이 각자 registerAll() 을 부른다. 패키지 리소스(Bundle.module)에서 읽으므로 Info.plist 는 필요 없다.
import CoreText
import SwiftUI

public enum HangulFonts {
    public enum Face: String, CaseIterable, Sendable {
        case sansLight = "HCSans-Light"
        case sansMedium = "HCSans-Medium"
        case serifRegular = "HCSerif-Regular"
        case groteskMedium = "HCGrotesk-Medium"

        /// 글꼴을 못 쓸 때 시스템 글꼴의 굵기
        var fallbackWeight: Font.Weight {
            switch self {
            case .sansLight: return .light
            case .sansMedium, .groteskMedium: return .medium
            case .serifRegular: return .regular
            }
        }
    }

    /// 네 글꼴을 등록한다. 이미 등록돼 있으면 성공으로 친다.
    @discardableResult
    public static func registerAll() -> [Face: Bool] {
        var out: [Face: Bool] = [:]
        for face in Face.allCases {
            let url = Bundle.module.url(forResource: face.rawValue, withExtension: "ttf", subdirectory: "Fonts")
            out[face] = (url.map(register(url:)) ?? false) || isAvailable(face)
        }
        return out
    }

    /// 실패해도 멈추지 않고 false 를 돌려준다(Review Focus 5).
    @discardableResult
    public static func register(url: URL) -> Bool {
        var error: Unmanaged<CFError>?
        if CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) { return true }
        if let e = error?.takeRetainedValue(), CFErrorGetCode(e) == CTFontManagerError.alreadyRegistered.rawValue {
            return true
        }
        return false
    }

    public static func isAvailable(_ face: Face) -> Bool {
        isAvailable(postScriptName: face.rawValue)
    }

    /// 고정 크기 글꼴. 손쉬운 사용의 글자 크기 설정에 따라 커지지 않는다(Review Focus 4).
    public static func font(_ face: Face, size: CGFloat) -> Font {
        font(postScriptName: face.rawValue, size: size, weight: face.fallbackWeight)
    }

    static func isAvailable(postScriptName: String) -> Bool {
        let f = CTFontCreateWithName(postScriptName as CFString, 12, nil)
        return (CTFontCopyPostScriptName(f) as String) == postScriptName
    }

    static func font(postScriptName: String, size: CGFloat, weight: Font.Weight) -> Font {
        isAvailable(postScriptName: postScriptName)
            ? .custom(postScriptName, fixedSize: size)
            : .system(size: size, weight: weight)
    }
}
