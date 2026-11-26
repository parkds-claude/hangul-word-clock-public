// 판을 담는 물체: 서리 유리 · 백자 · 직물. 값은 docs/iphone/mockups 의 v2(유리) · v1(백자 A, 직물 C).
// 유리에는 받침 · 바닥 비침이 없다(사용자 지시 2026-11-26).
import HangulClockCore
import SwiftUI

public struct SlabView: View {
    let material: SlabMaterial
    let palette: Palette
    let lit: [LitCell]
    let size: CGFloat

    public init(material: SlabMaterial, palette: Palette, lit: [LitCell], size: CGFloat = 288) {
        self.material = material
        self.palette = palette
        self.lit = lit
        self.size = size
    }

    /// 288pt 판 기준 값을 size 에 맞춰 줄이거나 키운다.
    private func s(_ v: CGFloat) -> CGFloat { v * size / 288 }

    private var face: HangulFonts.Face {
        switch material {
        case .glass: return .sansMedium
        case .porcelain: return .serifRegular
        case .fabric: return .groteskMedium
        }
    }

    private var inset: CGFloat {
        switch material {
        case .glass: return s(24)
        case .porcelain: return s(23)
        case .fabric: return s(26)
        }
    }

    public var body: some View {
        ZStack {
            surface
            GridView(lit: lit, palette: palette, face: face, fontSize: (size - 2 * inset) / 6 * 0.65)
                .padding(inset)
        }
        .frame(width: size, height: size)
    }

    @ViewBuilder
    private var surface: some View {
        switch material {
        case .glass:
            let shape = RoundedRectangle(cornerRadius: s(22), style: .continuous)
            shape
                // Gemini 검토 1: 시안 밝기(판 안 - 바탕 +20.6)에 맞춰 흰빛을 1.3배로(0.11/0.035/0.07 은 +16.7 이었다)
                .fill(LinearGradient(colors: [.white.opacity(0.145), .white.opacity(0.046), .white.opacity(0.092)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(shape.strokeBorder(.white.opacity(0.15), lineWidth: 1))
                .overlay(shape.strokeBorder(LinearGradient(colors: [.white.opacity(0.3), .clear],
                                                           startPoint: .top, endPoint: .center), lineWidth: 1))
                .shadow(color: .black.opacity(0.6), radius: s(24), y: s(22))
        case .porcelain:
            let shape = RoundedRectangle(cornerRadius: s(31), style: .continuous)
            shape
                .fill(RadialGradient(colors: [Color(RGB(hex: 0xFDFBF8)), Color(RGB(hex: 0xF1EBE2)), Color(RGB(hex: 0xE7E0D5))],
                                     center: UnitPoint(x: 0.32, y: 0.22), startRadius: 0, endRadius: size * 0.9))
                .overlay(shape.strokeBorder(LinearGradient(colors: [.white, .clear, Color(red: 0.47, green: 0.39, blue: 0.27).opacity(0.13)],
                                                           startPoint: .top, endPoint: .bottom), lineWidth: s(2)))
                .shadow(color: Color(red: 0.31, green: 0.24, blue: 0.16).opacity(0.4), radius: s(16), y: s(18))
        case .fabric:
            let shape = RoundedRectangle(cornerRadius: s(42), style: .continuous)
            shape
                .fill(Color(RGB(hex: 0x3C3E41)))
                .overlay(FabricWeave().clipShape(shape))
                .overlay(shape.strokeBorder(LinearGradient(colors: [.white.opacity(0.08), .clear, .black.opacity(0.3)],
                                                           startPoint: .top, endPoint: .bottom), lineWidth: s(2)))
                .shadow(color: Color(red: 0.16, green: 0.12, blue: 0.08).opacity(0.5), radius: s(12), y: s(14))
        }
    }
}

/// 스피커 천 같은 엇갈린 짜임(v1 직물의 두 방향 줄무늬)
private struct FabricWeave: View {
    var body: some View {
        Canvas { ctx, size in
            let step: CGFloat = 4
            var light = Path(), dark = Path()
            var x: CGFloat = -size.height
            while x < size.width + size.height {
                light.move(to: CGPoint(x: x, y: 0)); light.addLine(to: CGPoint(x: x + size.height, y: size.height))
                dark.move(to: CGPoint(x: x + size.height, y: 0)); dark.addLine(to: CGPoint(x: x, y: size.height))
                x += step
            }
            ctx.stroke(light, with: .color(.white.opacity(0.04)), lineWidth: 2)
            ctx.stroke(dark, with: .color(.black.opacity(0.2)), lineWidth: 2)
        }
    }
}
