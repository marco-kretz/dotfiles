# mk.dotfiles

These are the dotfiles I use on my linux-machines. Feel free to use, share or whatever.<br>
Use [chezmoi](https://www.chezmoi.io/) to copy the configs to their correct destination.

## OS

[**Archlinux**](https://archlinux.org/)

## Deps

Install required packages:

-   `sudo pacman -S zsh stow fzf fd bat eza starship`

Install antidote for zsh plugins:

-   `git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote`

## General tweaks

### KDE Plasma

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

### GNOME

#### Increase window timeout

This increases the grace period for GNOME thinking that a window has crashed. Most useful for some games.

-   `gsettings set org.gnome.mutter check-alive-timeout 30000`

Resize windows by holding down right mouse button

-   `gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true`

#### Auto unlock SSH keys

Make sure GNOME's GCR ssh-agent wrapper is running:

-   `systemctl enable --now --user gcr-ssh-agent.service`

### Hyprland

-   GTK-Theme: [Graphite](https://github.com/vinceliuice/Graphite-gtk-theme)
-   Cursor: Posy (included in the repo, xcursor + hyprcursor variant taken from [here](https://github.com/simtrami/posy-improved-cursor-linux) and [here](https://github.com/itsHanibee/posy-improved-cursor-hypr))
    <br>
-   Status bar: `waybar`
-   App launcher: `rofi`
-   Notification daemon: `mako`

~MK
