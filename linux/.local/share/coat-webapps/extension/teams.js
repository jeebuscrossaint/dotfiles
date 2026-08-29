// Microsoft Teams pack — declarative tier.
//
// Teams is the same Fluent v9 design system as Outlook, so the semantic token
// map is shared wholesale (coat-fluent.js) and almost nothing is Teams-specific.
//
// UNVERIFIED, unlike the Outlook pack. omarchy-webapp-theme does not cover
// Teams, so there is no by-value token hunt to inherit and this was written from
// the Fluent v9 token contract rather than from a live tenant. The Fluent names
// are stable and correct; which Teams surface each one paints is the part that
// may be wrong. If a surface comes out wrong, find its real token with:
//
//   getComputedStyle(document.documentElement)   // filter for --
//
// and add it below.
//
// Light/dark: Settings -> Appearance -> Theme -> "Follow OS setting". The
// MAIN-world shim makes "the OS" mean coat.

CoatTheme.register({
  id: "teams",

  cssVars(theme, s) {
    return Object.assign({}, fluentVars(theme, s), {
      // Teams leans on Background3 for the left app rail and the chat/team list,
      // and Background1 for the message pane -- the same split Outlook uses for
      // rail vs reading pane, which fluentVars already encodes.

      // Your own chat bubbles ride the brand wash rather than a neutral, so
      // they follow the accent instead of Microsoft purple.
      "--colorBrandBackground2Hover": withAlpha(s.accent, 0.22),
      "--colorBrandBackground2Pressed": withAlpha(s.accent, 0.3),

      // Presence dots carry real meaning, so they take the scheme's own status
      // slots literally rather than a hue derived from the accent.
      "--colorPaletteGreenBackground2": withAlpha(s.green, 0.2),
      "--colorPaletteRedBackground2": withAlpha(s.red, 0.2),
      "--colorPaletteYellowBackground2": withAlpha(s.yellow, 0.2),
      "--colorPaletteDarkOrangeForeground1": s.orange,
      "--colorPaletteDarkOrangeBackground3": s.orange,

      // Mentions and unread pips.
      "--colorPaletteRedForeground3": s.red,
      "--colorNeutralForeground2BrandHover": s.accent,
      "--colorNeutralForeground2BrandSelected": s.accent,
    });
  },

  apply(theme, s) {
    // Same reasoning as the Outlook pack: Fluent points the scrollbar thumb at a
    // border token, which makes it the brightest thing in a quiet list.
    let style = document.getElementById("coat-teams-extra");
    if (!style) {
      style = document.createElement("style");
      style.id = "coat-teams-extra";
      (document.head || document.documentElement).appendChild(style);
    }
    const thumb = withAlpha(s.fg, 0.15);
    const thumbHover = withAlpha(s.fg, 0.3);
    style.textContent = [
      "html, body { scrollbar-color: " + thumb + " transparent; }",
      "::-webkit-scrollbar-track { background: transparent !important; }",
      "::-webkit-scrollbar-thumb { background-color: " + thumb + " !important; border-radius: 4px !important; }",
      "::-webkit-scrollbar-thumb:hover { background-color: " + thumbHover + " !important; }",
    ].join("\n");
  },
});
