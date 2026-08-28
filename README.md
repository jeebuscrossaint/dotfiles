# dotfiles

![arch](misc/preview_arch.png) ![openbsd](misc/preview_openbsd.png) ![windows](misc/preview_windows.png)

mango · waybar · kitty · fish · nvim · fuzzel · coat · glazewm

arch linux · openbsd · windows 11

---

**deps:** stow, [coat](https://github.com/jeebuscrossaint/coat)

```sh
git clone https://github.com/jeebuscrossaint/.dotfiles ~/.dotfiles
~/.dotfiles/install.fish
```

The installer stows `linux/`, then applies coat. It backs up (or, with `--adopt`,
absorbs) anything already sitting where a link belongs, since stow otherwise
refuses the whole package, and verifies the links afterwards. `--dry-run`,
`--uninstall` and `-h` do what they say.

set canvas url for assignment notifications (`canvas-notify`):
```sh
echo "YOUR_URL" > ~/.config/canvas/ical-url
```

install nerd fonts on openbsd (or anywhere without packages):
```sh
./install-nerdfonts.sh
```

---

**extensions:** uBlock Origin · SponsorBlock · BetterCanvas · Return YouTube Dislike · Proton Pass · Dark Reader , Adaptive Tab Bar Color, Imagus

**wallpapers**

- https://github.com/rann01/IRIX-tiles
- https://github.com/dharmx/walls
- https://github.com/wallace-aph/tiles-and-such
- https://github.com/tile-anon/tiles
- https://github.com/peteroupc/classic-wallpaper
- https://github.com/makccr/wallpapers
- https://github.com/whoisYoges/lwalpapers
- https://github.com/Axenide/Wallpapers
