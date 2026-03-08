#!/usr/bin/env python3
"""
Generate light and dark 1024×1024 app icons for Snake Universe.

No external dependencies — uses only Python stdlib.
Output: snake_game/assets/icons/icon_dark.png
        snake_game/assets/icons/icon_light.png

Design: 2-cell-thick snake making an S-curve across a 16×16 logical grid,
        with a visible head (eyes) at the bottom tip.
"""

import math
import os
import struct
import zlib

# ── Grid constants ─────────────────────────────────────────────────────────────
IMG = 1024          # final image size (pixels)
N   = 16            # logical grid cells per side
C   = IMG // N      # pixels per cell (64)

BG, BODY, HEAD = 0, 1, 2

# 2-cell-thick S-curve.
# Tail: rows 1-2, cols 2-11 (top-left).
# Head: rows 13-14, cols 10-11 (bottom-right, facing down).
GRID = [
    #  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15
    [  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],  #  0
    [  0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0],  #  1  top horiz
    [  0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0],  #  2  top horiz
    [  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0],  #  3  right vert
    [  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0],  #  4  right vert
    [  0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0],  #  5  mid horiz
    [  0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0],  #  6  mid horiz
    [  0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],  #  7  left vert
    [  0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],  #  8  left vert
    [  0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0],  #  9  bot horiz
    [  0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0],  # 10  bot horiz
    [  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0],  # 11  right vert
    [  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0],  # 12  right vert
    [  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0],  # 13  head
    [  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0],  # 14  head
    [  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],  # 15
]

# Head: cols 10-11, rows 13-14. Snake faces DOWN → eyes at row-14 centre.
_EYE_R = int(C * 0.16)   # ~10 px radius
_EYES  = [
    (10 * C + C // 2, 14 * C + C // 2),   # left eye  (col 10 centre, row 14 centre)
    (11 * C + C // 2, 14 * C + C // 2),   # right eye (col 11 centre, row 14 centre)
]

def _is_eye(px: int, py: int) -> bool:
    return any(math.hypot(px - ex, py - ey) < _EYE_R for ex, ey in _EYES)

# ── Colour palettes ────────────────────────────────────────────────────────────
DARK = dict(
    bg   = (10,  15,  10,  255),   # #0A0F0A — matches game background
    body = (57,  255, 20,  255),   # #39FF14 — neon green
    eye  = (10,  15,  10,  255),   # dark pupil
)
LIGHT = dict(
    bg   = (240, 248, 235, 255),   # very light green-white
    body = (15,  100, 8,   255),   # dark forest green
    eye  = (240, 248, 235, 255),   # light pupil
)

# ── PNG writer (RGBA, stdlib only) ────────────────────────────────────────────
def _chunk(name: bytes, data: bytes) -> bytes:
    c = name + data
    return struct.pack('>I', len(data)) + c + struct.pack('>I', zlib.crc32(c) & 0xFFFFFFFF)

def write_png(path: str, rows: list[bytes]) -> None:
    """Write an RGBA PNG from a list of row byte-strings (each 4*width bytes)."""
    h = len(rows)
    w = len(rows[0]) // 4
    raw  = b''.join(b'\x00' + r for r in rows)   # filter byte 0 (None) per row
    # IHDR: width, height, bit_depth=8, color_type=6 (RGBA), compress=0, filter=0, interlace=0
    ihdr = _chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0))
    idat = _chunk(b'IDAT', zlib.compress(raw, 1))
    iend = _chunk(b'IEND', b'')
    with open(path, 'wb') as f:
        f.write(b'\x89PNG\r\n\x1a\n' + ihdr + idat + iend)
    print(f'  {path}  ({os.path.getsize(path) // 1024} KB)')

# ── Icon generator ─────────────────────────────────────────────────────────────
def generate(path: str, colors: dict) -> None:
    # Each pixel is 4 bytes (RGBA). Build single-pixel bytes correctly.
    bg_px   = bytes(colors['bg'])    # exactly 4 bytes
    body_px = bytes(colors['body'])  # exactly 4 bytes
    eye_px  = bytes(colors['eye'])   # exactly 4 bytes

    # Pre-build solid cell strips (C pixels wide = C*4 bytes) for fast assembly.
    bg_strip   = bg_px   * C   # 256 bytes
    body_strip = body_px * C   # 256 bytes

    rows = []
    for y in range(IMG):
        gy = y // C
        row = bytearray()
        for gx in range(N):
            cell = GRID[gy][gx]
            if cell == BG:
                row += bg_strip
            elif cell == BODY:
                row += body_strip
            else:  # HEAD — per-pixel eye check
                base_x = gx * C
                for sx in range(C):
                    px = base_x + sx
                    row += eye_px if _is_eye(px, y) else body_px
        rows.append(bytes(row))

    write_png(path, rows)

# ── Main ──────────────────────────────────────────────────────────────────────
if __name__ == '__main__':
    os.makedirs('snake_game/assets/icons', exist_ok=True)

    print('Generating dark icon …')
    generate('snake_game/assets/icons/icon_dark.png', DARK)

    print('Generating light icon …')
    generate('snake_game/assets/icons/icon_light.png', LIGHT)

    print('Done.')
