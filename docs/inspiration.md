# Design inspiration

This project doesn't include or redistribute any of Apple's own images or
fonts — those are copyrighted and aren't ours to ship. Instead, here are the
references that shaped the look this toolkit goes for. Open these links
directly rather than expecting copies of them in the repo:

- [Finder window, ls.graphics macOS icon set](https://products.ls.graphics/macos/images/Finder.jpg)
- [macOS Big Sur — redesigned apps (Apple Newsroom)](https://www.apple.com/newsroom/images/product/os/macos/standard/apple_macos-bigsur_redesignedapps_06222020_big.jpg.large.jpg)
- [macOS Catalina preview (Apple Newsroom)](https://www.apple.com/newsroom/images/product/os/macos/standard/Apple-previews-macOS-Catalina-Twitter-screen-06032019_big.jpg.large.jpg)

What mac-kali actually ships instead:

| macOS element        | What this repo uses                                   |
|-----------------------|--------------------------------------------------------|
| System font (SF Pro)  | [Inter](https://github.com/rsms/inter) (open, SF-like) — or your own legally-owned SF files, see `assets/fonts/` |
| Wallpaper              | An original gradient wallpaper in `assets/wallpapers/` |
| Window/GTK chrome, icons, cursors | [WhiteSur](https://github.com/vinceliuice/WhiteSur-gtk-theme) theme family (GPL-3.0, made for exactly this purpose) |
| Menu bar               | `xfce4-panel`, rebuilt as a single top bar             |
| Dock                   | `plank`, with a custom macOS-style theme               |
| Spotlight              | `rofi`, with a custom centered search theme            |
