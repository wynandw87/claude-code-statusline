#!/usr/bin/env bash
# Claude Code status line script
# Uses node instead of jq for JSON parsing (Windows compatibility)

input=$(cat)

# --- Extract fields using node ---
eval "$(echo "$input" | node -e "
const chunks = [];
process.stdin.on('data', c => chunks.push(c));
process.stdin.on('end', () => {
  try {
    const d = JSON.parse(chunks.join(''));
    const pct = d.context_window?.used_percentage ?? '';
    const cwd = d.workspace?.current_dir ?? d.cwd ?? '';
    const cost = d.cost?.total_cost_usd ?? '';

    const input_tok = d.context_window?.total_input_tokens ?? '';
    const output_tok = d.context_window?.total_output_tokens ?? '';

    console.log('used_pct=\"' + pct + '\"');
    console.log('cwd=\"' + (cwd || '').replace(/\"/g, '') + '\"');
    console.log('cost=\"' + cost + '\"');
    console.log('input_tok=\"' + input_tok + '\"');
    console.log('output_tok=\"' + output_tok + '\"');
  } catch(e) {
    console.log('used_pct=\"\"');
    console.log('cwd=\"\"');
    console.log('cost=\"\"');
    console.log('input_tok=\"\"');
    console.log('output_tok=\"\"');
  }
});
")"

# --- ANSI colors ---
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
DIM='\033[2m'
RESET='\033[0m'
BOLD='\033[1m'

# --- Context block ---
ctx_block=""
if [ -n "$used_pct" ]; then
  pct_int=${used_pct%.*}
  pct_int=${pct_int:-0}

  if [ "$pct_int" -ge 90 ]; then
    bar_color="$RED"
  elif [ "$pct_int" -ge 70 ]; then
    bar_color="$YELLOW"
  else
    bar_color="$GREEN"
  fi

  filled=$(( pct_int * 10 / 100 ))
  empty=$(( 10 - filled ))
  bar=""
  for (( i=0; i<filled; i++ )); do bar="${bar}█"; done
  for (( i=0; i<empty; i++ )); do bar="${bar}░"; done

  ctx_block="${bar_color}${bar} ${pct_int}%${RESET}"
else
  ctx_block="${DIM}ctx:n/a${RESET}"
fi

# --- Cost block ---
if [ -n "$cost" ]; then
  cost_fmt=$(printf '$%.2f' "$cost")
  cost_block="${CYAN}${cost_fmt}${RESET}"
else
  cost_block="${DIM}$-.--${RESET}"
fi

# --- Directory block ---
if [ -n "$cwd" ]; then
  dir="${cwd##*/}"
  dir="${dir##*\\}"
  [ -z "$dir" ] && dir="$cwd"
  dir_block="${BOLD}${BLUE}${dir}${RESET}"
else
  dir_block="${DIM}~${RESET}"
fi

# --- Tokens block ---
format_tokens() {
  local n="$1"
  if [ -z "$n" ] || [ "$n" = "0" ]; then
    echo "0"
  elif [ "$n" -ge 1000000 ]; then
    echo "$(( n / 1000000 )).$(( (n % 1000000) / 100000 ))M"
  elif [ "$n" -ge 1000 ]; then
    echo "$(( n / 1000 )).$(( (n % 1000) / 100 ))k"
  else
    echo "$n"
  fi
}

if [ -n "$input_tok" ] || [ -n "$output_tok" ]; then
  in_fmt=$(format_tokens "${input_tok:-0}")
  out_fmt=$(format_tokens "${output_tok:-0}")
  tok_block="${DIM}in:${RESET}${CYAN}${in_fmt}${RESET} ${DIM}out:${RESET}${CYAN}${out_fmt}${RESET}"
else
  tok_block="${DIM}tok:n/a${RESET}"
fi

# --- Assemble ---
sep="${DIM} | ${RESET}"
echo -e "${dir_block}${sep}${ctx_block}${sep}${cost_block}${sep}${tok_block}"
