#!/usr/bin/env python3
"""Génère toutes les images de Flocon. Usage : python3 branding/generer.py (demande rsvg-convert)."""
import math, os, random, subprocess

ici = os.path.dirname(os.path.abspath(__file__))
GRAD = ('<linearGradient id="g" gradientUnits="userSpaceOnUse" x1="-250" y1="-250" x2="250" y2="250">'
        '<stop offset="0" stop-color="#ffffff"/><stop offset="1" stop-color="#5ecbff"/></linearGradient>')
FOND = ('<linearGradient id="bg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#071a33"/>'
        '<stop offset="0.55" stop-color="#0d3b66"/><stop offset="1" stop-color="#127a8a"/></linearGradient>')


def flocon(cx, cy, r, w, couleur, op=1, bras=True):
    """Flocon en chevrons. Que des polyline/polygon/line : GTK ne les remplit pas en mode icône symbolique."""
    g = [f'<g transform="translate({cx},{cy})" stroke="{couleur}" stroke-width="{w}" stroke-linecap="round" '
         f'stroke-linejoin="round" fill="none" opacity="{op}">']
    for i in range(6):
        g.append(f'<g transform="rotate({i * 60})">')
        if bras:
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


def petits_flocons(W, H, n, zone_libre):
    random.seed(7)
    out = []
    while len(out) < n:
        x, y = random.randint(100, W - 100), random.randint(100, H - 100)
        if math.hypot(x - W / 2, y - H / 2) < zone_libre:
            continue
        out.append(flocon(x, y, random.randint(30, 90) * W // 3840, max(2, 5 * W // 3840), "#bfe9ff",
                          round(random.uniform(0.06, 0.18), 2)))
    return ''.join(out)


def logo_texte(x, y, h):
    """Logo + nom « Flocon » sur une ligne, centré en (x, y), hauteur h (largeur totale ≈ 4,1 h)."""
    x -= 0.47 * h  # le texte est plus large que le logo : recentre l'ensemble
    return (flocon(x - 1.15 * h, y, h * 0.45, h * 0.075, "url(#g)", 1, False) +
            f'<text x="{x - 0.5 * h}" y="{y + 0.27 * h}" font-family="DejaVu Sans" font-weight="bold" '
            f'font-size="{0.78 * h}" fill="#ffffff">Flocon</text>')


def ecrire(nom, svg):
    open(os.path.join(ici, nom), 'w').write(svg)


def fond(W, H, contenu, n=26, zone_libre=0):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}">\n<defs>{FOND}'
            f'<radialGradient id="glow" cx="0.5" cy="0.5" r="0.5"><stop offset="0" stop-color="#7fd8ff" '
            f'stop-opacity="0.35"/><stop offset="1" stop-color="#7fd8ff" stop-opacity="0"/></radialGradient>'
            f'{GRAD}</defs>\n<rect width="{W}" height="{H}" fill="url(#bg)"/>\n'
            f'{petits_flocons(W, H, n, zone_libre)}\n{contenu}\n</svg>')


ecrire('logo.svg', f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">\n<defs>{GRAD}</defs>\n'
                   f'{flocon(256, 256, 230, 34, "url(#g)", 1, False)}\n</svg>')
# Icône symbolique (menu du bureau) : blanc uni, sans dégradé.
ecrire('logo-symbolique.svg', f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">\n'
                              f'{flocon(8, 8, 7.2, 1.5, "#ffffff", 1, False)}\n</svg>')
ecrire('logo-texte.svg', f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 200">\n<defs>{GRAD}</defs>\n'
                         f'{logo_texte(320, 100, 140)}\n</svg>')
W, H = 3840, 2160
ecrire('wallpaper.svg', fond(W, H, f'<circle cx="{W / 2}" cy="{H / 2}" r="900" fill="url(#glow)"/>\n'
                                   f'{flocon(W / 2, H / 2, 330, 44, "url(#g)", 0.97, False)}', zone_libre=950))
# Menus de démarrage : le menu s'affiche au centre, le logo va en haut.
ecrire('boot-efi.svg', fond(1920, 1080, logo_texte(960, 150, 110), n=18))
ecrire('boot-bios.svg', fond(800, 600, logo_texte(400, 90, 70), n=10))

for nom, largeur in (('wallpaper', 3840), ('logo', 256), ('logo-texte', 640), ('boot-efi', 1920), ('boot-bios', 800)):
    subprocess.run(['rsvg-convert', '-w', str(largeur), os.path.join(ici, nom + '.svg'),
                    '-o', os.path.join(ici, nom + '.png')], check=True)
print('images générées dans', ici)
