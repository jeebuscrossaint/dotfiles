const HOST = "com.coat.webapp_theme";

// Every site a pack covers, taken straight from the manifest's content-script
// matches -- adding a pack never touches this file.
const MATCH_PATTERNS = [
  ...new Set(chrome.runtime.getManifest().content_scripts.flatMap((cs) => cs.matches)),
];
const MATCH_HOSTS = [
  ...new Set(
    MATCH_PATTERNS.map((p) =>
      p.replace(/^\*:\/\//, "").replace(/\/.*$/, "").replace(/^\*\./, "")
    )
  ),
];

function isThemedUrl(url) {
  try {
    const host = new URL(url).hostname;
    return MATCH_HOSTS.some((h) => host === h || host.endsWith("." + h));
  } catch (_) {
    return false;
  }
}

let port = null;
let reconnectTimer = null;

function connect() {
  // The service worker reaches this from three directions -- the module-level
  // call below, onInstalled and onStartup. Without the guard each opens its own
  // port, every port spawns its own native host, and each theme change then
  // gets broadcast to the same tabs N times.
  if (port) return;
  try {
    port = chrome.runtime.connectNative(HOST);
  } catch (e) {
    console.warn("[coat] connectNative threw:", e);
    scheduleReconnect();
    return;
  }

  port.onMessage.addListener((theme) => {
    if (!theme || !theme.bg) return;
    console.log("[coat] theme pushed:", theme.theme_name, theme.bg);
    chrome.storage.local.set({ theme });
    broadcast(theme);
  });

  port.onDisconnect.addListener(() => {
    const err = chrome.runtime.lastError;
    console.warn("[coat] native host disconnected:", err && err.message);
    port = null;
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

function broadcast(theme) {
  chrome.tabs.query({ url: MATCH_PATTERNS }, (tabs) => {
    for (const t of tabs) {
      chrome.tabs.sendMessage(t.id, { type: "coat-theme", theme }).catch(() => {});
    }
  });
}

chrome.runtime.onMessage.addListener((msg, _sender, sendResponse) => {
  if (msg && msg.type === "request-theme") {
    chrome.storage.local.get("theme").then(({ theme }) => sendResponse(theme || null));
    return true; // keep the channel open for the async reply
  }
});

chrome.tabs.onUpdated.addListener((tabId, info, tab) => {
  if (info.status !== "complete") return;
  if (!tab.url || !isThemedUrl(tab.url)) return;
  chrome.storage.local.get("theme").then(({ theme }) => {
    if (theme) chrome.tabs.sendMessage(tabId, { type: "coat-theme", theme }).catch(() => {});
  });
});

chrome.runtime.onInstalled.addListener(connect);
chrome.runtime.onStartup.addListener(connect);
connect();
