// Runs in the page's MAIN world at document_start.
//
// Spoofs window.matchMedia('(prefers-color-scheme: ...)') so a site left on
// "sync with system" follows the coat scheme rather than the OS. Without this,
// switching between a dark and a light scheme repaints our tokens but leaves
// the site's own logic convinced it is still in the other mode -- which is
// where the mismatched icons and half-inverted panels come from.
//
// Adapted from omarchy-webapp-theme (MIT, Scott Jones).

(function () {
  if (window.__coatPCSInstalled) return;
  window.__coatPCSInstalled = true;

  const orig = window.matchMedia.bind(window);
  let isDark = orig("(prefers-color-scheme: dark)").matches;
  const entries = new Set(); // every change-listener registration, all queries
  const owners = new Set();  // one per MediaQueryList we handed out

  function makeProxy(query) {
    const wantsDark = /dark/i.test(query);
    const wantsLight = /light/i.test(query);
    const target = orig(query);
    // Registrations share one Set, so each has to record which MediaQueryList
    // it came from. Without that, a site that hands the same callback to both
    // the dark and the light query and later detaches one would silently
    // detach the other too. `addListener` is a legacy alias of
    // `addEventListener("change")`, so they share a registration space and
    // either remover cancels either add.
    const owner = {};
    let onchange = null;

    const capOf = (o) => (typeof o === "boolean" ? o : !!(o && o.capture));

    function has(cb, capture) {
      for (const e of entries) {
        if (e.owner === owner && e.cb === cb && e.capture === capture) return true;
      }
      return false;
    }

    function add(cb, options) {
      const capture = capOf(options);
      const usable = typeof cb === "function" || typeof (cb && cb.handleEvent) === "function";
      // Native listeners dedupe on identity; adding twice must not fire twice.
      if (!usable || (options && options.signal && options.signal.aborted) || has(cb, capture)) return;
      const entry = { owner, cb, capture, once: !!(options && options.once), wantsDark, wantsLight };
      entries.add(entry);
      if (options && options.signal) {
        entry.signal = options.signal;
        entry.abort = () => entries.delete(entry);
        entry.signal.addEventListener("abort", entry.abort, { once: true });
      }
    }

    function remove(cb, options) {
      const capture = capOf(options);
      for (const e of Array.from(entries)) {
        if (e.owner !== owner || e.cb !== cb || e.capture !== capture) continue;
        entries.delete(e);
        if (e.signal) e.signal.removeEventListener("abort", e.abort);
      }
    }

    const proxy = new Proxy(target, {
      get(t, prop) {
        if (prop === "matches") {
          if (wantsDark) return isDark;
          if (wantsLight) return !isDark;
          return t.matches;
        }
        if (prop === "media") return query;
        if (prop === "onchange") return onchange;
        if (prop === "addEventListener") {
          return (evt, cb, options) => { if (evt === "change") add(cb, options); };
        }
        if (prop === "removeEventListener") {
          return (evt, cb, options) => { if (evt === "change") remove(cb, options); };
        }
        if (prop === "addListener") return (cb) => add(cb, false);
        if (prop === "removeListener") return (cb) => remove(cb, false);
        if (prop === "dispatchEvent") return (e) => t.dispatchEvent(e);
        const v = t[prop];
        return typeof v === "function" ? v.bind(t) : v;
      },
      set(t, prop, value) {
        if (prop === "onchange") {
          onchange = typeof value === "function" ? value : null;
          return true;
        }
        t[prop] = value;
        return true;
      },
    });

    // onchange handlers hang off the proxy, so the notifier needs a way back.
    Object.defineProperty(owner, "fire", {
      value: (event) => { if (onchange) { try { onchange.call(proxy, event); } catch (_) {} } },
    });
    Object.defineProperty(owner, "proxy", { value: proxy });
    Object.defineProperty(owner, "wantsDark", { value: wantsDark });
    Object.defineProperty(owner, "wantsLight", { value: wantsLight });
    owners.add(owner);
    return proxy;
  }

  window.matchMedia = function (query) {
    const q = String(query);
    if (/prefers-color-scheme/i.test(q)) return makeProxy(q);
    return orig(q);
  };

  function notify() {
    // Snapshot first: a handler may add or remove listeners while we iterate.
    for (const owner of Array.from(owners)) {
      const matches = owner.wantsDark ? isDark : owner.wantsLight ? !isDark : false;
      const event = { matches, media: owner.proxy.media, type: "change", target: owner.proxy };
      owner.fire(event);
    }
    for (const e of Array.from(entries)) {
      if (!entries.has(e)) continue;
      const matches = e.wantsDark ? isDark : e.wantsLight ? !isDark : false;
      const event = { matches, media: e.owner.proxy.media, type: "change", target: e.owner.proxy };
      if (e.once) {
        entries.delete(e);
        if (e.signal) e.signal.removeEventListener("abort", e.abort);
      }
      try {
        if (typeof e.cb === "function") e.cb.call(e.owner.proxy, event);
        else e.cb.handleEvent(event);
      } catch (_) {}
    }
  }

  document.addEventListener("coat:set-color-scheme", (e) => {
    const next = !!(e && e.detail && e.detail.dark);
    if (next === isDark) return;
    isDark = next;
    notify();
  });
})();
