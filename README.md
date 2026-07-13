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
stow -t ~ git zsh opencode agents claude-code fonts vicinae pipewire voxtype environment
```

### Claude Code settings

`claude-code/.claude/settings.json` is **git-ignored** because it accumulates machine-local, project-specific permission entries that should not be public. Bootstrap it from the tracked template before stowing:

```bash
cp claude-code/.claude/settings.json.example claude-code/.claude/settings.json
```

## General tweaks

### SSH agent (GCR)

SSH keys are unlocked via the [GCR ssh-agent](https://gitlab.gnome.org/GNOME/gcr) wrapper. Keys are stored in the system keyring and unlocked once per login; GUI apps and terminal tools pick up the agent through `SSH_AUTH_SOCK`.

1. Install dependencies:

```bash
sudo dnf install gcr openssh
```

2. Enable the user service (socket activation):

```bash
systemctl --user enable --now gcr-ssh-agent.socket
```

3. Stow the environment config:

```bash
stow -t ~ environment
```

The `environment` module symlinks `~/.config/environment.d/ssh_askpass.conf`, which sets:

```conf
SSH_AUTH_SOCK=${XDG_RUNTIME_DIR}/gcr/ssh
SSH_ASKPASS=/usr/libexec/gcr-ssh-askpass
SSH_ASKPASS_REQUIRE=prefer
```

systemd loads these variables on login. Log out and back in (or reboot) after stowing.

~MK
