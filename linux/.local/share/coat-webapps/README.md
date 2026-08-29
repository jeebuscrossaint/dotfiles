# coat-webapps

Make websites follow the active coat scheme, live. Modelled on
[omarchy-webapp-theme](https://github.com/scottjones/omarchy-webapp-theme) (MIT);
the matchMedia shim is adapted from it, the rest is written against coat.

## How it hangs together

    coat apply  ──writes──▶  ~/.local/state/coat/manifest.json
                                     │ inotify
                                     ▼
                         ~/.local/bin/coat-webapp-host   (native messaging)
                                     │ length-prefixed JSON on stdout
                                     ▼
                            background.js (service worker)
                                     │ chrome.tabs.sendMessage
                                     ▼
                     coat-runtime.js ──▶ site pack ──▶ CSS custom properties

The host reads the scheme coat.yaml pins, resolving it the same way coat does
(`prefer_base24` picks base24 → base16 → generated). It is push-only: it emits
on connect and on every apply, and never parses anything the browser sends.

`manifest.json` is the trigger because coat has no hook system and rewrites that
file on every apply however it was invoked — `coat set`, `coat match`, or the
awww wrapper retheming from a new wallpaper.

## Loading it

Chromium 137+ disabled `--load-extension`, so it goes in by hand once:

    chrome://extensions → Developer mode → Load unpacked
    → ~/.local/share/coat-webapps/extension

The extension ID is pinned by the `key` in its manifest, so it stays
`miifgcafnndcmaijinhnahgejmaplegb` across reloads and the native-messaging
manifest keeps matching it.

Set each site's own appearance to follow the system (Discord: Appearance →
Theme → Sync with computer; GitHub: Appearance → Theme mode → Sync with system).
The MAIN-world shim makes "the system" mean coat.

## Adding a site

Write `<name>.js` calling `CoatTheme.register({ id, cssVars })`, returning a map
of *that site's own* CSS custom properties. Then add it to `SITES` and
regenerate the manifest. Enumerate the tokens in devtools:

    getComputedStyle(document.documentElement)  // then filter for --

Surfaces available on the `s` argument are defined in `coat-surfaces.js`.
Semantic slots (`s.red`, `s.green`, …) come straight from the scheme — use them
literally rather than re-deriving a hue from the accent.

## Firefox

Needs Developer Edition: release Firefox refuses unsigned add-ons outright, and
`xpinstall.signatures.required` is only honoured on Developer/Nightly/ESR.

    about:config → xpinstall.signatures.required = false
    ./build-xpi.py
    about:addons → gear → Install Add-on From File → coat-webapps.xpi

`about:debugging`'s "Load Temporary Add-on" also works but is gone on restart,
which is why the xpi exists at all.

Then grant it access to the sites: about:addons → coat web app theme →
Permissions. Firefox MV3 makes host permissions OPTIONAL, so without this the
content scripts never run.

The two browsers need slightly different manifests — Chromium pins its
extension id with `key` and runs a service worker; Firefox identifies by
`browser_specific_settings.gecko.id` and has no MV3 service worker. Rather than
carry both sets of keys and have each browser warn about the other's,
`extension/manifest.json` is the Chromium one and `build-xpi.py` transforms it
on the way into the archive.

### Before stowing on a fresh machine

    mkdir -p ~/.mozilla/native-messaging-hosts

stow FOLDS a directory that does not exist in the target: rather than linking
the one file inside it, it symlinks the whole `~/.mozilla` to the repo. Firefox
then builds its entire profile — history, cookies, cache, sessionstore — inside
the git tree on first launch. Pre-creating the directory makes stow link just
the leaf.

### Where Firefox looks for the native-messaging manifest

Firefox 155 on this machine uses XDG paths: its root is `~/.config/mozilla/`,
not `~/.mozilla/` — profiles live in `~/.config/mozilla/firefox/`. So the
manifest has to be at

    ~/.config/mozilla/native-messaging-hosts/com.coat.webapp_theme.json

The traditional `~/.mozilla/native-messaging-hosts/` path is stowed as well,
since a build without the XDG migration still reads that one and an unused
manifest is inert. If the host is not spawning, check which of the two that
Firefox actually reads before assuming the extension is at fault.
