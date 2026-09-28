#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

pkg_install plank

THEME_NAME="macOS-Dark"
THEME_DIR="$HOME/.local/share/plank/themes/$THEME_NAME"
mkdir -p "$THEME_DIR"
cp "$SCRIPT_DIR/../config/plank/dock.theme" "$THEME_DIR/dock.theme"

DOCK_PATH="/net/launchpad/plank/docks/dock1/"
SCHEMA="net.launchpad.plank.dock.settings:$DOCK_PATH"

if command -v gsettings >/dev/null 2>&1; then
  gsettings set "$SCHEMA" theme "$THEME_NAME" 2>/dev/null || log_warn "Could not set the Plank theme via gsettings — set it from Plank's own Preferences (right-click dock > Preferences)."
  gsettings set "$SCHEMA" position "BOTTOM" 2>/dev/null || true
  gsettings set "$SCHEMA" alignment "CENTER" 2>/dev/null || true
  gsettings set "$SCHEMA" icon-size 48 2>/dev/null || true
  gsettings set "$SCHEMA" hide-mode "INTELLIGENT" 2>/dev/null || true
  gsettings set "$SCHEMA" pinned-only false 2>/dev/null || true

  # Pin whichever common apps actually exist on this machine — don't guess.
  CANDIDATES=(
    firefox-esr.desktop firefox.desktop
    thunar.desktop org.xfce.thunar.desktop
    xfce4-terminal.desktop qterminal.desktop kitty.desktop
    xfce4-taskmanager.desktop
  )
  PINNED=()
  for name in "${CANDIDATES[@]}"; do
    for dir in /usr/share/applications "$HOME/.local/share/applications"; do
      if [[ -f "$dir/$name" ]]; then
        PINNED+=("$dir/$name")
        break
      fi
    done
  done
  if [[ ${#PINNED[@]} -gt 0 ]]; then
    joined=""
    for p in "${PINNED[@]}"; do joined+="'$p', "; done
    gsettings set "$SCHEMA" pinned-launchers "[${joined%, }]" 2>/dev/null || true
  fi
else
  log_warn "gsettings not found — install glib2.0-bin / dconf-gsettings-backend to auto-configure Plank, or set it up by hand from the dock's Preferences."
fi

mkdir -p "$HOME/.config/autostart"
cat > "$HOME/.config/autostart/plank.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Plank
Comment=macOS-style dock (mac-kali)
Exec=plank
Icon=plank
X-GNOME-Autostart-enabled=true
EOF

restart_plank
log_ok "Plank dock installed and styled to look/behave like the macOS Dock."
