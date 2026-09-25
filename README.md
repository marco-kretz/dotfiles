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
stow -t ~ bin git starship agents claude-code codex pi opencode pipewire voxtype openrgb ddev hypr playwright
```

| Package | What it links |
|---|---|
| `bin` | `~/.local/bin/z-vault-sort` (sorts the Obsidian inbox into notes via TypeSafe Jev; dry run by default, `--apply` moves) |
| `git` | `~/.gitconfig` |
| `starship` | `~/.config/starship.toml` |
| `agents` | `~/.agents/skills/*` (skills shared by all coding agents) |
| `claude-code` | `~/.claude/CLAUDE.md`, native `agents/`, statusline script, `settings.json.example` |
| `pi` | `~/.pi/agent/AGENTS.md`, local extension, `settings.json.example`; bootstrapped `settings.json` is git-ignored |
| `codex` | `~/.codex/{config.toml,AGENTS.md}`, native `agents/*.toml`, and a portable `config.toml.example` |
| `playwright` | `~/.playwright/cli.config.json` (headless system Chromium for Playwright CLI) |
| `opencode` | `~/.config/opencode/{opencode.json,tui.json,agents/,AGENTS.md}` |
| `pipewire` | MMX 300 EQ sink, pulse autogain block, WirePlumber drop-in that disables ALSA suspend-on-idle (broken stereo after standby) |
| `voxtype` | `~/.config/voxtype/config.toml` |
| `openrgb` | `sizes.ors`, `zWhite` / `zOff` profiles, Omarchy `theme-set` hook that syncs the LEDs to the theme accent, oneshot that applies it on graphical login, sleep hook (not stowed, see below) |
| `ddev` | `~/.ddev/commands/host/worktree` (`ddev worktree <branch>`: new git worktree as its own DDEV project, incl. DB copy) |
| `hypr` | My Hyprland overrides in `~/.config/hypr/`: `hyprland.lua`, `bindings.lua`, `autostart.lua`, `workspaces.lua`, `monitors.lua`, `input.lua`. Files still at the Omarchy default (`looknfeel.lua`, `hyprsunset.conf`, `xdph.conf`, `.luarc.json`) stay untracked so package updates keep improving them. |
| `wsl` | WSL2-only (not on Omarchy): `~/.zshrc`, `~/.zsh_plugins.txt` (antidote), `~/.gitconfig.wsl` (included by `~/.gitconfig`: plain `less` pager, `gh` credential helper); SSH agent relayed from Windows via `npiperelay` + `socat` |

On WSL2, stow the shell package instead of the desktop ones:

```bash
stow -t ~ wsl starship git agents claude-code
```

After stowing `pipewire`:

```bash
systemctl --user restart wireplumber
```

After stowing `openrgb`:

```bash
systemctl --user daemon-reload
systemctl --user enable --now openrgb-profile.service

# Sleep hook: blanks the LEDs before suspend and restores them on resume.
# systemd only scans /usr/lib/systemd/system-sleep (not /etc), so it is symlinked, not stowed.
sudo ln -sf ~/GitHub/dotfiles/openrgb/system-sleep/openrgb /usr/lib/systemd/system-sleep/openrgb

# The user needs read access to the SMBus devices for RAM / motherboard zones:
sudo usermod -aG i2c "$USER"   # takes effect after the next login
```

The LED color follows the active Omarchy theme's `accent` from its `colors.toml`. To use a different
color for the LEDs than for the UI, drop a hex value into
`~/.config/omarchy/themes/<slug>/openrgb-accent` — it wins over `accent`.

### Agent skills

Only skills are shared. Each harness owns its complete global instruction file;
there is no common base file to import or read. Shared skills live in
`agents/.agents/skills/`, stowed to `~/.agents/skills/`. Pi and Codex discover this
directory directly. Claude Code uses symlinks into it:

```bash
stow -t ~ agents claude-code codex pi
./link-agent-skills.sh --dry-run --prune
./link-agent-skills.sh --prune
```

The linker preserves existing harness-specific files and symlinks. `--prune` removes
only broken links created in its own `~/.agents/skills/<name>` format, not unrelated links.
Do not add duplicate shared skills under Pi or Codex's private skill roots.

#### `openai-image`

The `openai-image` skill needs an OpenAI API key. It is not part of this repo — create
it once per machine:

```bash
install -m 600 /dev/null ~/.config/openai.env
printf 'export OPENAI_API_KEY=sk-...\n' > ~/.config/openai.env
echo '[ -f ~/.config/openai.env ] && . ~/.config/openai.env' >> ~/.bashrc
```

Shared skills must not embed harness-specific agent names, model IDs, or tool APIs.
Review routing belongs in the harness's own instruction file:

| Harness | Global instructions (self-contained) | Subagent config | Independent PR review |
|---|---|---|---|
| Pi | `pi/.pi/agent/AGENTS.md` | `settings.json` → `subagents.agentOverrides` | Native `pi-subagents` `reviewer` |
| Claude Code | `claude-code/.claude/CLAUDE.md` | `.claude/agents/*.md` | `code-quality-reviewer` |
| Codex | `codex/.codex/AGENTS.md` | `.codex/agents/*.toml` | `reviewer` |

The three files overlap in wording on purpose. Editing one does not change the others;
keep a rule in the harness where it belongs instead of reintroducing a shared base.

Pi's four configured core child roles inherit its global instruction file. Other
children need the applicable rules in their task packet. Keep harness-specific skills
and agents in their harness package, never in the shared skills root.

Manual-only shared skills use both `disable-model-invocation: true` (Pi/Claude) and
`agents/openai.yaml` with `policy.allow_implicit_invocation: false` (Codex).
An explicit Codex `skills.config` disable still takes precedence.

These customized shared skills are **dotfile-owned forks**, not upstream-managed
installs. Their old `npx skills` update registrations were removed locally so a later
bulk update cannot overwrite the customizations. To adopt another upstream skill,
inspect it in a temporary directory, copy the selected files into the shared package,
and Stow them; do not install over existing dotfile symlinks. Keep unmodified,
package-managed skills separate and update those through their own manager.

The retired `why` and `verify-this` skills are removed. The `omarchy` and `diagnose-crash` skills remain
Omarchy-owned and are not tracked here. Private harness skills remain untouched.

Check the portable setup and safe linker behavior with:

```bash
PYTHONDONTWRITEBYTECODE=1 python -m unittest discover -s tests
```

### Claude Code settings

`claude-code/.claude/settings.json` is **git-ignored** because it accumulates machine-local, project-specific permission entries that should not be public. Bootstrap it from the tracked template before stowing:

```bash
cp claude-code/.claude/settings.json.example claude-code/.claude/settings.json
```

### Pi settings

Bootstrap the machine-local config before Stowing:

```bash
cp pi/.pi/agent/settings.json.example pi/.pi/agent/settings.json
stow -t ~ pi
```

If existing files conflict, back them up and compare them first; do not use a blind
`stow --adopt`. Pi's credentials, models cache, sessions, trust, npm packages, themes,
and runtime artifacts stay outside this package. The template uses the built-in dark
theme; keep machine-specific theme/model preferences in the ignored live settings.

Extension versions are pinned to the inspected installation. Update pins deliberately
in both live settings and the template, then install/update through Pi. Ponytail's
always-on extension and general mode skill are excluded in Pi; only its focused
review, audit, and debt skills are loaded. This does not change another harness's
Ponytail configuration. Core shared rules already cover minimal changes and testing.

After setup changes, restart Pi to refresh extensions, tools, skills, and agent overrides.
Restart Codex after instruction/config changes; restart Claude Code after agent changes.
Do not treat already-loaded instructions in an existing conversation as refreshed.

### Codex settings

`codex/.codex/config.toml` is **git-ignored** because Codex stores machine-local paths,
project trust, plugin state, and desktop settings in it. The tracked `config.toml.example`
contains model defaults, subagent defaults, general settings, and plugin enablement.
On a new machine, bootstrap the config before stowing:

```bash
cp codex/.codex/config.toml.example codex/.codex/config.toml
stow -t ~ codex
```

The Codex-specific `AGENTS.md` and the `agents/*.toml` subagent definitions are tracked
directly. Shared skills remain in the `agents` package. Install the enabled plugins separately on new machines.
Credentials, sessions, caches, and local approval rules remain outside the package.
After changing portable settings, update `config.toml.example` as well.

Codex does not use Ponytail or the retired `astra-orchestrator` skill. Agent defaults
live in the config; review routing lives in `AGENTS.md` and `agents/reviewer.toml`.
Browser MCP plugins are disabled. Browser checks use CLI tools headlessly with
`/usr/bin/chromium`; prefer existing project tests. For exploratory checks, install
Playwright CLI through mise (verified with `@playwright/cli` 0.1.21):

```bash
mise use -g npm:@playwright/cli@0.1.21
stow -t ~ playwright
playwright-cli -s=my-task open https://your-project.ddev.site
playwright-cli -s=my-task find "relevant label"
playwright-cli -s=my-task close
```

The global config uses headless system Chromium with its sandbox enabled and an
isolated in-memory profile. No browser download, browser MCP, or personal browser
session is needed. Project `.playwright/cli.config.json` files and CLI options can
override these defaults; `playwright-cli -s=my-task config-print` shows the resolved
configuration for an open session.
Use a named session per task and close it afterward. Read targeted `find` results
or snapshot excerpts; use `--raw` for focused result values and screenshots only
when visual evidence is needed. Inspect error/result output as well as exit status:
the CLI can report a browser error with exit code 0. Keep repeatable regression
tests in the project.
The existing `~/.local/bin/playwright` wrapper is managed separately and unchanged.

~MK
