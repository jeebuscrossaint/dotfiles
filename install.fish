#!/usr/bin/env fish
#
# install.fish — link this repo's configs into $HOME with GNU Stow.
#
# Stow refuses to touch anything if a single target is already a real file, so
# this plans first, resolves the conflicts, then re-plans afterwards to prove the
# links actually landed.

set -g repo (path dirname (path resolve (status filename)))
set -g pkg linux

argparse -X 0 h/help n/dry-run v/verbose b/backup a/adopt y/yes no-coat uninstall t/target= -- $argv
or exit 2

if set -q _flag_help
    printf '%s\n' "usage: install.fish [options]

  -n, --dry-run    show what would change, touch nothing
  -b, --backup     move conflicting files aside instead of asking
  -a, --adopt      absorb conflicting files INTO the repo (git diff afterwards)
  -y, --yes        never prompt; implies --backup
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

command -q stow
or die "GNU Stow is missing.  pacman -S stow  ·  apt install stow  ·  pkg_add stow"
test -d $repo/$pkg
or die "no '$pkg' package in $repo — is this the dotfiles repo?"
test -w $target
or die "$target is not writable"

printf '\n%sdotfiles%s  %s → %s\n' "$c_step" "$c_off" (string replace $HOME '~' $repo) (string replace $HOME '~' $target)
dim (stow --version | string collect)
echo

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
