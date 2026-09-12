-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Make the 4K display Wine/Proton's default monitor.
o.exec_on_start("xrandr --output DP-2 --primary")

-- Start Obsidian so it lands in its special workspace.
o.launch_on_start("obsidian")
