# Minecraft

One instance: **1.8.9 PvP**, Forge 11.15.1.2318 on Java 8, in PrismLauncher.
Only the mods are tracked — [`minecraft/mods.txt`](minecraft/mods.txt) plus
Prism's `.index` metadata — one `wget -i` rebuilds the whole mods folder, no
manual downloads. [`minecraft/README.md`](minecraft/README.md) has the command.
Settings, saves and resource packs are not in the repo.

## Modlist

Mostly Polyfrost/OneConfig, plus OptiFine. `mods.txt` installs all 27 of these;
the three disabled jars below are in `.index` only.

| Mod | Version |
|---|---|
| 3D Skin Layers | 1.2.0 |
| Animatium Legacy (OverflowAnimations) | 2.2.5 |
| ArmorHUD | 1.1 |
| Autotip | 1.0.0 |
| BehindYou (SnapLook) | 3.2.2 |
| Canelex Keystrokes Revamp | 1.0.0 |
| Chatting | 2.0.6 |
| ColorSaturation | 1.0.0 |
| CrashPatch | 2.0.2 |
| DamageTint | 3.3.0 |
| Essential | forge_1.8.9 |
| GlintColorizer | 2.0.1 |
| Hytils Reborn | 1.7.5 |
| Lunar Block Overlay | 2.1.0 |
| No Hurt Cam | 1.0.0 |
| OneConfig | 0.2.2 (+bootstrap 1.0.3) |
| OptiFine | 1.8.9 HD U L5 |
| Patcher (PolyPatcher) | 1.10.4 |
| PolyBlur | 1.0.2 |
| PolyCrosshair | 1.0.3 |
| PolyHitbox | 1.0.3 |
| PolyNametag | 1.0.10 |
| PolySprint | 1.0.2 |
| PolyTime | 1.0.2 |
| PolyWeather | 1.0.0 |
| TabStats | 1.3.0 |
| TNT Countdown | 1.4.1-alpha |
| Wavey Capes | 1.2.0 |

Disabled, kept on disk as `.jar.disabled`: Better Chat 1.5, OverflowParticles
1.0.2, VanillaHUD 2.2.12 (the OneConfig HUD replaced it).
