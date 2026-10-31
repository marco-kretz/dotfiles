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

-- Spotify always lives in the "spotify" special workspace (SUPER+M).
o.window({ class = "^spotify$" }, { workspace = "special:spotify silent" })

-- Brave Origin: fully opaque (its class isn't in Omarchy's browser match).
o.window({ class = "^brave-origin$" }, { tag = "-default-opacity", opacity = "1 1" })

-- Much less transparency than Omarchy's defaults (0.985/0.96, browsers 1/0.985).
o.window({ tag = "default-opacity" }, { opacity = "1 0.99" })
o.window({ tag = "chromium-based-browser" }, { opacity = "1 0.995" })
o.window({ tag = "firefox-based-browser" }, { opacity = "1 0.995" })

o.window("GeForceNOW", { immediate = true })

-- Bitwarden extension popout in Firefox (master password unlock): float it.
-- Firefox opens it titled "Mozilla Firefox" and renames it afterwards, and
-- static rules like float only see the initial title, so react to the rename.
o.window({ class = "^firefox", title = "\\(Bitwarden.*\\) - Bitwarden" }, { no_screen_share = true })
hl.on("window.title", function(w)
  if w == nil or w.floating or not w.class:find("^firefox") or not w.title:find("%(Bitwarden.*%) %- Bitwarden") then
    return
  end
  hl.dispatch(hl.dsp.window.float({ action = "set", window = w }))
  hl.dispatch(hl.dsp.window.resize({ x = 875, y = 600, window = w }))
  hl.dispatch(hl.dsp.window.center({ window = w }))
end)

-- Bitwarden extension popout in Brave: its app-window class carries the extension ID, so a static rule suffices.
o.window({ class = "^brave-nngceckbapebfimnlniiiahkandclblb-.*" }, { float = true, center = true, no_screen_share = true })

