// 한글 글자 시계: 몇 시 몇 분에 어느 칸을 켜는가.
// 표(ClockTables.swift)는 preview/clock-core.js 에서 만든다. 여기에는 순서만 있다.
// 기기 firmware/hangul_clock/clock_rules.h 의 litCells 와 같은 순서다(I2).

/// 켜진 칸의 종류. rawValue 는 정답표의 kind 이름과 같다.
public enum Kind: String, Sendable {
    case morning, day, evening, night, num, unit, noon
}

/// 때가 시작하는 시. 아침 < 낮 < 저녁 < 밤. 밤은 다음 날 아침 전까지다.
public struct Bounds: Equatable, Sendable {
    public var morning: Int
    public var day: Int
    public var evening: Int
    public var night: Int
    public var noon: Bool

    public init(morning: Int, day: Int, evening: Int, night: Int, noon: Bool) {
        self.morning = morning
        self.day = day
        self.evening = evening
        self.night = night
        self.noon = noon
    }

    public static let standard = Bounds(
        morning: ClockTables.defaultMorning, day: ClockTables.defaultDay,
        evening: ClockTables.defaultEvening, night: ClockTables.defaultNight,
        noon: ClockTables.defaultNoon
    )
}

public struct LitCell: Equatable, Sendable {
    public let cell: Int
    public let kind: Kind

    public init(cell: Int, kind: Kind) {
        self.cell = cell
        self.kind = kind
    }
}

public enum ClockRules {
    /// 0 아침, 1 낮, 2 저녁, 3 밤
    public static func period(hour: Int, bounds: Bounds) -> Int {
        if hour >= bounds.night || hour < bounds.morning { return 3 }
        if hour >= bounds.evening { return 2 }
        if hour >= bounds.day { return 1 }
        return 0
    }

    /// hour 0~23, minute 0~59. 켜지는 칸을 읽는 차례로 돌려준다.
    public static func lit(hour: Int, minute: Int, bounds: Bounds = .standard) -> [LitCell] {
        var out: [LitCell] = []
        func add(_ cells: [Int], _ kind: Kind) { out += cells.map { LitCell(cell: $0, kind: kind) } }

        if bounds.noon && hour == 12 && minute == 0 {
            add(ClockTables.noon, .noon)
            return out
        }
        let p = period(hour: hour, bounds: bounds)
        add(ClockTables.period[p], [Kind.morning, .day, .evening, .night][p])
        let h12 = hour % 12 == 0 ? 12 : hour % 12
        add(ClockTables.hour[h12], .num)
        add(ClockTables.si, .unit)
        if minute > 0 {
            let t = minute / 10, u = minute % 10
            if t >= 2 { add(ClockTables.tens[t], .num) }
            if t >= 1 { add(ClockTables.sip, .num) }
            if u > 0 { add(ClockTables.unit[u], .num) }
            add(ClockTables.bun, .unit)
        }
        return out
    }
}
