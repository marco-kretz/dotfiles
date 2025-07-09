#!/bin/bash

# Check if gnome-keyring-daemon is already running and start it if not
if ! pgrep -x gnome-keyring-daemon > /dev/null; then
    eval "$(gnome-keyring-daemon --start)"
fi

# Set environment variables for SSH agent if you want gnome-keyring to manage SSH keys
# This assumes gcr-ssh-agent.socket is enabled and active (see below)
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"

# You might need to set these for some applications
export XDG_CURRENT_DESKTOP="Hyprland"
export XDG_SESSION_DESKTOP="Hyprland"
