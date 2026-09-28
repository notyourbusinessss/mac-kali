# mac-kali

Turn a stock **Kali Linux XFCE** desktop into something that looks and feels
like macOS — GTK theme, icons, cursors, a top menu bar, a Dock, a
Spotlight-style launcher, and a matching wallpaper. Scripted, idempotent, and
reversible.

See [`docs/inspiration.md`](docs/inspiration.md) for the design references
this was built from (linked, not redistributed — see **Note on assets**
below).

## What it does

| Piece            | How                                                                 |
|-------------------|----------------------------------------------------------------------|
| GTK theme          | [WhiteSur-Dark](https://github.com/vinceliuice/WhiteSur-gtk-theme) |
| Icons               | [WhiteSur icon theme](https://github.com/vinceliuice/WhiteSur-icon-theme) |
| Cursors             | [WhiteSur cursors](https://github.com/vinceliuice/WhiteSur-cursors) |
| Fonts               | [Inter](https://github.com/rsms/inter) (open SF Pro alternative)   |
| Window buttons      | Traffic-light close/minimize/maximize, moved to the top-left       |
| Menu bar            | `xfce4-panel` rebuilt as one thin bar across the top                |
| Dock                 | `plank`, bottom-centered, with a custom macOS-style theme          |
| Spotlight            | `rofi`, centered rounded search bound to `Super+Space`             |
| Wallpaper             | An original gradient wallpaper (see `assets/wallpapers/`)          |

## Requirements

- Kali Linux (or another Debian-based distro) running the XFCE desktop
- A normal user account with `sudo` access — **don't run as root**
- An internet connection (the theme/icon/cursor packs are pulled from GitHub)

## Quick start

```bash
git clone https://github.com/notyourbusinessss/mac-kali.git
cd mac-kali
./install.sh
```

Log out and back in once it finishes so every setting settles cleanly.

Run non-interactively (no prompts):

```bash
./install.sh --yes
```

Run (or re-run) just one piece:

```bash
./install.sh --only=dock
./install.sh --only=panel,wallpaper
./install.sh --skip=fonts
```

Each script under `scripts/` is also self-contained and can be run directly,
e.g. `bash scripts/50-dock.sh`.

## Customizing

- **Light mode instead of dark:** `WHITESUR_GTK_OPTS='-c light' ./install.sh --only=gtk-theme`
  (see [WhiteSur-gtk-theme's options](https://github.com/vinceliuice/WhiteSur-gtk-theme) for the full list — accent colors, panel opacity, etc.)
- **Real San Francisco font:** if you already legally own it (from a Mac or
  an Apple Developer account), drop the `.otf`/`.ttf` files in `assets/fonts/`
  before running `./install.sh --only=fonts`.
- **Your own wallpaper:** drop an image in `assets/wallpapers/` and run
  `./install.sh --only=wallpaper`.
- **Dock apps:** edit the pinned list from the dock itself (drag icons on/off),
  or tweak `CANDIDATES` in `scripts/50-dock.sh`.
- **Panel layout:** right-click the panel → *Panel* → *Panel Preferences* for
  anything the script doesn't nail on the first try.

## Undoing it

```bash
./uninstall.sh
```

This restores every setting `install.sh` touched (theme, icons, cursor,
fonts, window buttons, the Super+Space shortcut) from a snapshot it took
before making any change, and offers to restore your panel layout from its
pre-install backup. Theme/icon/font *files* are left on disk under
`~/.themes`, `~/.icons` and `~/.local/share/fonts/mac-kali` — delete those
folders yourself if you want them fully gone.

You can also just re-run a single step to redo it, e.g. `./install.sh --only=panel`.

## Note on assets

The images linked as inspiration in this README and in `docs/inspiration.md`
are Apple's and a third party's copyrighted work — this repo links to them,
it doesn't download, host, or ship copies of them. The GTK/icon/cursor theme
this uses ([WhiteSur](https://github.com/vinceliuice/WhiteSur-gtk-theme)) is
open-source (GPL-3.0) artwork built specifically to evoke the macOS look,
not a copy of Apple's assets. The bundled wallpaper is original artwork made
for this repo. Apple's actual San Francisco font isn't redistributable, so
the default font is Inter, an open alternative — see **Customizing** above
if you own a legal copy of SF Pro and want to use it instead.

## Full reset (nuclear option)

If things get into a broken/half-applied state and `./uninstall.sh` isn't
cutting it, you can wipe *all* of XFCE's config and let it regenerate stock
defaults — not just what mac-kali touched. This moves your config aside
(rather than deleting it) so nothing's actually lost:

```bash
TS=$(date +%s)
mv ~/.config/xfce4        ~/.config/xfce4.bak-$TS
mv ~/.config/gtk-3.0      ~/.config/gtk-3.0.bak-$TS 2>/dev/null
mv ~/.config/autostart    ~/.config/autostart.bak-$TS 2>/dev/null
rm -f ~/.gtkrc-2.0

# make sure Kali's own theme/icon files on disk are pristine
sudo apt-get install --reinstall kali-themes kali-desktop-xfce

# stop the mac-kali dock/launcher processes
pkill plank 2>/dev/null

# optional: also remove what mac-kali installed into your home dir
rm -rf ~/.themes/WhiteSur* ~/.icons/WhiteSur* \
       ~/.local/share/fonts/mac-kali ~/.local/share/plank/themes/macOS-Dark \
       ~/.local/share/backgrounds/mac-kali ~/.config/rofi/mac-spotlight.rasi
```

Then **log all the way out and back in** (not just restart the panel) —
XFCE needs a fresh session to regenerate default config from scratch.

Heads up: this resets *any* XFCE customization you've made, not just
mac-kali's — try `./uninstall.sh` first if you just want mac-kali's changes
undone while keeping your own tweaks.

## License

[MIT](LICENSE) for the scripts and original assets in this repo. Third-party
components it installs (WhiteSur, Plank, rofi, Inter) keep their own
licenses.
