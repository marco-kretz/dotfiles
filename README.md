# mk.dotfiles

These are the dotfiles I use on my Linux machines. Feel free to use, share or whatever.

## OS

[**Omarchy**](https://omarchy.org/) (Arch Linux, Hyprland). Shell is the Omarchy default (bash) with Starship.

## Deps

```bash
sudo pacman -S stow starship
```

## Stow packages

```bash
stow -t ~ git starship agents claude-code opencode pipewire voxtype openrgb
```

| Package | What it links |
|---|---|
| `git` | `~/.gitconfig` |
| `starship` | `~/.config/starship.toml` |
| `agents` | `~/.agents/AGENTS.md` (shared rules for all coding agents) and `~/.agents/skills/*` |
| `claude-code` | `~/.claude/CLAUDE.md`, statusline script, `settings.json.example` |
| `opencode` | `~/.config/opencode/{opencode.json,tui.json,agents/}`, `AGENTS.md` symlinks to the shared one |
| `pipewire` | MMX 300 EQ sink, pulse autogain block, WirePlumber drop-in that disables ALSA suspend-on-idle (broken stereo after standby) |
| `voxtype` | `~/.config/voxtype/config.toml` |
| `openrgb` | `sizes.ors`, `zWhite` / `zOff` profiles, oneshot that applies `zWhite` on graphical login |

After stowing `pipewire`:

```bash
systemctl --user restart wireplumber
```

After stowing `openrgb`:

```bash
systemctl --user daemon-reload
systemctl --user enable --now openrgb-profile.service
```

### Agent skills

Skills live in `agents/.agents/skills/` and are stowed to `~/.agents/skills/`, which is where
[`npx skills`](https://github.com/vercel-labs/skills) installs to as well. To add a new skill,
install it with `npx skills add <repo> -g`, then move the resulting directory from `~/.agents/skills/`
into `agents/.agents/skills/` and run `stow -t ~ agents`.

Claude Code reads `~/.claude/skills/`, so link them there once (idempotent, `--prune` removes dead links):

```bash
./link-agent-skills.sh --prune
```

The `omarchy` and `diagnose-crash` skills are shipped by Omarchy itself and are not tracked here.

### Claude Code settings

`claude-code/.claude/settings.json` is **git-ignored** because it accumulates machine-local, project-specific permission entries that should not be public. Bootstrap it from the tracked template before stowing:

```bash
cp claude-code/.claude/settings.json.example claude-code/.claude/settings.json
```

~MK
