"""生成 1024x1024 App 图标（纯标准库，无需 Pillow）。

设计：深靛蓝 -> 紫 -> 青的对角渐变底 + 三圈白色同心环 + 中心实心圆点。
运行：python make_icon.py
"""
import math
import struct
import zlib
from pathlib import Path

SIZE = 1024
OUT = Path(__file__).resolve().parent.parent / "Sources/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png"

# 三个渐变色标 (r, g, b)
STOPS = [
    (0.00, (42, 27, 99)),     # #2A1B63 深靛蓝
    (0.55, (108, 60, 233)),   # #6C3CE9 紫
    (1.00, (34, 211, 238)),   # #22D3EE 青
]


def lerp(a, b, t):
    return a + (b - a) * t


def gradient(t):
    t = min(max(t, 0.0), 1.0)
    for i in range(len(STOPS) - 1):
        t0, c0 = STOPS[i]
        t1, c1 = STOPS[i + 1]
        if t <= t1:
            k = (t - t0) / (t1 - t0) if t1 > t0 else 0.0
            return tuple(lerp(c0[j], c1[j], k) for j in range(3))
    return STOPS[-1][1]


def smoothstep(edge0, edge1, x):
    if edge1 == edge0:
        return 0.0
    t = min(max((x - edge0) / (edge1 - edge0), 0.0), 1.0)
    return t * t * (3 - 2 * t)


CX = CY = SIZE / 2
RINGS = [(300.0, 26.0, 0.30), (215.0, 22.0, 0.42), (140.0, 18.0, 0.55)]
DOT_R = 74.0

rows = []
for y in range(SIZE):
    row = bytearray()
    row.append(0)  # PNG filter type 0
    for x in range(SIZE):
        # 对角渐变 + 轻微暗角
        t = (x + y) / (2.0 * (SIZE - 1))
        r, g, b = gradient(t)
        dx = (x - CX) / CX
        dy = (y - CY) / CY
        vignette = 1.0 - 0.22 * min((dx * dx + dy * dy) / 2.0, 1.0)
        r, g, b = r * vignette, g * vignette, b * vignette

        # 白色同心环
        dist = math.hypot(x - CX, y - CY)
        alpha = 0.0
        for radius, width, peak in RINGS:
            half = width / 2.0
            d = abs(dist - radius)
            if d < half:
                alpha = max(alpha, peak * (1.0 - smoothstep(half * 0.35, half, d)))
        # 中心圆点
        if dist < DOT_R + 2.0:
            alpha = max(alpha, 0.96 * (1.0 - smoothstep(DOT_R - 3.0, DOT_R + 2.0, dist)))

        if alpha > 0:
            r = r * (1 - alpha) + 255 * alpha
            g = g * (1 - alpha) + 255 * alpha
            b = b * (1 - alpha) + 255 * alpha

        row += bytes((int(r + 0.5) & 0xFF, int(g + 0.5) & 0xFF, int(b + 0.5) & 0xFF))
    rows.append(bytes(row))

raw = b"".join(rows)


def chunk(tag, data):
    return (
        struct.pack(">I", len(data))
        + tag
        + data
        + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)
    )


png = b"\x89PNG\r\n\x1a\n"
png += chunk(b"IHDR", struct.pack(">IIBBBBB", SIZE, SIZE, 8, 2, 0, 0, 0))
png += chunk(b"IDAT", zlib.compress(raw, 9))
png += chunk(b"IEND", b"")

OUT.parent.mkdir(parents=True, exist_ok=True)
OUT.write_bytes(png)
print(f"wrote {OUT} ({len(png) / 1024:.1f} KB)")
