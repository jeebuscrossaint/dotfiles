// coat web-app theming — engine runtime (site-agnostic).
//
// Owns the theme channel to background.js and drives whichever site pack
// registered itself. Only one pack ever loads per page (each pack's manifest
// entry matches just its own site), so a single registry slot is enough.
//
// A pack supplies any of:
//   cssVars(theme, s)    declarative tier -- a map of the SITE'S OWN custom
//                        properties to values. Enough on its own for anything
//                        that themes through CSS variables.
//   apply(theme, s)      full tier -- arbitrary painting, for sites that do not.
//   onColorMode(isDark)  flip the site's own light/dark setting.

const CoatTheme = {
  _pack: null,
  _lastKey: null,   // JSON of the last applied theme; de-dups repeat pushes
  _lastIsDark: null, // onColorMode fires only on a light<->dark crossing
  _pending: null,
  current: null,    // { theme, surfaces } -- packs read this for re-paints

  register(pack) {
    this._pack = pack;
    // Packs load in a separate content-script entry from the engine, so a theme
    // can land in the gap before the pack registers -- in which case apply()
    // has already run pack-less and armed the de-dup key. Replay it.
    if (this.current) {
      this._lastKey = null;
      this.apply(this.current.theme);
    } else if (this._pending) {
      const t = this._pending;
      this._pending = null;
      this.apply(t);
    }
  },

  // Re-run the current theme past the de-dup guard. Packs call this when the
  // site has clobbered their paint.
  reapply() {
    if (!this.current) return;
    this._lastKey = null;
    this.apply(this.current.theme);
  },

  apply(theme) {
    if (!theme || !theme.bg) return;
    if (!this._pack) {
      this._pending = theme;
      return;
    }
    const surfaces = deriveSurfaces(theme);
    if (!surfaces) return;

    const key = JSON.stringify(theme);
    if (key === this._lastKey) return;
    this._lastKey = key;
    this.current = { theme, surfaces };

    const isDark = surfaces.isDark;
    document.documentElement.style.colorScheme = isDark ? "dark" : "light";
    // Tells the MAIN-world matchMedia shim what to report, so a site set to
    // "follow the system" follows the scheme instead.
    document.dispatchEvent(
      new CustomEvent("coat:set-color-scheme", { detail: { dark: isDark } })
    );

    if (this._lastIsDark !== isDark) {
      this._lastIsDark = isDark;
      if (this._pack.onColorMode) this._pack.onColorMode(isDark, theme, surfaces);
    }

    if (this._pack.cssVars) {
      // Defined on EVERY element, not just :root. Sites commonly redefine their
      // theme tokens on a wrapper below <html>, which shadows a root-level
      // value for the entire subtree that matters. An author-!important
      // declaration on each element beats the site's own non-important
      // definitions wherever they live, with no selector knowledge needed.
      const vars = this._pack.cssVars(theme, surfaces) || {};
      let css = "html, html * {";
      for (const [name, value] of Object.entries(vars)) {
        if (value == null) continue;
        css += `${name}: ${value} !important;`;
      }
      css += "}";
      let style = document.getElementById("coat-webapp-vars");
      if (!style) {
        style = document.createElement("style");
        style.id = "coat-webapp-vars";
        (document.head || document.documentElement).appendChild(style);
      }
      style.textContent = css;
    }

    if (this._pack.apply) this._pack.apply(theme, surfaces);
  },
};

// One long-lived port to background.js. It answers with the current theme as
// soon as it is opened and pushes every later one down the same channel, so
// there is no separate fetch-on-load path to keep in step.
//
// browser.* first: Firefox's chrome.* is callback-based, Chrome's is not.
const api = globalThis.browser ?? globalThis.chrome;

function connectBackground() {
  let port;
  try {
    port = api.runtime.connect({ name: "coat" });
  } catch (_) {
    // Extension reloading or shutting down; try again shortly.
    setTimeout(connectBackground, 1000);
    return;
  }
  port.onMessage.addListener((msg) => {
    if (msg && msg.type === "coat-theme") CoatTheme.apply(msg.theme);
  });
  // The service worker is torn down when idle and on every extension reload.
  // Reconnecting is what makes a long-lived tab keep receiving themes instead
  // of going stale the first time that happens.
  port.onDisconnect.addListener(() => setTimeout(connectBackground, 1000));
}

connectBackground();
