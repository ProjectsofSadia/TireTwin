from pathlib import Path
import fastf1
import numpy as np
import pandas as pd

YEAR = 2024
DRIVER = "VER"
EVENTS = {
    "Bahrain": "bahrain.csv",
    "Monaco": "monaco.csv",
    "Monza": "monza.csv",
    "Silverstone": "silverstone.csv",
    "Suzuka": "suzuka.csv",
}

OUT = Path("data/processed")
CACHE = Path("fastf1_cache")


def nearest_weather(session, lap):
    weather = session.weather_data.copy()
    if weather.empty:
        return np.nan, np.nan
    midpoint = lap["LapStartTime"] + (lap["LapTime"] / 2)
    idx = (weather["Time"] - midpoint).abs().idxmin()
    row = weather.loc[idx]
    return float(row.get("AirTemp", np.nan)), float(row.get("TrackTemp", np.nan))


def infer_qualifying_segment(session, lap_time):
    # Fastest-lap-across-session is the explicit selection rule. This helper
    # records which classified qualifying segment time it most closely matches.
    try:
        result = session.results.loc[DRIVER]
    except Exception:
        return "unknown"
    best = (None, None)
    for seg in ["Q1", "Q2", "Q3"]:
        val = result.get(seg, pd.NaT)
        if pd.isna(val):
            continue
        diff = abs((val - lap_time).total_seconds())
        if best[1] is None or diff < best[1]:
            best = (seg, diff)
    if best[0] is not None and best[1] <= 0.005:
        return best[0]
    return "unclassified-fastest"


def extract_event(event, filename):
    print(f"\nLoading {YEAR} {event} qualifying...")
    session = fastf1.get_session(YEAR, event, "Q")
    session.load()

    laps = session.laps.pick_drivers(DRIVER)
    accurate = laps.pick_accurate()
    pool = accurate if len(accurate) else laps
    lap = pool.pick_fastest()
    if lap is None or pd.isna(lap["LapTime"]):
        raise RuntimeError(f"No usable lap for {event}")

    tel = lap.get_telemetry().copy()
    required = ["Time","Distance","Speed","Throttle","Brake","RPM","nGear","DRS","X","Y"]
    missing = [c for c in required if c not in tel.columns]
    if missing:
        raise RuntimeError(f"Missing channels at {event}: {missing}")

    air, track = nearest_weather(session, lap)
    out = tel[required].copy()
    out["Time"] = out["Time"].dt.total_seconds()
    out = out.rename(columns={"nGear":"Gear"})
    out["Brake"] = out["Brake"].astype(bool).astype(int)
    out["AirTemp_C"] = air
    out["TrackTemp_C"] = track
    out = out.apply(pd.to_numeric, errors="coerce")
    out = out.dropna(subset=["Time","Distance","Speed","Throttle","Brake","RPM","Gear","DRS","X","Y"])
    out = out.sort_values("Distance").drop_duplicates("Distance").reset_index(drop=True)

    path = OUT / filename
    out.to_csv(path, index=False)
    seg = infer_qualifying_segment(session, lap["LapTime"])
    print(f"{event}: lap {int(lap['LapNumber'])}, {lap['LapTime']}, {seg}, {len(out)} samples")
    print(f"Weather: air={air:.1f} C, track={track:.1f} C")
    print(f"Saved: {path}")
    return {
        "Event": event,
        "Year": YEAR,
        "Session": "Q",
        "Driver": DRIVER,
        "SelectionRule": "fastest accurate lap across full qualifying session",
        "QualifyingSegment": seg,
        "LapNumber": float(lap["LapNumber"]),
        "LapTime": str(lap["LapTime"]),
        "Samples": len(out),
        "AirTemp_C": air,
        "TrackTemp_C": track,
        "File": str(path),
    }


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    CACHE.mkdir(parents=True, exist_ok=True)
    fastf1.Cache.enable_cache(str(CACHE))
    rows=[]
    for event, fn in EVENTS.items():
        rows.append(extract_event(event, fn))
    pd.DataFrame(rows).to_csv(OUT/"telemetry_manifest_v2.csv", index=False)
    print("\nDONE — all v2 telemetry files and manifest created.")

if __name__ == "__main__":
    main()
