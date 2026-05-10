# Pi dotfiles

GNU stow package for my Pi configuration and extensions.

## Layout

When you run `stow -t ~ pi` from the dotfiles repo, these paths are symlinked:

```text
~/.pi/agent/settings.json
~/.pi/agent/extensions/explore-codebase/index.ts
~/.pi/agent/extensions/omarchy-system-theme.ts
~/.pi/agent/skills/omarchy
```

Root files like this README, `package.json`, `settings.example.json`, and `scripts/` are ignored by stow via `.stow-local-ignore`.

## Included public Pi config

- `settings.json` with default model/theme and package list
- `explore-codebase` extension
- `omarchy-system-theme.ts` extension to sync Pi's light/dark theme with Omarchy
- `omarchy` skill symlink to the local Omarchy skill installation
- `npm:pi-codex-image-gen` in settings so Pi installs the image generation package

Not included: auth tokens, session history, and generated package state files.

## explore_codebase

`.pi/agent/extensions/explore-codebase/index.ts` registers an `explore_codebase` tool. The main agent can delegate broad codebase searches to a read-only sub-agent that runs Pi in JSON mode with only these tools enabled:

- `read`
- `grep` — Pi's grep tool uses `rg`/ripgrep internally
- `find`
- `ls`

The sub-agent is instructed to prefer ripgrep-backed searches, read only relevant files, and return a concise findings report with paths and line references.

## Install on a new machine

From the dotfiles repo root:

```bash
stow -t ~ pi
```

Or use the helper:

```bash
~/GitHub/dotfiles/pi/scripts/install.sh
```

If `~/.pi/agent/settings.json` already exists as a regular file, the helper moves it into this stow package first and keeps a `.backup-before-stow` copy.

## Configuration

The extension reads the explorer model from `~/.pi/agent/settings.json`:

```json
{
  "subagents": {
    "explorer": {
      "provider": "openai-codex",
      "model": "gpt-5.3-codex",
      "thinkingLevel": "medium"
    }
  }
}
```

Environment variables override the file config:

```bash
PI_EXPLORER_PROVIDER=openai-codex
PI_EXPLORER_MODEL=gpt-5.3-codex
PI_EXPLORER_THINKING=medium
```

## Alternative: install as Pi package

This directory is also a valid Pi package:

```bash
pi install ~/GitHub/dotfiles/pi
```

For my own machines I prefer stow, because the extension and settings are regular dotfile symlinks.

## Do not commit

Do **not** commit:

```text
~/.pi/agent/auth.json
~/.pi/agent/sessions/
~/.pi/agent/extensions/codex-image-gen-install.json
```

`codex-image-gen-install.json` is generated package state; `npm:pi-codex-image-gen` in `settings.json` is the portable config.
