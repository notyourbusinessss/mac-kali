#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

snapshot ORIG_FONT_NAME xsettings /Gtk/FontName
snapshot ORIG_WM_FONT xfwm4 /general/title_font

# Apple's San Francisco font is proprietary and can't be redistributed here,
# so the default is Inter — an open-source font with very similar metrics
# and shapes. If you own a legal copy of San Francisco (e.g. from a Mac or
# an Apple Developer account), drop the .otf/.ttf files into assets/fonts/
# before running this script and they'll be installed and preferred instead.
pkg_install fonts-inter || log_warn "fonts-inter isn't packaged here; falling back to Cantarell."

DEFAULT_FONT="Cantarell 10"
if fc-list | grep -qi "Inter"; then
  DEFAULT_FONT="Inter 10"
fi
xfconf_set xsettings /Gtk/FontName string "$DEFAULT_FONT"
xfconf_set xfwm4 /general/title_font string "$DEFAULT_FONT"

LOCAL_FONTS_DIR="$SCRIPT_DIR/../assets/fonts"
if compgen -G "$LOCAL_FONTS_DIR/*.[ot]tf" > /dev/null 2>&1; then
  mkdir -p "$HOME/.local/share/fonts/mac-kali"
  cp -f "$LOCAL_FONTS_DIR"/*.[ot]tf "$HOME/.local/share/fonts/mac-kali/"
  fc-cache -f "$HOME/.local/share/fonts/mac-kali" >/dev/null
  FIRST_FAMILY="$(fc-scan --format '%{family[0]}\n' "$HOME/.local/share/fonts/mac-kali"/*.[ot]tf 2>/dev/null | head -n1)"
  if [[ -n "$FIRST_FAMILY" ]]; then
    xfconf_set xsettings /Gtk/FontName string "$FIRST_FAMILY 10"
    xfconf_set xfwm4 /general/title_font string "$FIRST_FAMILY 10"
    log_ok "Installed local fonts and set '$FIRST_FAMILY' as the UI font."
  fi
fi

log_ok "Fonts configured ($DEFAULT_FONT unless a local font was found)."
