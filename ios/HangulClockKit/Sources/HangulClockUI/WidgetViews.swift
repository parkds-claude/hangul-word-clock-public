// 위젯 화면 6종(스펙 7.2 · 7.3 · 7.4). 위젯 확장은 이 화면을 감싸기만 한다.
// 바탕은 위젯 확장이 containerBackground 로 붙인다(StandBy 에서 아이폰이 지울 수 있게).
// 글자는 모두 고정 크기(Review Focus 4).
import HangulClockCore
import SwiftUI
import WidgetKit

// MARK: 잠금화면

/// 날짜 옆 한 줄: 때 + 시
public struct InlineClockView: View {
    let words: ClockWords
    public init(words: ClockWords) { self.words = words }

    public var body: some View {
        Text(words.inline).font(HangulFonts.font(.sansMedium, size: 15))
    }
}

/// 큰 시계 아래 직사각형 칸: 왼쪽 작은 판, 오른쪽 문장 두 줄(제목 없음). 잠금화면은 늘 한 색이다.
public struct RectangularClockView: View {
    let time: ClockTime
    let words: ClockWords
    public init(time: ClockTime, words: ClockWords) {
        self.time = time
        self.words = words
    }

    public var body: some View {
        GeometryReader { geo in
            let side = geo.size.height - 6
            HStack(spacing: 7) {
                GridView(lit: ClockRules.lit(hour: time.hour, minute: time.minute), palette: Palettes.palette(.daylight, .glass),
                         face: .sansMedium, fontSize: side / 6 * 0.72, monochrome: true)
                    .frame(width: side, height: side)
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(Array(words.rectangularLines.enumerated()), id: \.offset) { i, line in
                        Text(line)
                            .font(HangulFonts.font(.sansMedium, size: 14))
                            .foregroundStyle(Color.white.opacity(i == 0 ? 1 : 0.8))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                }
                Spacer(minLength: 0)
            }
            .frame(maxHeight: .infinity)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(words.sentence)
    }
}

/// 동그라미: 가운데 시 글자, 바깥 고리가 분(분/60). 0분 · 정오는 빈 고리.
public struct CircularClockView: View {
    let time: ClockTime
    let words: ClockWords
    public init(time: ClockTime, words: ClockWords) {
        self.time = time
        self.words = words
    }

    /// 가운데 글: 시 이름(예 "여섯"), 정오면 "정오"
    public var centerText: String { words.hourWord }
    /// 고리 비율 0~1
    public var ringFraction: Double { words.isNoon ? 0 : Double(time.minute) / 60 }
    /// VoiceOver 가 읽는 글: 문장 전체(최종 검토)
    public var accessibilityText: String { words.sentence }

    public var body: some View {
        ZStack {
            Circle().stroke(Color.white.opacity(0.25), lineWidth: 4)
            Circle()
                .trim(from: 0, to: ringFraction)
                .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .widgetAccentable()
            Text(centerText)
                .font(HangulFonts.font(.sansMedium, size: 19))
                .foregroundStyle(Color.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(10)
        }
        .padding(3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }
}

// MARK: 홈 화면 · StandBy

/// 작은 위젯 "글자 판"
public struct GridSmallView: View {
    let time: ClockTime
    let palette: Palette
    @Environment(\.widgetRenderingMode) private var renderingMode

    public init(time: ClockTime, palette: Palette) {
        self.time = time
        self.palette = palette
    }

    /// VoiceOver 가 읽는 글: 판은 숨기고 문장을 읽는다(최종 검토)
    public var accessibilityText: String { ClockWords.at(time).sentence }

    public var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            GridView(lit: ClockRules.lit(hour: time.hour, minute: time.minute), palette: palette, face: .sansMedium,
                     fontSize: side / 6 * 0.62, monochrome: renderingMode != .fullColor)
                .frame(width: side, height: side)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }
}

/// 작은 위젯 "글자 문장": 때(작게) / 시 / 분. 0분은 두 줄, 정오는 한 줄.
public struct SentenceSmallView: View {
    let words: ClockWords
    let palette: Palette
    @Environment(\.widgetRenderingMode) private var renderingMode

    public init(words: ClockWords, palette: Palette) {
        self.words = words
        self.palette = palette
    }

    private var mono: Bool { renderingMode != .fullColor }
    private var litColor: Color { mono ? .white : Color(palette.lit) }
    private var periodColor: Color { mono ? .white : Color(palette.period) }

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if words.isNoon {
                Text("정오").font(HangulFonts.font(.sansLight, size: 46)).foregroundStyle(periodColor)
            } else {
                Text(words.period).font(HangulFonts.font(.sansMedium, size: 17)).foregroundStyle(periodColor)
                Text(words.hourText).font(HangulFonts.font(.sansLight, size: 32)).foregroundStyle(litColor)
                if let minute = words.minuteWords {
                    Text(minute).font(HangulFonts.font(.sansLight, size: 32)).foregroundStyle(litColor.opacity(0.82))
                }
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(words.sentence)
    }
}

/// 큰 위젯: 판 + 아래 문장
public struct LargeClockView: View {
    let time: ClockTime
    let words: ClockWords
    let palette: Palette
    @Environment(\.widgetRenderingMode) private var renderingMode

    public init(time: ClockTime, words: ClockWords, palette: Palette) {
        self.time = time
        self.words = words
        self.palette = palette
    }

    public var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height - 30)
            VStack(spacing: 8) {
                GridView(lit: ClockRules.lit(hour: time.hour, minute: time.minute), palette: palette, face: .sansMedium,
                         fontSize: side / 6 * 0.62, monochrome: renderingMode != .fullColor)
                    .frame(width: side, height: side)
                Text(words.sentence)
                    .font(HangulFonts.font(.sansLight, size: 17))
                    .foregroundStyle(renderingMode != .fullColor ? Color.white : Color(palette.lit).opacity(0.78))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(words.sentence)
    }
}
