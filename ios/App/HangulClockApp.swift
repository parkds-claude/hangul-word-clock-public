import HangulClockUI
import SwiftUI

@main
struct HangulClockApp: App {
    init() {
        HangulFonts.registerAll()
    }

    var body: some Scene {
        WindowGroup {
            ClockScreen()
                .keepAwakeWhenCharging()
        }
    }
}
