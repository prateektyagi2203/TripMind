import math

def oklch_to_hex(L, C, H):
    h = math.radians(H)
    a = C * math.cos(h)
    b = C * math.sin(h)
    l_ = L + 0.3963377774 * a + 0.2158037573 * b
    m_ = L - 0.1055613458 * a - 0.0638541728 * b
    s_ = L - 0.0894841775 * a - 1.2914855480 * b
    l, m, s = l_**3, m_**3, s_**3
    r = 4.0767416621*l - 3.3077115913*m + 0.2309699292*s
    g = -1.2684380046*l + 2.6097574011*m - 0.3413193965*s
    bl = -0.0041960863*l - 0.7034186147*m + 1.7076147010*s
    def enc(c):
        c = max(0.0, min(1.0, c))
        c = 1.055*(c**(1/2.4))-0.055 if c > 0.0031308 else 12.92*c
        return round(max(0, min(1, c))*255)
    return f"#{enc(r):02X}{enc(g):02X}{enc(bl):02X}"

tokens = {
    "background": (0.985, 0.012, 85),
    "foreground": (0.22, 0.04, 230),
    "card": (1, 0, 0),
    "primary": (0.38, 0.07, 215),
    "primary_fg": (0.98, 0.01, 90),
    "secondary": (0.94, 0.02, 85),
    "secondary_fg": (0.28, 0.05, 225),
    "muted": (0.94, 0.015, 85),
    "muted_fg": (0.5, 0.03, 230),
    "accent": (0.92, 0.04, 60),
    "sunset": (0.72, 0.16, 45),
    "sunset_fg": (0.99, 0.01, 90),
    "ocean": (0.55, 0.11, 220),
    "ocean_fg": (0.99, 0.01, 90),
    "sand": (0.95, 0.03, 80),
    "destructive": (0.58, 0.22, 27),
    "border": (0.88, 0.02, 85),
    "input": (0.9, 0.02, 85),
    "ring": (0.55, 0.11, 220),
    "grad_sunset_1": (0.78, 0.14, 60),
    "grad_sunset_2": (0.7, 0.17, 35),
    "grad_sunset_3": (0.55, 0.13, 350),
    "grad_ocean_1": (0.45, 0.09, 220),
    "grad_ocean_2": (0.32, 0.06, 230),
}

for name, (L, C, H) in tokens.items():
    print(f"{name:16} {oklch_to_hex(L, C, H)}")
