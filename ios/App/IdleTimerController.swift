// I7: 앱이 앞에 있고 충전 중(충전 중 · 다 참)이면 화면 자동 꺼짐을 끈다. 판단은 IdlePolicy(시험 있음).
import HangulClockCore
import SwiftUI
import UIKit

private struct KeepAwakeWhenCharging: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        content
            .onAppear {
                UIDevice.current.isBatteryMonitoringEnabled = true
                update()
            }
            .onChange(of: scenePhase) { _, _ in update() }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.batteryStateDidChangeNotification)) { _ in update() }
    }

    private func update() {
        let state = UIDevice.current.batteryState
        UIApplication.shared.isIdleTimerDisabled = IdlePolicy.keepAwake(
            isForeground: scenePhase == .active,
            isCharging: state == .charging || state == .full
        )
    }
}

extension View {
    func keepAwakeWhenCharging() -> some View { modifier(KeepAwakeWhenCharging()) }
}
