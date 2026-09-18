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
(the `base24` flag in coat’s state file picks base24 → base16 → generated). It is push-only: it emits
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
    about:addons → gear → Install Add-on From File → coat-webapps.xpi

(`coat apply webapps` has already built the xpi; `./build-xpi.py` does it alone.)

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

### On a fresh machine

    coat apply webapps

That is the whole setup. coat's `webapps` module writes the native-messaging
manifests and builds the xpi; then install the xpi in Firefox once (below).

None of this is stowed, and that is deliberate. A native-messaging manifest
carries an ABSOLUTE path to the host program, so a tracked copy is correct on
exactly one machine — on any other, Firefox silently fails to spawn the host and
the extension installs, enables, and themes nothing. They are generated against
the running `$HOME` instead.

It also removes a trap that used to live here: stow FOLDS a directory that does
not exist in the target, so a stowed `~/.mozilla/native-messaging-hosts` meant
symlinking the whole of `~/.mozilla` into the repo, and Firefox building its
profile — history, cookies, cache — inside the git tree on first launch. Nothing
is symlinked there now, so there is nothing to fold.

Both manifest locations are written, because Firefox 155 uses XDG paths
(`~/.config/mozilla/`) while older builds read `~/.mozilla/`, and an unused
manifest is inert. Chromium's `NativeMessagingHosts` is written too, keyed by
extension origin rather than id.

## Firefox's own chrome

`coat-firefox-theme.js` repaints the browser itself — tab strip, toolbar,
urlbar, popups, sidebar — through `browser.theme.update()`, live, with no
restart. It runs in the background context and only ships in the xpi.

This is why the Firefox build has its own background script list: the chrome
theming needs `deriveSurfaces()` in the background scope, which Chromium's
single `service_worker` entry cannot express.

coat's `firefox.tera` (userChrome.css) does the same job statically and needs a
restart per scheme change. Enabling both is redundant — the theme API wins,
since it repaints live and does not need
`toolkit.legacyUserProfileCustomizations.stylesheets`.

**Chromium's chrome cannot be themed this way.** Its browser theme is a packaged
theme extension with no runtime API, so only page content is themed there.
