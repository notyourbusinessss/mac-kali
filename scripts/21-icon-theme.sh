#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

snapshot ORIG_ICON_THEME xsettings /Net/IconThemeName

SRC_DIR="$HOME/.cache/mac-kali/sources/WhiteSur-icon-theme"
clone_or_update "https://github.com/vinceliuice/WhiteSur-icon-theme.git" "$SRC_DIR"

log "Installing the WhiteSur icon theme..."
# shellcheck disable=SC2086
( cd "$SRC_DIR" && ./install.sh ${WHITESUR_ICON_OPTS:-} )

xfconf_set xsettings /Net/IconThemeName string "WhiteSur"
log_ok "Icon theme installed (WhiteSur)."
