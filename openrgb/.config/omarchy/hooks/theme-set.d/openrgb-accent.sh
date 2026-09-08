#!/bin/bash
# Sync OpenRGB static color to the new theme's accent color.
# ~/.config/omarchy/themes/<slug>/openrgb-accent overrides the theme's accent
# with a hand-picked hex (e.g. for a color perceptibly clearer than the UI accent).
THEME_SLUG=$1
THEME_DIR="$HOME/.config/omarchy/themes/$THEME_SLUG"
COLORS_TOML="$THEME_DIR/colors.toml"
[ -f "$COLORS_TOML" ] || COLORS_TOML="/usr/share/omarchy/themes/$THEME_SLUG/colors.toml"

if [ -f "$THEME_DIR/openrgb-accent" ]; then
    ACCENT=$(grep -oE '[0-9a-fA-F]{6}' "$THEME_DIR/openrgb-accent" | head -1)
elif [ -f "$COLORS_TOML" ]; then
    ACCENT=$(grep -m1 '^accent' "$COLORS_TOML" | grep -oE '[0-9a-fA-F]{6}')
fi
[ -n "$ACCENT" ] || exit 0

openrgb -m direct -c "$ACCENT"
