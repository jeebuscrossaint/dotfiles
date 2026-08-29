// Theme Firefox's own chrome — tab strip, toolbar, urlbar, popups, sidebar.
//
// Firefox-only, and the reason this is worth doing at all: browser.theme.update()
// repaints the whole chrome LIVE, with no restart. The userChrome.css route (what
// coat's firefox.tera writes) needs a restart to pick up a new scheme, which is
// exactly what makes it feel bolted on.
//
// Chromium has no counterpart. Its browser theme is a packaged theme extension
// and cannot be updated at runtime, so the chrome there stays untouched.
//
// Runs in the background context, where the theme API lives. background.js calls
// applyBrowserTheme() on every push if this file loaded; the Chromium build does
// not include it.

function applyBrowserTheme(theme) {
  const api = globalThis.browser ?? globalThis.chrome;
  if (!api || !api.theme || !api.theme.update) return;

  const s = deriveSurfaces(theme);
  if (!s) return;

  // Ink for text sitting on the accent -- solved, since a pale accent makes
  // white unreadable.
  const onAccent =
    contrastRatio(s.accent, "#ffffff") >= contrastRatio(s.accent, "#000000")
      ? "#ffffff"
      : "#000000";

  // s.fgMuted is solved against the PAGE, and chrome ink does not sit on the
  // page -- unselected tab labels and toolbar glyphs sit on the frame, which is
  // a different surface. Re-solve per surface, or the tab strip goes to ~2:1 on
  // schemes whose frame drifts furthest from the page.
  const mutedOn = (surface) =>
    withAlpha(s.fg, alphaForContrast(s.fg, [surface], 4.5));
  const frameMuted = mutedOn(s.railBg);

  api.theme.update({
    colors: {
      // Tab strip / titlebar. The deepest chrome, same role as an app's rail.
      frame: s.railBg,
      frame_inactive: s.railBg,
      // The selected tab is continuous with the page below it, so it takes the
      // page surface rather than a chrome one -- that continuity is what makes
      // the active tab read as active without a border.
      tab_selected: s.bg,
      tab_text: s.fg,
      tab_background_text: frameMuted,
      tab_line: s.accent,
      tab_loading: s.accent,

      // Nav toolbar sits directly under the selected tab, so it matches it.
      toolbar: s.bg,
      toolbar_text: s.fg,
      toolbar_top_separator: "transparent",
      toolbar_bottom_separator: s.borderMuted,
      toolbar_vertical_separator: s.borderMuted,

      // URL bar: an inset well, so a step off the toolbar it sits in.
      toolbar_field: s.surface,
      toolbar_field_text: s.fg,
      toolbar_field_border: "transparent",
      toolbar_field_focus: s.surfaceHigh,
      toolbar_field_text_focus: s.fg,
      toolbar_field_border_focus: s.accent,
      toolbar_field_highlight: s.selectedBg,
      toolbar_field_highlight_text: s.fg,

      // Menus, the urlbar dropdown, doorhangers.
      popup: s.surface,
      popup_text: s.fg,
      popup_border: s.borderColor,
      popup_highlight: s.selectedBg,
      popup_highlight_text: s.fg,

      // Bookmarks/history sidebar.
      sidebar: s.sidebarBg,
      sidebar_text: s.fg,
      sidebar_border: s.borderColor,
      sidebar_highlight: s.accent,
      sidebar_highlight_text: onAccent,

      // Toolbar button states.
      button_background_hover: s.hoverBg,
      button_background_active: s.selectedBg,

      // Toolbar glyphs. Muted so they recede, accent when demanding attention.
      icons: frameMuted,
      icons_attention: s.accent,

      // about:newtab / about:home.
      ntp_background: s.bg,
      ntp_text: s.fg,
    },
    properties: {
      // Tells Firefox which way to render chrome elements it draws itself,
      // rather than letting it infer polarity from the frame colour -- the
      // inference gets it wrong on low-contrast schemes.
      color_scheme: s.isDark ? "dark" : "light",
      content_color_scheme: s.isDark ? "dark" : "light",
    },
  });
}
