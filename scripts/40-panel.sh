#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# The panel plugin layout can't be neatly "snapshotted" like a single
# property, so instead we back up the whole panel config directory and tell
# the user how to restore it by hand (uninstall.sh also looks for this).
BACKUP_DIR="$HOME/.config/xfce4/panel.mac-kali.bak-$(date +%s)"
if [[ -d "$HOME/.config/xfce4/panel" ]]; then
  log "Backing up current panel config to $BACKUP_DIR"
  cp -a "$HOME/.config/xfce4/panel" "$BACKUP_DIR"
fi

log "Resetting the panel and building a single macOS-style top menu bar..."
xfce4-panel --quit >/dev/null 2>&1 || true
sleep 1
xfconf-query -c xfce4-panel -p / -R -r >/dev/null 2>&1 || true
sleep 1

# A single thin panel spanning the top of the screen.
xfconf-query -c xfce4-panel -p /panels -n -a -t int -s 1 >/dev/null 2>&1 || \
  xfconf-query -c xfce4-panel -p /panels -n -t int -s 1 -a >/dev/null 2>&1 || \
  log_warn "Could not create the /panels array — you may need to add one panel manually first (right-click desktop > Panel > Add New Panel), then re-run this script."

xfconf_set xfce4-panel /panels/panel-1/position string "p=6;x=0;y=0"
xfconf_set xfce4-panel /panels/panel-1/position-locked bool true
xfconf_set xfce4-panel /panels/panel-1/length uint 100
xfconf_set xfce4-panel /panels/panel-1/length-adjust bool true
xfconf_set xfce4-panel /panels/panel-1/size uint 26
xfconf_set xfce4-panel /panels/panel-1/autohide-behavior uint 0
xfconf_set xfce4-panel /panels/panel-1/background-style uint 0
xfconf_set xfce4-panel /panels/panel-1/icon-size uint 16

nohup xfce4-panel >/dev/null 2>&1 &
disown
sleep 2

add_plugin() {
  xfce4-panel --add="$1" >/dev/null 2>&1 || log_warn "Couldn't add panel plugin '$1' — add it by hand via right-click panel > Panel > Add New Items."
}

add_plugin whiskermenu   # Apple-menu-style launcher, far left
add_plugin separator
if dpkg -s xfce4-appmenu-plugin >/dev/null 2>&1; then
  add_plugin appmenu      # real global app menu, if available
fi
add_plugin separator
add_plugin systray
add_plugin pulseaudio
add_plugin power-manager-button
add_plugin clock
add_plugin actions        # lock/logout, far right

restart_panel

log_ok "Panel rebuilt as a single macOS-style top bar."
log "  Backup of your previous panel: $BACKUP_DIR"
log "  Layout not quite right? Right-click the panel > Panel > Panel Preferences to"
log "  fine-tune it, or restore the backup with:"
log "    rm -rf ~/.config/xfce4/panel && cp -a '$BACKUP_DIR' ~/.config/xfce4/panel && xfce4-panel -r"
