// 위젯 시간표 항목(I6): 언제(date) 어떤 시각(time)을 어떤 빛 색(light)으로 그릴지.
import Foundation

public struct EntryPlan: Equatable, Sendable {
    public let date: Date
    public let time: ClockTime
    public let light: LightColor

    public init(date: Date, time: ClockTime, light: LightColor) {
        self.date = date
        self.time = time
        self.light = light
    }

    /// 항목 TimelineSteps.entryCount 개. 각 time 은 그 date 를 step 분 단위로 내린 시각.
    public static func plan(now: Date, timeZone: TimeZone, light: LightColor,
                            step: Int = TimelineSteps.widgetStepMinutes) -> [EntryPlan] {
        TimelineSteps.dates(from: now, stepMinutes: step, count: TimelineSteps.entryCount, timeZone: timeZone).map {
            EntryPlan(date: $0, time: ClockTime.from($0, timeZone: timeZone, stepMinutes: step), light: light)
        }
    }

    /// 새 시간표를 받을 시각: 항목 10개를 남긴 때(60개면 50번째). 마지막 항목까지 기다리면
    /// 새로 받는 일이 늦을 때 위젯이 마지막 분에 멈춘다(최종 검토 Important 1, 스펙 4절).
    public static func reloadDate(for plan: [EntryPlan]) -> Date? {
        guard !plan.isEmpty else { return nil }
        return plan.count > 10 ? plan[plan.count - 10].date : plan[0].date
    }
}
