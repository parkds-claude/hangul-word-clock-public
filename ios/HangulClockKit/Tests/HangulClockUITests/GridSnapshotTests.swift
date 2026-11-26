import HangulClockCore
import SwiftUI
import XCTest
@testable import HangulClockUI

/// 판과 재질 6가지(빛 색 2 × 재질 3). 18:45 로 그린다.
@MainActor
final class GridSnapshotTests: XCTestCase {
    private let lit1845 = ClockRules.lit(hour: 18, minute: 45)
    private let litCells: Set<Int> = [3, 4, 12, 13, 19, 23, 25, 30, 35]

    override func setUp() {
        super.setUp()
        HangulFonts.registerAll()
    }

    func testSixCombosRender() throws {
        for light in LightColor.allCases {
            for material in SlabMaterial.allCases {
                let view = SlabView(material: material, palette: Palettes.palette(light, material), lit: lit1845)
                    .padding(36)
                    .background(Color(Palettes.palette(light, material).background[0]))
                let img = try XCTUnwrap(Snapshot.render(view, size: CGSize(width: 360, height: 360)), "\(light) \(material)")
                XCTAssertEqual(img.width, 1080)
                Snapshot.save(img, name: "slab-\(light.rawValue)-\(material.rawValue)")
            }
        }
    }

    /// 칸 = 240pt 판을 6등분. 칸 가운데(안쪽 8pt 를 뺀 곳)의 평균 밝기를 잰다.
    private func cellLumas(_ img: CGImage) -> [Int: Double] {
        var out: [Int: Double] = [:]
        for i in 0..<36 {
            let rect = CGRect(x: CGFloat(i % 6) * 40 + 8, y: CGFloat(i / 6) * 40 + 8, width: 24, height: 24)
            out[i] = Snapshot.meanLuma(img, rect: rect)
        }
        return out
    }

    func testLitCellsBrighterThanUnlit() throws {
        let view = GridView(lit: lit1845, palette: Palettes.palette(.daylight, .glass), face: .sansMedium, fontSize: 26)
            .background(Color.black)
        let img = try XCTUnwrap(Snapshot.render(view, size: CGSize(width: 240, height: 240)))
        Snapshot.save(img, name: "grid-daylight-glass")
        let l = cellLumas(img)
        let litMin = litCells.map { l[$0]! }.min()!
        let unlitMax = (0..<36).filter { !litCells.contains($0) }.map { l[$0]! }.max()!
        XCTAssertGreaterThan(litMin, unlitMax)
    }

    func testMonochromeOpacities() throws {
        let view = GridView(lit: lit1845, palette: Palettes.palette(.daylight, .glass), face: .sansMedium, fontSize: 26,
                            monochrome: true)
            .background(Color.black)
        let img = try XCTUnwrap(Snapshot.render(view, size: CGSize(width: 240, height: 240)))
        Snapshot.save(img, name: "grid-monochrome")
        let l = cellLumas(img)
        let litMean = litCells.map { l[$0]! }.reduce(0, +) / Double(litCells.count)
        let unlit = (0..<36).filter { !litCells.contains($0) }
        let unlitMean = unlit.map { l[$0]! }.reduce(0, +) / Double(unlit.count)
        XCTAssertGreaterThanOrEqual(litMean, unlitMean * 2.5)
    }
}
