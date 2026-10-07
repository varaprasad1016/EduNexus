"""Generates the EduNexus launcher icons (legacy + adaptive) for Android.

Run from the project root:  python tool/make_icon.py
"""
import math
import os

from PIL import Image, ImageDraw

INDIGO = (46, 42, 158)
VIOLET = (108, 76, 241)
SAFFRON = (255, 138, 0)
WHITE = (255, 255, 255)
S = 2048  # master canvas, downsampled for anti-aliasing

ROOT = os.path.join(os.path.dirname(__file__), "..", "android", "app", "src", "main", "res")


def gradient(size):
    img = Image.new("RGB", (size, size))
    px = img.load()
    for y in range(size):
        for x in range(size):
            t = (x + y) / (2 * size - 2)
            px[x, y] = tuple(int(INDIGO[i] + (VIOLET[i] - INDIGO[i]) * t) for i in range(3))
    return img


def quad(p0, p1, p2, steps=60):
    return [
        (
            (1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t * t * p2[0],
            (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1],
        )
        for t in (i / steps for i in range(steps + 1))
    ]


def draw_mark(d, w, ox=0, oy=0):
    """Draws the book + nexus mark into a w x w box at (ox, oy)."""
    P = lambda x, y: (ox + x * w, oy + y * w)
    # book pages
    left = quad(P(0.5, 0.78), P(0.36, 0.68), P(0.18, 0.70)) + quad(P(0.18, 0.52), P(0.36, 0.50), P(0.5, 0.60))
    right = quad(P(0.5, 0.78), P(0.64, 0.68), P(0.82, 0.70)) + quad(P(0.82, 0.52), P(0.64, 0.50), P(0.5, 0.60))
    d.polygon(left, fill=WHITE)
    d.polygon(right, fill=(232, 228, 255))
    # nexus
    cx, cy = P(0.5, 0.36)
    r = 0.2 * w
    nodes = [(cx + math.cos(math.radians(a)) * r, cy + math.sin(math.radians(a)) * r) for a in (-150, -90, -30)]
    lw = int(0.035 * w)
    for n in nodes + [P(0.5, 0.58)]:
        d.line([(cx, cy), n], fill=WHITE, width=lw)
    nr = 0.055 * w
    for nx, ny in nodes:
        d.ellipse([nx - nr, ny - nr, nx + nr, ny + nr], fill=WHITE)
    cr = 0.085 * w
    ring = 0.025 * w
    d.ellipse([cx - cr - ring / 2, cy - cr - ring / 2, cx + cr + ring / 2, cy + cr + ring / 2], fill=WHITE)
    d.ellipse([cx - cr + ring / 2, cy - cr + ring / 2, cx + cr - ring / 2, cy + cr - ring / 2], fill=SAFFRON)


def full_icon(rounded=True):
    img = gradient(S).convert("RGBA")
    d = ImageDraw.Draw(img)
    draw_mark(d, S)
    if rounded:
        mask = Image.new("L", (S, S), 0)
        ImageDraw.Draw(mask).rounded_rectangle([0, 0, S - 1, S - 1], radius=int(S * 0.23), fill=255)
        img.putalpha(mask)
    return img


def round_icon():
    img = gradient(S).convert("RGBA")
    d = ImageDraw.Draw(img)
    draw_mark(d, S)
    mask = Image.new("L", (S, S), 0)
    ImageDraw.Draw(mask).ellipse([0, 0, S - 1, S - 1], fill=255)
    img.putalpha(mask)
    return img


def adaptive_foreground():
    # 108dp canvas; the visible safe zone is the central 66dp. Mark fits ~72dp.
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    inner = int(S * 72 / 108)
    off = (S - inner) // 2
    draw_mark(d, inner, off, off + int(S * 0.01))
    return img


def adaptive_background():
    return gradient(S).convert("RGBA")


def save(img, path, size):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.resize((size, size), Image.LANCZOS).save(path)


def main():
    legacy = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
    adaptive = {"mdpi": 108, "hdpi": 162, "xhdpi": 216, "xxhdpi": 324, "xxxhdpi": 432}
    sq, rd, fg, bg = full_icon(), round_icon(), adaptive_foreground(), adaptive_background()
    for dens, px in legacy.items():
        save(sq, os.path.join(ROOT, f"mipmap-{dens}", "ic_launcher.png"), px)
        save(rd, os.path.join(ROOT, f"mipmap-{dens}", "ic_launcher_round.png"), px)
    for dens, px in adaptive.items():
        save(fg, os.path.join(ROOT, f"mipmap-{dens}", "ic_launcher_foreground.png"), px)
        save(bg, os.path.join(ROOT, f"mipmap-{dens}", "ic_launcher_background.png"), px)
    xml = (
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@mipmap/ic_launcher_background"/>\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
        '    <monochrome android:drawable="@mipmap/ic_launcher_foreground"/>\n'
        "</adaptive-icon>\n"
    )
    v26 = os.path.join(ROOT, "mipmap-anydpi-v26")
    os.makedirs(v26, exist_ok=True)
    for name in ("ic_launcher.xml", "ic_launcher_round.xml"):
        with open(os.path.join(v26, name), "w", encoding="utf-8") as f:
            f.write(xml)
    store = os.path.join(os.path.dirname(__file__), "..", "assets", "branding")
    os.makedirs(store, exist_ok=True)
    save(sq, os.path.join(store, "edunexus_icon_1024.png"), 1024)
    save(full_icon(rounded=False), os.path.join(store, "edunexus_icon_playstore_512.png"), 512)
    print("icons written")


if __name__ == "__main__":
    main()
