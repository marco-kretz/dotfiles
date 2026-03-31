# mk.dotfiles

These are the dotfiles I use on my linux-machines. Feel free to use, share or whatever.<br>

## OS

[**Omarchy**](https://omarchy.org/)

## Deps

Install required packages:

- `sudo pacman -S zsh stow fzf fd bat eza starship`

Install antidote for zsh plugins:

- `git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote`

## General tweaks

### Hyprland

```
# Use gcr-ssh agent
env = SSH_AUTH_SOCK, $XDG_RUNTIME_DIR/gcr/ssh

# No scaling for XWayland apps
xwayland {
    force_zero_scaling = true
}

# Allow HDR in fullscreen
render {
    cm_fs_passthrough = 1
}

# Disable mouse acceleration
input {
    force_no_accel = true
}
```

### Sysctl

```CONF
# Virtual Memory Tweaks for 64GB RAM (!)
# Force data to write to disk sooner to prevent massive "stop-the-world" flushes
vm.dirty_bytes = 268435456
vm.dirty_background_bytes = 134217728

# Decrease swappiness
vm.swappiness = 10

# Gaming Performance
# Disable split lock mitigate. This fixes FPS drops in many games (e.g. God of War)
# creating a performance penalty when games do sloppy memory locking.
kernel.split_lock_mitigate = 0

# Network (BBR is better for gaming latency/jitter than Cubic)
net.core.default_qdisc = cake
net.ipv4.tcp_congestion_control = bbr
```

### KDE Plasma

#### Auto unlock SSH key

1. `sudo pacman -S ksshaskpass openssh`
2. `stow -t ~ kde_ssh`
3. `systemctl enable --user ssh-agent`
4. Correct env vars are available after relog.

### GNOME (not using right now)

#### Increase window timeout

This increases the grace period for GNOME thinking that a window has crashed. Most useful for some games.

- `gsettings set org.gnome.mutter check-alive-timeout 30000`

Resize windows by holding down right mouse button

- `gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true`

#### Auto unlock SSH keys

Make sure GNOME's GCR ssh-agent wrapper is running:

- `systemctl enable --now --user gcr-ssh-agent.service`

~MK
