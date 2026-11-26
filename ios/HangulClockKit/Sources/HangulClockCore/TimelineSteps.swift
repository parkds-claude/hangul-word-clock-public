// 위젯 시간표(I6). 위젯은 이 시각들마다 그려 둔 화면을 아이폰이 바꿔 단다.
import Foundation

public enum TimelineSteps {
    /// 위젯 간격(분). 기기 시험에서 1분 넘게 늦는 일이 잦으면 5 로 바꾼다(스펙 I6).
    public static let widgetStepMinutes = 1
    /// 한 번에 넣는 항목 수. 다 쓰면 아이폰이 다시 받는다(.atEnd).
    public static let entryCount = 60

    /// 첫 항목은 now. 나머지는 now 뒤의 stepMinutes 배수 분 경계(초 0).
    /// 분 경계는 달력으로 구한다. 초를 더하지 않으므로 서머타임에 없는 시각이 나오지 않는다.
    public static func dates(from now: Date, stepMinutes: Int, count: Int, timeZone: TimeZone) -> [Date] {
        guard count > 0 else { return [] }
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = timeZone
        let step = max(1, stepMinutes)
        var out = [now]
        var t = now
        while out.count < count {
            guard let next = cal.nextDate(after: t, matching: DateComponents(second: 0), matchingPolicy: .nextTime) else { break }
            t = next
            if cal.component(.minute, from: next) % step == 0 { out.append(next) }
        }
        return out
    }
}
