-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Super+scroll: only cycle workspaces on the focused monitor (niri-like).
-- Default Omarchy uses e+1/e-1, which walks every existing workspace and
-- can jump to the other screen.
hl.unbind("SUPER + mouse_down")
hl.unbind("SUPER + mouse_up")
o.bind("SUPER + mouse_down", "Scroll workspace forward on this monitor", hl.dsp.focus({ workspace = "m+1" }))
o.bind("SUPER + mouse_up", "Scroll workspace backward on this monitor", hl.dsp.focus({ workspace = "m-1" }))

hl.unbind("SUPER + SHIFT + M") -- previously: Music
o.bind("SUPER + SHIFT + M", "Omarchy Spotify", "omarchy shell -q quickshell.spotify.player togglePlayer")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Obsidian on a special workspace, reachable from anywhere with SUPER+N.
o.bind("SUPER + N", "Toggle Obsidian", hl.dsp.workspace.toggle_special("obsidian"))

-- Spotify on a special workspace, reachable from anywhere with SUPER+M.
o.bind("SUPER + M", "Toggle Spotify", hl.dsp.workspace.toggle_special("spotify"))

-- Next to the system menu (SUPER+ESCAPE): confirm, then reboot once into Windows.
o.bind("SUPER + SHIFT + ESCAPE", "Reboot into Windows", "omarchy-reboot-windows")
