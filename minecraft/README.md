# Minecraft — 1.8.9 PvP instance

PrismLauncher instance `1.8.9`: Forge 11.15.1.2318, LWJGL 2.9.4, Java 8 (Zulu),
3G fixed heap. Lives at `~/.local/share/PrismLauncher/instances/1.8.9`.

## Reinstalling the mods

    set mods ~/.local/share/PrismLauncher/instances/1.8.9/minecraft/mods
    mkdir -p $mods
    wget -P $mods -i ~/dotfiles/minecraft/mods.txt

That's 28 of the 34 jars. `1.8.9/minecraft/mods/.index/` is the same list in
packwiz form — Prism's own metadata, one `.pw.toml` per mod carrying the version,
the sha512 and the URL. Copy it next to the jars and Prism can update them from
its mod page. `mods.txt` is just those URLs pulled out flat.

Six were dropped in by hand and aren't in either list:

| Jar | |
|---|---|
| `OptiFine_1.8.9_HD_U_L5.jar` | optifine.net, 1.8.9 HD U L5 |
| `AutoTip-1.0.0+1.8.9-forge.jar` | |
| `MurderMysteryPlus-0.17.0.jar` | |
| `betterchat-1.5-for-1.8.9.jar` | **disabled** |
| `OverflowParticles-1.8.9-forge-1.0.2.jar` | **disabled** |
| `VanillaHUD-1.8.9-forge-2.2.12.jar` | **disabled** — the OneConfig HUD replaced it |

Rename the disabled three to `.jar.disabled` or just don't install them.

## Settings

A snapshot, kept because it's small and dropping it loses the HUD layout. Copy
it back by hand; there's nothing to run.

    cp -r 1.8.9/. ~/.local/share/PrismLauncher/instances/1.8.9/

`instance.cfg` and `mmc-pack.json` (loader versions, JVM args, heap, java path),
`options.txt` / `optionsof.txt` / `optionsshaders.txt`, `servers.dat`, the Forge
`config/` tree, and `OneConfig/config/` — that last one holds every Polyfrost
mod's settings, including the HUD layout.

Excluded: the jars, `essential/` and `OneConfig/` runtime caches (92M), `saves/`,
`resourcepacks/` (286M), logs, crash reports, screenshots, and
`config/creamykeys_keyboards/` (2.3M of keypress samples that ship with the mod).

To re-snapshot after changing settings in-game, copy the same paths back the
other way.

## Resource packs

`resourcepacks.sha256` is names and hashes for the nine packs, so you can check a
backup. It can't rebuild them — they came in by hand with no source URL, and 286M
of zips doesn't belong in git. `§4minemanner pack` is the one selected in
`options.txt`.

Regenerate after adding a pack:

    cd ~/.local/share/PrismLauncher/instances/1.8.9/minecraft/resourcepacks
    sha256sum *.zip >~/dotfiles/minecraft/resourcepacks.sha256

## Trap: `WrapperCommand=prime-run`

`instance.cfg` sets `WrapperCommand=prime-run`. The display is wired to the Intel
iGPU, so forcing the 4070 copies every frame back over PCIe — about 2fps. Clear
it and let it render on the iGPU.
