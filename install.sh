#!/usr/bin/env bash
# mac-kali — turn a stock Kali Linux XFCE desktop into something that looks
# and behaves like macOS: GTK theme, icons, cursors, a top menu bar, a
# Plank dock, a Spotlight-style launcher, and a matching wallpaper.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Options:
  -y, --yes          Don't prompt for confirmation
      --only=LIST     Comma-separated step names to run
      --skip=LIST     Comma-separated step names to skip
  -h, --help          Show this help

Steps (in order):
  preflight dependencies gtk-theme icon-theme cursor-theme fonts
  window-manager panel dock launcher wallpaper finish

Examples:
  ./install.sh                     # run everything
  ./install.sh --only=dock,panel   # just redo the dock and panel
  ./install.sh --skip=wallpaper    # do everything except the wallpaper
EOF
}

ONLY=""
SKIP=""
for arg in "$@"; do
  case "$arg" in
    -y|--yes) MAC_KALI_YES=1 ;;
    --only=*) ONLY="${arg#*=}" ;;
    --skip=*) SKIP="${arg#*=}" ;;
    -h|--help) usage; exit 0 ;;
    *) die "Unknown option: $arg (see --help)" ;;
  esac
done
export MAC_KALI_YES

[[ $EUID -eq 0 ]] && die "Run this as your normal desktop user, not root — it calls sudo itself when it needs to."

STEPS=(
  "00-preflight.sh:preflight"
  "10-dependencies.sh:dependencies"
  "20-gtk-theme.sh:gtk-theme"
  "21-icon-theme.sh:icon-theme"
  "22-cursor-theme.sh:cursor-theme"
  "23-fonts.sh:fonts"
  "30-window-manager.sh:window-manager"
  "40-panel.sh:panel"
  "50-dock.sh:dock"
  "60-launcher.sh:launcher"
  "70-wallpaper.sh:wallpaper"
  "80-finish.sh:finish"
)

should_run() {
  local name="$1"
  if [[ -n "$ONLY" ]]; then
    [[ ",$ONLY," == *",$name,"* ]] || return 1
  fi
  if [[ -n "$SKIP" ]]; then
    [[ ",$SKIP," == *",$name,"* ]] && return 1
  fi
  return 0
}

log "mac-kali — macOS-style theming for Kali's XFCE desktop"
for entry in "${STEPS[@]}"; do
  file="${entry%%:*}"; name="${entry##*:}"
  should_run "$name" || continue
  log "── ${name} ──────────────────────────────"
  bash "$SCRIPT_DIR/scripts/$file"
done

log_ok "Done. Log out and back in for everything to settle cleanly."
