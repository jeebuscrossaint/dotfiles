#!/usr/bin/env fish
# Copy the PvP instance's SOURCE files between PrismLauncher and this repo.
#
# Not stow: mods rewrite their config on exit, and several do it as
# write-tmp-then-rename, which replaces a symlink with a real file. Copying is
# the only thing that survives a play session.

set -l instance 1.8.9
set -l live ~/.local/share/PrismLauncher/instances/$instance
set -l repo (realpath (dirname (status filename)))/$instance

# Everything here is either hand-set or rewritten by a mod's settings GUI.
# Jars, assets, saves, caches and logs are all excluded: see README.md.
set -l paths \
    instance.cfg \
    mmc-pack.json \
    minecraft/options.txt \
    minecraft/optionsof.txt \
    minecraft/optionsshaders.txt \
    minecraft/servers.dat \
    minecraft/config/ \
    minecraft/OneConfig/config/ \
    minecraft/tabstats/config.json \
    minecraft/essential/config.toml \
    minecraft/mods/.index/

# creamykeys ships 2.3M of keypress .ogg samples under config/ -- shipped
# assets, not settings. patcher/ is a resolved-entrypoint cache.
set -l excludes --exclude 'creamykeys_keyboards/' --exclude '*.bak' --exclude '*.bak-*'

function usage
    echo "usage: sync.fish pull|push|diff"
    echo "  pull   live instance -> repo   (after changing settings in-game)"
    echo "  push   repo -> live instance   (on a fresh box, or to revert)"
    echo "  diff   show what pull would change"
end

set -l mode $argv[1]
set -l flags
switch "$mode"
    case pull push
        set flags -a --delete
    case diff
        set flags -a --delete -n -i
    case '*'
        usage
        exit 1
end

if not test -d $live
    echo "no instance at $live" >&2
    exit 1
end

for p in $paths
    set -l from $live/$p
    set -l to $repo/$p
    if test "$mode" = push
        set from $repo/$p
        set to $live/$p
    end
    # A path listed here can legitimately not exist yet (a mod never opened its
    # GUI). Skip instead of letting rsync error the whole run.
    test -e (string trim -r -c / $from); or continue
    mkdir -p (dirname $to)
    rsync $flags $excludes $from $to
end

# The packs are 286M of zips with no download URLs -- unreproducible, so the
# repo carries their names and hashes and nothing else.
if test "$mode" != push
    set -l packs $live/minecraft/resourcepacks
    if test -d $packs
        pushd $packs
        sha256sum *.zip 2>/dev/null >$repo/../resourcepacks.sha256
        popd
    end
end
