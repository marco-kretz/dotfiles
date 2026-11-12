# Setup

## Basics

```bash
sudo pacman -S stow starship
cp claude-code/.claude/settings.json.example claude-code/.claude/settings.json   # git-ignored, machine-local
stow --no-folding -t ~ git starship mise agents claude-code playwright notizen pipewire openrgb ddev brave noctalia
```

On WSL2, stow only the shell packages:

```bash
stow -t ~ wsl starship git agents claude-code
```

If existing files conflict, back them up and compare them first; do not use a blind `stow --adopt`.

## Agent skills

Shared skills live in `agents/.agents/skills/` (stowed to `~/.agents/skills/`). Claude Code reads them through
symlinks in `~/.claude/skills/`:

```bash
./link-agent-skills.sh --dry-run --prune
./link-agent-skills.sh --prune
```

The linker keeps existing files and foreign symlinks; `--prune` only removes its own broken links.
Skills must not embed harness-specific agent names, model IDs or tool APIs; those belong in `CLAUDE.md`.
The skills are dotfile-owned forks: to adopt an upstream skill, inspect it in a temp directory and copy it in
instead of installing over the symlinks.

`openai-image` needs an API key, kept outside the repo:

```bash
install -m 600 /dev/null ~/.config/openai.env
printf 'export OPENAI_API_KEY=sk-...\n' > ~/.config/openai.env
```

Tests for the linker and skill format:

```bash
PYTHONDONTWRITEBYTECODE=1 python -m unittest discover -s tests
```

## Playwright CLI

`playwright-cli` comes from mise; the stowed config runs headless system Chromium with an isolated in-memory
profile. `playwright-cli -s=<session> config-print` shows the resolved config.

```bash
playwright-cli -s=my-task open https://your-project.ddev.site
playwright-cli -s=my-task find "relevant label"
playwright-cli -s=my-task close
```

## Notizen

Expects the vault at `~/Dokumente/Notizen` with its own `.claude/commands/triage.md`. The timer runs
`claude -p /triage` daily at 07:30 (file tools only, confined to the vault), refreshes `GitHub.md` via
`notizen-github` first and commits the result.

```bash
systemctl --user daemon-reload
systemctl --user enable --now notizen-triage.timer
```

`notizen-toggle` is bound to Mod+N in the compositor config.

## PipeWire

```bash
systemctl --user restart wireplumber
```

## OpenRGB

Needs the `noctalia` package.

```bash
systemctl --user daemon-reload
systemctl --user enable --now openrgb-profile.service

# Sleep hook: systemd only scans /usr/lib/systemd/system-sleep, so it is symlinked, not stowed.
sudo ln -sf ~/GitHub/dotfiles/openrgb/system-sleep/openrgb /usr/lib/systemd/system-sleep/openrgb

# SMBus access for RAM / motherboard zones (after next login):
sudo usermod -aG i2c "$USER"
```

The LED color follows the palette's `mPrimary`; a hex value in `~/.config/noctalia/openrgb-accent` overrides it.
Self-test of the palette hook: `~/.config/noctalia/palette-sync --check`.

## Firefox

Palette sync via Pywalfox:

```bash
uv tool install pywalfox
pywalfox install
# Firefox with an XDG profile (~/.config/mozilla) does not read ~/.mozilla, so install the manifest system-wide.
sudo install -Dm644 ~/.mozilla/native-messaging-hosts/pywalfox.json /usr/lib/mozilla/native-messaging-hosts/pywalfox.json
rm -r ~/.mozilla   # only if pywalfox install created it
```

Restart Firefox and click "Fetch Pywal colors" once. For Vesktop, enable `noctalia.theme.css` under
Settings → Themes.

`user.js` is not stowed because the profile directory name is random:

```bash
ln -sf ~/GitHub/dotfiles/firefox/user.js ~/.config/mozilla/firefox/*.dev-edition-default/user.js
```

Removing a pref from `user.js` does not revert it; reset it in `about:config` as well.
