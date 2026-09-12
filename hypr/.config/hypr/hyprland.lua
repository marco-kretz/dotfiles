-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.workspaces")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Steam / Proton games always land on workspace 7. Proton & native Steam
-- games get the class steam_app_<appid> (or steam_app_battlenet for the
-- Battle.net launcher), so match that prefix. The Steam client itself
-- (class "steam") is unaffected.
o.window({ class = "^steam_app_" }, { workspace = "7" })

-- World of Warcraft (Battle.net / Proton) shares class steam_app_battlenet
-- with the launcher, so also match the title. Force compositor fullscreen
-- so the bar is hidden instead of a tiled window sitting below it.
o.window({ class = "^steam_app_battlenet$", title = "^World of Warcraft" }, {
  fullscreen = true,
  tag = "-default-opacity",
  opacity = "1 1",
  idle_inhibit = "fullscreen",
})

-- unscale XWayland
hl.config({
  xwayland = {
    force_zero_scaling = true
  }
})

-- Obsidian always lives in the "obsidian" special workspace (SUPER+N).
o.window({ class = "^md\\.obsidian\\.Obsidian$" }, { workspace = "special:obsidian silent" })
