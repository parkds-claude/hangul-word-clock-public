import HangulClockUI
import SwiftUI
import WidgetKit

@main
struct HangulClockWidgetBundle: WidgetBundle {
    init() {
        HangulFonts.registerAll()
    }

    var body: some Widget {
        LockClockWidget()
        GridWidget()
        SentenceWidget()
    }
}
