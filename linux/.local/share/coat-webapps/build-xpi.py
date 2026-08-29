#!/usr/bin/env python3
"""Pack extension/ into coat-webapps.xpi.

Firefox has no persistent "load unpacked": about:debugging's temporary add-on is
gone on restart. A plain zip installed from about:addons does persist -- which
needs xpinstall.signatures.required=false, hence Developer Edition.

Chromium does not use this file; it loads extension/ directly.
"""
import json
import os
import sys
import zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
EXT = os.path.join(HERE, "extension")
OUT = os.path.join(HERE, "coat-webapps.xpi")

# Must match allowed_extensions in
# ~/.mozilla/native-messaging-hosts/com.coat.webapp_theme.json.
GECKO_ID = "coat-webapps@amarnath"

# Firefox-only background scope: theming the browser chrome needs the surface
# derivation in the background context, not just in content scripts.
BACKGROUND_SCRIPTS = [
    "coat-colors.js",
    "coat-surfaces.js",
    "coat-firefox-theme.js",
    "background.js",
]

SRC_MANIFEST = os.path.join(EXT, "manifest.json")
if not os.path.isfile(SRC_MANIFEST):
    sys.exit("no manifest.json in %s -- run make-manifest.py first" % EXT)


def firefox_manifest(m):
    """Chromium manifest -> Firefox manifest.

    Three differences, each of which is a load-time warning in the other
    browser if left in place:
      - `key` pins the Chromium extension id and means nothing to Firefox.
      - Firefox has no MV3 service worker; background scripts run as an event
        page instead.
      - Firefox identifies an extension by browser_specific_settings.gecko.id,
        which the native-messaging manifest allow-lists by name.
    """
    m = json.loads(json.dumps(m))  # don't mutate the caller's copy
    m.pop("key", None)
    m["browser_specific_settings"] = {
        "gecko": {"id": GECKO_ID, "strict_min_version": "128.0"}
    }
    sw = m.get("background", {}).get("service_worker")
    if sw:
        # Firefox loads these in order into one shared global, so the theme
        # module and the colour helpers it needs must come before background.js.
        # Chromium's single service_worker entry cannot express this, which is
        # the other reason the two manifests are separate.
        m["background"] = {"scripts": BACKGROUND_SCRIPTS}
    # browser.theme.update() is what makes the chrome repaint live; Chromium has
    # no equivalent, so the permission would only be an unknown-key warning there.
    m["permissions"] = sorted(set(m.get("permissions", [])) | {"theme"})
    return m


manifest = firefox_manifest(json.load(open(SRC_MANIFEST)))

with zipfile.ZipFile(OUT, "w", zipfile.ZIP_DEFLATED) as z:
    # manifest.json has to sit at the archive ROOT, not under extension/.
    z.writestr("manifest.json", json.dumps(manifest, indent=2) + "\n")
    for root, _dirs, files in os.walk(EXT):
        for f in sorted(files):
            if f == "manifest.json":
                continue  # replaced by the transformed one above
            full = os.path.join(root, f)
            z.write(full, os.path.relpath(full, EXT))

print("wrote %s (%d bytes)" % (OUT, os.path.getsize(OUT)))
