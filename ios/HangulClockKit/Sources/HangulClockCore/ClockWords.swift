// 시각을 한국어 말로 바꾼다. 숫자 말은 preview/clock-core.js 의 HOUR_WORD · DIG · sino 와 같다.
// 위젯마다 쓰는 줄 나눔은 스펙 7.4 표를 따른다.
import Foundation

/// 하루 중 시각(시 0~23, 분 0~59).
public struct ClockTime: Equatable, Sendable {
    public let hour: Int
    public let minute: Int

    public init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }

    /// 양력 달력으로 읽는다(아이폰 달력 설정과 상관없이, Review Focus 2). 분은 stepMinutes 의 배수로 내린다.
    public static func from(_ date: Date, timeZone: TimeZone, stepMinutes: Int = 1) -> ClockTime {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = timeZone
        let c = cal.dateComponents([.hour, .minute], from: date)
        let step = max(1, stepMinutes)
        return ClockTime(hour: c.hour ?? 0, minute: (c.minute ?? 0) / step * step)
    }
}

public struct ClockWords: Equatable, Sendable {
    public let isNoon: Bool
    /// 아침 · 낮 · 저녁 · 밤. 정오면 빈 글.
    public let period: String
    /// 예 "여섯". 정오면 "정오".
    public let hourWord: String
    /// 예 "사십오 분". 0분 · 정오면 nil.
    public let minuteWords: String?

    private static let hourNames = ["열두", "한", "두", "세", "네", "다섯", "여섯", "일곱", "여덟", "아홉", "열", "열한"]
    private static let digits = ["", "일", "이", "삼", "사", "오", "육", "칠", "팔", "구"]
    private static let periodNames = ["아침", "낮", "저녁", "밤"]

    /// 예 "여섯 시". 정오면 "정오".
    public var hourText: String { isNoon ? "정오" : "\(hourWord) 시" }

    /// 예 "저녁 여섯 시 사십오 분" · "저녁 여섯 시" · "정오"
    public var sentence: String { ([inline] + (minuteWords.map { [$0] } ?? [])).joined(separator: " ") }

    /// 잠금화면 한 줄: 때 + 시
    public var inline: String { isNoon ? "정오" : "\(period) \(hourText)" }

    /// 작은 위젯 "글자 문장": 때 / 시 / 분
    public var sentenceLines: [String] {
        isNoon ? ["정오"] : [period, hourText] + (minuteWords.map { [$0] } ?? [])
    }

    /// 잠금화면 직사각형 칸: 때 + 시 / 분
    public var rectangularLines: [String] {
        [inline] + (minuteWords.map { [$0] } ?? [])
    }

    public static func at(_ t: ClockTime, bounds: Bounds = .standard) -> ClockWords {
        if bounds.noon && t.hour == 12 && t.minute == 0 {
            return ClockWords(isNoon: true, period: "", hourWord: "정오", minuteWords: nil)
        }
        let p = ClockRules.period(hour: t.hour, bounds: bounds)
        let tens = t.minute / 10, units = t.minute % 10
        let sino = (tens >= 2 ? digits[tens] : "") + (tens >= 1 ? "십" : "") + digits[units]
        return ClockWords(
            isNoon: false,
            period: periodNames[p],
            hourWord: hourNames[t.hour % 12],
            minuteWords: t.minute > 0 ? "\(sino) 분" : nil
        )
    }
}
