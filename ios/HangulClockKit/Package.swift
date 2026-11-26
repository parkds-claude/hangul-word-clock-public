// swift-tools-version: 5.10
// 한글 글자 시계 아이폰
//   HangulClockCore: 규칙 · 문장 · 시간표 · 색 값(Foundation 만)
//   HangulClockUI:   판 · 재질 · 위젯 화면(SwiftUI), 판 글자 30자 글꼴 리소스
// 5.10: Swift 6 언어 모드의 엄격한 동시성 오류를 피한다(계획 기록장 Ruling).
import PackageDescription

let package = Package(
    name: "HangulClockKit",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "HangulClockCore", targets: ["HangulClockCore"]),
        .library(name: "HangulClockUI", targets: ["HangulClockUI"]),
    ],
    targets: [
        .target(name: "HangulClockCore"),
        .target(
            name: "HangulClockUI",
            dependencies: ["HangulClockCore"],
            resources: [.copy("Fonts")]
        ),
        .testTarget(
            name: "HangulClockCoreTests",
            dependencies: ["HangulClockCore"],
            resources: [.copy("Golden")]
        ),
        .testTarget(
            name: "HangulClockUITests",
            dependencies: ["HangulClockUI"]
        ),
    ]
)
