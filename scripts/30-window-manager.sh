#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

snapshot ORIG_WM_THEME xfwm4 /general/theme
snapshot ORIG_BUTTON_LAYOUT xfwm4 /general/button_layout
snapshot ORIG_COMPOSITING xfwm4 /general/use_compositing

log "Setting window theme, traffic-light button order, and compositing..."

xfconf_set xfwm4 /general/theme string "WhiteSur-Dark"

# xfwm4 button_layout: letters left of '|' are left-aligned, right of it are
# right-aligned. C=close H=hide(minimize) M=maximize — macOS keeps all three
# grouped on the left with nothing on the right.
xfconf_set xfwm4 /general/button_layout string "CHM|"

xfconf_set xfwm4 /general/use_compositing bool true
xfconf_set xfwm4 /general/show_frame_shadow bool true
xfconf_set xfwm4 /general/show_popup_shadow bool true
xfconf_set xfwm4 /general/frame_opacity int 100
xfconf_set xfwm4 /general/inactive_opacity int 100
xfconf_set xfwm4 /general/wireframe_move bool false
xfconf_set xfwm4 /general/box_move bool false
xfconf_set xfwm4 /general/snap_to_border bool true
xfconf_set xfwm4 /general/snap_to_windows bool true
xfconf_set xfwm4 /general/scroll_workspaces bool false

restart_wm
log_ok "Window manager configured."
