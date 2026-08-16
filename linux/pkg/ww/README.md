# ww - Universal Wayland Wallpaper Setter

Fast wallpaper setter for Wayland compositors with support for images, videos, slideshows, and daemon mode.

## Features

- **Extensive format support**: PNG, JPEG, WebP, TIFF, JXL, BMP, TGA, PNM, Farbfeld
- **Animated wallpapers**: GIF, MP4, WebM with looping support
- **Slideshow mode**: Automatic wallpaper rotation with 16 transition effects
- **Daemon mode**: Background service with auto-restore from cache
- **High performance**: Up to 240 FPS transitions, bicubic scaling
- **Multi-monitor**: Per-output configuration and caching
- **Works with**: Sway, Hyprland, River, and other wlroots compositors

## Formats

Static: PNG, JPEG, WebP, TIFF/TIF, JXL, BMP, TGA, PNM/PBM/PGM/PPM, Farbfeld  
Animated: GIF, MP4, WebM, Animated WebP

## Installation

### Nix Flakes (Recommended)

```bash
# Try without installing
nix run github:jeebuscrossaint/ww -- --help

# Install to profile
nix profile install github:jeebuscrossaint/ww

# Build locally
git clone https://github.com/jeebuscrossaint/ww.git
cd ww
nix build
./result/bin/ww --version

# Add to your NixOS configuration
{
  inputs.ww.url = "github:jeebuscrossaint/ww";
  # ...
  environment.systemPackages = [ inputs.ww.packages.${system}.default ];
}

# Or use in home-manager
{
  home.packages = [ inputs.ww.packages.${pkgs.system}.default ];
}

# Development shell with all dependencies
nix develop github:jeebuscrossaint/ww
```

**What gets installed:**
- Binary: `$out/bin/ww`
- Man page: `$out/share/man/man1/ww.1.gz`
- Bash completion: `$out/share/bash-completion/completions/ww`
- Zsh completion: `$out/share/zsh/site-functions/_ww`
- Fish completion: `$out/share/fish/vendor_completions.d/ww.fish`

No xmake package manager dependencies - uses Nix packages directly!

### Building from Source

```bash
git clone https://github.com/jeebuscrossaint/ww.git
cd ww
./generate_protocols.sh   # Generate Wayland protocol bindings
xmake                      # Build the project (auto-installs most dependencies)
xmake install              # Install to ~/.local/bin (or use sudo for system-wide)
```

### Dependencies

Install xmake first. It'll download most deps automatically (stb, libtiff, libwebp, libjxl, ffmpeg).

You just need Wayland dev packages:

```bash
# Arch Linux
sudo pacman -S wayland wayland-protocols

# Gentoo
sudo emerge -av media-libs/wayland media-libs/wayland-protocols

# Ubuntu/Debian
sudo apt install libwayland-dev wayland-protocols

# Fedora
sudo dnf install wayland-devel wayland-protocols-devel
```


### Building

Generate the Wayland protocol bindings first:

```bash
./generate_protocols.sh
```

This script uses `wayland-scanner` to generate:
- `build/protocols/wlr-layer-shell-unstable-v1-client-protocol.h`
- `build/protocols/wlr-layer-shell-unstable-v1-protocol.c`
- `build/protocols/xdg-shell-client-protocol.h`
- `build/protocols/xdg-shell-protocol.c`

The script also fixes a C++ keyword collision (`namespace` → `name_space` in wlr-layer-shell).

Run this once, then build:

```bash
# Release build
xmake f -m release
xmake

# Debug build (with symbols, no optimization)
xmake f -m debug
xmake

# Clean build
xmake clean
xmake

# Install to ~/.local/bin
xmake install

# Install system-wide
sudo xmake install -o /usr/local
```

### Build Troubleshooting

- **"cannot find protocol header files"** → Run `./generate_protocols.sh` first
- **"wayland-scanner not found"** → Install wayland-protocols
- **First build slow?** → xmake is downloading deps, subsequent builds are faster
- **Package download fails?** → Try `xmake f --pkg=system` or install system packages

### Shell Completions

Shell completion scripts are available for bash, zsh, and fish:

```bash
# Bash
sudo cp completions/ww.bash /usr/share/bash-completion/completions/ww

# Zsh
sudo cp completions/_ww /usr/share/zsh/site-functions/_ww

# Fish
sudo cp completions/ww.fish /usr/share/fish/vendor_completions.d/ww.fish
```

See `completions/README.md` for detailed installation instructions.

### Man Page

Install the man page:

```bash
sudo cp man/ww.1 /usr/share/man/man1/ww.1
sudo mandb
man ww
```

## Usage

### Basic Usage

```bash
# Set wallpaper on all outputs
ww /path/to/image.png

# Set wallpaper on specific output
ww -o DP-1 /path/to/image.jpg

# List available outputs
ww --list-outputs

# Set animated wallpaper (looping)
ww --loop /path/to/video.mp4

# Set wallpaper with different scaling modes
ww --mode fill /path/to/image.jpg
ww --mode center --color '#282828' /path/to/logo.png

# Set solid color background
ww --color '#FF5733'

# Run as daemon (auto-restores wallpapers on login)
ww --daemon
```

### Daemon Mode

Run `ww` as a background daemon that persists wallpapers and auto-restores them on login:

```bash
# Start daemon (forks to background)
ww --daemon

# Set wallpaper normally - it gets cached automatically
ww -m fill ~/wallpapers/mountain.jpg

# Restart your compositor - daemon will restore the wallpaper!
ww --daemon

# Add to your compositor config for auto-start
# Hyprland: ~/.config/hypr/hyprland.conf
exec-once = ww --daemon

# Sway: ~/.config/sway/config
exec ww --daemon
```

**How it works:**
- Daemon mode forks to background and stays running
- Wallpapers are cached per-output in `~/.cache/ww/`
- On startup, daemon automatically restores last wallpaper for each output
- Supports all features: slideshows, transitions, videos, etc.
- Each monitor can have a different wallpaper

**Cache location:** `~/.cache/ww/<output-name>`

### Slideshow Mode

```bash
# Basic slideshow with multiple files (5 minute interval by default)
ww -S image1.jpg image2.png image3.webp

# Slideshow with custom interval (60 seconds)
ww -S -i 60 ~/wallpapers/*.jpg

# Random order slideshow
ww -S -r -i 120 ~/wallpapers/*.png

# Scan directory for images
ww -S ~/wallpapers/

# Recursively scan directory and subdirectories
ww -S -R ~/wallpapers/

# Slideshow with fade transition (2 second fade)
ww -S -t fade -d 2.0 ~/wallpapers/*.png

# Slideshow with fade at 60 FPS (smoother)
ww -S -t fade -d 2.0 -f 60 ~/wallpapers/*.png

# Slideshow with slide transition
ww -S -t slide-left -d 1.5 ~/wallpapers/
```

## Options

```
-o, --output <name>      Set wallpaper for specific output
-m, --mode <mode>        Scaling mode: fit, fill, stretch, center, tile (default: fit)
-c, --color <#RRGGBB>    Solid color background or letterbox color
-l, --loop               Loop animated wallpapers (GIF/video)
-S, --slideshow          Slideshow mode (multiple files/directories)
-i, --interval <sec>     Slideshow interval in seconds (default: 300)
-r, --random             Random slideshow order
-R, --recursive          Scan directories recursively
-t, --transition <type>  Transition effect: none, fade, slide-left, slide-right,
                         slide-up, slide-down (default: fade)
-d, --duration <sec>     Transition duration in seconds (default: 1.0)
-f, --fps <fps>          Transition frame rate (default: 30, max: 240)
-D, --daemon             Run in background and restore wallpapers from cache
-L, --list-outputs       List available outputs
-v, --version            Show version information
-h, --help               Show help message
```

### Scaling Modes

- **fit** - Scale to fit with letterboxing (preserves aspect ratio, default)
- **fill** - Scale to fill, crop if needed (preserves aspect ratio)
- **stretch** - Stretch to fill, ignore aspect ratio
- **center** - No scaling, center image
- **tile** - Repeat image to fill screen

### Transition Effects

**Basic:**
- **none** - Instant switch, no transition
- **fade** - Smooth crossfade between images

**Slide:**
- **slide-left** - Slide old image left, new image from right
- **slide-right** - Slide old image right, new image from left
- **slide-up** - Slide old image up, new image from bottom
- **slide-down** - Slide old image down, new image from top

**Zoom:**
- **zoom-in** - Zoom in while fading to new image
- **zoom-out** - Zoom out while fading to new image

**Circle:**
- **circle-open** - Circular reveal from random position outward
- **circle-close** - Circular collapse from random position inward

**Wipe:**
- **wipe-left** - Curtain wipe from left to right
- **wipe-right** - Curtain wipe from right to left
- **wipe-up** - Curtain wipe from bottom to top
- **wipe-down** - Curtain wipe from top to bottom

**Effects:**
- **dissolve** - Random pixel dissolve effect
- **pixelate** - Pixelate transition with mosaic effect

### FPS Control

Trade-off between smoothness and performance:
- **15 FPS** - Lower CPU, good for older systems
- **30 FPS** (default) - Balanced
- **60 FPS** - Smooth, higher CPU
- **120 FPS** - Ultra-smooth, highest CPU

```bash
# Smooth 60 FPS fade
ww -S -t fade -d 2.0 -f 60 ~/wallpapers/

# Performance mode at 15 FPS
ww -S -t fade -d 2.0 -f 15 ~/wallpapers/
```

## Scaling Quality

Uses bicubic interpolation for high-quality scaling (bilinear for extreme scale factors). Way better than nearest-neighbor - no jagged edges or pixelation.

## Performance

- Bicubic/bilinear scaling for quality
- SIMD optimizations in release builds
- LTO enabled
- 60 FPS transitions (configurable)

Rough CPU usage at 60 FPS:
- 1080p: ~5-10%
- 1600p: ~10-15%
- 4K: ~40-50%

## Compositor Support

Works with wlroots-based compositors (needs `wlr-layer-shell-unstable-v1`).

## Documentation

- [Installation Guide](INSTALL.md) - Detailed installation instructions
- [Daemon Mode](docs/DAEMON_MODE.md) - Background daemon documentation
- [Shell Completions](completions/README.md) - Completion installation
- Man page: `man ww` (after installation)

## Contributing

PRs welcome! See [issues](https://github.com/jeebuscrossaint/ww/issues) for ideas.

## License

See LICENSE file for details.

## Thanks

Inspired by swaybg, awww, mpvpaper, and the billion other wallpaper setters out there.
