// 홈 화면 위젯 바탕: 앱 바탕보다 조금 밝은 유리판(시안 v2 의 .wl). Codex 검토 1.
// 위젯 확장이 containerBackground 로 붙이므로 StandBy 에서는 아이폰이 지운다.
import HangulClockCore
import SwiftUI

public struct WidgetGlassBackground: View {
    let light: LightColor
    public init(light: LightColor) { self.light = light }

    public var body: some View {
        let hex: [UInt32] = light == .daylight ? [0x2A2E35, 0x171A1E, 0x1D2025] : [0x352D25, 0x1C1814, 0x221D19]
        LinearGradient(stops: [
            .init(color: Color(RGB(hex: hex[0])), location: 0),
            .init(color: Color(RGB(hex: hex[1])), location: 0.55),
            .init(color: Color(RGB(hex: hex[2])), location: 1),
        ], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
