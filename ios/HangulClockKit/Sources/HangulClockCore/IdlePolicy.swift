// I7: 책상 위 시계로 쓰도록, 앱이 앞에 있고 충전 중일 때만 화면 자동 꺼짐을 끈다.
public enum IdlePolicy {
    public static func keepAwake(isForeground: Bool, isCharging: Bool) -> Bool {
        isForeground && isCharging
    }
}
