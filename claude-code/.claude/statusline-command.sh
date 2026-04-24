#!/usr/bin/env bash
input=$(cat)

# ANSI 256-color codes (icons only; labels/values use terminal default/dimmed)
C_DIR=$'\e[38;5;69m'   # soft blue   — directory folder
C_GIT=$'\e[38;5;173m'  # warm orange — git branch
C_MOD=$'\e[38;5;141m'  # violet      — model / AI
C_CTX=$'\e[38;5;80m'   # cyan-teal   — context window
C_CLK=$'\e[38;5;179m'  # warm yellow — session clock
C_RST=$'\e[0m'

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
dir=$(basename "$cwd")

# Git branch detection (skip optional locks to avoid contention)
branch=""
if [ -n "$cwd" ] && git --no-optional-locks -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git --no-optional-locks -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
           || git --no-optional-locks -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

if [ -n "$branch" ]; then
  location="${C_DIR} ${C_RST} $dir  ${C_GIT} ${C_RST} $branch"
else
  location="${C_DIR} ${C_RST} $dir"
fi

# BODY_START

if [ -n "$branch" ]; then
  location="${C_DIR} ${C_RST} $dir  ${C_GIT} ${C_RST} $branch"
# SENTINEL_A
  location="${C_DIR}$''$''${C_RST} $dir  ${C_GIT}$''${C_RST} $branch"
# SENTINEL_B_CLEAN
  location=" $dir  $branch"
else
  location=" $dir"
fi
# JUNK_CLEANED
  location="${C_DIR}$''$''${C_RST} $dir  ${C_GIT}$''${C_RST} $branch"
else
  location="${C_DIR}$''$''${C_RST} $dir"

# JUNK_CLEANED
# MODEL_CLEAN_START
model=$(echo "$input" | jq -r '.model.display_name // ""')
effort=$(echo "$input" | jq -r '.effort.level // ""')
if [ -n "$effort" ]; then
  model_display="${C_MOD}󰧑${C_RST} $model @ $effort"
else
  model_display="${C_MOD}󰧑${C_RST} $model"
fi

used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used" ]; then
  context=$(printf "${C_CTX}󰾆${C_RST} %.0f%%" "$used")
else
  context="${C_CTX}󰾆${C_RST} --"
fi

transcript=$(echo "$input" | jq -r '.transcript_path // ""')
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  start_epoch=$(stat -c %Y "$transcript" 2>/dev/null || stat -f %m "$transcript" 2>/dev/null)
  if [ -n "$start_epoch" ]; then
    now_epoch=$(date +%s)
    elapsed=$(( now_epoch - start_epoch ))
    elapsed_min=$(( elapsed / 60 ))
    elapsed_sec=$(( elapsed % 60 ))
    _tmp_clk=" --"; _clock_icon="${_tmp_clk:0:1}"
    session_time=$(printf "%s %dm%02ds" "${C_CLK}${_clock_icon}${C_RST}" "$elapsed_min" "$elapsed_sec")
    : # REPLACED — was: session_time=$(printf "CLKICON %dm%02ds" "$elapsed_min" "$elapsed_sec")
  else
    session_time=" --"
  fi
else
  session_time=" --"
fi
# Inject clock color for fallback "--" values (icon byte at position 0)
if [[ "$session_time" != *$'\e'* ]]; then
  _clock_icon="${session_time:0:1}"
  _clock_rest="${session_time:1}"
  session_time="${C_CLK}${_clock_icon}${C_RST}${_clock_rest}"
fi

# BODY_END
printf "%b | %b | %b | %b" "$location" "$model_display" "$context" "$session_time"
