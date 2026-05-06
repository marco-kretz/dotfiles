#!/usr/bin/env bash
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
dir=$(basename "$cwd")

# Git branch detection (skip optional locks to avoid contention)
branch=""
if [ -n "$cwd" ] && git --no-optional-locks -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git --no-optional-locks -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
           || git --no-optional-locks -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

format_tokens() {
  local tokens="$1"
  if [ -z "$tokens" ] || ! [[ "$tokens" =~ ^[0-9]+$ ]]; then
    printf -- "--"
    return
  fi

  awk -v tokens="$tokens" 'BEGIN {
    if (tokens >= 1000) {
      printf "%.1fk", tokens / 1000
    } else {
      printf "%d", tokens
    }
  }'
}

used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
token_count=$(echo "$input" | jq -r '.context_window.current_token_count // .context_window.used_tokens // .context_window.token_count // empty')
transcript=$(echo "$input" | jq -r '.transcript_path // ""')

if [ -z "$token_count" ] && [ -n "$transcript" ] && [ -f "$transcript" ]; then
  token_count=$(tail -n 200 "$transcript" \
    | jq -r 'select(.message.usage? != null) | .message.usage | ((.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0))' 2>/dev/null \
    | tail -n 1)
fi

token_display=$(format_tokens "$token_count")
if [ -n "$used" ]; then
  context_usage=$(printf "%s (%.0f%%)" "$token_display" "$used")
else
  context_usage="${token_display} (--)"
fi

location="${dir:-"--"}"
if [ -n "$branch" ]; then
  branch_display="$branch"
else
  branch_display=""
fi

model=$(echo "$input" | jq -r '.model.display_name // ""')
effort=$(echo "$input" | jq -r '.effort.level // ""')
if [ -n "$effort" ]; then
  model_display="${model:-"--"} @ $effort"
else
  model_display="${model:-"--"}"
fi

if [ -n "$branch_display" ]; then
  printf "%s | %s | %s | %s" "$location" "$branch_display" "$model_display" "$context_usage"
else
  printf "%s | %s | %s" "$location" "$model_display" "$context_usage"
fi
