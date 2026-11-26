import CoreGraphics
import ImageIO
import SwiftUI
import UniformTypeIdentifiers

/// 시험용 그림 도우미. 그림은 HC_SNAPSHOT_DIR(tools/ios.sh test-ui 가 build-ios/snapshots 로 넘김)에 쓴다.
enum Snapshot {
    static let scale: CGFloat = 3

    @MainActor
    static func render<V: View>(_ view: V, size: CGSize, dynamicType: DynamicTypeSize = .large) -> CGImage? {
        let renderer = ImageRenderer(content: view
            .frame(width: size.width, height: size.height)
            .environment(\.dynamicTypeSize, dynamicType))
        renderer.scale = scale
        return renderer.cgImage
    }

    static func save(_ image: CGImage, name: String) {
        guard let dir = ProcessInfo.processInfo.environment["HC_SNAPSHOT_DIR"], !dir.isEmpty else { return }
        let url = URL(fileURLWithPath: dir).appendingPathComponent("\(name).png")
        guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else { return }
        CGImageDestinationAddImage(dest, image, nil)
        CGImageDestinationFinalize(dest)
    }

    /// rect(pt) 안 픽셀의 평균 밝기(0~1).
    static func meanLuma(_ image: CGImage, rect: CGRect) -> Double {
        let px = rgba(image)
        let x0 = max(0, Int(rect.minX * scale)), x1 = min(image.width, Int(rect.maxX * scale))
        let y0 = max(0, Int(rect.minY * scale)), y1 = min(image.height, Int(rect.maxY * scale))
        var sum = 0.0, n = 0.0
        for y in y0..<y1 {
            for x in x0..<x1 {
                let i = (y * image.width + x) * 4
                sum += (0.2126 * Double(px[i]) + 0.7152 * Double(px[i + 1]) + 0.0722 * Double(px[i + 2])) / 255
                n += 1
            }
        }
        return n > 0 ? sum / n : 0
    }

    /// 두 그림의 픽셀이 같은가
    static func samePixels(_ a: CGImage, _ b: CGImage) -> Bool {
        a.width == b.width && a.height == b.height && rgba(a) == rgba(b)
    }

    private static func rgba(_ image: CGImage) -> [UInt8] {
        var buf = [UInt8](repeating: 0, count: image.width * image.height * 4)
        let ctx = CGContext(data: &buf, width: image.width, height: image.height, bitsPerComponent: 8,
                            bytesPerRow: image.width * 4, space: CGColorSpaceCreateDeviceRGB(),
                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        ctx.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        return buf
    }
}
