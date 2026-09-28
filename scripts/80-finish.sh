#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

snapshot ORIG_DECORATION_LAYOUT xsettings /Gtk/DecorationLayout

# Client-side-decorated GTK3 apps read this for their own titlebar button order.
xfconf_set xsettings /Gtk/DecorationLayout string "close,minimize,maximize:menu"

restart_panel
restart_desktop
restart_plank
restart_wm

log_ok "mac-kali setup finished."
cat <<'EOF'

Next steps:
  * Log out and back in so every change settles cleanly.
  * Fine-tune the panel:      right-click it -> Panel -> Panel Preferences
  * Fine-tune the dock:       right-click it -> Preferences
  * Change accent/wallpaper:  Settings Manager -> Appearance / Desktop
  * Want to undo any of this? See uninstall.sh
EOF
