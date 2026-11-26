#!/usr/bin/env python3
"""아이폰 앱 글꼴 만들기(스펙 I4): 판 글자 30자만 남기고 새 이름을 붙인다.

원본(저장소 밖 ~/.cache/hangul-word-clock/):
  NotoSansKR-wght.ttf (가변), NotoSerifKR-wght.ttf (가변), IBMPlexSansKR-Medium.ttf
결과: ios/HangulClockKit/Sources/HangulClockUI/Fonts/HC*.ttf + licenses/

SIL OFL 의 예약 이름(Noto Sans KR 의 "Source", IBM Plex 의 "Plex")을 바뀐 글꼴에 쓰지 않으려고
글꼴 이름을 HCSans · HCSerif · HCGrotesk 로 바꾼다. 저작권 · 사용권 글(name ID 0, 13, 14)은 그대로 둔다.
"""
import os
import re
import shutil
import sys
from pathlib import Path

from fontTools import subset
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

ROOT = Path(__file__).resolve().parent.parent
CACHE = Path.home() / ".cache" / "hangul-word-clock"
OUT = ROOT / "ios" / "HangulClockKit" / "Sources" / "HangulClockUI" / "Fonts"

# (PostScript 이름, 가족 이름, 굵기 이름, 원본, 가변 굵기 또는 None)
FACES = [
    ("HCSans-Light", "HCSans", "Light", "NotoSansKR-wght.ttf", 300),
    ("HCSans-Medium", "HCSans", "Medium", "NotoSansKR-wght.ttf", 500),
    ("HCSerif-Regular", "HCSerif", "Regular", "NotoSerifKR-wght.ttf", 400),
    ("HCGrotesk-Medium", "HCGrotesk", "Medium", "IBMPlexSansKR-Medium.ttf", None),
]
LICENSES = [
    ("OFL.txt", "NotoSansKR-OFL.txt"),
    ("OFL-NotoSerifKR.txt", "NotoSerifKR-OFL.txt"),
    ("OFL-IBMPlexSansKR.txt", "IBMPlexSansKR-OFL.txt"),
]
MAX_BYTES = 100_000


def grid_chars() -> str:
    js = (ROOT / "preview" / "clock-core.js").read_text(encoding="utf-8")
    m = re.search(r"const GRID = \[(.*?)\];", js)
    if not m:
        sys.exit("preview/clock-core.js 에서 GRID 를 찾지 못함")
    chars = "".join(dict.fromkeys(re.sub(r"[^가-힣]", "", m.group(1))))
    if len(chars) != 30:
        sys.exit(f"판 글자가 30자가 아니다: {len(chars)}")
    return chars


def rename(font: TTFont, ps: str, family: str, style: str) -> None:
    name = font["name"]
    keep_ids = {0, 5, 7, 8, 9, 10, 11, 12, 13, 14}
    name.names = [r for r in name.names if r.nameID in keep_ids]
    values = {1: family, 2: style, 3: f"{ps};hangul-word-clock subset", 4: f"{family} {style}", 6: ps,
              16: family, 17: style}
    for name_id, value in values.items():
        name.setName(value, name_id, 3, 1, 0x409)
        name.setName(value, name_id, 1, 0, 0)
    if "CFF " in font:
        font["CFF "].cff.fontNames = [ps]


def build(ps: str, family: str, style: str, src: str, weight, chars: str) -> Path:
    font = TTFont(CACHE / src)
    if weight is not None and "fvar" in font:
        font = instancer.instantiateVariableFont(font, {"wght": weight})
    opts = subset.Options()
    opts.layout_features = ["*"]
    opts.hinting = False
    opts.notdef_outline = True
    opts.name_IDs = ["*"]
    opts.name_languages = ["*"]
    sub = subset.Subsetter(opts)
    sub.populate(text=chars + " ")
    sub.subset(font)
    for tag in ("STAT", "DSIG"):
        if tag in font:
            del font[tag]
    rename(font, ps, family, style)
    out = OUT / f"{ps}.ttf"
    font.save(out)
    return out


def check(path: Path, ps: str, chars: str) -> str:
    f = TTFont(path)
    hangul = {cp for cp in f.getBestCmap() if 0xAC00 <= cp <= 0xD7A3}
    got_ps = f["name"].getDebugName(6)
    size = path.stat().st_size
    names = " ".join(str(r.toUnicode()) for r in f["name"].names if r.nameID in (1, 4, 6, 16))
    problems = []
    if hangul != {ord(c) for c in chars}:
        problems.append(f"한글 {len(hangul)}자")
    if got_ps != ps:
        problems.append(f"PS 이름 {got_ps}")
    if size >= MAX_BYTES:
        problems.append(f"크기 {size}")
    if re.search(r"Plex|Source|Noto", names):
        problems.append(f"예약 이름이 남음: {names}")
    if problems:
        sys.exit(f"{path.name}: " + ", ".join(problems))
    return f"{path.name}: 한글 {len(hangul)}, {size:,} 바이트(<100KB), 이름 {got_ps}"


def main() -> None:
    chars = grid_chars()
    OUT.mkdir(parents=True, exist_ok=True)
    for ps, family, style, src, weight in FACES:
        if not (CACHE / src).exists():
            sys.exit(f"원본 글꼴이 없다: {CACHE / src}")
        print(check(build(ps, family, style, src, weight, chars), ps, chars))
    lic = OUT / "licenses"
    lic.mkdir(exist_ok=True)
    for src, dst in LICENSES:
        shutil.copyfile(CACHE / src, lic / dst)
    (lic / "README.md").write_text(
        "# 글꼴 사용권\n\n"
        "이 폴더의 HC*.ttf 는 아래 글꼴에서 판 글자 30자만 남기고 이름을 바꾼 것이다(tools/subset_fonts.py).\n"
        "SIL Open Font License 1.1 을 따른다. 예약 이름(Source, Plex)을 쓰지 않으려고 이름을 바꿨다.\n\n"
        "- HCSans-Light, HCSans-Medium: Noto Sans KR (NotoSansKR-OFL.txt)\n"
        "- HCSerif-Regular: Noto Serif KR (NotoSerifKR-OFL.txt)\n"
        "- HCGrotesk-Medium: IBM Plex Sans KR (IBMPlexSansKR-OFL.txt)\n",
        encoding="utf-8",
    )
    print(f"사용권 {len(LICENSES)}개 + README → {lic.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
