#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

log "Installing build & runtime dependencies..."

CORE_PKGS=(
  git curl wget unzip
  sassc optipng inkscape
  libglib2.0-dev-bin
  plank rofi
  xdotool
  xfce4-whiskermenu-plugin
  xfce4-pulseaudio-plugin
  fonts-cantarell fonts-noto-color-emoji
)
pkg_install "${CORE_PKGS[@]}"

# Best-effort extras — nice to have, but not on every Kali/Debian release
# (GTK2 is being phased out, and the exact global-menu plugin package varies),
# so each is allowed to fail without blocking the rest of the install.
pkg_install gtk2-engines-murrine gtk2-engines-pixbuf || log_warn "GTK2 engines aren't available here — fine, mac-kali is GTK3-based; this only affects theming of old GTK2-only apps."
pkg_install xfce4-appmenu-plugin || log_warn "xfce4-appmenu-plugin isn't available on this system — the panel will skip the global app menu."

log_ok "Dependencies installed."
