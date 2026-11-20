#!/usr/bin/env python3
"""Generate EmbedForge app icon: PCB + terminal prompt design."""
import random
from PIL import Image, ImageDraw

W = 1024
# palette
BG = (16, 21, 28, 255)        # anthracite
BG2 = (23, 30, 40, 255)
BLUE = (56, 182, 255, 255)    # electronic blue
BLUE_D = (30, 110, 168, 255)
GREEN = (64, 229, 131, 255)   # terminal green
OFFW = (238, 243, 248, 255)
ORANGE = (255, 169, 77, 255)

random.seed(7)


def rounded(draw, box, r, fill):
    draw.rounded_rectangle(box, radius=r, fill=fill)


def circuit_traces(draw, x0, y0, x1, y1, color, pad_r, n=24, width=6):
    """Draw orthogonal circuit traces with pads, with some cut from corners."""
    # keep inside central safe area
    cx0, cy0 = x0, y0
    for _ in range(n):
        sx = random.randint(x0, x1)
        sy = random.randint(y0, y1)
        length = random.randint(120, 320)
        horizontal = random.random() < 0.5
        if horizontal:
            ex = sx + length if sx + length < x1 else sx - length
            draw.line([(sx, sy), (ex, sy)], fill=color, width=width)
            ex, ey = ex, sy
        else:
            ey = sy + length if sy + length < y1 else sy - length
            draw.line([(sx, sy), (sx, ey)], fill=color, width=width)
            ex, ey = sx, ey
        draw.ellipse([sx - pad_r, sy - pad_r, sx + pad_r, sy + pad_r], fill=color)
        if ex > x0 and ex < x1:
            draw.ellipse([ex - pad_r, ey - pad_r, ex + pad_r, ey + pad_r], fill=color)
        _ = cx0, cy0


def draw_icon(path, full_bg=True, fg=False):
    img = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    if full_bg:
        # rounded square background
        for i in range(8):
            t = i / 8
            col = (int(BG[0] + (BG2[0] - BG[0]) * t),
                   int(BG[1] + (BG2[1] - BG[1]) * t),
                   int(BG[2] + (BG2[2] - BG[2]) * t), 255)
            inset = int(i * 18)
            d.rounded_rectangle([inset, inset, W - inset, W - inset],
                                radius=max(60, 180 - i * 14), fill=col)
        # outer ring accent
        d.rounded_rectangle([40, 40, W - 40, W - 40], radius=180,
                            outline=(38, 50, 66, 255), width=8)
    # ---- circuit traces around the chip ----
    circuit_traces(d, 150, 150, W - 150, W - 150, BLUE, 14)
    # ---- central CPU chip ----
    chip = [W // 2 - 250, W // 2 - 250, W // 2 + 250, W // 2 + 250]
    # pins
    pin = 220  # pin length
    pin_w = 26
    # left
    for i in range(8):
        y = chip[1] + 60 + i * 46
        d.rectangle([chip[0] - pin - 10, y, chip[0], y + pin_w], fill=BLUE_D)
    # right
    for i in range(8):
        y = chip[1] + 60 + i * 46
        d.rectangle([chip[2], y, chip[2] + pin + 10, y + pin_w], fill=BLUE_D)
    # top
    for i in range(6):
        x = chip[0] + 66 + i * 56
        d.rectangle([x, chip[1] - pin - 10, x + pin_w, chip[1]], fill=BLUE_D)
    # bottom
    for i in range(6):
        x = chip[0] + 66 + i * 56
        d.rectangle([x, chip[3], x + pin_w, chip[3] + pin + 10], fill=BLUE_D)
    # chip body with subtle gradient
    d.rounded_rectangle(chip, radius=46, fill=(26, 34, 46, 255))
    d.rounded_rectangle(chip, radius=46, outline=BLUE, width=10)
    # inner ring
    inner = [chip[0] + 34, chip[1] + 34, chip[2] - 34, chip[3] - 34]
    d.rounded_rectangle(inner, radius=28, outline=(46, 60, 78, 255), width=5)
    # pin dots on inner ring
    for i in range(8):
        y = inner[1] + 22 + i * 26
        d.ellipse([chip[0] + 10, y, chip[0] + 26, y + 16], fill=BLUE)
        d.ellipse([chip[2] - 26, y, chip[2] - 10, y + 16], fill=BLUE)
    # terminal prompt ">_" in green
    from PIL import ImageFont
    try:
        f = ImageFont.truetype("assets/fonts/monotech.ttf", 300)
    except Exception:
        f = ImageFont.load_default()
    txt = ">_"
    box = d.textbbox((0, 0), txt, font=f)
    tw, th = box[2] - box[0], box[3] - box[1]
    d.text((W // 2 - tw // 2 - box[0], W // 2 - th // 2 - 20 - box[1]), txt,
           font=f, fill=GREEN)
    # underscore accent line
    d.rounded_rectangle([W // 2 - 150, W // 2 + 150, W // 2 + 150, W // 2 + 175],
                        radius=12, fill=GREEN)
    if fg:
        # strip background for adaptive foreground
        # (keep only chip + prompt; just reuse image on transparent)
        pass
    if full_bg and not fg:
        img.save(path, "PNG")
    else:
        img.save(path, "PNG")


if __name__ == "__main__":
    draw_icon("assets/images/icon/icon_1024.png", full_bg=True)
    draw_icon("assets/images/icon/icon_foreground.png", full_bg=False)
    print("icons written")