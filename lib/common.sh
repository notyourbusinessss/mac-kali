#!/usr/bin/env bash
# Shared helpers sourced by every install script in mac-kali.
set -euo pipefail

if [[ -t 1 ]]; then
  C_RESET=$'\e[0m'; C_BLUE=$'\e[34m'; C_GREEN=$'\e[32m'; C_YELLOW=$'\e[33m'; C_RED=$'\e[31m'
else
  C_RESET=""; C_BLUE=""; C_GREEN=""; C_YELLOW=""; C_RED=""
fi

log()      { printf '%s\n' "${C_BLUE}==>${C_RESET} $*"; }
log_ok()   { printf '%s\n' "${C_GREEN}==>${C_RESET} $*"; }
log_warn() { printf '%s\n' "${C_YELLOW}==> warning:${C_RESET} $*" >&2; }
log_err()  { printf '%s\n' "${C_RED}==> error:${C_RESET} $*" >&2; }
die()      { log_err "$*"; exit 1; }

MAC_KALI_YES="${MAC_KALI_YES:-0}"
confirm() {
  [[ "$MAC_KALI_YES" == "1" ]] && return 0
  local reply
  read -r -p "${1:-Continue?} [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

require_apt() {
  command -v apt-get >/dev/null 2>&1 || die "This installer targets Debian/Kali (apt-get not found)."
}

APT_UPDATED=0
pkg_install() {
  require_apt
  local missing=()
  for p in "$@"; do
    dpkg -s "$p" >/dev/null 2>&1 || missing+=("$p")
  done
  [[ ${#missing[@]} -eq 0 ]] && return 0
  if [[ "$APT_UPDATED" -eq 0 ]]; then
    log "Updating apt package lists..."
    # A nonzero exit here is often just a broken post-update hook (e.g.
    # command-not-found's db rebuilder erroring on some Kali installs) —
    # the package lists themselves usually still updated fine. Don't treat
    # that as fatal; let the actual `apt-get install` below fail loudly if
    # the lists really are unusable.
    sudo apt-get update -qq || log_warn "apt-get update reported an error (often a harmless post-update hook) — continuing with whatever package lists are available."
    APT_UPDATED=1
  fi
  log "Installing: ${missing[*]}"
  if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${missing[@]}"; then
    return 0
  fi

  # One renamed/unavailable package name shouldn't block everything else in
  # the batch — Debian/Kali package names do drift over time. Retry one at a
  # time so the good ones still get installed.
  log_warn "Batch install failed (likely one unavailable/renamed package in the list) — retrying individually so that doesn't block the rest."
  local p failed=()
  for p in "${missing[@]}"; do
    dpkg -s "$p" >/dev/null 2>&1 && continue
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$p" || failed+=("$p")
  done
  if [[ ${#failed[@]} -gt 0 ]]; then
    log_warn "Couldn't install: ${failed[*]} — skipping. mac-kali will still work, just without whatever those provide."
  fi
}

clone_or_update() {
  local url="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ -d "$dest/.git" ]]; then
    log "Updating $(basename "$dest")..."
    git -C "$dest" pull --ff-only --quiet
  else
    log "Cloning $(basename "$dest")..."
    git clone --depth=1 --quiet "$url" "$dest"
  fi
}

# xfconf_set CHANNEL PROPERTY TYPE VALUE
xfconf_set() {
  xfconf-query -c "$1" -p "$2" -n -t "$3" -s "$4" >/dev/null 2>&1 || \
  xfconf-query -c "$1" -p "$2" -t "$3" -s "$4"
}

MAC_KALI_STATE_DIR="$HOME/.local/share/mac-kali"
MAC_KALI_STATE_FILE="$MAC_KALI_STATE_DIR/original-settings.env"

# snapshot VAR_NAME CHANNEL PROPERTY — remember the pre-mac-kali value once,
# so uninstall.sh can restore exactly what was there before.
snapshot() {
  local var="$1" channel="$2" prop="$3"
  mkdir -p "$MAC_KALI_STATE_DIR"
  touch "$MAC_KALI_STATE_FILE"
  grep -q "^${var}=" "$MAC_KALI_STATE_FILE" 2>/dev/null && return 0
  local val
  val="$(xfconf-query -c "$channel" -p "$prop" 2>/dev/null || true)"
  printf '%s=%q\n' "$var" "$val" >> "$MAC_KALI_STATE_FILE"
}

restart_panel()   { command -v xfce4-panel >/dev/null 2>&1 && xfce4-panel -r >/dev/null 2>&1; return 0; }
restart_desktop() { command -v xfdesktop >/dev/null 2>&1 && xfdesktop --reload >/dev/null 2>&1; return 0; }
restart_wm()      { command -v xfwm4 >/dev/null 2>&1 && { xfwm4 --replace >/dev/null 2>&1 & disown; }; return 0; }
restart_plank()   { pkill -u "$USER" plank >/dev/null 2>&1; sleep 0.5; { nohup plank >/dev/null 2>&1 & disown; }; return 0; }
