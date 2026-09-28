#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

DEST_DIR="$HOME/.local/share/backgrounds/mac-kali"
mkdir -p "$DEST_DIR"

# Use whatever image(s) live in assets/wallpapers — a user-supplied wallpaper
# takes priority over the bundled placeholder if more than one file is there.
SRC_IMAGE=""
for f in "$SCRIPT_DIR"/../assets/wallpapers/*.{png,jpg,jpeg,svg}; do
  [[ -f "$f" ]] || continue
  [[ "$(basename "$f")" == "big-sur-inspired.svg" ]] && continue
  SRC_IMAGE="$f"
  break
done
[[ -z "$SRC_IMAGE" ]] && SRC_IMAGE="$SCRIPT_DIR/../assets/wallpapers/big-sur-inspired.svg"

cp "$SRC_IMAGE" "$DEST_DIR/"
WALLPAPER="$DEST_DIR/$(basename "$SRC_IMAGE")"

if [[ "$WALLPAPER" == *.svg ]]; then
  if command -v rsvg-convert >/dev/null 2>&1; then
    rsvg-convert -w 3840 -h 2160 "$WALLPAPER" -o "${WALLPAPER%.svg}.png"
    WALLPAPER="${WALLPAPER%.svg}.png"
  elif command -v convert >/dev/null 2>&1; then
    convert -background none -density 300 "$WALLPAPER" -resize 3840x2160 "${WALLPAPER%.svg}.png"
    WALLPAPER="${WALLPAPER%.svg}.png"
  else
    log_warn "Neither rsvg-convert nor ImageMagick found — using the SVG directly (works if gdk-pixbuf's SVG loader is installed)."
  fi
fi

FOUND=0
while IFS= read -r prop; do
  [[ -z "$prop" ]] && continue
  xfconf_set xfce4-desktop "$prop" string "$WALLPAPER"
  FOUND=1
done < <(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep -E 'last-image$' || true)

while IFS= read -r prop; do
  [[ -z "$prop" ]] && continue
  xfconf_set xfce4-desktop "$prop" int 5
done < <(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep -E 'image-style$' || true)

if [[ "$FOUND" -eq 0 ]]; then
  xfconf_set xfce4-desktop /backdrop/screen0/monitor0/workspace0/last-image string "$WALLPAPER"
  xfconf_set xfce4-desktop /backdrop/screen0/monitor0/workspace0/image-style int 5
fi

restart_desktop
log_ok "Wallpaper set to $(basename "$WALLPAPER")."
log "  Want a different one? Drop an image into assets/wallpapers/ and re-run:"
log "    ./install.sh --only=wallpaper"
