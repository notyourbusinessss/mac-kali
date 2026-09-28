#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

log "Installing build & runtime dependencies..."

CORE_PKGS=(
  git curl wget unzip
  sassc optipng inkscape
  libglib2.0-dev-bin libgdk-pixbuf2.0-dev
  gtk2-engines-murrine gtk2-engines-pixbuf
  plank rofi
  xdotool
  xfce4-whiskermenu-plugin
  xfce4-pulseaudio-plugin
  fonts-cantarell fonts-noto-color-emoji
)
pkg_install "${CORE_PKGS[@]}"

# A real macOS-style global menu bar needs this plugin. It isn't packaged for
# every release, so it's optional — the panel still looks the part without it.
pkg_install xfce4-appmenu-plugin || log_warn "xfce4-appmenu-plugin isn't available on this system — the panel will skip the global app menu."

log_ok "Dependencies installed."
