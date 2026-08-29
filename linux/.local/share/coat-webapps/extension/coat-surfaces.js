// coat web-app theming — surface derivation (site-agnostic).
//
// deriveSurfaces() is the CONTRACT between the engine and a site pack: it turns
// the palette the native host pushed into the named surfaces a pack paints
// with. The returned shape IS the API -- packs read these fields by name.

function deriveSurfaces(theme) {
  if (!theme || !theme.bg) return null;
  const bgRgb = hexToRgb(theme.bg);
  if (!bgRgb) return null;

  const c = theme.colors || {};

  // Decided from the pixels, not from theme.variant. A scheme's declared
  // variant is metadata a human typed; the luminance of base00 is what the eye
  // actually gets, and the two disagree often enough to matter.
  const isDark = relLuminance(bgRgb) < 0.5;
  const fg = theme.fg || (isDark ? "#e6e6e6" : "#1f1f1f");
  const accent = theme.accent || (isDark ? "#7aa2f7" : "#1264a3");
  // Shade direction: lighten on dark schemes, darken on light ones.
  const dir = isDark ? 1 : -1;

  // Recessed chrome (sidebars, rails, nav). Every app in this family steps its
  // chrome DARKER than the reading surface, in both polarities -- Fluent's light
  // ladder is #ffffff pane -> #f5f5f5 list -> #f0f0f0 rail, and Discord's rail is
  // darker than its chat pane.
  //
  // base24 nominally defines base10/base11 as the darker/darkest background, but
  // they are only usable when they are a STEP. On light schemes they are usually
  // the dark-variant pair instead: 3024-day goes #f7f7f7 -> #3d3a38 and
  // builtin-light #ffffff -> #383838, which is a full inversion, not a panel.
  // Measured over the 30 light base24 schemes, so take them only when the
  // luminance gap is small enough to read as elevation.
  //
  // base01/base02 would be the obvious base16 candidates and are deliberately
  // NOT used: across the library those slots land anywhere, and chrome built on
  // them goes illegible on the schemes that put them near base05.
  const bgLum = relLuminance(bgRgb);
  // Below this there is no room left to go darker, so recession has to lift.
  const recessDir = bgLum < 0.02 ? 1 : -1;

  function recess(candidate, amount) {
    if (candidate) {
      const rgb = hexToRgb(candidate);
      if (rgb && Math.abs(relLuminance(rgb) - bgLum) <= 0.12) return candidate;
    }
    return shade(theme.bg, recessDir * amount);
  }

  const recessed = recess(c.base10, 0.03);
  const recessedDeep = recess(c.base11, 0.06);

  // A touch of accent in the chrome so the whole app reads as themed rather
  // than merely grey. Kept low -- heavier mixes flood the chrome on warm or
  // saturated accents.
  const sidebarBg = mix(recessed, accent, isDark ? 0.08 : 0.05);
  const railBg = mix(recessedDeep, accent, isDark ? 0.08 : 0.05);

  // Elevation ladder for popovers, menus and modals.
  const surface = shade(theme.bg, dir * 0.05);
  const surfaceHigh = shade(theme.bg, dir * 0.08);
  const surfaceHigher = shade(theme.bg, dir * 0.11);

  // Muted/secondary text. An rgba ink rather than an opaque mix, so it keeps
  // adapting to whichever surface it lands on -- but with the alpha solved for
  // a contrast TARGET instead of being a flat fraction of fg, which goes under
  // the AA floor on low-contrast schemes.
  //
  // Solved against the page bg only. Also demanding 6:1 on the accent-tinted
  // sidebar pushes the alpha to 1.0 on schemes with little headroom, which
  // collapses muted onto fg and destroys the distinction it exists to make.
  const fgMuted = withAlpha(fg, alphaForContrast(fg, [theme.bg], 6));
  const fgSubtle = withAlpha(fg, alphaForContrast(fg, [theme.bg], 4.5));
  // Stronger than fg, for unread/emphasis rows.
  const fgStrong = shade(fg, dir * 0.125);

  return {
    bg: theme.bg,
    isDark,
    dir,
    fg,
    fgStrong,
    fgMuted,
    fgSubtle,
    accent,
    sidebarBg,
    railBg,
    surface,
    surfaceHigh,
    surfaceHigher,
    hoverBg: withAlpha(accent, 0.18),
    selectedBg: withAlpha(accent, 0.32),
    borderColor: withAlpha(fg, 0.14),
    borderMuted: withAlpha(fg, 0.08),
    // Semantic slots, passed through literally. A pack that wants a danger red
    // or a diff green takes the scheme's, never a hue re-derived from accent.
    red: c.base08 || accent,
    orange: c.base09 || accent,
    yellow: c.base0A || accent,
    green: c.base0B || accent,
    cyan: c.base0C || accent,
    blue: c.base0D || accent,
    magenta: c.base0E || accent,
  };
}
