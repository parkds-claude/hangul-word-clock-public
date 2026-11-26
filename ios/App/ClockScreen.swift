// 앱 첫 화면: 1분마다 ClockScreenContent 를 다시 그린다. 빛 색 · 재질을 바꾸면 저장하고 위젯을 새로 그린다.
import HangulClockCore
import HangulClockUI
import SwiftUI
import WidgetKit

struct ClockScreen: View {
    private let store = ThemeStore.shared(appGroupID: Bundle.main.object(forInfoDictionaryKey: "HCAppGroupID") as? String)
    @State private var light: LightColor = .daylight
    @State private var material: SlabMaterial = .glass
    @State private var loaded = false

    var body: some View {
        TimelineView(.everyMinute) { context in
            ClockScreenContent(now: context.date, timeZone: .current, light: $light, material: $material)
        }
        .onAppear {
            guard !loaded else { return }
            light = store.light
            material = store.material
            loaded = true
        }
        .onChange(of: light) { _, value in
            store.light = value
            WidgetCenter.shared.reloadAllTimelines()
        }
        .onChange(of: material) { _, value in
            store.material = value
        }
        .statusBarHidden(false)
        .preferredColorScheme(ClockScreenContent.preferredScheme(for: material))
    }
}
