#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

pkg_install rofi

THEME_DST_DIR="$HOME/.config/rofi"
mkdir -p "$THEME_DST_DIR"
cp "$SCRIPT_DIR/../config/rofi/mac-spotlight.rasi" "$THEME_DST_DIR/mac-spotlight.rasi"

snapshot ORIG_SUPER_SPACE_SHORTCUT xfce4-keyboard-shortcuts "/commands/custom/<Super>space"

# Bind Super+Space to the Spotlight-style launcher, like Cmd+Space on macOS.
xfconf_set xfce4-keyboard-shortcuts "/commands/custom/<Super>space" string \
  "rofi -show drun -theme $THEME_DST_DIR/mac-spotlight.rasi"

log_ok "Spotlight-style launcher installed. Press Super+Space to open it."
log "  If the shortcut doesn't fire, set it manually in Settings Manager > Keyboard > Application Shortcuts."
