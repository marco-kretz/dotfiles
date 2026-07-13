# mk.dotfiles

These are the dotfiles I use on my Linux machines. Feel free to use, share or whatever.

## OS

[**Fedora 44**](https://fedoraproject.org/) with [**Niri**](https://github.com/niri-wm/niri) and [**Noctalia Shell**](https://github.com/noctalia-dev/noctalia).

## Deps

Install required packages:

```bash
sudo dnf install zsh stow fzf fd-find bat eza starship
```

Install antidote for zsh plugins:

```bash
git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote
```

## Stow packages

```bash
stow -t ~ git zsh opencode agents claude-code pi fonts vicinae pipewire voxtype
```

The `pi` package symlinks Pi settings and extensions into `~/.pi/agent/`.

### Claude Code settings

`claude-code/.claude/settings.json` is **git-ignored** because it accumulates machine-local, project-specific permission entries that should not be public. Bootstrap it from the tracked template before stowing:

```bash
cp claude-code/.claude/settings.json.example claude-code/.claude/settings.json
```

## General tweaks

### Sysctl

```conf
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

1. `sudo dnf install ksshaskpass openssh`
2. `stow -t ~ kde_ssh`
3. `systemctl enable --user ssh-agent`
4. Correct env vars are available after relog.

### GNOME (not using right now)

#### Increase window timeout

This increases the grace period for GNOME thinking that a window has crashed. Most useful for some games.

```bash
gsettings set org.gnome.mutter check-alive-timeout 30000
```

Resize windows by holding down right mouse button:

```bash
gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true
```

#### Auto unlock SSH keys

Make sure GNOME's GCR ssh-agent wrapper is running:

```bash
systemctl enable --now --user gcr-ssh-agent.service
```

~MK
