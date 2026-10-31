-- Pin numbered workspaces to monitors so Super+1..9 and Super+scroll
-- stay on the intended screen.
--
--   left   Odyssey (side):  1 2 3 9
--   right  Dell (main):     4 5 6 7 8
--
-- Monitors are matched by description, not port (DP-n can change).
-- persistent keeps empty assigned workspaces alive so Super+scroll
-- with m+/- walks the full set on that monitor.

local leftMonitor = "desc:Samsung Electric Company Odyssey G50A"
local rightMonitor = "desc:Dell Inc. DELL G3223Q"

local assignments = {
  { monitor = leftMonitor, workspaces = { 1, 2, 3, 9 }, default = 1 },
  { monitor = rightMonitor, workspaces = { 4, 5, 6, 7, 8 }, default = 4 },
}

for _, assignment in ipairs(assignments) do
  for _, id in ipairs(assignment.workspaces) do
    hl.workspace_rule({
      workspace = tostring(id),
      monitor = assignment.monitor,
      persistent = true,
      default = id == assignment.default,
      -- Workspace 1: master layout, main window 2/3 (master.mfact in looknfeel.lua).
      layout = id == 1 and "master" or nil,
    })
  end
end
