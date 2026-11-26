#!/usr/bin/env python3
"""앱 아이콘(1024×1024, 불투명): 유리 바탕에 6×6 점, 18:45 의 9칸이 켜진다(docs/iphone/v2-glass.png 오른쪽 위).
결과: ios/App/Assets.xcassets/AppIcon.appiconset/"""
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "ios" / "App" / "Assets.xcassets"
SIZE = 1024
LIT = {3, 4, 12, 13, 19, 23, 25, 30, 35}   # 18:45
PERIOD = {3, 4}                             # 저녁


def main() -> None:
    img = Image.new("RGB", (SIZE, SIZE))
    top, bottom = (0x3A, 0x3F, 0x47), (0x17, 0x1A, 0x1E)
    d = ImageDraw.Draw(img)
    for y in range(SIZE):
        t = y / (SIZE - 1)
        d.line([(0, y), (SIZE, y)], fill=tuple(round(a + (b - a) * t) for a, b in zip(top, bottom)))
    glow = Image.new("RGB", (SIZE, SIZE))
    dots = Image.new("RGBA", (SIZE, SIZE))
    gd, dd = ImageDraw.Draw(glow), ImageDraw.Draw(dots)
    margin, r = 190, 30
    step = (SIZE - 2 * margin) / 5
    for i in range(36):
        cx, cy = margin + (i % 6) * step, margin + (i // 6) * step
        box = (cx - r, cy - r, cx + r, cy + r)
        if i in LIT:
            color = (0xCF, 0xE0, 0xFF) if i in PERIOD else (0xF5, 0xF5, 0xF2)
            gd.ellipse((cx - r * 1.6, cy - r * 1.6, cx + r * 1.6, cy + r * 1.6), fill=color)
            dd.ellipse(box, fill=color + (255,))
        else:
            dd.ellipse(box, fill=(0x50, 0x54, 0x5A, 255))
    img = Image.blend(img, Image.composite(glow, img, glow.convert("L")).filter(ImageFilter.GaussianBlur(28)), 0.35)
    img.paste(dots, (0, 0), dots)
    icon_dir = OUT / "AppIcon.appiconset"
    icon_dir.mkdir(parents=True, exist_ok=True)
    img.save(icon_dir / "AppIcon-1024.png")
    (OUT / "Contents.json").write_text(json.dumps({"info": {"author": "xcode", "version": 1}}, indent=2) + "\n")
    (icon_dir / "Contents.json").write_text(json.dumps({
        "images": [{"filename": "AppIcon-1024.png", "idiom": "universal", "platform": "ios", "size": "1024x1024"}],
        "info": {"author": "xcode", "version": 1},
    }, indent=2) + "\n")
    print(f"아이콘: {(icon_dir / 'AppIcon-1024.png').relative_to(ROOT)}")


if __name__ == "__main__":
    main()
