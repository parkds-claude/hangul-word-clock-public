// 위젯 3종(스펙 7.2 · 7.3): 잠금화면 "글자 시계"(한 줄 · 직사각형 · 동그라미), 홈 "글자 판"(작은 · 큰), 홈 "글자 문장"(작은).
// 홈 위젯 바탕은 containerBackground 라서 StandBy 에서 아이폰이 지운다.
import HangulClockCore
import HangulClockUI
import SwiftUI
import WidgetKit

private func glassBackground(_ light: LightColor) -> some View {
    WidgetGlassBackground(light: light)
}

struct LockClockWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "LockClockWidget", provider: ClockProvider()) { entry in
            LockClockEntryView(entry: entry)
        }
        .configurationDisplayName("글자 시계")
        .description("잠금화면에 지금 시각을 한글로 보인다.")
        .supportedFamilies([.accessoryInline, .accessoryRectangular, .accessoryCircular])
    }
}

private struct LockClockEntryView: View {
    let entry: ClockEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        let words = ClockWords.at(entry.time)
        switch family {
        case .accessoryInline:
            InlineClockView(words: words).containerBackground(for: .widget) { Color.clear }
        case .accessoryRectangular:
            RectangularClockView(time: entry.time, words: words).containerBackground(for: .widget) { Color.clear }
        default:
            CircularClockView(time: entry.time, words: words).containerBackground(for: .widget) { AccessoryWidgetBackground() }
        }
    }
}

struct GridWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "GridWidget", provider: ClockProvider()) { entry in
            GridEntryView(entry: entry)
        }
        .configurationDisplayName("글자 판")
        .description("6×6 글자 판에 지금 시각의 글자만 켠다.")
        .supportedFamilies([.systemSmall, .systemLarge])
    }
}

private struct GridEntryView: View {
    let entry: ClockEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        let palette = Palettes.palette(entry.light, .glass)
        Group {
            if family == .systemLarge {
                LargeClockView(time: entry.time, words: ClockWords.at(entry.time), palette: palette)
            } else {
                GridSmallView(time: entry.time, palette: palette)
            }
        }
        .containerBackground(for: .widget) { glassBackground(entry.light) }
    }
}

struct SentenceWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "SentenceWidget", provider: ClockProvider()) { entry in
            SentenceSmallView(words: ClockWords.at(entry.time), palette: Palettes.palette(entry.light, .glass))
                .containerBackground(for: .widget) { glassBackground(entry.light) }
        }
        .configurationDisplayName("글자 문장")
        .description("지금 시각을 때 · 시 · 분 세 줄로 보인다.")
        .supportedFamilies([.systemSmall])
    }
}
