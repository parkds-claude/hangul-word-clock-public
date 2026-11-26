// 빛 색 · 재질 설정 저장(I3). 앱 그룹 공유 설정에 두어 앱과 위젯이 함께 쓴다.
// 앱 그룹을 열 수 없으면(이름이 없거나 무료 계정에서 막힘) 이 앱만의 설정을 쓴다.
import Foundation

public final class ThemeStore {
    private let defaults: UserDefaults
    private static let lightKey = "hc.light"
    private static let materialKey = "hc.material"

    public init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    /// 모르는 값(깨졌거나 옛 판의 값)이면 주광색(Review Focus 3).
    public var light: LightColor {
        get { defaults.string(forKey: Self.lightKey).flatMap(LightColor.init(rawValue:)) ?? .daylight }
        set { defaults.set(newValue.rawValue, forKey: Self.lightKey) }
    }

    /// 모르는 값이면 유리.
    public var material: SlabMaterial {
        get { defaults.string(forKey: Self.materialKey).flatMap(SlabMaterial.init(rawValue:)) ?? .glass }
        set { defaults.set(newValue.rawValue, forKey: Self.materialKey) }
    }

    public static func shared(appGroupID: String?) -> ThemeStore {
        let group = appGroupID.flatMap { $0.isEmpty ? nil : UserDefaults(suiteName: $0) }
        return ThemeStore(defaults: group ?? .standard)
    }
}
