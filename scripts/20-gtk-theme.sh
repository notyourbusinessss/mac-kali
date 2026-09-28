#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

snapshot ORIG_GTK_THEME xsettings /Net/ThemeName

SRC_DIR="$HOME/.cache/mac-kali/sources/WhiteSur-gtk-theme"
clone_or_update "https://github.com/vinceliuice/WhiteSur-gtk-theme.git" "$SRC_DIR"

log "Building & installing the WhiteSur GTK theme (this takes a minute)..."
# shellcheck disable=SC2086
( cd "$SRC_DIR" && ./install.sh ${WHITESUR_GTK_OPTS:-} )

xfconf_set xsettings /Net/ThemeName string "WhiteSur-Dark"

log_ok "GTK theme installed (WhiteSur-Dark)."
log "  Prefer light mode? Set WHITESUR_GTK_OPTS='-c light' and re-run this script,"
log "  then change /Net/ThemeName to WhiteSur-Light in the Appearance settings."
