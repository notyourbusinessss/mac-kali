#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

snapshot ORIG_CURSOR_THEME xsettings /Gtk/CursorThemeName

SRC_DIR="$HOME/.cache/mac-kali/sources/WhiteSur-cursors"
clone_or_update "https://github.com/vinceliuice/WhiteSur-cursors.git" "$SRC_DIR"

log "Installing the WhiteSur cursor theme..."
# shellcheck disable=SC2086
( cd "$SRC_DIR" && ./install.sh ${WHITESUR_CURSOR_OPTS:-} )

xfconf_set xsettings /Gtk/CursorThemeName string "WhiteSur-cursors"
log_ok "Cursor theme installed."
