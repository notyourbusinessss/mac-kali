#!/usr/bin/env bash
# Reverts the settings mac-kali/install.sh changed, using the values it
# snapshotted before each change. GTK theme/icon/cursor *files* themselves
# are left installed in ~/.themes, ~/.icons, ~/.icons — remove those
# directories yourself if you want them gone entirely.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

[[ $EUID -eq 0 ]] && die "Run this as your normal desktop user, not root."

log "Reverting mac-kali's changes..."

if [[ -f "$MAC_KALI_STATE_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$MAC_KALI_STATE_FILE"

  [[ -n "${ORIG_GTK_THEME:-}" ]]          && xfconf_set xsettings /Net/ThemeName string "$ORIG_GTK_THEME"
  [[ -n "${ORIG_ICON_THEME:-}" ]]         && xfconf_set xsettings /Net/IconThemeName string "$ORIG_ICON_THEME"
  [[ -n "${ORIG_CURSOR_THEME:-}" ]]       && xfconf_set xsettings /Gtk/CursorThemeName string "$ORIG_CURSOR_THEME"
  [[ -n "${ORIG_FONT_NAME:-}" ]]          && xfconf_set xsettings /Gtk/FontName string "$ORIG_FONT_NAME"
  [[ -n "${ORIG_DECORATION_LAYOUT:-}" ]]  && xfconf_set xsettings /Gtk/DecorationLayout string "$ORIG_DECORATION_LAYOUT"
  [[ -n "${ORIG_WM_THEME:-}" ]]           && xfconf_set xfwm4 /general/theme string "$ORIG_WM_THEME"
  [[ -n "${ORIG_BUTTON_LAYOUT:-}" ]]      && xfconf_set xfwm4 /general/button_layout string "$ORIG_BUTTON_LAYOUT"
  [[ -n "${ORIG_WM_FONT:-}" ]]            && xfconf_set xfwm4 /general/title_font string "$ORIG_WM_FONT"
  [[ -n "${ORIG_COMPOSITING:-}" ]]        && xfconf_set xfwm4 /general/use_compositing bool "$ORIG_COMPOSITING"
  [[ -n "${ORIG_SUPER_SPACE_SHORTCUT:-}" ]] && xfconf_set xfce4-keyboard-shortcuts "/commands/custom/<Super>space" string "$ORIG_SUPER_SPACE_SHORTCUT"

  log_ok "Restored the settings mac-kali had saved from before it ran."
else
  log_warn "No saved settings found — falling back to Kali's typical XFCE defaults."
  xfconf_set xsettings /Net/ThemeName string "Kali-Dark"
  xfconf_set xfwm4 /general/theme string "Kali-Dark"
  xfconf_set xfwm4 /general/button_layout string "O|SHMC"
fi

rm -f "$HOME/.config/autostart/plank.desktop"
pkill -u "$USER" plank >/dev/null 2>&1 || true

LATEST_BACKUP="$(ls -dt "$HOME"/.config/xfce4/panel.mac-kali.bak-* 2>/dev/null | head -n1 || true)"
if [[ -n "$LATEST_BACKUP" ]]; then
  if confirm "Restore panel layout from backup: $LATEST_BACKUP ?"; then
    rm -rf "$HOME/.config/xfce4/panel"
    cp -a "$LATEST_BACKUP" "$HOME/.config/xfce4/panel"
    xfce4-panel -r >/dev/null 2>&1 || true
  fi
else
  log_warn "No panel backup found — reset it by hand via right-click panel > Panel > Panel Preferences, or delete ~/.config/xfce4/panel and restart xfce4-panel."
fi

restart_panel
restart_desktop
restart_wm

log_ok "Done. Theme/icon/font files are still on disk under ~/.themes, ~/.icons and"
log "  ~/.local/share/fonts/mac-kali — delete those folders too if you want a full clean-up."
