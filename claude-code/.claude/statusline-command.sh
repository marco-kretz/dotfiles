#!/usr/bin/env bash
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
dir=$(basename "$cwd")

# Git branch detection (skip optional lock to avoid contention)
branch=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" -c core.useBuiltinFSMonitor=false symbolic-ref --short HEAD 2>/dev/null \
            || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

if [ -n "$branch" ]; then
  location=" $dir  $branch"
else
  location=" $dir"
fi

model=$(echo "$input" | jq -r '.model.display_name // ""')
effort=$(echo "$input" | jq -r '.reasoning_effort // .effort // ""')
if [ -n "$effort" ]; then
  model_display="󰧑 $model @ $effort"
else
  model_display="󰧑 $model"
fi

used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used" ]; then
  context=$(printf "󰾆 %.0f%%" "$used")
else
  context="󰾆 --"
fi

transcript=$(echo "$input" | jq -r '.transcript_path // ""')
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  start_epoch=$(stat -c %Y "$transcript" 2>/dev/null || stat -f %m "$transcript" 2>/dev/null)
  if [ -n "$start_epoch" ]; then
    now_epoch=$(date +%s)
    elapsed=$(( now_epoch - start_epoch ))
    elapsed_min=$(( elapsed / 60 ))
    elapsed_sec=$(( elapsed % 60 ))
    session_time=$(printf " %dm%02ds" "$elapsed_min" "$elapsed_sec")
  else
    session_time=" --"
  fi
else
  session_time=" --"
fi

printf "%s | %s | %s | %s" "$location" "$model_display" "$context" "$session_time"
