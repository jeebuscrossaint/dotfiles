// Fluent UI v9 token map — shared by every Microsoft web app.
//
// Outlook and Teams are both Fluent v9, so they share one semantic token
// family and one mapping. Anything Microsoft-specific but app-specific (the
// legacy Office palette, suite-header ink) stays in the individual pack.
//
// Fluent's ladder runs lightest→darkest in light mode; shade() walks the
// correct direction for the active scheme via s.dir, so one expression covers
// both polarities.
//
// Token names verified against a live Outlook mailbox by omarchy-webapp-theme
// (MIT, Scott Jones) — 984 custom properties enumerated. The values are coat's.

function fluentVars(theme, s) {
  const bg2 = shade(s.bg, s.dir * 0.02);
  const bg5 = shade(s.bg, s.dir * 0.08);
  const bg6 = shade(s.bg, s.dir * 0.1);
  const hover = shade(s.bg, s.dir * 0.04);
  const pressed = shade(s.bg, s.dir * 0.07);
  // Stronger than borderColor: Stroke1 draws real dividers, not hairlines.
  const strokeStrong = withAlpha(s.fg, s.isDark ? 0.22 : 0.18);

  return {
    // ----- surfaces -----
    // 1 is the reading/content surface and every card and dialog; 3 is the
    // secondary list column; 4 is the rail and header row.
    "--colorNeutralBackground1": s.bg,
    "--colorNeutralBackground1Hover": hover,
    "--colorNeutralBackground1Pressed": pressed,
    "--colorNeutralBackground1Selected": s.selectedBg,
    "--colorNeutralBackground2": bg2,
    "--colorNeutralBackground2Hover": hover,
    "--colorNeutralBackground2Pressed": pressed,
    "--colorNeutralBackground2Selected": s.selectedBg,
    "--colorNeutralBackground3": s.sidebarBg,
    "--colorNeutralBackground3Hover": s.hoverBg,
    "--colorNeutralBackground3Pressed": pressed,
    "--colorNeutralBackground3Selected": s.selectedBg,
    "--colorNeutralBackground4": s.railBg,
    "--colorNeutralBackground5": bg5,
    "--colorNeutralBackground6": bg6,
    "--colorNeutralBackgroundDisabled": bg2,
    "--colorNeutralBackgroundInverted": s.fg,

    // Transparent-by-default button surfaces.
    "--colorSubtleBackground": "transparent",
    "--colorSubtleBackgroundHover": s.hoverBg,
    "--colorSubtleBackgroundPressed": s.selectedBg,
    "--colorSubtleBackgroundSelected": s.selectedBg,
    // Fluent's overlay set for controls sitting on a BRANDED fill. The app rail
    // re-declares these on its own <FluentProvider> wrapper, below :root — which
    // the engine's "html, html *" sweep still reaches. Left alone, the selected
    // rail tile paints a saturated cyan belonging to no scheme.
    "--colorSubtleBackgroundLightAlphaHover": s.hoverBg,
    "--colorSubtleBackgroundLightAlphaPressed": s.selectedBg,
    "--colorSubtleBackgroundLightAlphaSelected": s.selectedBg,

    // ----- text -----
    "--colorNeutralForeground1": s.fg,
    "--colorNeutralForeground1Hover": s.fgStrong,
    "--colorNeutralForeground2": withAlpha(s.fg, 0.88),
    "--colorNeutralForeground3": s.fgMuted,
    "--colorNeutralForeground4": s.fgSubtle,
    "--colorNeutralForegroundDisabled": withAlpha(s.fg, 0.38),
    "--colorNeutralForegroundInverted": s.bg,
    "--colorNeutralForegroundOnBrand": onColor(s.accent),
    "--colorNeutralForegroundStaticInverted": s.bg,

    // ----- borders -----
    "--colorNeutralStroke1": strokeStrong,
    "--colorNeutralStroke2": s.borderColor,
    "--colorNeutralStroke3": s.borderColor,
    "--colorNeutralStrokeAccessible": withAlpha(s.fg, 0.4),
    "--colorTransparentStroke": "transparent",

    // ----- brand -> accent -----
    // Background2 is the pale selected/highlight wash, not a fill.
    "--colorBrandBackground": s.accent,
    "--colorBrandBackgroundHover": shade(s.accent, -s.dir * 0.06),
    "--colorBrandBackgroundPressed": shade(s.accent, -s.dir * 0.12),
    "--colorBrandBackground2": withAlpha(s.accent, 0.15),
    "--colorBrandBackgroundInverted": s.bg,
    "--colorBrandForeground1": s.accent,
    "--colorBrandForeground2": shade(s.accent, -s.dir * 0.08),
    "--colorBrandForegroundLink": s.accent,
    "--colorBrandForegroundLinkHover": shade(s.accent, s.dir * 0.1),
    "--colorBrandStroke1": s.accent,
    "--colorBrandStroke2": withAlpha(s.accent, 0.4),
    "--colorCompoundBrandBackground": s.accent,
    "--colorCompoundBrandForeground1": s.accent,
    "--colorCompoundBrandStroke": s.accent,

    // ----- status, straight from the scheme's own slots -----
    "--colorPaletteRedForeground1": s.red,
    "--colorPaletteRedBackground3": s.red,
    "--colorPaletteGreenForeground1": s.green,
    "--colorPaletteGreenBackground3": s.green,
    "--colorPaletteYellowForeground1": s.yellow,
    "--colorPaletteYellowBackground3": s.yellow,
    "--colorStatusDangerForeground1": s.red,
    "--colorStatusSuccessForeground1": s.green,
    "--colorStatusWarningForeground1": s.yellow,
  };
}

// Ink for text sitting ON a filled swatch. Solved rather than assumed: white on
// a pale accent is unreadable, and a scheme's accent can be pale.
function onColor(hex) {
  return contrastRatio(hex, "#ffffff") >= contrastRatio(hex, "#000000") ? "#ffffff" : "#000000";
}

// A colour that reads as "look here" against a themed grid. Prefers the
// scheme's own warm slots and takes them LITERALLY -- no hue remapping -- but
// skips one that is too close to the accent to be distinguishable, since being
// distinct from everything else on the grid is the whole job.
function highlightAgainst(s) {
  const MIN_DISTANCE = 90;
  for (const c of [s.yellow, s.orange, s.red, s.magenta]) {
    if (c && colorDistance(c, s.accent) >= MIN_DISTANCE) return c;
  }
  return s.red || s.accent;
}
