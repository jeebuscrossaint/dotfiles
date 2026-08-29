#!/usr/bin/env python3
"""Regenerate extension/manifest.json. Run after adding a site pack."""
import json, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
EXT = os.path.join(HERE, "extension")

# This file emits the CHROMIUM manifest. build-xpi.py transforms it for Firefox
# on the way into the archive -- carrying both browsers' keys in one file means
# each one warns about the other's, and the warnings are not harmless-looking.
# Pinned so the extension ID stays put across reloads and the Chromium
# native-messaging manifest's allowed_origins keeps matching it.
KEY = open(os.path.join(HERE, "chromium-key.txt")).read().strip()

# name -> match patterns. Add a pack here, then rerun this.
SITES = {
    "discord": ["*://discord.com/*"],
    "github": ["*://github.com/*", "*://gist.github.com/*"],
    "outlook": [
        "*://outlook.office.com/*",
        "*://outlook.office365.com/*",
        "*://outlook.live.com/*",
        "*://outlook.cloud.microsoft/*",
    ],
    "teams": [
        "*://teams.microsoft.com/*",
        "*://teams.live.com/*",
        "*://teams.cloud.microsoft/*",
    ],
}

all_matches = [m for v in SITES.values() for m in v]

manifest = {
    "manifest_version": 3,
    "name": "coat web app theme",
    "version": "0.1.0",
    "description": "Make web apps follow the active coat scheme: palette, accent, and light/dark.",
    "key": KEY,
    "permissions": ["nativeMessaging", "storage"],
    "host_permissions": all_matches,
    "background": {"service_worker": "background.js"},
    "content_scripts": [
        # MAIN world, so the page's own matchMedia is the one we replace.
        # Firefox supports world:MAIN from 128.
        {"matches": all_matches, "js": ["inject-prefers-color-scheme.js"],
         "run_at": "document_start", "all_frames": False, "world": "MAIN"},
        # The engine. One entry, so these three share a scope.
        {"matches": all_matches,
         "js": ["coat-colors.js", "coat-surfaces.js", "coat-fluent.js", "coat-runtime.js"],
         "run_at": "document_start", "all_frames": False},
    ] + [
        {"matches": m, "js": ["%s.js" % name], "run_at": "document_start", "all_frames": False}
        for name, m in SITES.items()
    ],
}

with open(os.path.join(EXT, "manifest.json"), "w") as fh:
    fh.write(json.dumps(manifest, indent=2) + "\n")
print("wrote manifest.json for:", ", ".join(SITES))
