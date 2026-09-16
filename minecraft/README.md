# Minecraft mods — 1.8.9 PvP

Forge 11.15.1.2318, Java 8. Polyfrost/OneConfig stack plus OptiFine.

## Install

    ./install.fish --minecraft

Creates the instance if it isn't there (Forge 11.15.1.2318 on 1.8.9, 3G heap),
fetches the mods, and leaves an instance Prism picks up on next start. Safe to
run against an instance you made yourself — it only writes `instance.cfg` and
`mmc-pack.json` when they're absent, and skips entirely if jars are present.

By hand, minus OptiFine:

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

**OptiFine** is deliberately not in `mods.txt`. optifine.net puts an ad page in
front of the jar and the real file sits behind a `downloadx?f=...&x=<token>` URL
whose token rotates within minutes. A stale token does not 404 — it answers
`200` with a 19-byte `Request not found.` body, which wget saves as the jar
without complaint, so you end up one mod short and no error. `install.fish`
scrapes a fresh token from the ad page instead and checks the result starts with
the `PK` zip magic before keeping it. That needs a browser User-Agent; a bare
curl gets refused.

**AutoTip** is the Modrinth release of `1.0.0+1.8.9-forge`, which is the same
build that was installed by hand. Nothing special about it now.

## Left out

Three jars sit in `.index/` but stay out of `mods.txt` because they're disabled
on disk as `.jar.disabled`: Better Chat 1.5, OverflowParticles 1.0.2, VanillaHUD
2.2.12 — the OneConfig HUD replaced that last one. Their URLs are in their
`.pw.toml` if you want them back.

MurderMysteryPlus 0.17.0 is installed but not tracked.
