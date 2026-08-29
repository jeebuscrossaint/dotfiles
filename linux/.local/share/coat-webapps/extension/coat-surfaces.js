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

  // The floor every derived surface has to keep: the page's own text must read
  // on it about as well as it reads on the page. Capped at AA so a scheme whose
  // base05-on-base00 is already broken does not make this unsatisfiable -- 45 of
  // the 534 schemes are in that state and nothing here can rescue them.
  const floor = Math.min(contrastRatio(fg, theme.bg), 4.5);

  // Pull a candidate surface back toward the page until fg reads on it. Any
  // surface is allowed to be a step off the page; none is allowed to cost
  // legibility to get there.
  function legible(candidate) {
    if (contrastRatio(fg, candidate) >= floor) return candidate;
    for (let t = 0.1; t <= 1; t += 0.1) {
      const pulled = mix(candidate, theme.bg, t);
      if (contrastRatio(fg, pulled) >= floor) return pulled;
    }
    return theme.bg;
  }

  // Elevation, guarded. Conventionally lighter on dark schemes -- but on a
  // scheme with little headroom that walks straight into the foreground, so the
  // step gives way to legibility rather than the other way round.
  function step(amount) {
    return legible(shade(theme.bg, dir * amount));
  }

  // base24 nominally defines base10/base11 as the darker/darkest background, but
  // they are usable only when they are a STEP. Measured as a CONTRAST ratio, not
  // a luminance delta: a 0.12 luminance gap is imperceptible against a white page
  // and an entire panel-worth against a near-black one, so the raw delta admits
  // exactly the inversions it is meant to exclude.
  function recess(candidate, amount) {
    if (candidate && contrastRatio(theme.bg, candidate) <= 1.6) {
      const guarded = legible(candidate);
      if (guarded === candidate) return candidate;
    }
    return legible(shade(theme.bg, recessDir * amount));
  }

  const recessed = recess(c.base10, 0.03);
  const recessedDeep = recess(c.base11, 0.06);

  // A touch of accent in the chrome so the whole app reads as themed rather
  // than merely grey. Kept low -- heavier mixes flood the chrome on warm or
  // saturated accents.
  const sidebarBg = legible(mix(recessed, accent, isDark ? 0.08 : 0.05));
  const railBg = legible(mix(recessedDeep, accent, isDark ? 0.08 : 0.05));

  // Elevation ladder for popovers, menus and modals.
  const surface = step(0.05);
  const surfaceHigh = step(0.08);
  const surfaceHigher = step(0.11);

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
