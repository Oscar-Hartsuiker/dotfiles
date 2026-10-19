#!/usr/bin/env python3
"""wind.py [dayOffset] -> JSON for the wind chart (GFS via Open-Meteo, knots)."""

import json, math, sys, time, urllib.parse, urllib.request
from datetime import datetime, timedelta
from pathlib import Path
from zoneinfo import ZoneInfo

STATION = "Cape St Francis"
LAT, LON = -34.21, 24.84
TZ = ZoneInfo("Africa/Johannesburg")
CACHE = Path.home() / ".cache" / "surf" / "wind_gfs.json"
TTL = 1800  # seconds

URL = "https://api.open-meteo.com/v1/gfs?" + urllib.parse.urlencode(
    {
        "latitude": LAT,
        "longitude": LON,
        "hourly": "wind_speed_10m,wind_direction_10m,wind_gusts_10m",
        "wind_speed_unit": "kn",
        "timezone": "Africa/Johannesburg",
        "past_days": 2,
        "forecast_days": 7,
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
        if CACHE.exists():  # offline: fall back to stale cache
            return json.loads(CACHE.read_text())
        raise


def sun_times(day, lat, lon, tz_hours):
    """NOAA simplified sunrise/sunset -> local decimal hours."""
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
    rise = 720 - 4 * (lon + ha) - eqt
    sset = 720 - 4 * (lon - ha) - eqt
    return rise / 60 + tz_hours, sset / 60 + tz_hours


def main():
    off = int(sys.argv[1]) if len(sys.argv) > 1 else 0
    data = fetch()
    h = data["hourly"]
    idx = {t: i for i, t in enumerate(h["time"])}

    def val(key, dt):
        i = idx.get(dt.strftime("%Y-%m-%dT%H:%M"))
        return None if i is None else h[key][i]

    now = datetime.now(TZ)
    day = (now + timedelta(days=off)).replace(hour=0, minute=0, second=0, microsecond=0)

    points, gusts, dirs = [], [], []
    for hr in range(25):  # 00:00 -> 24:00
        dt = day + timedelta(hours=hr)
        sp, gu, di = (
            val("wind_speed_10m", dt),
            val("wind_gusts_10m", dt),
            val("wind_direction_10m", dt),
        )
        if sp is None:
            continue
        points.append([hr, round(sp, 1)])
        gusts.append([hr, round(gu if gu is not None else sp, 1)])
        dirs.append([hr, round(di)] if di is not None else [hr, 0])
    if not points:
        raise RuntimeError("no GFS data for that day")

    # current speed, linearly interpolated between hours
    now_h = now.hour + now.minute / 60 if off == 0 else -1
    cur, rising = points[0][1], False
    if off == 0:
        a = int(now_h)
        s0 = val("wind_speed_10m", day + timedelta(hours=a)) or 0
        s1 = val("wind_speed_10m", day + timedelta(hours=a + 1)) or s0
        cur = s0 + (s1 - s0) * (now_h - a)
        prev = val("wind_speed_10m", day + timedelta(hours=max(a - 1, 0))) or s0
        rising = cur >= prev
    else:
        rising = points[-1][1] >= points[0][1]

    rise, sset = sun_times(day, LAT, LON, day.utcoffset().total_seconds() / 3600)
    peak = max(gusts, key=lambda p: p[1])
    out = {
        "station": STATION,
        "label": day.strftime("%a %d %b"),
        "unit": "kn",
        "current": round(cur, 1),
        "rising": rising,
        "now": now_h,
        "points": points,  # [hour, wind speed kn]
        "gusts": gusts,  # [hour, gust kn]
        "dirs": dirs,  # [hour, direction wind comes FROM, degrees]
        "nights": [[0, round(rise, 2)], [round(sset, 2), 24]],
        "max_gust": {"h": peak[0], "v": peak[1], "time": f"{peak[0] % 24:02d}:00"},
    }
    print(json.dumps(out))


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"wind.py: {e}", file=sys.stderr)
        sys.exit(1)
