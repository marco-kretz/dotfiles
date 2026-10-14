#!/bin/bash
# Write the theme's palette as a Vesktop (Vencord) theme. Enable once under
# Vesktop settings > Themes; later theme switches just rewrite the file.
THEMES_DIR="$HOME/.config/vesktop/themes"
[ -d "$THEMES_DIR" ] || exit 0

c() { omarchy-theme-color "$@"; }

cat >"$THEMES_DIR/omarchy.theme.css" <<EOF
/**
 * @name Omarchy
 * @description Generated from the current Omarchy theme by ~/.config/omarchy/hooks/theme-set.d/vesktop.sh
 */
:root, .theme-dark, .theme-darker, .theme-midnight, .theme-light {
  --background-base-lowest: $(c darker_background) !important;
  --background-base-lower: $(c dark_background) !important;
  --background-base-low: $(c background) !important;
  --background-surface-high: $(c lighter_background) !important;
  --background-surface-higher: $(c lighter_background) !important;
  --background-surface-highest: $(c selection_background) !important;
  --chat-background-default: $(c background) !important;
  --text-default: $(c foreground) !important;
  --text-strong: $(c bright_foreground) !important;
  --text-muted: $(c muted) !important;
  --text-link: $(c blue) !important;
  --interactive-normal: $(c foreground) !important;
  --interactive-hover: $(c bright_foreground) !important;
  --interactive-active: $(c bright_foreground) !important;
  --interactive-muted: $(c muted) !important;
  --brand-500: $(c accent) !important;
}
EOF
