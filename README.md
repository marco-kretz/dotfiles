# mk.dotfiles

These are the dotfiles I use on my linux-machines. Feel free to use, share or whatever.<br>

## OS

[**Omarchy**](https://omarchy.org/)

## Deps

Install required packages:

-   `sudo pacman -S zsh stow fzf fd bat eza starship`

Install antidote for zsh plugins:

-   `git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote`

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
# Virtual Memory Tweaks for 64GB RAM
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

### KDE Plasma (not using right now)

#### Auto unlock SSH key

1. `stow -t ~ kde_ssh` - Makes sure to set the correct env vars
2. Create two user systemd service files:

    ```BASH
    # ~/config/systemd/user/ssh-agent.service

    [Unit]
    Description=SSH key agent
    Before=default.target

    [Service]
    Type=simple
    Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
    ExecStart=/usr/bin/ssh-agent -D -a $SSH_AUTH_SOCK

    [Install]
    WantedBy=default.target
    ```

    ```BASH
    # ~/config/systemd/user/ssh-add.service

    [Unit]
    Description=Add default SSH key to agent
    After=ssh-agent.service
    Requires=ssh-agent.service

    [Service]
    Type=oneshot
    Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
    ExecStart=/usr/bin/ssh-add ~/.ssh/id_rsa
    RemainAfterExit=yes

    [Install]
    WantedBy=default.target
    ```

3. Let systemd detect the new services: `systemctl daemon-reload`
4. Start the services: `systemctl enable --user  --now ssh-agent.service && systemctl enable --user --now ssh-add.service`

### GNOME (not using right now)

#### Increase window timeout

This increases the grace period for GNOME thinking that a window has crashed. Most useful for some games.

-   `gsettings set org.gnome.mutter check-alive-timeout 30000`

Resize windows by holding down right mouse button

-   `gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true`

#### Auto unlock SSH keys

Make sure GNOME's GCR ssh-agent wrapper is running:

-   `systemctl enable --now --user gcr-ssh-agent.service`

~MK
