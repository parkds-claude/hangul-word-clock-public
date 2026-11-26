#!/usr/bin/env python3
"""시험 그림(build-ios/snapshots/*.png)을 한 장에 모은다. 사용: contact_sheet.py <폴더> <결과.png>"""
import sys
from pathlib import Path
from PIL import Image, ImageDraw

src, out = Path(sys.argv[1]), Path(sys.argv[2])
files = sorted(p for p in src.glob("*.png") if p.name != out.name)
if not files:
    sys.exit(0)
cell, pad, cols = 300, 12, 6
rows = (len(files) + cols - 1) // cols
sheet = Image.new("RGB", (cols * (cell + pad) + pad, rows * (cell + pad + 18) + pad), (40, 40, 40))
draw = ImageDraw.Draw(sheet)
for i, f in enumerate(files):
    im = Image.open(f).convert("RGB")
    im.thumbnail((cell, cell))
    x = pad + (i % cols) * (cell + pad)
    y = pad + (i // cols) * (cell + pad + 18)
    sheet.paste(im, (x, y))
    draw.text((x, y + cell + 2), f.stem[:40], fill=(220, 220, 220))
sheet.save(out)
