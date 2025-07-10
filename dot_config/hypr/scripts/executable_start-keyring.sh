#!/bin/bash

# Check if gnome-keyring-daemon is already running and start it if not
if ! pgrep -x gnome-keyring-daemon > /dev/null; then
    eval "$(gnome-keyring-daemon --start)"
fi

