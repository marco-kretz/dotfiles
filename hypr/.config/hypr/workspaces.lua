-- Pin numbered workspaces to monitors so Super+1..9 and Super+scroll
-- stay on the intended screen.
--
--   DP-1  Odyssey (side):  1 2 3 9
--   DP-2  Dell (main):     4 5 6 7 8
--
-- persistent keeps empty assigned workspaces alive so Super+scroll
-- with m+/- walks the full set on that monitor.

local assignments = {
  { monitor = "DP-1", workspaces = { 1, 2, 3, 9 }, default = 1 },
  { monitor = "DP-2", workspaces = { 4, 5, 6, 7, 8 }, default = 4 },
}

for _, assignment in ipairs(assignments) do
  for _, id in ipairs(assignment.workspaces) do
    hl.workspace_rule({
      workspace = tostring(id),
      monitor = assignment.monitor,
      persistent = true,
      default = id == assignment.default,
    })
  end
end
