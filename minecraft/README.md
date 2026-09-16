# Minecraft mods — 1.8.9 PvP

Forge 11.15.1.2318, Java 8. Polyfrost/OneConfig stack plus OptiFine.

## Install

    ./install.fish --minecraft

Or by hand:

    set mods ~/.local/share/PrismLauncher/instances/1.8.9/minecraft/mods
    mkdir -p $mods
    wget -P $mods --content-disposition -i ~/dotfiles/minecraft/mods.txt
    cp -r ~/dotfiles/minecraft/.index $mods/

All 27 mods, no manual steps. Verified: every jar this pulls is byte-identical
to the installed one.

`--content-disposition` is not optional. The OptiFine URL is a `downloadx?f=...`
query, so without it wget names the file after the query string instead of the
jar and Forge ignores it.

`.index/` is Prism's own metadata, one `.pw.toml` per mod with the version,
sha512 and URL. Copying it in makes Prism list them as managed mods with update
buttons rather than 27 anonymous jars.

## Notes on two of the URLs

**OptiFine** has no stable download page link — optifine.net puts an ad
interstitial in front, and the real file sits behind a `downloadx` URL with an
`x=` token. The token in `mods.txt` is checked and serves the correct L5 jar. If
it ever 404s, load `https://optifine.net/adloadx?f=OptiFine_1.8.9_HD_U_L5.jar`
and pull the fresh `downloadx` href out of the page.

**AutoTip** is the Modrinth release of `1.0.0+1.8.9-forge`, which is the same
build that was installed by hand. Nothing special about it now.

## Left out

Three jars sit in `.index/` but stay out of `mods.txt` because they're disabled
on disk as `.jar.disabled`: Better Chat 1.5, OverflowParticles 1.0.2, VanillaHUD
2.2.12 — the OneConfig HUD replaced that last one. Their URLs are in their
`.pw.toml` if you want them back.

MurderMysteryPlus 0.17.0 is installed but not tracked.
