#!/usr/bin/env bash
#
# link-agent-skills.sh
#
# Symlinks skills from ~/.agents/skills/ into ~/.claude/skills/ so that
# Claude Code picks them up. Idempotent — safe to run repeatedly.
#
# Usage: ./link-agent-skills.sh [--dry-run] [--prune]
#   --dry-run   Show what would happen without making changes
#   --prune     Remove dead symlinks in ~/.claude/skills/ that point to
#               non-existent ~/.agents/skills/ targets

set -euo pipefail

SRC="${HOME}/.agents/skills"
DST="${HOME}/.claude/skills"

DRY_RUN=0
PRUNE=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --prune)   PRUNE=1 ;;
    -h|--help)
      sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

run() {
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "DRY: $*"
  else
    "$@"
  fi
}

# Source check
if [[ ! -d "$SRC" ]]; then
  echo "No directory at $SRC — nothing to do." >&2
  exit 0
fi

# Ensure destination exists
if [[ ! -d "$DST" ]]; then
  run mkdir -p "$DST"
fi

linked=0
skipped=0
pruned=0

# Link skills
shopt -s nullglob
for skill_path in "$SRC"/*/; do
  name="$(basename "$skill_path")"
  target="$DST/$name"

  # Only link directories that actually contain a SKILL.md
  if [[ ! -f "$skill_path/SKILL.md" ]]; then
    echo "⚠ $name: no SKILL.md — skipped"
    (( ++skipped ))
    continue
  fi

  if [[ -L "$target" ]]; then
    # Existing symlink — already pointing to the right place?
    current="$(readlink "$target")"
    if [[ "$current" == "${skill_path%/}" ]]; then
      (( ++skipped ))
      continue
    fi
    echo "↻ $name: symlink points to $current, re-linking"
    run rm "$target"
  elif [[ -e "$target" ]]; then
    echo "✗ $name: real file/directory exists at $target — skipped"
    (( ++skipped ))
    continue
  fi

  run ln -s "${skill_path%/}" "$target"
  echo "✓ $name linked"
  (( ++linked ))
done

# Prune dead symlinks
if [[ $PRUNE -eq 1 ]]; then
  for link in "$DST"/*; do
    [[ -L "$link" ]] || continue
    if [[ ! -e "$link" ]]; then
      echo "✗ $(basename "$link"): dead symlink removed"
      run rm "$link"
      (( ++pruned ))
    fi
  done
fi

echo ""
echo "Done: $linked linked, $skipped unchanged/skipped, $pruned pruned"
[[ $DRY_RUN -eq 1 ]] && echo "(Dry run — no actual changes made)"
