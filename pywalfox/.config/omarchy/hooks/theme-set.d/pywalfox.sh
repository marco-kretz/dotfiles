#!/bin/bash
# Feed the theme's terminal palette to Pywalfox (Firefox) in pywal's colors.json format.
command -v pywalfox >/dev/null || exit 0

python3 - "$HOME/.local/state/omarchy/current/theme/alacritty.toml" "$(omarchy-theme-bg-current 2>/dev/null)" <<'EOF' || exit 0
import json, os, sys, tomllib

c = tomllib.load(open(sys.argv[1], "rb"))["colors"]
names = ["black", "red", "green", "yellow", "blue", "magenta", "cyan", "white"]
palette = [c["normal"][n] for n in names] + [c["bright"][n] for n in names]
# pywal convention: color0 is the background, color15 the foreground.
palette[0], palette[15] = c["primary"]["background"], c["primary"]["foreground"]

out = os.path.expanduser("~/.cache/wal/colors.json")
os.makedirs(os.path.dirname(out), exist_ok=True)
json.dump({
    "wallpaper": sys.argv[2],
    "special": {"background": palette[0], "foreground": palette[15], "cursor": palette[15]},
    "colors": {f"color{i}": v for i, v in enumerate(palette)},
}, open(out, "w"), indent=2)
EOF

pywalfox update &>/dev/null || true
