# Pi dotfiles

GNU stow package for my Pi configuration and extensions.

## Layout

When you run `stow -t ~ pi` from the dotfiles repo, these paths are symlinked:

```text
~/.pi/agent/settings.json
~/.pi/agent/extensions/explore-codebase/index.ts
~/.pi/agent/extensions/consult-advisor/index.ts
~/.pi/agent/extensions/omarchy-system-theme.ts
~/.pi/agent/skills/omarchy
```

Root files like this README, `package.json`, `settings.example.json`, and `scripts/` are ignored by stow via `.stow-local-ignore`.

## Included public Pi config

- `settings.json` with default model/theme and package list
- `explore-codebase` extension
- `consult-advisor` extension for a higher-reasoning read-only advisor sub-agent
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

The sub-agent is instructed to act as a scanner, not an implementer: prefer ripgrep-backed searches, read only relevant files, avoid speculation, and return the smallest useful set of grounded findings.

Optional modes:

- `targeted_search` — find concrete features, symbols, routes, config, or text
- `impact_analysis` — find code paths and risks affected by changing something
- `behavior_trace` — trace a request, command, event, or workflow through the code

Output is compact Markdown with fixed sections: summary, relevant files, entry points, data flow, tests, risks/side effects, open questions, and confidence.

## consult_advisor

`.pi/agent/extensions/consult-advisor/index.ts` registers a `consult_advisor` tool. The main agent can delegate difficult reasoning to a stronger read-only advisor model.

Use it for:

- deeper reasoning or second opinions
- when the current agent is unsure or in doubt
- plan review and design critique
- debugging strategy
- risk analysis
- architecture trade-offs

Default model config:

```json
{
  "subagents": {
    "advisor": {
      "provider": "openai-codex",
      "model": "gpt-5.5",
      "thinkingLevel": "xhigh"
    }
  }
}
```

Environment overrides:

```bash
PI_ADVISOR_PROVIDER=openai-codex
PI_ADVISOR_MODEL=gpt-5.5
PI_ADVISOR_THINKING=xhigh
```

The advisor gets only read-only tools (`read`, `grep`, `find`, `ls`) and outputs compact Markdown: recommendation, reasoning, risks, checks, open questions, and confidence.

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

The extensions read sub-agent model config from `~/.pi/agent/settings.json`:

```json
{
  "subagents": {
    "explorer": {
      "provider": "openai-codex",
      "model": "gpt-5.3-codex",
      "thinkingLevel": "medium"
    },
    "advisor": {
      "provider": "openai-codex",
      "model": "gpt-5.5",
      "thinkingLevel": "xhigh"
    }
  }
}
```

Environment variables override the file config:

```bash
PI_EXPLORER_PROVIDER=openai-codex
PI_EXPLORER_MODEL=gpt-5.3-codex
PI_EXPLORER_THINKING=medium
PI_ADVISOR_PROVIDER=openai-codex
PI_ADVISOR_MODEL=gpt-5.5
PI_ADVISOR_THINKING=xhigh
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
