#!/usr/bin/env bash

detect_sourced() {
  if [[ -n "${BASH_VERSION:-}" ]]; then
    [[ "${BASH_SOURCE[0]:-}" != "${0:-}" ]] && return 0
    return 1
  fi

  if [[ -n "${ZSH_VERSION:-}" ]]; then
    case "${ZSH_EVAL_CONTEXT:-}" in
      *:file) return 0 ;;
    esac
  fi

  return 1
}

IS_SOURCED=0
if detect_sourced; then
  IS_SOURCED=1
fi

# Avoid changing the parent shell behavior when this file is sourced.
if [[ "$IS_SOURCED" -eq 0 ]]; then
  set -euo pipefail
fi

detect_script_path() {
  if [[ -n "${BASH_SOURCE:-}" ]]; then
    printf '%s\n' "${BASH_SOURCE[0]}"
    return
  fi

  if [[ -n "${ZSH_VERSION:-}" ]]; then
    printf '%s\n' "${(%):-%N}"
    return
  fi

  printf '%s\n' "$0"
}

SCRIPT_PATH="$(detect_script_path)"
ROOT_DIR="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"
MCP_SETTINGS_DIR="$ROOT_DIR/.gemini"
MCP_SETTINGS_FILE="$MCP_SETTINGS_DIR/settings.json"

if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'
  C_BOLD=$'\033[1m'
  C_CYAN=$'\033[36m'
  C_GREEN=$'\033[32m'
  C_YELLOW=$'\033[33m'
  C_RED=$'\033[31m'
  C_MAGENTA=$'\033[35m'
  C_BLUE=$'\033[34m'
else
  C_RESET=""
  C_BOLD=""
  C_CYAN=""
  C_GREEN=""
  C_YELLOW=""
  C_RED=""
  C_MAGENTA=""
  C_BLUE=""
fi

hex_to_rgb() {
  local hex="${1#\#}"
  printf '%d %d %d\n' "$((16#${hex:0:2}))" "$((16#${hex:2:2}))" "$((16#${hex:4:2}))"
}

rgb_to_ansi() {
  local r="$1"
  local g="$2"
  local b="$3"
  printf '\033[38;2;%s;%s;%sm' "$r" "$g" "$b"
}

gradient_text() {
  local text="$1"
  local len="${#text}"
  local idx
  local -a stops=( "#4796E3" "#9177C7" "#CA6673" )
  local -a rgb0 rgb1 rgb2
  local start_rgb end_rgb color
  local segment pos local_pos
  local r g b

  if [[ "$len" -eq 0 ]]; then
    return 0
  fi

  read -r -a rgb0 <<< "$(hex_to_rgb "${stops[0]}")"
  read -r -a rgb1 <<< "$(hex_to_rgb "${stops[1]}")"
  read -r -a rgb2 <<< "$(hex_to_rgb "${stops[2]}")"

  for ((idx = 0; idx < len; idx++)); do
    if (( len == 1 )); then
      r="${rgb0[0]}"
      g="${rgb0[1]}"
      b="${rgb0[2]}"
    elif (( idx <= (len - 1) / 2 )); then
      segment=$(( (len - 1) / 2 ))
      if (( segment == 0 )); then
        segment=1
      fi
      pos="$idx"
      local_pos=$(( pos * 1000 / segment ))
      r=$(( rgb0[0] + (rgb1[0] - rgb0[0]) * local_pos / 1000 ))
      g=$(( rgb0[1] + (rgb1[1] - rgb0[1]) * local_pos / 1000 ))
      b=$(( rgb0[2] + (rgb1[2] - rgb0[2]) * local_pos / 1000 ))
    else
      segment=$(( len - 1 - (len - 1) / 2 ))
      if (( segment == 0 )); then
        segment=1
      fi
      pos=$(( idx - (len - 1) / 2 ))
      local_pos=$(( pos * 1000 / segment ))
      r=$(( rgb1[0] + (rgb2[0] - rgb1[0]) * local_pos / 1000 ))
      g=$(( rgb1[1] + (rgb2[1] - rgb1[1]) * local_pos / 1000 ))
      b=$(( rgb1[2] + (rgb2[2] - rgb1[2]) * local_pos / 1000 ))
    fi

    color="$(rgb_to_ansi "$r" "$g" "$b")"
    printf '%s%s' "$color" "${text:idx:1}"
  done

  printf '%s\n' "$C_RESET"
}

say() { printf '%s\n' "$1"; }
info() { say "${C_CYAN}${1}${C_RESET}"; }
ok() { say "${C_GREEN}${1}${C_RESET}"; }
warn() { say "${C_YELLOW}${1}${C_RESET}"; }
error() { say "${C_RED}${1}${C_RESET}"; }
title() { say "${C_BOLD}${C_MAGENTA}${1}${C_RESET}"; }
gemini_note() { say "${C_BOLD}${C_BLUE}${1}${C_RESET}"; }

# Functions return to caller when sourced, but terminate process when executed.
finish() {
  local code="${1:-0}"
  if [[ "$IS_SOURCED" -eq 1 ]]; then
    return "$code"
  fi
  exit "$code"
}

has_gemini_cli() { command -v gemini >/dev/null 2>&1; }

gemini_status_label() {
  if has_gemini_cli; then
    printf '%s\n' "${C_GREEN}[available]${C_RESET}"
  else
    printf '%s\n' "${C_RED}[not installed]${C_RESET}"
  fi
}

terminal_width() {
  local cols
  cols=80
  if command -v tput >/dev/null 2>&1; then
    cols="$(tput cols 2>/dev/null || printf '80')"
  fi
  if [[ -z "$cols" || "$cols" -lt 40 ]]; then
    cols=80
  fi
  printf '%s\n' "$cols"
}

print_centered() {
  local text="$1"
  local color="${2:-}"
  local cols pad
  cols="$(terminal_width)"
  pad=$(( (cols - ${#text}) / 2 ))
  if (( pad < 0 )); then
    pad=0
  fi
  printf '%*s%s%s%s\n' "$pad" "" "$color" "$text" "$C_RESET"
}

print_centered_block() {
  local color="$1"
  shift
  local cols max_len pad line
  cols="$(terminal_width)"
  max_len=0

  for line in "$@"; do
    if (( ${#line} > max_len )); then
      max_len=${#line}
    fi
  done

  pad=$(( (cols - max_len) / 2 ))
  if (( pad < 0 )); then
    pad=0
  fi

  for line in "$@"; do
    printf '%*s%s%s%s\n' "$pad" "" "$color" "$line" "$C_RESET"
  done
}

print_hash_rule() {
  local cols
  cols="$(terminal_width)"
  print_centered "$(printf '%*s' "$cols" '' | tr ' ' '#')" "$C_CYAN"
}

show_datadoe_banner() {
  print_hash_rule
  print_centered_block "$C_CYAN" \
    "____    _  _____   _    ____   ___  _____   __  __  ____  ____" \
    "|  _ \\  / \\|_   _| / \\  |  _ \\ / _ \\| ____| |  \\/  |/ ___||  _ \\" \
    "| | | |/ _ \\ | |  / _ \\ | | | | | | |  _|   | |\\/| | |    | |_) |" \
    "| |_| / ___ \\| | / ___ \\| |_| | |_| | |___  | |  | | |___ |  __/" \
    "|____/_/   \\_\\_|/_/   \\_\\____/ \\___/|_____| |_|  |_|\\____||_|"
  print_hash_rule
}

show_intro() {
  show_datadoe_banner
  info "Loading project secrets from .env..."
  print_centered "$(gradient_text "Google Gemini CLI is ready to launch.")"
  ok "DataDoe MCP key loaded into this shell session."
}

print_cli_missing_hint() {
  warn "Gemini CLI is not installed or not available on PATH."
  say "Install it and then retry:"
  say "  npm install -g @google/gemini-cli"
}

usage() {
  show_datadoe_banner
  say ""
  title "DataDoe + Gemini Launcher Manual"
  say "----------------------------------------"
  info "Usage:"
  say "  ./scripts/start-gemini.sh"
  say "  ./scripts/start-gemini.sh --cli"
  say "  ./scripts/start-gemini.sh --check"
  say ""
  info "Options:"
  say "  --cli      Start Gemini CLI after loading .env"
  say "  --check    Validate .env loading, mcp-remote config, and Gemini CLI availability"
  say "  -h, --help Show this help message"
}

load_env() {
  if [[ ! -f "$ENV_FILE" ]]; then
    error "Missing .env at $ENV_FILE"
    warn "Create it from .env.example and set DATADOE_MCP_KEY."
    return 1
  fi

  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a

  if [[ -z "${DATADOE_MCP_KEY:-}" ]]; then
    error "DATADOE_MCP_KEY is empty after loading .env."
    return 1
  fi
}

configure_mcp_remote_settings() {
  mkdir -p "$MCP_SETTINGS_DIR"
  info "Syncing .gemini/settings.json to mcp-remote workaround config..."

  cat > "$MCP_SETTINGS_FILE" <<'EOF'
{
  "mcpServers": {
    "datadoe": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-remote@latest",
        "https://api.datadoe.com/mcp/v1",
        "--transport",
        "http-only",
        "--header",
        "datadoe-mcp-key:${DATADOE_MCP_KEY}"
      ],
      "env": {
        "DATADOE_MCP_KEY": "$DATADOE_MCP_KEY"
      }
    }
  }
}
EOF

  ok "mcp-remote configuration synced."
}

start_gemini_cli() {
  if ! has_gemini_cli; then
    error "Cannot launch Gemini CLI."
    print_cli_missing_hint
    return 1
  fi

  gemini_note "Launching Gemini CLI..."
  cd "$ROOT_DIR"
  exec gemini
}

handle_menu_choice() {
  local choice="$1"

  case "$choice" in
    1)
      if has_gemini_cli; then
        start_gemini_cli
      else
        error "You selected Gemini CLI, but it is unavailable."
        print_cli_missing_hint
      fi
      ;;
    2)
      warn "Launch aborted. No worries, your key remains safe."
      return 0
      ;;
    *)
      error "Unknown option '$choice'. Please run again and pick 1 or 2."
      ;;
  esac

  return 1
}

choose_mode() {
  local choice

  while true; do
    say ""
    gemini_note "Choose launch mode:"
    say "  ${C_BOLD}1${C_RESET}) Gemini CLI $(gemini_status_label)"
    say "  ${C_BOLD}2${C_RESET}) Exit"
    printf "${C_CYAN}Enter option [1-2]: ${C_RESET}"

    if ! read -r choice; then
      warn "No input received. Exiting launcher."
      return 0
    fi

    if handle_menu_choice "$choice"; then
      return 0
    fi
  done
}

main() {
  case "${1:-}" in
    -h|--help)
      usage
      if [[ "$IS_SOURCED" -eq 1 ]]; then
        warn "Tip: run this launcher as './scripts/start-gemini.sh' (without source)."
      fi
      return 0
      ;;
  esac

  if ! load_env; then
    return 1
  fi

  configure_mcp_remote_settings

  show_intro

  case "${1:-}" in
    --cli) start_gemini_cli ;;
    --check)
      if ! has_gemini_cli; then
        error "Check failed: Gemini CLI is unavailable."
        print_cli_missing_hint
        return 1
      fi
      gemini_note "Check complete: DATADOE_MCP_KEY is loaded, mcp-remote config is synced, and Gemini CLI is available."
      return 0
      ;;
    "") choose_mode ;;
    *)
      error "Unknown option: ${1:-}"
      usage
      return 1
      ;;
  esac
}

main "$@"
finish $?
