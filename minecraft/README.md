# Minecraft mods — 1.8.9 PvP

Forge 11.15.1.2318, Java 8. 31 jars: 28 enabled, 3 disabled.

## Install

    set mods ~/.local/share/PrismLauncher/instances/1.8.9/minecraft/mods
    mkdir -p $mods
    wget -P $mods -i ~/dotfiles/minecraft/mods.txt
    cp -r ~/dotfiles/minecraft/.index $mods/

`mods.txt` is 25 direct Modrinth URLs — the enabled mods that Prism knows how to
fetch. `.index/` is Prism's own metadata, one `.pw.toml` per mod with the
version, sha512 and URL; copying it in makes Prism list them as managed mods and
offer updates instead of showing 25 anonymous jars.

## The three not in the list

No Modrinth entry, so no URL to fetch. Grab these by hand:

| Jar | Where |
|---|---|
| `OptiFine_1.8.9_HD_U_L5.jar` | optifine.net → 1.8.9 → HD U L5 |
| `AutoTip-1.0.0+1.8.9-forge.jar` | Autotip, GitHub releases |
| `MurderMysteryPlus-0.17.0.jar` | Hypixel forums / the mod's own release page |

## The three disabled

In `.index/` (so Prism sees them) but deliberately left out of `mods.txt`:
Better Chat 1.5, OverflowParticles 1.0.2, VanillaHUD 2.2.12 — the OneConfig HUD
replaced that last one. If you ever want them back, the URLs are in their
`.pw.toml`; rename to `.jar.disabled` to keep them off.
