-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- GDK_SCALE is integer-only (1 or 2). Omarchy defaults to 2 for HiDPI
-- laptops. These monitors are 1.0 (1440p) and 1.33 (4K); 2 doubles
-- XWayland apps (Steam, Spotify, …). Native Wayland apps still follow
-- each monitor's Hyprland scale.
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = "auto"

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "DP-1", mode = "2560x1440@144", position = "0x0", scale = omarchy_monitor_scale })
hl.monitor({ output = "DP-2", mode = "3840x2160@144", position = "2560x0", scale = 1.33 })

