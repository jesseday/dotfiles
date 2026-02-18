#!/bin/bash

# Line 1: Model, tokens, context bar, thinking (universal)
# Line 2: Token breakdown + cache hit rate (enterprise cost awareness)

# Color definitions (matching PowerShell version)
BLUE='\033[38;2;0;153;255m'
ORANGE='\033[38;2;255;176;85m'
GREEN='\033[38;2;0;160;0m'
CYAN='\033[38;2;46;149;153m'
RED='\033[38;2;255;85;85m'
YELLOW='\033[38;2;230;200;0m'
PURPLE='\033[38;2;180;120;255m'
DIM='\033[2m'
RESET='\033[0m'

# Read JSON from stdin
input=$(cat)

# Extract model and context info
model=$(echo "$input" | /usr/bin/jq -r '.model.display_name // "Unknown"')
context_size=$(echo "$input" | /usr/bin/jq -r '.context_window.context_window_size // 0')
used_pct=$(echo "$input" | /usr/bin/jq -r '.context_window.used_percentage // 0')

# Calculate current token usage
input_tokens=$(echo "$input" | /usr/bin/jq -r '.context_window.current_usage.input_tokens // 0')
output_tokens=$(echo "$input" | /usr/bin/jq -r '.context_window.current_usage.output_tokens // 0')
cache_creation=$(echo "$input" | /usr/bin/jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
cache_read=$(echo "$input" | /usr/bin/jq -r '.context_window.current_usage.cache_read_input_tokens // 0')

current_tokens=$((input_tokens + output_tokens + cache_creation + cache_read))

# Format token counts with k/m suffixes
format_tokens() {
  local tokens=$1
  # Convert to integer if it has decimals
  tokens=${tokens%.*}

  if [ $tokens -ge 1000000 ]; then
    local result=$(echo "scale=1; $tokens / 1000000" | bc)
    printf "%.1fm" $result
  elif [ $tokens -ge 1000 ]; then
    local result=$(echo "scale=0; $tokens / 1000" | bc)
    printf "%.0fk" $result
  else
    printf "%d" $tokens
  fi
}

current_display=$(format_tokens $current_tokens)
total_display=$(format_tokens $context_size)

# Build context usage bar
build_context_bar() {
  local percent=$1
  local width=10

  # Convert to integer
  local pct_int=${percent%.*}

  # Calculate filled and empty dots
  local filled=$(echo "scale=0; $pct_int * $width / 100" | bc)
  local empty=$((width - filled))

  # Choose color based on percentage (Green: 0-39, Yellow: 40-74, Red: 75+)
  local bar_color="${GREEN}"
  if [ $(echo "$pct_int >= 75" | bc) -eq 1 ]; then
    bar_color="${RED}"
  elif [ $(echo "$pct_int >= 40" | bc) -eq 1 ]; then
    bar_color="${YELLOW}"
  fi

  # Build bar string
  local bar=""
  for ((i=0; i<filled; i++)); do bar="${bar}●"; done
  for ((i=0; i<empty; i++)); do bar="${bar}○"; done

  # Return colored "22% ●●○○○○○○○○" format
  printf "${bar_color}%.0f%% %s${RESET}" "$percent" "$bar"
}

context_bar=$(build_context_bar $used_pct)

# Check thinking mode from settings
thinking_status="${DIM}Off${RESET}"
if [ -f "$HOME/.claude/settings.json" ]; then
  thinking_enabled=$(cat "$HOME/.claude/settings.json" | /usr/bin/jq -r '.alwaysThinkingEnabled // false')
  if [ "$thinking_enabled" = "true" ]; then
    thinking_status="${ORANGE}On${RESET}"
  fi
fi

# Line 1: Model | Tokens | Context Bar | Thinking
printf "${BLUE}%s${RESET} ${DIM}|${RESET} ${ORANGE}%s${RESET} ${DIM}/${RESET} ${ORANGE}%s${RESET} ${DIM}|${RESET} %b ${DIM}|${RESET} thinking: %b\n" \
  "$model" "$current_display" "$total_display" "$context_bar" "$thinking_status"

# Line 2: Token breakdown by cost category (enterprise)
# Enterprise plans pay per-token, so breaking out categories is actionable:
#   input tokens, output tokens, cache creation (write), cache read (hit)
PURPLE='\033[38;2;180;120;255m'

input_display=$(format_tokens $input_tokens)
output_display=$(format_tokens $output_tokens)
cache_write_display=$(format_tokens $cache_creation)
cache_read_display=$(format_tokens $cache_read)

# Calculate cache hit rate (reads vs total cache activity)
# Higher is better — cache reads are ~10x cheaper than cache creation
cache_total=$((cache_creation + cache_read))
if [ $cache_total -gt 0 ]; then
  cache_hit_pct=$(echo "scale=0; $cache_read * 100 / $cache_total" | bc)
  # Color the hit rate: green >=70%, yellow >=40%, red <40%
  cache_color="${RED}"
  if [ $cache_hit_pct -ge 70 ]; then
    cache_color="${GREEN}"
  elif [ $cache_hit_pct -ge 40 ]; then
    cache_color="${YELLOW}"
  fi
  cache_hit_str="${cache_color}${cache_hit_pct}%${RESET}"
else
  cache_hit_str="${DIM}--${RESET}"
fi

printf "${DIM}in:${RESET}${CYAN}%s${RESET} ${DIM}out:${RESET}${ORANGE}%s${RESET} ${DIM}|${RESET} ${DIM}cache w:${RESET}${PURPLE}%s${RESET} ${DIM}r:${RESET}${GREEN}%s${RESET} ${DIM}hit:${RESET}%b\n" \
  "$input_display" "$output_display" "$cache_write_display" "$cache_read_display" "$cache_hit_str"
