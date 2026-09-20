#!/usr/bin/env fish
#
# install.fish — link this repo's configs into $HOME with GNU Stow.
#
# Stow refuses to touch anything if a single target is already a real file, so
# this plans first, resolves the conflicts, then re-plans afterwards to prove the
# links actually landed.

set -g repo (path dirname (path resolve (status filename)))
set -g pkg linux

argparse -X 0 h/help n/dry-run v/verbose b/backup a/adopt y/yes no-coat minecraft uninstall c/check skip-checks install-deps t/target= -- $argv
or exit 2

if set -q _flag_help
    printf '%s\n' "usage: install.fish [options]

  -n, --dry-run    show what would change, touch nothing
  -b, --backup     move conflicting files aside instead of asking
  -a, --adopt      absorb conflicting files INTO the repo (git diff afterwards)
  -y, --yes        never prompt; implies --backup
  -c, --check      only check for missing dependencies, then stop
      --install-deps  install the missing packages without asking
      --skip-checks   link without checking dependencies at all
  -v, --verbose    list every link, not a summary
  -t, --target DIR link into DIR instead of the home directory
      --no-coat    skip the coat theme step
      --minecraft  also build the 1.8.9 PvP instance (~40M of mod downloads)
      --uninstall  remove the links this script created
  -h, --help       this"
    exit 0
end

set -g target $HOME
set -q _flag_target; and set -g target (path resolve $_flag_target)
set -q _flag_yes; and set -g _flag_backup 1

# Colour, unless piped or NO_COLOR.
set -g c_step ''; set -g c_ok ''; set -g c_warn ''; set -g c_err ''; set -g c_dim ''; set -g c_off ''
if not set -q NO_COLOR; and isatty stdout
    set c_step (set_color -o cyan); set c_ok (set_color -o green)
    set c_warn (set_color -o yellow); set c_err (set_color -o red)
    set c_dim (set_color brblack); set c_off (set_color normal)
end

function step; printf '%s::%s %s\n' "$c_step" "$c_off" "$argv"; end
function ok;   printf '%s ✓%s %s\n' "$c_ok" "$c_off" "$argv"; end
function note; printf '%s !%s %s\n' "$c_warn" "$c_off" "$argv"; end
function dim;  printf '%s   %s%s\n' "$c_dim" "$argv" "$c_off"; end
function die;  printf '%s ✗%s %s\n' "$c_err" "$c_off" "$argv" >&2; exit 1; end

# Everything stow says, conflicts included; simulation noise dropped, stow's own
# exit status preserved (a pipeline here would hand back string's status instead).
function stow_run
    set -l out (stow -v -d $repo -t $target $argv $pkg 2>&1)
    set -l rc $status
    for line in $out
        string match -qv -- 'WARNING: in simulation mode*' $line; and echo $line
    end
    return $rc
end

# Target paths, relative to $target, that stow is refusing to overwrite.
function conflicts_in
    for line in $argv
        string match -q '*cannot stow*' -- $line
        or string match -q '*existing target*' -- $line
        or continue
        for re in 'over existing target (\S+) since' \
                  'existing target is not owned by stow: (\S+)' \
                  'existing target is neither a link nor a directory: (\S+)'
            set -l m (string match -r -- $re $line)
            if test (count $m) -ge 2
                echo $m[2]
                break
            end
        end
    end
end

function plural -a n one many
    test $n -eq 1; and echo "$n $one"; or echo "$n $many"
end

# Targets stow reported linking, relative to $target.
function link_paths
    for line in $argv
        set -l m (string match -r '^LINK: (\S+)' -- $line)
        test (count $m) -ge 2; and echo $m[2]
    end
end

test -d $repo/$pkg
or die "no '$pkg' package in $repo — is this the dotfiles repo?"
test -w $target
or die "$target is not writable"

# --- dependencies -------------------------------------------------------------
#
#   group | probe | label | tier | pacman | aur | hint
#
# probe  cmd:BINARY · font:FAMILY · path:P1 P2 (any one existing is enough)
# tier   req  the installer itself cannot run
#        core something tracked here calls it and breaks without it
#        opt  one feature degrades
#
# Rows above `chat` are derived from what the tracked configs and ~/.local/bin
# scripts actually invoke — grep before adding one, and keep the paths in step
# with the probes in start-polkit and mango's config.conf.
#
# The cli, chat, dev and apps groups are the other kind of row: nothing in this
# repo calls them, they are just what this person installs on every machine. All
# `opt`, so a server or a VM can decline the lot and still get a working session.
#
# `cli` is the terminal tooling reached for by hand rather than by a script: gdu
# for what ate the disk, glow for a README. It sits down here rather than in
# `terminal` because nothing in this repo invokes it, which is the line the two
# halves of this table are split on.
#
# Kept SHORT on purpose. The first version of this group also carried rclone,
# pandoc, cloc, powertop and strace, picked by diffing installed packages against
# the table rather than by asking what actually gets used. Being installed is not
# the same as being wanted on the next machine. AUR names are the exact ones in use, forks included -- slack's
# wayland fork, and the -bin builds of the Electron apps.
# No cmd: row for anything this repo ships in ~/.local/bin — the stow run puts
# the script on PATH, so the probe passes on a machine missing the real package
# (that is what the nvidia-prime row did).
#
# The conky rows are the whole desktop readout, so they are core: conky itself,
# curl and jq for the weather it fetches from Open-Meteo, and pstree for the process
# tree in the left panel. cava and gawk are opt because each degrades quietly
# rather than breaking -- conky_cava returns an empty string when nothing is
# writing ~/.cache/cava.state, and tree.awk without gawk's character-counting
# RLENGTH colours every branch at the same depth instead of erroring.
#
# One font, not two: coat.yaml asks for JetBrainsMono Nerd Font Mono in all three
# slots. It used to be SFMono plus SF Pro from nerd-fonts-apple, and a machine set
# up from the old rows themed itself into tofu.
set -g dep_table \
    "installer|cmd:stow|stow|req|stow||" \
    "installer|cmd:git|git|core|git||" \
    "installer|cmd:fish|fish|req|fish||" \
    "compositor|cmd:mango|mango|core||mangowm|https://github.com/DreamMaoMao/mango" \
    "compositor|cmd:uwsm|uwsm|core|uwsm||" \
    "compositor|path:/usr/lib/xdg-desktop-portal-wlr /usr/libexec/xdg-desktop-portal-wlr|xdg-desktop-portal-wlr|core|xdg-desktop-portal-wlr||" \
    "compositor|path:/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 /usr/libexec/polkit-gnome-authentication-agent-1 /usr/local/libexec/polkit-gnome-authentication-agent-1|polkit agent|core|polkit-gnome||" \
    "compositor|path:/usr/lib/xdg-desktop-portal-gtk /usr/libexec/xdg-desktop-portal-gtk|xdg-desktop-portal-gtk|core|xdg-desktop-portal-gtk||" \
    "desktop|cmd:dunst|dunst|core|dunst||" \
    "desktop|cmd:fuzzel|fuzzel|core|fuzzel||" \
    "desktop|cmd:swayidle|swayidle|core|swayidle||" \
    "desktop|cmd:swaylock|swaylock|core|swaylock||" \
    "desktop|cmd:conky|conky|core|conky||" \
    "desktop|cmd:wlsunset|wlsunset|core|wlsunset||" \
    "desktop|cmd:swaybg|swaybg|opt|swaybg||" \
    "desktop|cmd:cava|cava|opt|cava||" \
    "terminal|cmd:kitty|kitty|core|kitty||" \
    "terminal|cmd:micro|micro|core|micro||" \
    "terminal|cmd:nvim|neovim|opt|neovim||" \
    "terminal|cmd:lsd|lsd|opt|lsd||" \
    "terminal|cmd:bat|bat|opt|bat||" \
    "terminal|cmd:fastfetch|fastfetch|opt|fastfetch||" \
    "terminal|cmd:rg|ripgrep|opt|ripgrep||" \
    "clipboard|cmd:wl-copy|wl-clipboard|core|wl-clipboard||" \
    "clipboard|cmd:cliphist|cliphist|core|cliphist||" \
    "clipboard|cmd:wl-clip-persist|wl-clip-persist|opt||wl-clip-persist|" \
    "clipboard|cmd:grim|grim|core|grim||" \
    "clipboard|cmd:slurp|slurp|core|slurp||" \
    "clipboard|cmd:satty|satty|opt|satty||" \
    "clipboard|cmd:swappy|swappy|opt|swappy||" \
    "system|cmd:wpctl|wireplumber|core|wireplumber||" \
    "system|cmd:notify-send|libnotify|core|libnotify||" \
    "system|cmd:brightnessctl|brightnessctl|core|brightnessctl||" \
    "system|cmd:playerctl|playerctl|opt|playerctl||" \
    "system|cmd:pavucontrol|pavucontrol|opt|pavucontrol||" \
    "system|cmd:jq|jq|core|jq||" \
    "system|cmd:curl|curl|core|curl||" \
    "system|cmd:pstree|psmisc|core|psmisc||" \
    "system|cmd:gawk|gawk|opt|gawk||" \
    "system|cmd:python3|python|core|python||" \
    "system|cmd:nmcli|networkmanager|core|networkmanager||" \
    "system|cmd:sshd|openssh|opt|openssh||" \
    "system|cmd:smartctl|smartmontools|opt|smartmontools||" \
    "system|cmd:paccache|pacman-contrib|opt|pacman-contrib||" \
    "system|path:/usr/lib/systemd/system-generators/zram-generator|zram-generator|opt|zram-generator||" \
    "system|cmd:tailscale|tailscale|opt|tailscale||" \
    "theme|cmd:cargo|rust toolchain|core|rustup||https://rustup.rs" \
    "theme|cmd:coat|coat|core|||cargo install --git https://github.com/jeebuscrossaint/coat" \
    "theme|path:/usr/share/icons/WhiteSur-dark /usr/share/icons/WhiteSur|WhiteSur icon theme|core||whitesur-icon-theme|" \
    "theme|path:/usr/share/themes/adw-gtk3-dark|adw-gtk3|core|adw-gtk-theme||" \
    "fonts|font:JetBrainsMono Nerd Font|JetBrainsMono Nerd Font|core|ttf-jetbrains-mono-nerd||./install-nerdfonts.sh" \
    "fonts|font:Font Awesome|Font Awesome|core|otf-font-awesome||" \
    "fonts|font:Noto Color Emoji|Noto Color Emoji|core|noto-fonts-emoji||" \
    "apps|cmd:btop|btop|opt|btop||" \
    "apps|cmd:mpv|mpv|opt|mpv||" \
    "apps|cmd:zathura|zathura|opt|zathura||" \
    "apps|cmd:chromium|chromium|opt|chromium||" \
    "apps|cmd:prismlauncher|prismlauncher|opt|prismlauncher||" \
    "apps|cmd:yazi|yazi|opt|yazi||" \
    "apps|cmd:blueman-manager|blueman|opt|blueman||" \
    "apps|cmd:bluetoothctl|bluez-utils|opt|bluez-utils||" \
    "apps|cmd:openlogi|openlogi|opt||openlogi-bin|" \
    "apps|cmd:tradingview|tradingview|opt||tradingview|" \
    "apps|cmd:yt-dlp|yt-dlp|opt|yt-dlp||" \
    "apps|path:/usr/lib/zathura/libpdf-poppler.so|zathura pdf backend|opt|zathura-pdf-poppler||" \
    "apps|cmd:firefox-developer-edition|firefox developer edition|core|firefox-developer-edition||" \
    "apps|cmd:nvibrant|nvibrant|opt||nvibrant-bin|" \
    "apps|cmd:fd|fd|opt|fd||" \
    "apps|cmd:magick|imagemagick|opt|imagemagick||" \
    "apps|cmd:torbrowser-launcher|tor browser|opt|torbrowser-launcher||" \
    "apps|cmd:tor|tor|opt|tor||" \
    "apps|cmd:i2pd|i2pd|opt|i2pd||" \
    "cli|cmd:gdu|gdu|opt|gdu||" \
    "cli|cmd:glow|glow|opt|glow||" \
    "chat|cmd:slack|slack|opt||slack-desktop-wayland-jetm|" \
    "chat|cmd:discord|discord|opt|discord||" \
    "chat|path:/etc/pacman.d/hooks/vencord-hook.hook|vencord|opt||vencord-installer-bin vencord-hook|" \
    "chat|path:/opt/teams-for-linux|teams for linux|opt||teams-for-linux-bin|" \
    "chat|path:/opt/outlook-for-linux|outlook for linux|opt||outlook-for-linux-bin|" \
    "chat|cmd:zoom|zoom|opt||zoom|" \
    "dev|cmd:claude|claude code|opt||claude-code|" \
    "dev|cmd:claude-desktop|claude desktop|opt||claude-desktop|" \
    "dev|cmd:code|vscode|opt||visual-studio-code-bin|" \
    "dev|cmd:gh|github cli|opt|github-cli||" \
    "dev|cmd:clion-eap|clion eap|opt||clion-eap|" \
    "dev|path:/usr/lib/jvm/zulu-8|zulu 8 jdk|opt||zulu-8-bin|" \
    "toys|cmd:cbonsai|cbonsai|opt||cbonsai|" \
    "toys|cmd:pipes-rs|pipes-rs|opt||pipes-rs|" \
    "toys|cmd:cmatrix|cmatrix|opt|cmatrix||"

function aur_helper
    for h in paru yay
        command -q $h; and echo $h; and return
    end
end

# paru is a cargo build, so the toolchain has to land before the clone does --
# that ordering is the whole function: rustup, a default toolchain, then makepkg.
function bootstrap_aur_helper
    command -q git; and command -q makepkg
    or begin
        step "Installing base-devel and git first..."
        fish -c "sudo pacman -S --needed --noconfirm base-devel git"
        or begin; note "could not install base-devel — paru cannot be built"; return 1; end
    end

    if not command -q cargo
        step "Installing rustup first — paru builds with cargo..."
        fish -c "sudo pacman -S --needed --noconfirm rustup"
        or begin; note "could not install rustup — paru cannot be built"; return 1; end
    end
    ensure_rust
    command -q cargo; or begin; note "no working cargo — paru cannot be built"; return 1; end

    set -l dir (mktemp -d)
    step "Building paru..."
    git clone -q --depth 1 https://aur.archlinux.org/paru.git $dir/paru
    and fish -c "cd $dir/paru; and makepkg -si --noconfirm"
    set -l rc $status
    rm -rf $dir
    test $rc -eq 0; or begin; note "paru build failed — install it by hand"; return 1; end
    command -q paru
end

function dep_present -a probe
    set -l parts (string split -m1 : -- $probe)
    switch $parts[1]
        case cmd
            command -q $parts[2]
        case font
            test (count $font_families) -gt 0; or return 0 # no fontconfig: don't cry wolf
            string match -qi -- "*$parts[2]*" $font_families
        case path
            for p in (string split ' ' -- $parts[2])
                test -e $p; and return 0
            end
            return 1
    end
end

# y/n, with --yes and --install-deps answering for it.
function confirm -a prompt
    set -q _flag_install_deps; and return 0
    set -q _flag_yes; and return 0
    isatty stdin; or return 1
    read -P "  $prompt [y/N] " -l answer
    echo
    string match -qi 'y*' -- (string trim -- $answer)
end

function enable_service
    command -q systemctl; or return 0
    set -l scope
    set -l unit $argv[1]
    test "$argv[1]" = --user; and set scope --user; and set unit $argv[2]

    systemctl $scope is-enabled -q $unit 2>/dev/null; and return 0
    step "systemctl $scope enable --now $unit"
    if test -n "$scope"
        systemctl --user enable --now $unit; or note "$unit did not start"
    else
        sudo systemctl enable --now $unit; or note "$unit did not start"
    end
end

# asusd is the fan curves, keyboard LEDs and battery charge limit; supergfxd is
# the GPU mode switch. AUR-only, and pointless on anything that is not an ASUS.
# One pacman.conf key, set idempotently. An empty `value` means a bare flag line
# like ILoveCandy, which has no `=` and is not in the shipped file at all -- so
# the sed cannot just uncomment it, there is nothing there to uncomment.
function pacman_conf_set -a key value
    set -l line $key
    test -n "$value"; and set line "$key = $value"
    grep -qxF -- "$line" /etc/pacman.conf; and return 0

    if grep -qE "^[#[:space:]]*$key\\b" /etc/pacman.conf
        sudo sed -i -E "s|^[#[:space:]]*$key\\b.*|$line|" /etc/pacman.conf
    else
        sudo sed -i "0,/^\\[options\\]/s|^\\[options\\]|[options]\\n$line|" /etc/pacman.conf
    end
end

# ParallelDownloads is the one that earns its place: the shipped default is 5 and
# this table is 85 rows, most of them from a repo. Color and ILoveCandy are the
# progress bar, and they are the only thing in this file that is purely for the
# look of it.
function ensure_pacman_conf
    test -f /etc/pacman.conf; or return 0
    command -q pacman; or return 0

    set -l missing
    grep -qxF 'ParallelDownloads = 25' /etc/pacman.conf; or set -a missing ParallelDownloads
    grep -qxF ILoveCandy /etc/pacman.conf; or set -a missing ILoveCandy
    grep -qxF Color /etc/pacman.conf; or set -a missing Color
    test (count $missing) -gt 0; or return 0

    step "pacman.conf: $missing"
    confirm "set them?"; or return 0
    pacman_conf_set ParallelDownloads 25
    pacman_conf_set Color
    pacman_conf_set ILoveCandy
end

# chaotic-aur: prebuilt binaries for AUR packages, so paru is left building only
# the handful nobody else ships -- mangowm and the -eap/-bin oddities.
#
# It is a THIRD-PARTY repo: their build machines, their key, trusted by root on
# this box from here on. That is a real trade and it is stated rather than
# buried. It is the same one Omarchy makes by running its own repo; the
# difference is not having to run one.
#
# Not a replacement for paru. pacman resolves from the repo automatically once
# the stanza is in, and paru handles whatever no repo carries.
function ensure_chaotic_aur
    command -q pacman; or return 0
    test -f /etc/pacman.conf; or return 0
    grep -q '^\[chaotic-aur\]' /etc/pacman.conf; and return 0

    step "chaotic-aur is not configured"
    dim "prebuilt AUR binaries — a third-party repo, signed into this machine's root trust"
    confirm "bootstrap it?"; or return 0

    set -l key 3056513887B78AEB
    sudo pacman-key --recv-key $key --keyserver keyserver.ubuntu.com
    and sudo pacman-key --lsign-key $key
    and sudo pacman -U --needed --noconfirm \
        'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
        'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    or begin
        note "chaotic-aur bootstrap failed — paru will build from source instead"
        return 1
    end

    printf '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist\n' | sudo tee -a /etc/pacman.conf >/dev/null
    sudo pacman -Sy
end

# thermald and tuned are both hardware-conditional, for different reasons.
#
# thermald is Intel's thermal daemon (DPTF/RAPL). It is not a profile manager and
# does not contend with asusd, so it goes on any Intel box including the ASUS one.
#
# tuned IS the profile manager, and it is installed only where nothing else owns
# the platform profile. On the ASUS box asusd owns it and running both means two
# daemons writing one firmware knob. Anywhere else -- the ThinkPad -- nothing owns
# it at all and the profile sits wherever the firmware left it, which is the case
# tuned exists for. Mirrors ensure_asus deliberately.
function ensure_power_profile
    command -q systemctl; or return 0

    if grep -q GenuineIntel /proc/cpuinfo 2>/dev/null
        if not command -q thermald
            step "Intel CPU, no thermal daemon"
            printf '   %ssudo pacman -S --needed thermald%s\n' "$c_ok" "$c_off"
            confirm "install it?"
            and begin
                sudo pacman -S --needed --noconfirm thermald; or note "thermald did not install"
            end
        end
        command -q thermald; and enable_service thermald
    end

    if string match -qi '*asus*' -- (cat /sys/class/dmi/id/board_vendor 2>/dev/null)
        dim "ASUS board — asusd owns the platform profile, so tuned stays off here"
        return 0
    end

    if command -q tuned-adm
        enable_service tuned
        return 0
    end

    step "nothing owns the platform profile on this machine"
    dim "asusd covers this on the ASUS box; there is no equivalent here"
    printf '   %ssudo pacman -S --needed tuned tuned-ppd%s\n' "$c_ok" "$c_off"
    confirm "install them?"; or return 0
    sudo pacman -S --needed --noconfirm tuned tuned-ppd
    or begin; note "that failed — carry on by hand"; return 1; end
    enable_service tuned
end

function ensure_asus
    string match -qi '*asus*' -- (cat /sys/class/dmi/id/board_vendor 2>/dev/null)
    or return 0

    set -l want
    command -q asusctl; or set -a want asusctl
    command -q supergfxctl; or set -a want supergfxctl
    command -q rog-control-center; or set -a want rog-control-center
    test (count $want) -gt 0
    or begin; enable_service asusd; enable_service supergfxd; return 0; end

    step "ASUS board — the control stack is missing"
    printf '   %sparu -S --needed %s%s\n' "$c_ok" "$want" "$c_off"
    confirm "install it now?"; or return 0

    set -l helper (aur_helper)
    if test -z "$helper"
        bootstrap_aur_helper; or return 1
        set helper (aur_helper)
    end
    fish -c "$helper -S --needed $want"; or begin; note "that failed — carry on by hand"; return 1; end
    enable_service asusd
    enable_service supergfxd
end

# Things runit had no answer for, so they were never set up here before.
function ensure_systemd_extras
    command -q systemctl; or return 0

    # Kills the cgroup under memory pressure instead of whichever process the
    # kernel picks. uwsm puts every app in its own scope, so the runaway tab
    # goes and the compositor holding the session stays.
    enable_service systemd-oomd.service
    command -q paccache; and enable_service paccache.timer

    # /var/log/journal is the entire switch: without the directory the journal
    # lives in tmpfs and last boot's crash is gone by the time it is wanted.
    if not test -d /var/log/journal
        step "journals do not survive a reboot"
        if confirm "keep them (mkdir /var/log/journal)?"
            sudo mkdir -p /var/log/journal
            and sudo systemd-tmpfiles --create --prefix /var/log/journal
            or note "could not create /var/log/journal"
        end
    end

    # Compressed swap in RAM: the zram-generator replacement for zramen.
    if test -f /usr/lib/systemd/system-generators/zram-generator
        and not test -f /etc/systemd/zram-generator.conf
        step "zram-generator is installed but not configured"
        if confirm "set up zram swap, half of RAM, zstd?"
            printf '[zram0]\nzram-size = ram / 2\ncompression-algorithm = zstd\n' \
                | sudo tee /etc/systemd/zram-generator.conf >/dev/null
            and sudo systemctl daemon-reload
            and sudo systemctl start systemd-zram-setup@zram0.service
            or note "zram setup did not complete"
        end
    end
end

# MagicDNS is the reason to bother: tailscale wants a resolver it can put a
# split-DNS route into, and resolved is the one systemd ships.
function ensure_resolved
    command -q systemctl; or return 0
    command -q tailscale; or return 0
    systemctl is-enabled -q systemd-resolved 2>/dev/null; and return 0

    step "systemd-resolved is off, and tailscale is installed"
    dim "MagicDNS needs it; everything else gets a DNS cache out of it"
    confirm "enable it and point NetworkManager at it?"; or return 0
    sudo systemctl enable --now systemd-resolved
    and sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
    and printf '[main]\ndns=systemd-resolved\n' \
        | sudo tee /etc/NetworkManager/conf.d/dns.conf >/dev/null
    and sudo systemctl restart NetworkManager
    or note "resolved setup did not finish — check /etc/resolv.conf by hand"
end

# The session starts from a tty1 login, so tty1 logs in by itself. config.fish
# does the rest -- see the `uwsm check may-start` block at the top of it.
function ensure_autologin
    command -q systemctl; or return 0
    set -l dir /etc/systemd/system/getty@tty1.service.d
    test -f $dir/autologin.conf; and return 0

    step "tty1 does not log in by itself"
    dim "agetty --autologin $USER on tty1; config.fish execs mango-run from there"
    confirm "set that up?"; or return 0
    sudo mkdir -p $dir
    printf '[Service]\nExecStart=\nExecStart=-/usr/bin/agetty --autologin %s --noclear %%I $TERM\n' $USER \
        | sudo tee $dir/autologin.conf >/dev/null
    and sudo systemctl daemon-reload
    or note "could not write $dir/autologin.conf"
end

# Installed does not mean running. This is the runit service list from the old
# machine translated to units, minus the ones systemd already covers itself:
# dbus, logind, udevd are built in, journald replaces syslog-ng, and autovt@
# spawns the extra ttys on demand instead of six always-on agetty services.
function ensure_services
    command -q systemctl; or return 0

    enable_service NetworkManager
    enable_service systemd-timesyncd
    enable_service fstrim.timer
    command -q bluetoothctl; and enable_service bluetooth
    command -q thermald; and enable_service thermald
    if command -q tailscale
        enable_service tailscaled
        tailscale status &>/dev/null; or dim "tailscale is not logged in yet — sudo tailscale up"
    end

    # Audio is per-user and socket-activated: the sockets are what start it on
    # the first client, which is the thing the old launcher kept getting wrong.
    enable_service --user pipewire.socket
    enable_service --user pipewire-pulse.socket
    enable_service --user wireplumber.service

    command -q smartctl; and enable_service smartd
    command -q sshd; and enable_service sshd

    # Tor and I2P, both wanted running rather than merely installed. tor is the
    # system daemon -- a SOCKS5 proxy on 127.0.0.1:9050 -- and is NOT what Tor
    # Browser uses: the browser ships and starts its own, so torbrowser-launcher
    # works with or without this. Enabling it is for everything else that can be
    # pointed at a SOCKS port.
    #
    # i2pd is the C++ I2P router (the `i2p` package is the Java one and is
    # AUR-only); its web console is on 127.0.0.1:7070. Both bind loopback by
    # default and neither is reachable from the network as shipped.
    command -q tor; and enable_service tor
    command -q i2pd; and enable_service i2pd

    # tuned is held back on the ASUS box ONLY, where asusd owns the ACPI platform
    # profile. Everywhere else ensure_power_profile installs and enables it,
    # because nothing else owns the profile there -- so claiming it is off "on
    # purpose" on a ThinkPad would be reporting the opposite of what just happened.
    set -l optional
    if command -q tuned; and string match -qi '*asus*' -- (cat /sys/class/dmi/id/board_vendor 2>/dev/null)
        set -a optional "tuned (asusd owns the power profile)"
    end
    command -q docker; and set -a optional docker.service
    command -q ollama; and set -a optional ollama.service
    test (count $optional) -gt 0
    and dim "installed but not enabled, on purpose: $optional"
end

# rustup installs SHIMS, not a compiler: `cargo` exists and every build fails
# with "no override and no default toolchain set" until this runs.
function ensure_rust
    command -q rustup; or return 0
    set -l tc (rustup toolchain list 2>/dev/null | string match -v 'no installed*')
    test (count $tc) -gt 0; and return 0
    step "Installing the stable Rust toolchain..."
    rustup default stable; or note "rustup default stable failed — cargo will not build anything"
end

# coat is this repo's theming tool and is in no repository. Prefer the checkout
# if it is there: that is the one whose changes are being tested.
function ensure_coat
    command -q coat; and return 0
    command -q cargo; or return 1
    step "Installing coat..."
    if test -d $HOME/Projects/coat
        cargo install --path $HOME/Projects/coat
    else
        cargo install --git https://github.com/jeebuscrossaint/coat
    end
    or note "coat build failed"
end

# The proprietary stack, only if there is actually a 10de device on the bus.
# Packages only -- no modprobe drop-in, no udev rule, no MUX service. The tuned
# power setup in misc/ is this machine's, not a default; install it by hand if
# and when it is wanted.
function ensure_nvidia
    set -l found
    for v in /sys/bus/pci/devices/*/vendor
        test (cat $v 2>/dev/null) = 0x10de; and set found 1; and break
    end
    test -n "$found"; or return 0
    pacman -Qq nvidia-utils &>/dev/null; and return 0

    set -l want nvidia-open-dkms nvidia-utils libva-nvidia-driver egl-wayland
    pacman-conf --repo-list 2>/dev/null | string match -q multilib
    and set -a want lib32-nvidia-utils

    step "NVIDIA card found, no driver installed"
    printf '   %ssudo pacman -S --needed %s%s\n' "$c_ok" "$want" "$c_off"
    dim "nvidia-open is for Turing and newer; on anything older swap in nvidia-dkms"
    confirm "install it now?"; or return 0
    fish -c "sudo pacman -S --needed $want"; or note "that failed — carry on by hand"
end

# Reports what is missing; returns 1 if anything req/core is.
function check_deps
    set -g font_families
    command -q fc-list; and set -g font_families (fc-list : family 2>/dev/null | string split ,)

    set -l aur (aur_helper)

    set -l groups
    set -l rendered
    set -l miss_req; set -l miss_core; set -l miss_opt
    set -l want_pm; set -l want_aur; set -l hints; set -l orphans
    set -l total 0

    for rec in $dep_table
        set -l f (string split '|' -- $rec)
        set -l group $f[1]; set -l label $f[3]; set -l tier $f[4]
        set total (math $total + 1)

        set -l i (contains -i -- $group $groups)
        or begin
            set -a groups $group
            set -a rendered ''
            set i (count $groups)
        end

        set -l sep ''
        test -n "$rendered[$i]"; and set sep " $c_dim·$c_off"

        if dep_present $f[2]
            set rendered[$i] "$rendered[$i]$sep $c_dim$label$c_off"
            continue
        end

        switch $tier
            case req; set -a miss_req $label; set rendered[$i] "$rendered[$i]$sep $c_err✗ $label$c_off"
            case core; set -a miss_core $label; set rendered[$i] "$rendered[$i]$sep $c_err✗ $label$c_off"
            case '*'; set -a miss_opt $label; set rendered[$i] "$rendered[$i]$sep $c_warn✗ $label$c_off"
        end

        set -l pkg $f[5]
        set -l apkg $f[6]

        if test -n "$pkg"
            set -a want_pm $pkg
        else if test -n "$apkg"
            set -a want_aur $apkg
        else if test -n "$f[7]"
            contains -- "$label|$f[7]" $hints; or set -a hints "$label|$f[7]"
        else
            set -a orphans $label
        end
    end

    step "Checking $total dependencies..."
    for i in (seq (count $groups))
        printf '   %s%-11s%s%s\n' "$c_step" $groups[$i] "$c_off" "$rendered[$i]"
    end
    echo

    set -l gone (math (count $miss_req) + (count $miss_core) + (count $miss_opt))
    if test $gone -eq 0
        ok "everything is here"
        return 0
    end

    note "$gone missing — "(count $miss_req)" required, "(count $miss_core)" core, "(count $miss_opt)" optional"
    echo

    # The paste-me block, and the same thing as runnable commands.
    set -g dep_cmds
    test (count $want_pm) -gt 0
    and set -g dep_cmds $dep_cmds "sudo pacman -S --needed $want_pm"
    if test (count $want_aur) -gt 0
        if test -n "$aur"
            set -g dep_cmds $dep_cmds "$aur -S --needed $want_aur"
        else
            set -g want_paru $want_aur
            printf '   %s# no AUR helper yet — paru will be bootstrapped first, then:%s paru -S --needed %s\n' "$c_warn" "$c_off" "$want_aur"
        end
    end
    for c in $dep_cmds
        printf '   %s%s%s\n' "$c_ok" $c "$c_off"
    end
    for h in $hints
        set -l parts (string split -m1 '|' -- $h)
        printf '   %s%-22s%s %s\n' "$c_ok" $parts[2] "$c_off" "$c_dim# $parts[1]$c_off"
    end
    if test (count $orphans) -gt 0
        printf '   %s# no package known here for:%s %s\n' "$c_dim" "$c_off" "$orphans"
    end
    echo

    # Offer to actually run it.  Once only, however badly it goes.
    if test (count $dep_cmds) -gt 0; and not set -q deps_installed
        set -l go
        if set -q _flag_install_deps
            set go yes
        else if isatty stdin; and not set -q _flag_yes
            read -P "  run the "(count $dep_cmds)" command(s) above now? [y/N] " -l answer
            string match -qi 'y*' -- (string trim -- $answer); and set go yes
            echo
        end
        if test -n "$go"
            set -g deps_installed 1
            if set -q want_paru; and bootstrap_aur_helper
                set -g dep_cmds $dep_cmds "paru -S --needed $want_paru"
                set -e want_paru
            end
            for c in $dep_cmds
                step $c
                fish -c "$c"; or note "that failed — carry on by hand"
            end
            echo
            step "Re-checking..."
            set -e dep_cmds
            check_deps
            return $status
        end
    end

    test (count $miss_req) -eq 0 -a (count $miss_core) -eq 0
end

printf '\n%sdotfiles%s  %s → %s\n' "$c_step" "$c_off" (string replace $HOME '~' $repo) (string replace $HOME '~' $target)
command -q stow; and dim (stow --version | string collect)
echo

if set -q _flag_check
    check_deps
    exit $status
end

if not set -q _flag_skip_checks; and not set -q _flag_uninstall
    # Both BEFORE check_deps: the repo has to exist before the installer offers
    # to install anything, or every chaotic-carried package is a paru source build.
    ensure_pacman_conf
    ensure_chaotic_aur
    check_deps
    or note "linking anyway — the configs for the missing pieces are harmless on their own"
    echo
    ensure_nvidia
    ensure_asus
    ensure_power_profile
    ensure_rust
    ensure_coat
    ensure_services
    ensure_systemd_extras
    ensure_resolved
    ensure_autologin
end

command -q stow
or die "GNU Stow is missing:  sudo pacman -S stow"

# --- uninstall ----------------------------------------------------------------

if set -q _flag_uninstall
    step "Removing links..."
    set -l out (stow_run -D)
    if test $status -ne 0
        printf '%s\n' $out >&2
        die "stow -D failed"
    end
    ok (plural (count (string match -r '^UNLINK' -- $out)) link links)" removed"
    exit 0
end

# --- plan ---------------------------------------------------------------------

step "Planning..."
set -l plan (stow_run -n --restow)
set -l bad (conflicts_in $plan)

if test (count $bad) -gt 0
    note (plural (count $bad) target targets)" already exist and are not ours:"
    for f in $bad
        dim "~/$f"
    end
    echo

    set -l how
    if set -q _flag_adopt
        set how adopt
    else if set -q _flag_backup
        set how backup
    else if isatty stdin
        read -P "  [b]ack them up · [a]dopt them into the repo · [q]uit? " -l answer
        switch (string lower -- (string trim -- $answer))
            case b backup ''; set how backup
            case a adopt; set how adopt
            case '*'; die "nothing done"
        end
        echo
    else
        die "no terminal to ask on — re-run with --backup or --adopt"
    end

    if test $how = backup
        set -l stash $target/.dotfiles-backup/(date +%Y%m%d-%H%M%S)
        step "Backing up to "(string replace $HOME '~' $stash)
        for f in $bad
            mkdir -p (path dirname $stash/$f)
            mv -- $target/$f $stash/$f; or die "could not move ~/$f"
            dim "~/$f"
        end
        set plan (stow_run -n --restow)
    else
        step "Adopting..."
        stow_run --adopt --restow >/dev/null
        or die "stow --adopt failed"
        note 'the repo now holds those files\' contents — run git diff in it'
        set plan (stow_run -n --restow)
    end

    set bad (conflicts_in $plan)
    test (count $bad) -eq 0
    or begin
        printf '%s\n' $plan >&2
        die "still conflicting — resolve the paths above by hand"
    end
    echo
end

if set -q _flag_dry_run
    ok (plural (count (link_paths $plan)) link links)" to create, nothing conflicting"
    if set -q _flag_verbose
        for l in (link_paths $plan); dim "~/$l"; end
    end
    if set -q _flag_minecraft
        dim "would fetch "(count < $repo/minecraft/mods.txt)" mods into ~/.local/share/PrismLauncher/instances/1.8.9"
    end
    exit 0
end

# --- link ---------------------------------------------------------------------

step "Linking..."
set -l out (stow_run --restow)
set -l rc $status
if test $rc -ne 0
    printf '%s\n' $out >&2
    die "stow exited $rc"
end

set -l links (link_paths $out)

if set -q _flag_verbose
    for l in $links; dim "~/$l"; end
else
    # One line per top-level entry, so 60 links read as four numbers.
    set -l seen
    set -l counts
    for l in $links
        set -l top (string split -m1 / -- $l)[1]
        set -l i (contains -i -- $top $seen); or set i ''
        if test -n "$i"
            set counts[$i] (math $counts[$i] + 1)
        else
            set -a seen $top; set -a counts 1
        end
    end
    for i in (seq (count $seen))
        dim (printf '%-28s %s' $seen[$i] $counts[$i])
    end
end
ok (plural (count $links) link links)
echo

# --- verify -------------------------------------------------------------------

# A plain dry-run over a fully stowed package says nothing at all.  Anything
# left here means the install silently did not take.
step "Verifying..."
set -l left (stow_run -n)
if test (count $left) -gt 0
    printf '%s\n' $left >&2
    die "some targets did not get linked (above)"
end
ok "every target resolves into the repo"
echo

# --- minecraft ----------------------------------------------------------------

# Opt-in: ~40M of jars off the network, which nobody wants as a side effect of
# linking their dotfiles. Mods only — make the instance in Prism yourself.
if set -q _flag_minecraft
    set -l mods $target/.local/share/PrismLauncher/instances/1.8.9/minecraft/mods

    # If ~/.local did not exist, stow folded it into a symlink at this repo, and
    # writing "into $HOME" here would drop 40M of jars inside the working tree.
    set -l real (path resolve $mods)

    if string match -q "$repo/*" $real
        note "~/.local is a stow fold into the repo — mkdir ~/.local/share first, then rerun"
    else if not command -q wget
        note "wget not found — skipping mods"
    else if count $mods/*.jar >/dev/null
        dim "mods already installed, skipping"
    else
        step "Installing the 1.8.9 mods..."
        mkdir -p $mods

        # These two files are what make the folder an instance -- Prism finds
        # instances by scanning for instance.cfg, so without them the jars sit
        # in a directory no launcher ever reads. Written only when absent, so an
        # instance made in Prism keeps its own settings.
        set -l inst (path dirname (path dirname $mods))
        if not test -f $inst/mmc-pack.json
            echo '{"components":[{"cachedName":"LWJGL 2","dependencyOnly":true,"uid":"org.lwjgl","version":"2.9.4-nightly-20150209"},{"cachedName":"Minecraft","important":true,"uid":"net.minecraft","version":"1.8.9"},{"cachedName":"Forge","uid":"net.minecraftforge","version":"11.15.1.2318"}],"formatVersion":1}' >$inst/mmc-pack.json
        end
        if not test -f $inst/instance.cfg
            # No WrapperCommand on purpose: the display is on the Intel iGPU, so
            # prime-run copies every frame back over PCIe and lands around 2fps.
            printf '%s\n' '[General]' 'ConfigVersion=1.3' 'InstanceType=OneSix' 'name=1.8.9' \
                'OverrideMemory=true' 'MinMemAlloc=3072' 'MaxMemAlloc=3072' >$inst/instance.cfg
            dim "created the instance — Forge 11.15.1.2318, 3G heap"
        end
        # One URL at a time, NOT `wget -i`. With -i a single dead link makes wget
        # exit non-zero, and everything below -- the .index copy, OptiFine, the
        # count -- was skipped for 25 mods that downloaded perfectly well. Three
        # of these URLs had literal spaces in the filename and failed exactly
        # that way, so the whole flag looked broken.
        #
        # --content-disposition is load-bearing: the OptiFine URL is a
        # downloadx?f=... query, and without it wget names the jar after the
        # query string and Forge skips it.
        set -l failed
        for url in (string trim < $repo/minecraft/mods.txt | string match -v -r '^\s*(#|$)')
            wget -q -P $mods --content-disposition $url
            or set -a failed (string split / $url)[-1]
        end
        if test (count $failed) -gt 0
            note (count $failed)" mod(s) failed: $failed"
        end
        begin
            cp -r $repo/minecraft/.index $mods/

            # OptiFine is not in mods.txt: optifine.net hands out a downloadx
            # token that rotates, and a stale one answers 200 with a 19-byte
            # "Request not found." body -- wget would cheerfully save that as
            # the jar. Scrape a fresh token, then check for the zip magic.
            set -l of $mods/OptiFine_1.8.9_HD_U_L5.jar
            # A bare curl gets refused, and the link is single-quoted.
            set -l ua "Mozilla/5.0"
            set -l href (curl -sf -A $ua "https://optifine.net/adloadx?f=OptiFine_1.8.9_HD_U_L5.jar" \
                | string match -rg "(downloadx\\?f=OptiFine_1\\.8\\.9_HD_U_L5[^'\"]*)" | head -1)
            if test -n "$href"
                curl -sfL -A $ua -o $of "https://optifine.net/$href"
            end
            if test -f $of; and test (head -c2 $of) = PK
                dim "OptiFine L5 fetched"
            else
                rm -f $of
                note "OptiFine failed — grab it from optifine.net and drop it in $mods"
            end

            ok (count $mods/*.jar)" mods installed"
            # 1.8.9 will not start on a modern JRE.
            command -q java; or note "no java found — 1.8.9 needs Java 8 (zulu-8-bin)"
        end
    end
end

# --- theme --------------------------------------------------------------------

if set -q _flag_no_coat
    dim "coat skipped"
else if command -q coat
    step "Applying coat theme..."
    coat apply; or note "coat apply failed — theme not written"
else
    note "coat not found, theme skipped — https://github.com/jeebuscrossaint/coat"
end

contains -- $target/.local/bin $PATH
or note "~/.local/bin is not on PATH — the scripts in it will not be found"

# The compositor puts ~/.local/bin ahead of ~/.cargo/bin, so a stale copy there
# wins. That is how an August build of coat kept re-theming everything except
# the shell for a whole day.
if test -f $target/.local/bin/coat
    note "stale $target/.local/bin/coat shadows ~/.cargo/bin/coat under the compositor — delete it"
end

# The todo widget reads this and shows an empty card without it.
test -f $target/todo.md
or note "no ~/todo.md — the desktop todo widget will be empty until you make one"

printf '\n%sdone%s — open a new shell to pick it up.\n\n' "$c_ok" "$c_off"
