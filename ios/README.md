# 한글 글자 시계: 아이폰 앱 설치 안내

6×6 한글 글자판에서 지금 시각의 글자에만 불이 켜지는 시계입니다. 앱, 홈 화면 위젯, 잠금화면 위젯, StandBy(충전 중 탁상시계)에서 씁니다.

이 앱은 App Store 에 없습니다. 맥에서 Xcode 로 직접 빌드해 내 아이폰에 설치합니다.

## 1. 필요한 것

- 맥 1대와 Xcode. Xcode 26 · 27 에서 빌드를 확인했습니다. Xcode 는 맥 App Store 에서 무료로 받습니다.
- 아이폰 1대. iOS 17 이상이어야 합니다. StandBy 와 지금 쓰는 위젯 기능이 iOS 17 부터 있습니다.
- 맥과 아이폰을 잇는 USB 케이블.
- Apple ID. 무료 계정으로 됩니다. 유료 개발자 계정(연 99달러)은 없어도 됩니다.

경고: 무료 Apple ID 로 설치한 앱은 7일이 지나면 열리지 않습니다. 7일마다 이 안내의 4절을 다시 하면 됩니다. 유료 개발자 계정이면 1년 동안 열립니다.

## 2. 처음 한 번만 하는 준비

1. Xcode 를 엽니다. 메뉴 Xcode → 설정(Settings) → Accounts 로 갑니다.
2. 왼쪽 아래 + 를 누르고 Apple ID 로 로그인합니다.
3. 아이폰에서 설정 → 개인정보 보호 및 보안 → 개발자 모드를 켭니다. 아이폰이 다시 켜집니다. 이 메뉴는 아이폰을 맥에 한 번 꽂은 뒤에 보일 수 있습니다.
4. 아이폰을 USB 케이블로 맥에 꽂습니다. 아이폰에 "이 컴퓨터를 신뢰하겠습니까?"가 뜨면 신뢰를 누릅니다.

## 3. 내 이름으로 바꾸기

앱의 식별자는 세상에 하나뿐이어야 합니다. 그래서 받은 사람마다 자기 이름으로 바꿔야 합니다.

1. 내 식별자를 정합니다. 예: `com.hong.hangulclock`. 영문 소문자, 숫자, 점만 씁니다.
2. 팀 ID 를 찾습니다. Xcode → 설정 → Accounts 에서 내 Apple ID 를 고르면 팀 목록이 보입니다. 무료 계정이면 "(Personal Team)"이 붙은 팀입니다. 팀 ID 는 영문 대문자와 숫자 10자입니다. 찾기 어려우면 6절 1번을 봅니다.
3. `ios/` 폴더에 `Config.local.xcconfig` 파일을 새로 만들고 두 줄을 적습니다.

   ```
   HC_BUNDLE_PREFIX = com.hong.hangulclock
   DEVELOPMENT_TEAM = 내팀ID10자
   ```

   이 파일은 `.gitignore` 에 들어 있어서 git 에 올라가지 않습니다. 내 식별자와 팀 ID 를 남에게 보이지 않게 하려는 것입니다. `ios/Config.xcconfig` 의 `com.example.hangulclock` 은 견본이라 고치지 않습니다.

## 4. 아이폰에 설치

1. Xcode 로 `ios/HangulClock.xcodeproj` 를 엽니다.
2. 창 위쪽 가운데의 실행 대상을 내 아이폰으로 고릅니다.
3. 실행 단추(▶, 단축키 ⌘R)를 누릅니다. 처음에는 서명 준비로 1~2분 걸립니다.
4. 아이폰에 "신뢰하지 않는 개발자" 창이 뜨면, 아이폰에서 설정 → 일반 → VPN 및 기기 관리 → 내 Apple ID → 신뢰를 누릅니다.
5. 아이폰 홈 화면에서 "글자 시계" 앱을 엽니다.

## 5. 쓰는 법

- 재질: 앱 화면을 옆으로 밀면 서리 유리, 백자, 직물이 바뀝니다.
- 빛 색: 판 아래 동그라미로 고릅니다. 흰 동그라미는 주광색, 주황 동그라미는 전구색입니다. 고른 색은 홈 화면 위젯에도 쓰입니다.
- 홈 화면 위젯: 홈 화면 빈 곳을 길게 누릅니다 → 편집 → 위젯 추가 → "글자 시계"를 찾습니다. 글자 판(작게 · 크게)과 글자 문장이 있습니다.
- 잠금화면 위젯: 잠금화면을 길게 누릅니다 → 사용자화 → 잠금화면 → 위젯 칸 → "글자 시계".
- StandBy: 설정 → StandBy 를 켭니다. 아이폰을 충전하면서 가로로 눕혀 두면 탁상시계가 됩니다. 위젯 칸에 "글자 시계"를 넣습니다.
- 위젯은 1분마다 바뀌게 만들었습니다. 다만 위젯을 언제 다시 그릴지는 아이폰이 정하므로 늦을 수 있습니다.

## 6. 막힐 때

1. 팀 ID 를 모르겠다: Xcode 에서 프로젝트를 열고 왼쪽 목록 맨 위 HangulClock → TARGETS 의 HangulClock → Signing & Capabilities 로 갑니다. Team 칸을 누르면 팀 이름이 보입니다. 경고: 여기서 팀을 고르면 프로젝트 파일에 팀 ID 가 적혀 git 에 올라갈 수 있습니다. 팀 ID 만 확인하고, 값은 3절 3번 파일에 적는 쪽을 권합니다.
2. "bundle identifier … is not available" 오류: 식별자를 다른 사람이 이미 씁니다. 3절 3번 파일의 `HC_BUNDLE_PREFIX` 를 다른 이름으로 바꿉니다.
3. "App Groups" 서명 오류: 3절의 식별자와 팀이 앱과 위젯에 같은지 봅니다. 앱 그룹 이름은 `group.` 뒤에 식별자를 붙여 저절로 만들어집니다.
4. 7일 뒤 앱이 안 열린다: 4절을 다시 합니다. 위젯과 설정은 그대로 남습니다.
5. 무료 계정은 한 번에 앱 3개까지만 설치할 수 있습니다. 다른 시험 앱이 있으면 하나를 지웁니다.

## 7. 고치는 사람에게

- 구조: Swift 패키지 `ios/HangulClockKit`(Core = 규칙 · 문장 · 위젯 시간표 · 색, UI = 판 · 재질 · 위젯 화면 · 글꼴) + 앱 `ios/App` + 위젯 `ios/Widgets`.
- 규칙(판 · 칸 · 때 경계)의 정본은 `preview/clock-core.js` 입니다. `ios/HangulClockKit/Sources/HangulClockCore/ClockTables.swift` 는 손으로 고치지 않습니다. `node tools/gen_tables.js` 가 다시 만듭니다.
- 시험: `tools/ios.sh test-core`(맥에서 코어 시험), `tools/ios.sh test-ui`(시뮬레이터에서 화면 시험), `tools/ios.sh build`(앱 빌드). Node.js 가 필요합니다.
- 프로젝트 파일은 `ios/project.yml` 에서 XcodeGen 으로 만듭니다(`tools/ios.sh project`). 만든 `.xcodeproj` 도 함께 올려서 XcodeGen 없이도 열립니다. 다시 만들 때만 XcodeGen 이 필요합니다(`brew install xcodegen`). 도구가 대신 설치하지는 않습니다.
- `tools/ios.sh` 는 "HC iPhone 16e" 라는 시뮬레이터를 만들어 씁니다. iOS 26.3 런타임이 없으면 설치된 가장 새 iOS 런타임을 씁니다.
- 화면 시험 그림 모으기와 앱 아이콘 만들기에는 Pillow 가 필요합니다(`pip3 install pillow`).
- 글꼴을 다시 만들려면 원본 세 개를 `~/.cache/hangul-word-clock/` 에 둡니다: Noto Sans KR 가변 글꼴(`NotoSansKR-wght.ttf`), Noto Serif KR 가변 글꼴(`NotoSerifKR-wght.ttf`), IBM Plex Sans KR Medium(`IBMPlexSansKR-Medium.ttf`). Noto 는 Google Fonts, IBM Plex 는 IBM 의 Plex 배포처에서 받습니다. 그다음 `pip3 install fonttools` 뒤 `tools/ios.sh fonts` 를 돌립니다. 판 글자를 바꾸지 않으면 이 단계는 필요 없습니다.
- 위젯 단위를 5분으로 바꾸려면 `TimelineSteps.widgetStepMinutes` 하나만 바꿉니다.
- 글꼴은 판 글자 30자만 남긴 SIL OFL 글꼴입니다. 라이선스는 `ios/HangulClockKit/Sources/HangulClockUI/Fonts/licenses/` 에 있습니다.
