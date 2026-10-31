-- Make the 4K display Wine/Proton's default monitor.
o.exec_on_start("xrandr --output DP-2 --primary")

-- Start Obsidian so it lands in its special workspace.
o.launch_on_start("obsidian")

-- Play the Mario GIF across the Stream Deck keys.
o.exec_on_start("uv run --with streamdeck --with pillow ~/GitHub/streamdeck-gif-player/streamdeck-gif.py ~/GitHub/streamdeck-gif-player/mario-walk.gif")

-- Video wallpaper on all monitors. Bottom layer so it sits above omarchy-background.
o.exec_on_start([[mpvpaper -p -l bottom -o "no-audio loop hwdec=auto" ALL "$HOME/Videos/wallpaper videos/warwick-dark-experiment.3840x2160.mp4"]])
