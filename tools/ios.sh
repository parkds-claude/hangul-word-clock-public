#!/bin/bash
# 아이폰 앱 빌드 · 시험. 설치 안내: ios/README.md
#   tools/ios.sh sim        시험용 시뮬레이터(HC iPhone 16e, iOS 26.3)의 UDID. 없으면 만든다
#   tools/ios.sh gen        규칙 표 · 정답표 만들기(tools/gen_tables.js)
#   tools/ios.sh test-core  패키지 시험(맥에서, 빠름)
#   tools/ios.sh fonts      판 글자 30자 글꼴 만들기(tools/subset_fonts.py)
#   tools/ios.sh test-ui    패키지 시험(시뮬레이터에서, 그림 포함)
#   tools/ios.sh project    앱 프로젝트 만들기(XcodeGen, ios/project.yml → ios/HangulClock.xcodeproj)
#   tools/ios.sh build      시뮬레이터용 앱 빌드(build-ios/dd-app)
# 긴 출력은 build-ios/logs/ 에 두고 요약만 찍는다. 산출물은 build-ios/(git 제외).
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT=$(pwd)
SIM_NAME="HC iPhone 16e"
SIM_TYPE="com.apple.CoreSimulator.SimDeviceType.iPhone-16e"
SIM_RUNTIME="com.apple.CoreSimulator.SimRuntime.iOS-26-3"
KIT="$ROOT/ios/HangulClockKit"
OUT="$ROOT/build-ios"
mkdir -p "$OUT/logs"

# 시뮬레이터 런타임: SIM_RUNTIME 이 이 맥에 없으면 설치된 가장 새 iOS 런타임을 쓴다(공개판 검토, 2026-11-26)
sim_runtime() {
  xcrun simctl list runtimes -j | python3 -c '
import json, sys
want = sys.argv[1]
rts = [r for r in json.load(sys.stdin)["runtimes"] if r.get("isAvailable") and r.get("platform", "iOS") == "iOS"]
ids = [r["identifier"] for r in rts]
if want in ids:
    print(want)
elif rts:
    best = max(rts, key=lambda r: [int(x) for x in r["version"].split(".")])
    print(best["identifier"])
else:
    sys.exit("iOS 시뮬레이터 런타임이 없다. Xcode → 설정 → Components 에서 iOS 를 받는다")
' "$SIM_RUNTIME"
}

sim_udid() {
  local u
  u=$(xcrun simctl list devices -j | python3 -c '
import json, sys
name = sys.argv[1]
devs = json.load(sys.stdin)["devices"]
print(next((d["udid"] for runtime in devs.values() for d in runtime if d["name"] == name and d.get("isAvailable")), ""))
' "$SIM_NAME")
  if [ -z "$u" ]; then u=$(xcrun simctl create "$SIM_NAME" "$SIM_TYPE" "$(sim_runtime)"); fi
  echo "$u"
}

# 패키지 스킴 이름: 제품이 하나면 HangulClockKit, 여럿이면 HangulClockKit-Package (기록장 Ruling)
kit_scheme() {
  if (cd "$KIT" && xcodebuild -list 2>/dev/null) | grep -q "HangulClockKit-Package"; then echo HangulClockKit-Package; else echo HangulClockKit; fi
}

# xcodebuild 기록에서 요약 줄만 찍는다
summary() {
  grep -E "error:|Test Case .* failed|Executed [0-9]+ test|\*\* (TEST|BUILD) (SUCCEEDED|FAILED)" "$1" | tail -n 25 || true
}

cmd=${1:-}
case "$cmd" in
  sim)
    sim_udid ;;
  gen)
    node tools/gen_tables.js ;;
  test-core)
    node tools/gen_tables.js >/dev/null
    log="$OUT/logs/test-core.log"
    rm -rf "$OUT/core.xcresult"
    set +e
    (cd "$KIT" && xcodebuild test -scheme "$(kit_scheme)" -destination 'platform=macOS' \
      -derivedDataPath "$OUT/dd-core" -resultBundlePath "$OUT/core.xcresult") > "$log" 2>&1
    rc=$?
    set -e
    summary "$log"
    echo "기록: $log"
    exit $rc ;;
  fonts)
    python3 tools/subset_fonts.py ;;
  test-ui)
    # xcodebuild test 는 이 맥(macOS 27 + Xcode 26.3)에서 "test runner hung before establishing connection" 으로 멈춘다.
    # 같은 묶음을 시뮬레이터 안에서 xctest 로 직접 돌리면 통과한다(2026-11-26 확인). 그래서 빌드만 xcodebuild 로 하고
    # 실행은 simctl spawn xctest 로 한다. 시험 그림은 HC_SNAPSHOT_DIR(=build-ios/snapshots)에 바로 쓴다(기록장 Ruling).
    node tools/gen_tables.js >/dev/null
    udid=$(sim_udid)
    xcrun simctl bootstatus "$udid" -b >/dev/null 2>&1 || true
    log="$OUT/logs/test-ui-build.log"
    set +e
    (cd "$KIT" && xcodebuild build-for-testing -scheme "$(kit_scheme)" -destination "platform=iOS Simulator,id=$udid" \
      -derivedDataPath "$OUT/dd-ui") > "$log" 2>&1
    rc=$?
    set -e
    if [ $rc -ne 0 ]; then summary "$log"; echo "기록: $log"; exit $rc; fi
    xct="$(xcrun --sdk iphonesimulator --show-sdk-platform-path)/Developer/Library/Xcode/Agents/xctest"
    snap="$OUT/snapshots"
    rm -rf "$snap"; mkdir -p "$snap"
    fail=0
    for b in "$OUT"/dd-ui/Build/Products/Debug-iphonesimulator/*.xctest; do
      name=$(basename "$b" .xctest)
      blog="$OUT/logs/test-ui-$name.log"
      SIMCTL_CHILD_HC_SNAPSHOT_DIR="$snap" timeout 600 xcrun simctl spawn "$udid" "$xct" "$b" > "$blog" 2>&1 || true
      line=$(grep -E "Executed [0-9]+ tests?, with [0-9]+ failures?" "$blog" | tail -1 | sed 's/^[[:space:]]*//')
      echo "$name: ${line:-결과 없음(멈춤 또는 충돌) — 기록 $blog}"
      grep -E "error: |' failed \(" "$blog" | head -10 || true
      grep -q "Test Suite 'All tests' passed" "$blog" || fail=1
    done
    if ls "$snap"/*.png >/dev/null 2>&1; then
      python3 tools/contact_sheet.py "$snap" "$snap/sheet.png" && echo "그림 $(ls "$snap"/*.png | grep -vc sheet.png)장, 모아 본 그림: $snap/sheet.png"
    fi
    [ $fail -eq 0 ] && echo "** TEST SUCCEEDED **" || echo "** TEST FAILED **"
    exit $fail ;;
  project)
    # XcodeGen 이 없으면 설치하지 않고 알린다(받은 사람의 맥에 묻지 않고 설치하지 않는다)
    command -v xcodegen >/dev/null || { echo "XcodeGen 이 필요하다: brew install xcodegen"; exit 1; }
    python3 tools/make_app_icon.py
    xcodegen generate --spec ios/project.yml --quiet && echo "프로젝트: ios/HangulClock.xcodeproj" ;;
  build)
    udid=$(sim_udid)
    log="$OUT/logs/build-app.log"
    set +e
    xcodebuild build -project ios/HangulClock.xcodeproj -scheme HangulClock \
      -destination "platform=iOS Simulator,id=$udid" -derivedDataPath "$OUT/dd-app" > "$log" 2>&1
    rc=$?
    set -e
    summary "$log"
    echo "앱: $OUT/dd-app/Build/Products/Debug-iphonesimulator/HangulClock.app"
    echo "기록: $log"
    exit $rc ;;
  *)
    sed -n 2,11p "$0" | sed 's/^# \{0,1\}//'
    exit 1 ;;
esac
