// 6×6 판. 켜진 칸은 빛 색, 꺼진 칸은 옅은 색. 판 크기는 부모가 정한다(칸 = 1/6).
import HangulClockCore
import SwiftUI
import WidgetKit

public struct GridView: View {
    let lit: [LitCell]
    let palette: Palette
    let face: HangulFonts.Face
    let fontSize: CGFloat
    let monochrome: Bool

    /// monochrome: 잠금화면 · 색 입힘 모드용. 색 없이 켜짐 불투명, 꺼짐 25%.
    public init(lit: [LitCell], palette: Palette, face: HangulFonts.Face, fontSize: CGFloat, monochrome: Bool = false) {
        self.lit = lit
        self.palette = palette
        self.face = face
        self.fontSize = fontSize
        self.monochrome = monochrome
    }

    private static let periodKinds: Set<Kind> = [.morning, .day, .evening, .night, .noon]

    public var body: some View {
        let kinds = Dictionary(lit.map { ($0.cell, $0.kind) }, uniquingKeysWith: { first, _ in first })
        VStack(spacing: 0) {
            ForEach(0..<6, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<6, id: \.self) { col in
                        cell(row * 6 + col, kind: kinds[row * 6 + col])
                    }
                }
            }
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func cell(_ index: Int, kind: Kind?) -> some View {
        let text = Text(ClockTables.grid[index]).font(HangulFonts.font(face, size: fontSize))
        Group {
            if monochrome {
                if kind != nil {
                    text.foregroundStyle(Color.white).widgetAccentable()
                } else {
                    text.foregroundStyle(Color.white.opacity(0.25))
                }
            } else if let kind {
                let color = Color(Self.periodKinds.contains(kind) ? palette.period : palette.lit)
                text.foregroundStyle(color)
                    .shadow(color: color.opacity(0.6), radius: palette.glowRadius)
            } else {
                text.foregroundStyle(Color(palette.unlit))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
