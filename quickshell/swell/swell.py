#!/usr/bin/env python3
"""swell.py [dayOffset|all] -> JSON for the wave chart (GFS Wave via Open-Meteo)."""

import json, math, sys, time, urllib.parse, urllib.request
from datetime import datetime, timedelta
from pathlib import Path
from zoneinfo import ZoneInfo

STATION = "Cape St Francis"
LAT, LON = -34.21, 24.84
TZ = ZoneInfo("Africa/Johannesburg")
CACHE = Path.home() / ".cache" / "surf" / "waves_gfswave.json"
TTL = 1800


def cache_updated():
    try:
        return datetime.fromtimestamp(CACHE.stat().st_mtime, TZ).isoformat(timespec="minutes")
    except Exception:
        return None

URL = "https://marine-api.open-meteo.com/v1/marine?" + urllib.parse.urlencode(
    {
        "latitude": LAT,
        "longitude": LON,
        "hourly": "wave_height,wave_direction,wave_period",
        "models": "ncep_gfswave025",
        "timezone": "Africa/Johannesburg",
        "forecast_days": 11,
    }
)


def fetch():
    if CACHE.exists() and time.time() - CACHE.stat().st_mtime < TTL:
        return json.loads(CACHE.read_text())
    try:
        with urllib.request.urlopen(URL, timeout=15) as r:
            raw = r.read().decode()
        data = json.loads(raw)
        CACHE.parent.mkdir(parents=True, exist_ok=True)
        CACHE.write_text(raw)
        return data
    except Exception:
        if CACHE.exists():
            return json.loads(CACHE.read_text())
        raise


def sun_times(day, lat, lon, tz_hours):
    n = day.timetuple().tm_yday
    g = 2 * math.pi / 365 * (n - 1)
    eqt = 229.18 * (
        0.000075
        + 0.001868 * math.cos(g)
        - 0.032077 * math.sin(g)
        - 0.014615 * math.cos(2 * g)
        - 0.040849 * math.sin(2 * g)
    )
    decl = (
        0.006918
        - 0.399912 * math.cos(g)
        + 0.070257 * math.sin(g)
        - 0.006758 * math.cos(2 * g)
        + 0.000907 * math.sin(2 * g)
        - 0.002697 * math.cos(3 * g)
        + 0.00148 * math.sin(3 * g)
    )
    la = math.radians(lat)
    ha = math.degrees(
        math.acos(
            math.cos(math.radians(90.833)) / (math.cos(la) * math.cos(decl))
            - math.tan(la) * math.tan(decl)
        )
    )
    return (
        (720 - 4 * (lon + ha) - eqt) / 60 + tz_hours,
        (720 - 4 * (lon - ha) - eqt) / 60 + tz_hours,
    )


def build(data, off):
    h = data["hourly"]
    idx = {t: i for i, t in enumerate(h["time"])}

    def val(key, dt):
        i = idx.get(dt.strftime("%Y-%m-%dT%H:%M"))
        return None if i is None else h[key][i]

    now = datetime.now(TZ)
    day = (now + timedelta(days=off)).replace(hour=0, minute=0, second=0, microsecond=0)

    # all three lists share the same hours so the QML can index them together
    points, periods, dirs = [], [], []
    last_p, last_d = 0, 0
    for hr in range(25):
        dt = day + timedelta(hours=hr)
        ht = val("wave_height", dt)
        if ht is None:
            continue
        pe, di = val("wave_period", dt), val("wave_direction", dt)
        last_p = pe if pe is not None else last_p
        last_d = di if di is not None else last_d
        points.append([hr, round(ht, 2)])
        periods.append([hr, round(last_p, 1)])
        dirs.append([hr, round(last_d)])
    if not points:
        raise RuntimeError("no GFS Wave data for that day (nulls?)")

    now_h = now.hour + now.minute / 60 if off == 0 else -1
    cur, cur_period, rising = points[0][1], periods[0][1], False
    if off == 0:
        a = int(now_h)
        s0 = val("wave_height", day + timedelta(hours=a)) or 0
        s1 = val("wave_height", day + timedelta(hours=a + 1)) or s0
        cur = s0 + (s1 - s0) * (now_h - a)
        prev = val("wave_height", day + timedelta(hours=max(a - 1, 0))) or s0
        rising = cur >= prev
        cur_period = val("wave_period", day + timedelta(hours=a)) or 0
    else:
        rising = points[-1][1] >= points[0][1]

    rise, sset = sun_times(day, LAT, LON, day.utcoffset().total_seconds() / 3600)
    pk = max(points, key=lambda p: p[1])
    return {
        "station": STATION,
        "updated": cache_updated(),
        "label": day.strftime("%a %d %b"),
        "unit": "m",
        "current": round(cur, 2),
        "period": round(cur_period, 1),
        "rising": rising,
        "now": now_h,
        "points": points,  # [hour, wave height m]
        "periods": periods,  # [hour, wave period s]
        "dirs": dirs,  # [hour, direction waves come FROM, degrees]
        "nights": [[0, round(rise, 2)], [round(sset, 2), 24]],
        "peak": {"h": pk[0], "v": pk[1], "time": f"{pk[0] % 24:02d}:00"},
    }


def combine(days):
    pts, periods, dirs, nights, meta = [], [], [], [], []
    last_i = len(days) - 1
    for off, d in enumerate(days):
        base = off * 24
        for arr, dst in (
            (d["points"], pts),
            (d["periods"], periods),
            (d["dirs"], dirs),
        ):
            for hh, vv in arr:
                if hh < 24 or off == last_i:
                    dst.append([base + hh, vv])
        for n in d["nights"]:
            nights.append([base + n[0], base + n[1]])
        meta.append({"h": base, "label": d["label"], "short": d["label"][:6]})
    pk = max(pts, key=lambda p: p[1])
    out = dict(days[0])
    out.update(
        {
            "label": "10-day",
            "span": pts[-1][0],
            "points": pts,
            "periods": periods,
            "dirs": dirs,
            "nights": nights,
            "days": meta,
            "peak": {"h": pk[0], "v": pk[1], "time": f"{pk[0] % 24:02d}:00"},
        }
    )
    return out


def main():
    args = sys.argv[1:]
    data = fetch()
    if args and args[0] == "all":
        print(json.dumps(combine([build(data, off) for off in range(10)])))
    else:
        off = int(args[0]) if args else 0
        print(json.dumps(build(data, off)))


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"swell.py: {e}", file=sys.stderr)
        sys.exit(1)
