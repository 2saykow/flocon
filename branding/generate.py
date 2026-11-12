#!/usr/bin/env python3
"""Generates all Flocon images. Usage: python3 branding/generate.py (needs rsvg-convert)."""
import math, os, random, subprocess

here = os.path.dirname(os.path.abspath(__file__))
GRAD = ('<linearGradient id="g" gradientUnits="userSpaceOnUse" x1="-250" y1="-250" x2="250" y2="250">'
        '<stop offset="0" stop-color="#ffffff"/><stop offset="1" stop-color="#5ecbff"/></linearGradient>')
BG = ('<linearGradient id="bg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#071a33"/>'
      '<stop offset="0.55" stop-color="#0d3b66"/><stop offset="1" stop-color="#127a8a"/></linearGradient>')


def snowflake(cx, cy, r, w, color, op=1, arms=True):
    """Chevron snowflake. Only polyline/polygon/line: GTK does not fill them in symbolic icon mode."""
    g = [f'<g transform="translate({cx},{cy})" stroke="{color}" stroke-width="{w}" stroke-linecap="round" '
         f'stroke-linejoin="round" fill="none" opacity="{op}">']
    for i in range(6):
        g.append(f'<g transform="rotate({i * 60})">')
        if arms:
            g.append(f'<line x1="0" y1="{-0.22 * r}" x2="0" y2="{-r}"/>')
        for d, l in ((0.52, 0.26), (0.78, 0.17)):
            y = -d * r
            x, dy = l * r * math.sin(math.radians(55)), l * r * math.cos(math.radians(55))
            g.append(f'<polyline points="{-x:.2f},{y - dy:.2f} 0,{y:.2f} {x:.2f},{y - dy:.2f}"/>')
        g.append('</g>')
    pts = ' '.join(f'{0.22 * r * math.sin(math.radians(a)):.2f},{-0.22 * r * math.cos(math.radians(a)):.2f}'
                   for a in range(0, 360, 60))
    g.append(f'<polygon points="{pts}"/></g>')
    return '\n'.join(g)


def small_snowflakes(W, H, n, clear_radius):
    random.seed(7)
    out = []
    while len(out) < n:
        x, y = random.randint(100, W - 100), random.randint(100, H - 100)
        if math.hypot(x - W / 2, y - H / 2) < clear_radius:
            continue
        out.append(snowflake(x, y, random.randint(30, 90) * W // 3840, max(2, 5 * W // 3840), "#bfe9ff",
                             round(random.uniform(0.06, 0.18), 2)))
    return ''.join(out)


def logo_text(x, y, h):
    """Logo + "Flocon" name on one line, centred on (x, y), height h (total width ≈ 4.1 h)."""
    x -= 0.47 * h  # the text is wider than the logo: re-centre the whole
    return (snowflake(x - 1.15 * h, y, h * 0.45, h * 0.075, "url(#g)", 1, False) +
            f'<text x="{x - 0.5 * h}" y="{y + 0.27 * h}" font-family="DejaVu Sans" font-weight="bold" '
            f'font-size="{0.78 * h}" fill="#ffffff">Flocon</text>')


def write(name, svg):
    open(os.path.join(here, name), 'w').write(svg)


def background(W, H, content, n=26, clear_radius=0):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}">\n<defs>{BG}'
            f'<radialGradient id="glow" cx="0.5" cy="0.5" r="0.5"><stop offset="0" stop-color="#7fd8ff" '
            f'stop-opacity="0.35"/><stop offset="1" stop-color="#7fd8ff" stop-opacity="0"/></radialGradient>'
            f'{GRAD}</defs>\n<rect width="{W}" height="{H}" fill="url(#bg)"/>\n'
            f'{small_snowflakes(W, H, n, clear_radius)}\n{content}\n</svg>')


write('logo.svg', f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">\n<defs>{GRAD}</defs>\n'
                  f'{snowflake(256, 256, 230, 34, "url(#g)", 1, False)}\n</svg>')
# Symbolic icon (desktop menu): plain white, no gradient.
write('logo-symbolic.svg', f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">\n'
                           f'{snowflake(8, 8, 7.2, 1.5, "#ffffff", 1, False)}\n</svg>')
write('logo-text.svg', f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 200">\n<defs>{GRAD}</defs>\n'
                       f'{logo_text(320, 100, 140)}\n</svg>')
W, H = 3840, 2160
write('wallpaper.svg', background(W, H, f'<circle cx="{W / 2}" cy="{H / 2}" r="900" fill="url(#glow)"/>\n'
                                        f'{snowflake(W / 2, H / 2, 330, 44, "url(#g)", 0.97, False)}',
                                  clear_radius=950))
# Boot menus: the menu sits in the centre, the logo goes at the top.
write('boot-efi.svg', background(1920, 1080, logo_text(960, 150, 110), n=18))
write('boot-bios.svg', background(800, 600, logo_text(400, 90, 70), n=10))

for name, width in (('wallpaper', 3840), ('logo', 256), ('logo-text', 640), ('boot-efi', 1920), ('boot-bios', 800)):
    subprocess.run(['rsvg-convert', '-w', str(width), os.path.join(here, name + '.svg'),
                    '-o', os.path.join(here, name + '.png')], check=True)
print('images generated in', here)
