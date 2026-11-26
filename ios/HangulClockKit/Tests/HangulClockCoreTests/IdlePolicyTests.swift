import XCTest
@testable import HangulClockCore

/// I7: 앱이 앞에 있고 충전 중일 때만 화면을 켜 둔다.
final class IdlePolicyTests: XCTestCase {
    func testKeepAwakeOnlyWhenForegroundAndCharging() {
        XCTAssertTrue(IdlePolicy.keepAwake(isForeground: true, isCharging: true))
        XCTAssertFalse(IdlePolicy.keepAwake(isForeground: true, isCharging: false))
        XCTAssertFalse(IdlePolicy.keepAwake(isForeground: false, isCharging: true))
        XCTAssertFalse(IdlePolicy.keepAwake(isForeground: false, isCharging: false))
    }
}
