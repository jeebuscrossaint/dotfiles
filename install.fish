#!/usr/bin/env fish
#
# install.fish — link this repo's configs into $HOME with GNU Stow.
#
# Stow refuses to touch anything if a single target is already a real file, so
# this plans first, resolves the conflicts, then re-plans afterwards to prove the
# links actually landed.

set -g repo (path dirname (path resolve (status filename)))
set -g pkg linux

argparse -X 0 h/help n/dry-run v/verbose b/backup a/adopt y/yes no-coat uninstall c/check skip-checks install-deps t/target= -- $argv
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
#   group | probe | label | tier | pacman | aur | apt | openbsd | hint
#
# probe  cmd:BINARY · font:FAMILY · path:P1 P2 (any one existing is enough)
# tier   req  the installer itself cannot run
#        core something tracked here calls it and breaks without it
#        opt  one feature degrades
#
# Derived from what the tracked configs and ~/.local/bin scripts actually
# invoke — grep before adding a row, and keep the paths in step with the
# probes in start-polkit and hyprland.lua.
set -g dep_table \
    "installer|cmd:stow|stow|req|stow||stow|stow|" \
    "installer|cmd:git|git|core|git||git|git|" \
    "installer|cmd:fish|fish|req|fish||fish|fish|" \
    "compositor|cmd:hyprland|hyprland|core|hyprland||hyprland||https://hyprland.org" \
    "compositor|path:/usr/lib/xdg-desktop-portal-hyprland /usr/libexec/xdg-desktop-portal-hyprland|xdg-desktop-portal-hyprland|core|xdg-desktop-portal-hyprland||||" \
    "compositor|path:/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 /usr/libexec/polkit-gnome-authentication-agent-1 /usr/local/libexec/polkit-gnome-authentication-agent-1|polkit agent|core|polkit-gnome||policykit-1-gnome|polkit-gnome|" \
    "desktop|cmd:waybar|waybar|core|waybar||waybar|waybar|" \
    "desktop|cmd:fnott|fnott|core|fnott||fnott|fnott|" \
    "desktop|cmd:fuzzel|fuzzel|core|fuzzel||fuzzel|fuzzel|" \
    "desktop|cmd:awww|awww|core||awww|||" \
    "desktop|cmd:hypridle|hypridle|core|hypridle||||" \
    "desktop|cmd:hyprlock|hyprlock|core|hyprlock||||" \
    "desktop|cmd:swaylock|swaylock|core|swaylock||swaylock|swaylock|" \
    "terminal|cmd:kitty|kitty|core|kitty||kitty|kitty|" \
    "terminal|cmd:nvim|neovim|core|neovim||neovim|neovim|" \
    "terminal|cmd:lsd|lsd|opt|lsd||lsd|lsd|" \
    "terminal|cmd:bat|bat|opt|bat||bat|bat|" \
    "terminal|cmd:pfetch|pfetch|opt||pfetch-rs|||" \
    "clipboard|cmd:wl-copy|wl-clipboard|core|wl-clipboard||wl-clipboard|wl-clipboard|" \
    "clipboard|cmd:cliphist|cliphist|core|cliphist||||" \
    "clipboard|cmd:wl-clip-persist|wl-clip-persist|opt||wl-clip-persist|||" \
    "clipboard|cmd:grim|grim|core|grim||grim|grim|" \
    "clipboard|cmd:slurp|slurp|core|slurp||slurp|slurp|" \
    "clipboard|cmd:satty|satty|opt|satty||||" \
    "clipboard|cmd:swappy|swappy|opt|swappy||swappy|swappy|" \
    "system|cmd:wpctl|wireplumber|core|wireplumber||wireplumber|wireplumber|" \
    "system|cmd:notify-send|libnotify|core|libnotify||libnotify-bin|libnotify|" \
    "system|cmd:brightnessctl|brightnessctl|core|brightnessctl||brightnessctl|brightnessctl|" \
    "system|cmd:playerctl|playerctl|opt|playerctl||playerctl|playerctl|" \
    "system|cmd:pavucontrol|pavucontrol|opt|pavucontrol||pavucontrol|pavucontrol|" \
    "system|cmd:socat|socat|core|socat||socat|socat|" \
    "system|cmd:jq|jq|core|jq||jq|jq|" \
    "system|cmd:python3|python|core|python||python3|python|" \
    "theme|cmd:cargo|rust toolchain|core|rustup||rustup|rust|https://rustup.rs" \
    "theme|cmd:coat|coat|core|||||cargo install --git https://github.com/jeebuscrossaint/coat" \
    "fonts|font:SFMono Nerd Font|SFMono Nerd Font|core||nerd-fonts-apple|||./install-nerdfonts.sh" \
    "fonts|font:MartianMono Nerd Font|MartianMono Nerd Font|core|||||./install-nerdfonts.sh" \
    "fonts|font:Font Awesome|Font Awesome|core|otf-font-awesome||fonts-font-awesome|font-awesome|" \
    "apps|cmd:btop|btop|opt|btop||btop|btop|" \
    "apps|cmd:mpv|mpv|opt|mpv||mpv|mpv|" \
    "apps|cmd:zathura|zathura|opt|zathura||zathura|zathura|" \
    "apps|cmd:wttrbar|wttrbar|opt||wttrbar|||" \
    "apps|cmd:magick|imagemagick|opt|imagemagick||imagemagick|ImageMagick|" \
    "apps|cmd:broot|broot|opt|broot||broot||" \
    "apps|cmd:prime-run|nvidia-prime|opt|nvidia-prime||||" \
    "mango|cmd:mmsg|mangowm|opt||mangowm|||" \
    "mango|cmd:wlopm|wlopm|opt||wlopm|||" \
    "mango|cmd:foot|foot|opt|foot||foot|foot|"

function pkg_manager
    test (uname -s) = OpenBSD; and echo openbsd; and return
    command -q pacman; and echo pacman; and return
    command -q apt-get; and echo apt; and return
    echo unknown
end

function aur_helper
    for h in paru yay
        command -q $h; and echo $h; and return
    end
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

# Reports what is missing; returns 1 if anything req/core is.
function check_deps
    set -g font_families
    command -q fc-list; and set -g font_families (fc-list : family 2>/dev/null | string split ,)

    set -l pm (pkg_manager)
    set -l aur (aur_helper)
    set -l col 5
    switch $pm
        case apt; set col 7
        case openbsd; set col 8
        case unknown; set col 0
    end

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
            case req; set -a miss_req $label; set rendered[$i] "$rendered[$i]$sep $c_err✗$label$c_off"
            case core; set -a miss_core $label; set rendered[$i] "$rendered[$i]$sep $c_err✗$label$c_off"
            case '*'; set -a miss_opt $label; set rendered[$i] "$rendered[$i]$sep $c_warn✗$label$c_off"
        end

        set -l pkg ''
        test $col -gt 0; and set pkg $f[$col]
        set -l apkg ''
        test $pm = pacman; and set apkg $f[6]

        if test -n "$pkg"
            set -a want_pm $pkg
        else if test -n "$apkg"
            set -a want_aur $apkg
        else if test -n "$f[9]"
            contains -- "$label|$f[9]" $hints; or set -a hints "$label|$f[9]"
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
    if test (count $want_pm) -gt 0
        switch $pm
            case pacman; set -g dep_cmds $dep_cmds "sudo pacman -S --needed $want_pm"
            case apt; set -g dep_cmds $dep_cmds "sudo apt install $want_pm"
            case openbsd; set -g dep_cmds $dep_cmds "doas pkg_add $want_pm"
        end
    end
    if test (count $want_aur) -gt 0
        if test -n "$aur"
            set -g dep_cmds $dep_cmds "$aur -S --needed $want_aur"
        else
            printf '   %s# no AUR helper yet:%s git clone https://aur.archlinux.org/paru-bin.git && cd paru-bin && makepkg -si\n' "$c_warn" "$c_off"
            printf '   %s# then:%s paru -S --needed %s\n' "$c_warn" "$c_off" "$want_aur"
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
    test $pm = pacman; or printf '   %s# package names outside Arch are best-effort — check them%s\n' "$c_dim" "$c_off"
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
    check_deps
    or note "linking anyway — the configs for the missing pieces are harmless on their own"
    echo
end

command -q stow
or die "GNU Stow is missing.  pacman -S stow  ·  apt install stow  ·  pkg_add stow"

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

printf '\n%sdone%s — open a new shell to pick it up.\n\n' "$c_ok" "$c_off"
