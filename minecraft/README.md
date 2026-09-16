# Minecraft — 1.8.9 PvP instance

PrismLauncher instance `1.8.9`: Forge 11.15.1.2318, LWJGL 2.9.4, Java 8 (Zulu),
3G fixed heap. Lives at `~/.local/share/PrismLauncher/instances/1.8.9`.

## What's tracked, and what isn't

Only source: the things that are hand-set or written by a mod's settings GUI.

| Tracked | |
|---|---|
| `instance.cfg`, `mmc-pack.json` | loader versions, JVM args, heap, java path |
| `minecraft/options.txt`, `optionsof.txt`, `optionsshaders.txt` | vanilla + OptiFine video/control settings |
| `minecraft/config/` | Forge-era mod configs |
| `minecraft/OneConfig/config/` | every Polyfrost mod's settings — the HUD layout lives here |
| `minecraft/mods/.index/` | packwiz metadata: name, version, sha512 and download URL per mod |
| `minecraft/servers.dat` | server list |
| `minecraft/tabstats/config.json`, `essential/config.toml` | |

Not tracked, and why: the jars (41M, and `.index/` already reproduces them),
`essential/` and `OneConfig/` runtime downloads (92M of caches and libraries),
`saves/` (24M), `resourcepacks/` (286M), plus logs, crash reports, hs_err dumps,
screenshots and `usercache.json`.

`config/creamykeys_keyboards/` is excluded too — 2.3M of keypress `.ogg` samples
that ship with the mod. Shipped assets, not settings.

## Syncing

    ./sync.fish pull    # live instance -> repo, after changing settings in-game
    ./sync.fish push    # repo -> live instance, on a fresh box
    ./sync.fish diff    # what pull would change

Copies rather than stow-symlinks: several of these mods rewrite their config on
exit as write-tmp-then-rename, which replaces a symlink with a real file. A
symlinked tree silently stops tracking after one play session.

## Rebuilding the mods folder

28 of the 34 jars have a `.index/*.pw.toml` entry carrying a Modrinth URL and a
sha512. `packwiz` is the tool that reads them, or Prism re-downloads them itself
when it imports the instance.

These six were dropped in by hand and have no index entry — they need fetching
from source:

| Jar | Source |
|---|---|
| `OptiFine_1.8.9_HD_U_L5.jar` | optifine.net, 1.8.9 HD U L5 |
| `AutoTip-1.0.0+1.8.9-forge.jar` | Autotip |
| `MurderMysteryPlus-0.17.0.jar` | |
| `betterchat-1.5-for-1.8.9.jar` | **disabled** |
| `OverflowParticles-1.8.9-forge-1.0.2.jar` | **disabled** |
| `VanillaHUD-1.8.9-forge-2.2.12.jar` | **disabled** — superseded by the OneConfig HUD |

The three marked disabled are `.jar.disabled` on disk; keep them off unless you
want them back.

## Resource packs

`resourcepacks.sha256` carries the names and hashes of all nine packs. It cannot
rebuild them — they were dropped in by hand with no recorded source URL, and
286M of zips does not belong in a git repo. `§4minemanner pack` is the one
actually selected in `options.txt`. Back the folder up separately.

## Trap: `WrapperCommand=prime-run`

`instance.cfg` still sets `WrapperCommand=prime-run`. On this machine the
display is wired to the Intel iGPU, so forcing the 4070 means every frame gets
copied back across PCIe — it runs at roughly 2fps, not faster. Clear the wrapper
command and let it render on the iGPU.
