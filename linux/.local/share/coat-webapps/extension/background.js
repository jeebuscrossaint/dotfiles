// Chrome exposes a promise-based chrome.*; Firefox's chrome.* is callback-based
// and its promise API lives on browser.*. Taking browser first gets promises on
// both without a polyfill.
const api = globalThis.browser ?? globalThis.chrome;

const HOST = "com.coat.webapp_theme";

let nativePort = null;
let reconnectTimer = null;
let current = null;
// One long-lived port per themed tab.
//
// The obvious alternative -- tabs.query({url}) + tabs.sendMessage -- needs host
// permissions, and Firefox MV3 makes those OPTIONAL: until the user grants them
// by hand the query comes back empty and every push is silently dropped. Ports
// are initiated by the content script, which is already running, so they need
// no such grant. They also keep the service worker alive while a themed tab is
// open, which the query approach does not.
const clients = new Set();

function broadcast(theme) {
  for (const p of Array.from(clients)) {
    try {
      p.postMessage({ type: "coat-theme", theme });
    } catch (_) {
      clients.delete(p);
    }
  }
}

api.runtime.onConnect.addListener((p) => {
  if (!p || p.name !== "coat") return;
  clients.add(p);
  p.onDisconnect.addListener(() => clients.delete(p));
  // Hand over whatever we already have, so a tab opened between theme changes
  // is painted immediately instead of waiting for the next `coat apply`.
  if (current) {
    try {
      p.postMessage({ type: "coat-theme", theme: current });
    } catch (_) {
      clients.delete(p);
    }
  }
});

function connect() {
  // Reachable from three directions at once -- the module-level call below,
  // onInstalled and onStartup. Without the guard each opens its own port, every
  // port spawns its own native host, and each theme change then arrives N times.
  if (nativePort) return;
  try {
    nativePort = api.runtime.connectNative(HOST);
  } catch (e) {
    console.warn("[coat] connectNative threw:", e);
    scheduleReconnect();
    return;
  }

  nativePort.onMessage.addListener((theme) => {
    if (!theme || !theme.bg) return;
    console.log("[coat] theme pushed:", theme.theme_name, theme.bg);
    current = theme;
    api.storage.local.set({ theme });
    broadcast(theme);
  });

  nativePort.onDisconnect.addListener(() => {
    const err = api.runtime.lastError;
    console.warn("[coat] native host disconnected:", err && err.message);
    nativePort = null;
    scheduleReconnect();
  });

  // Nothing is ever written to the port: the host is push-only. It emits on
  // connect, then again on every `coat apply`.
}

function scheduleReconnect() {
  if (reconnectTimer) return;
  reconnectTimer = setTimeout(() => {
    reconnectTimer = null;
    connect();
  }, 3000);
}

// The worker can be torn down and restarted with tabs still open, which loses
// `current`. Seed it from storage so those tabs get a theme on reconnect even
// before the native host has said anything.
api.storage.local.get("theme").then(({ theme }) => {
  if (theme && !current) {
    current = theme;
    broadcast(theme);
  }
}).catch(() => {});

api.runtime.onInstalled.addListener(connect);
api.runtime.onStartup.addListener(connect);
connect();
