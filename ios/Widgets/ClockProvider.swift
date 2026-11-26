// 위젯 시간표: 지금부터 1분(또는 5분) 간격 항목 60개를 넣고, 다 쓰면 아이폰이 다시 받는다(I6).
// 빛 색은 앱 그룹 공유 설정에서 읽는다(I3).
import Foundation
import HangulClockCore
import HangulClockUI
import WidgetKit

struct ClockEntry: TimelineEntry {
    let date: Date
    let time: ClockTime
    let light: LightColor
}

struct ClockProvider: TimelineProvider {
    private var store: ThemeStore {
        ThemeStore.shared(appGroupID: Bundle.main.object(forInfoDictionaryKey: "HCAppGroupID") as? String)
    }

    private func plan(now: Date) -> [EntryPlan] {
        EntryPlan.plan(now: now, timeZone: .current, light: store.light)
    }

    private func entries(now: Date) -> [ClockEntry] {
        plan(now: now).map { ClockEntry(date: $0.date, time: $0.time, light: $0.light) }
    }

    func placeholder(in context: Context) -> ClockEntry {
        ClockEntry(date: .now, time: ClockTime(hour: 18, minute: 45), light: .daylight)
    }

    func getSnapshot(in context: Context, completion: @escaping (ClockEntry) -> Void) {
        completion(entries(now: .now)[0])
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ClockEntry>) -> Void) {
        HangulFonts.registerAll()
        let now = Date.now
        let p = plan(now: now)
        let entries = p.map { ClockEntry(date: $0.date, time: $0.time, light: $0.light) }
        // 10개를 남기고 새로 받는다(최종 검토 Important 1)
        let reload = EntryPlan.reloadDate(for: p) ?? now.addingTimeInterval(60)
        completion(Timeline(entries: entries, policy: .after(reload)))
    }
}
