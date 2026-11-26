// 앱 첫 화면 본체(스펙 7.1). 앱의 ClockScreen 이 1분마다 now 를 넘겨 다시 그린다.
// 첫 화면의 조작은 빛 색 동그라미 2개와 재질 점 3개뿐이다(스펙 4절). 재질은 판을 옆으로 밀어 바꾼다.
import HangulClockCore
import SwiftUI

public struct ClockScreenContent: View {
    let now: Date
    let timeZone: TimeZone
    @Binding var light: LightColor
    @Binding var material: SlabMaterial

    public init(now: Date, timeZone: TimeZone, light: Binding<LightColor>, material: Binding<SlabMaterial>) {
        self.now = now
        self.timeZone = timeZone
        self._light = light
        self._material = material
    }

    var time: ClockTime { ClockTime.from(now, timeZone: timeZone) }

    /// VoiceOver 가 읽는 문장
    public var sentence: String { ClockWords.at(time).sentence }

    /// 예 "11월 26일 목요일"
    public var dateText: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.timeZone = timeZone
        f.dateFormat = "M월 d일 EEEE"
        return f.string(from: now)
    }

    /// 화면 모드: 유리는 어두운 방(어두운 모드), 백자 · 직물은 밝은 방(밝은 모드). 상태 표시줄 글자가 바탕에서 보이게(최종 검토).
    public static func preferredScheme(for material: SlabMaterial) -> ColorScheme {
        material == .glass ? .dark : .light
    }

    /// 판 위 여백. 시안의 176pt 는 화면 맨 위부터라, 상태 표시줄 영역(safeTop)만큼 뺀다(Codex 검토 2).
    public static func slabTop(safeTop: CGFloat) -> CGFloat { max(0, 176 - safeTop) }

    /// 유리는 어두운 방이라 흰 글, 백자 · 직물은 밝은 방이라 짙은 글
    private var ink: Color { material == .glass ? .white : Color(RGB(hex: 0x2A2622)) }

    public var body: some View {
        let palette = Palettes.palette(light, material)
        ZStack {
            RadialGradient(colors: palette.background.map(Color.init), center: UnitPoint(x: 0.5, y: 0.36),
                           startRadius: 0, endRadius: 560)
                .ignoresSafeArea()
            GeometryReader { geo in
            VStack(spacing: 0) {
                Spacer().frame(height: Self.slabTop(safeTop: geo.safeAreaInsets.top))
                SlabView(material: material, palette: palette, lit: ClockRules.lit(hour: time.hour, minute: time.minute))
                    .animation(.easeInOut(duration: 0.6), value: time.minute)
                    .contentShape(Rectangle())
                    .gesture(DragGesture(minimumDistance: 30).onEnded { value in
                        if value.translation.width < -40 { step(+1) }
                        if value.translation.width > 40 { step(-1) }
                    })
                Text(sentence)
                    .font(HangulFonts.font(.sansLight, size: 19))
                    .foregroundStyle(ink.opacity(0.78))
                    .padding(.top, 24)
                Text(dateText)
                    .font(.system(size: 13))
                    .foregroundStyle(ink.opacity(0.38))
                    .padding(.top, 8)
                colorDots.padding(.top, 40)
                Spacer()
                pageDots.padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity)
            }
        }
    }

    private func step(_ delta: Int) {
        let all = SlabMaterial.allCases
        let i = all.firstIndex(of: material) ?? 0
        withAnimation(.easeInOut(duration: 0.3)) { material = all[(i + delta + all.count) % all.count] }
    }

    private var colorDots: some View {
        HStack(spacing: 22) {
            ForEach(LightColor.allCases, id: \.self) { c in
                Button { light = c } label: {
                    Circle()
                        .fill(RadialGradient(colors: c == .daylight ? [.white, Color(RGB(hex: 0xDFE8F5))]
                                                                     : [Color(RGB(hex: 0xFFE3BD)), Color(RGB(hex: 0xF2A65A))],
                                             center: UnitPoint(x: 0.35, y: 0.3), startRadius: 0, endRadius: 14))
                        .frame(width: 24, height: 24)
                        .overlay(Circle().stroke(ink.opacity(0.85), lineWidth: 2).padding(-6).opacity(light == c ? 1 : 0))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(c == .daylight ? "주광색" : "전구색")
                .accessibilityAddTraits(light == c ? .isSelected : [])
            }
        }
    }

    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(SlabMaterial.allCases, id: \.self) { m in
                Circle().fill(ink.opacity(material == m ? 0.85 : 0.25)).frame(width: 7, height: 7)
            }
        }
        .accessibilityElement()
        .accessibilityLabel("재질")
        .accessibilityValue(material == .glass ? "유리" : material == .porcelain ? "백자" : "직물")
        .accessibilityAdjustableAction { direction in
            step(direction == .increment ? +1 : -1)
        }
    }
}
