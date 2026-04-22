#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
import json
import openrazer.client

client = openrazer.client.DeviceManager()
devices = client.devices

for d in devices:
    try:
        if "DeathAdder V3 Pro" in d.name:
            pct = d.battery_level
            if callable(pct):
                pct = pct()

            charging = False
            try:
                charging = d.is_charging
                if callable(charging):
                    charging = charging()
            except Exception:
                pass

            pct = int(pct)

            if charging:
                icon = "󰂄"
                cls = "charging"
            elif pct >= 80:
                icon = "󰁹"
                cls = "good"
            elif pct >= 40:
                icon = "󰂀"
                cls = "normal"
            elif pct >= 20:
                icon = "󰁾"
                cls = "low"
            else:
                icon = "󰁺"
                cls = "critical"

            tooltip = f"Razer DeathAdder V3 Pro: {pct}%"
            if charging:
                tooltip += " (lädt)"

            print(json.dumps({
                "text": f"{icon} {pct}%",
                "tooltip": tooltip,
                "class": cls,
                "percentage": pct
            }))
            raise SystemExit(0)
    except Exception:
        pass

print(json.dumps({
    "text": "󰂃 N/A",
    "tooltip": "Kein Batteriewert verfügbar",
    "class": "warning",
    "percentage": 0
}))
PY
