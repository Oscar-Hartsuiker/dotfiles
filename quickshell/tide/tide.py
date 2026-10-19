#!/usr/bin/env python3
import json, time, urllib.request, sys
from datetime import datetime, timedelta
from pathlib import Path
from zoneinfo import ZoneInfo

STATION = "Cape St Francis"
LAT, LON = -34.25, 24.90  # keep this OFFSHORE: land grid cells return null
TZ = "Africa/Johannesburg"
# CACHE = Path.home() / ".cache/tide.json"
CACHE = Path.home() / ".cache/tide2.json"
MAX_AGE = 3 * 3600


def fetch():
    q = f"latitude={LAT}&longitude={LON}&timezone={TZ}&forecast_days=11"

    def get(url):
        with urllib.request.urlopen(url, timeout=15) as r:
            return json.load(r)

    m = get(
        f"https://marine-api.open-meteo.com/v1/marine?{q}&hourly=sea_level_height_msl"
    )
    s = get(f"https://api.open-meteo.com/v1/forecast?{q}&daily=sunrise,sunset")
    return {"t": time.time(), "tide": m["hourly"], "sun": s["daily"]}


def load():
    try:
        d = json.loads(CACHE.read_text())
        if time.time() - d["t"] < MAX_AGE:
            return d
    except Exception:
        pass
    try:
        d = fetch()
        CACHE.parent.mkdir(parents=True, exist_ok=True)
        CACHE.write_text(json.dumps(d))
        return d
    except Exception:
        return json.loads(CACHE.read_text())  # stale beats nothing


data = load()
P = datetime.fromisoformat
now = datetime.now(ZoneInfo(TZ)).replace(tzinfo=None)
start0 = now.replace(hour=0, minute=0, second=0, microsecond=0)
if now < start0:
    start0 -= timedelta(days=1)

import math

# --- harmonic fit: mean + M2, S2, N2, K1, O1 (periods in hours) ---
PERIODS = [12.4206, 12.0, 12.6583, 23.9345, 25.8193]


def basis(h):
    row = [1.0]
    for p in PERIODS:
        w = 2 * math.pi / p
        row += [math.cos(w * h), math.sin(w * h)]
    return row


def solve(A, b):
    n = len(b)
    M = [A[i][:] + [b[i]] for i in range(n)]
    for i in range(n):
        piv = max(range(i, n), key=lambda r: abs(M[r][i]))
        M[i], M[piv] = M[piv], M[i]
        for r in range(i + 1, n):
            f = M[r][i] / M[i][i]
            for c in range(i, n + 1):
                M[r][c] -= f * M[i][c]
    x = [0.0] * n
    for i in reversed(range(n)):
        x[i] = (M[i][n] - sum(M[i][j] * x[j] for j in range(i + 1, n))) / M[i][i]
    return x


hrs0 = lambda t: (t - start0).total_seconds() / 3600

pairs = [
    (hrs0(P(t)), v)
    for t, v in zip(data["tide"]["time"], data["tide"]["sea_level_height_msl"])
    if v is not None
]
H = [p[0] for p in pairs]
V = [p[1] for p in pairs]

rows = [basis(h) for h in H]
k = len(rows[0])
A = [
    [sum(r[i] * r[j] for r in rows) + (1e-3 if i == j else 0) for j in range(k)]
    for i in range(k)
]
b = [sum(r[i] * v for r, v in zip(rows, V)) for i in range(k)]
coef = solve(A, b)


def fit0(h):
    return sum(c * x for c, x in zip(coef, basis(h)))


# --- dense 10-minute grid from the fitted curve ---
STEP = 1 / 6


def build(offset):
    start = start0 + timedelta(days=offset)
    hrs = lambda t: (t - start).total_seconds() / 3600
    hn = hrs(now)
    fit = lambda h: fit0(h + offset * 24)
    grid = [-1 + i * STEP for i in range(int(31 / STEP) + 1)]
    F = [fit(h) for h in grid]

    ext = []
    for i in range(1, len(F) - 1):
        a, b_, c = F[i - 1], F[i], F[i + 1]
        d2 = a - 2 * b_ + c
        kind = "high" if (b_ > a and b_ >= c) else "low" if (b_ < a and b_ <= c) else None
        if kind and d2:
            h = grid[i] + STEP * (a - c) / (2 * d2)
            v = b_ - (a - c) ** 2 / (8 * d2)
            ext.append(
                {
                    "type": kind,
                    "h": round(h, 3),
                    "v": round(v, 3),
                    "time": (start + timedelta(hours=h)).strftime("%H:%M"),
                }
            )

    sun = data["sun"]
    rise = hrs(P(sun["sunrise"][offset]))
    sset = hrs(P(sun["sunset"][offset]))
    nights = [[0, rise], [sset, 24]]

    return {
        "station": STATION,
        "now": round(hn, 3),
        "current": round(fit(hn), 3),
        "rising": fit(hn + 0.25) > fit(hn),
        "points": [[round(h, 3), round(v, 4)] for h, v in zip(grid, F)],
        "extrema": ext,
        "nights": nights,
        "label": f"{start:%a %d %b}",
    }


def combine(days):
    pts, ext_all, nights, meta = [], [], [], []
    last_i = len(days) - 1
    for off, d in enumerate(days):
        base = off * 24
        for hh, vv in d["points"]:
            if 0 <= hh < 24 or (off == last_i and hh == 24):
                pts.append([base + hh, vv])
        for e in d["extrema"]:
            if 0 <= e["h"] < 24 or (off == last_i and e["h"] == 24):
                ext_all.append(dict(e, h=base + e["h"]))
        for n in d["nights"]:
            nights.append([base + n[0], base + n[1]])
        meta.append({"h": base, "label": d["label"], "short": d["label"][:6]})
    out = dict(days[0])
    out.update(
        {
            "label": "10-day",
            "span": pts[-1][0],
            "points": pts,
            "extrema": ext_all,
            "nights": nights,
            "days": meta,
        }
    )
    return out


def main():
    args = sys.argv[1:]
    offsets = range(10)
    if args and args[0] == "all":
        print(json.dumps(combine([build(off) for off in offsets])))
    else:
        offset = int(args[0]) if args else 0
        print(json.dumps(build(offset)))


if __name__ == "__main__":
    main()
