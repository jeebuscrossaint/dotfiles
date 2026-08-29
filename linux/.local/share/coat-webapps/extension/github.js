// GitHub pack — declarative tier.
//
// GitHub (Primer) ships TWO token generations at once and different parts of
// the site still read different ones, so both are set:
//   --bgColor-* / --fgColor-* / --borderColor-*   current
//   --color-canvas-* / --color-fg-* / --color-border-*  legacy, still live in
//                                                   older views and in Gist
//
// Light/dark: set Appearance -> Theme mode to "Sync with system". GitHub picks
// its day/night theme from prefers-color-scheme, which the MAIN-world shim
// drives from the coat scheme.

CoatTheme.register({
  id: "github",
  cssVars(theme, s) {
    const emphasisFg = s.isDark ? "#0f0f0f" : "#ffffff";
    // Solved rather than assumed: on a light scheme with a pale accent, white
    // label text on the accent is unreadable. Take whichever of the scheme's
    // own extremes actually clears AA against the accent.
    const onAccent =
      contrastRatio(s.accent, "#ffffff") >= contrastRatio(s.accent, "#000000")
        ? "#ffffff"
        : "#000000";

    return {
      // ── current generation ──────────────────────────────────────────────
      "--bgColor-default": s.bg,
      "--bgColor-muted": s.surface,
      "--bgColor-inset": s.railBg,
      "--bgColor-emphasis": s.surfaceHigher,
      "--bgColor-neutral-muted": s.borderMuted,
      "--bgColor-accent-muted": withAlpha(s.accent, 0.15),
      "--bgColor-accent-emphasis": s.accent,
      "--bgColor-success-muted": withAlpha(s.green, 0.15),
      "--bgColor-success-emphasis": s.green,
      "--bgColor-danger-muted": withAlpha(s.red, 0.15),
      "--bgColor-danger-emphasis": s.red,
      "--bgColor-attention-muted": withAlpha(s.yellow, 0.15),
      "--bgColor-attention-emphasis": s.yellow,
      "--bgColor-done-muted": withAlpha(s.magenta, 0.15),
      "--bgColor-done-emphasis": s.magenta,

      "--fgColor-default": s.fg,
      "--fgColor-muted": s.fgMuted,
      "--fgColor-accent": s.accent,
      "--fgColor-success": s.green,
      "--fgColor-danger": s.red,
      "--fgColor-attention": s.yellow,
      "--fgColor-done": s.magenta,
      "--fgColor-onEmphasis": onAccent,

      "--borderColor-default": s.borderColor,
      "--borderColor-muted": s.borderMuted,
      "--borderColor-accent-emphasis": s.accent,

      // Header is its own family and ignores the canvas tokens.
      "--header-bgColor": s.railBg,
      "--header-color": s.fg,
      "--color-header-bg": s.railBg,
      "--color-header-text": s.fgMuted,
      "--color-header-logo": s.fg,

      // Primary buttons (the green "Code"/"Merge" pair) take the scheme green.
      "--button-primary-bgColor-rest": s.green,
      "--button-primary-bgColor-hover": shade(s.green, s.dir * 0.1),
      "--button-primary-fgColor-rest": contrastRatio(s.green, "#ffffff") >= contrastRatio(s.green, "#000000") ? "#ffffff" : "#000000",
      "--button-default-bgColor-rest": s.surface,
      "--button-default-bgColor-hover": s.surfaceHigh,

      // ── legacy generation ───────────────────────────────────────────────
      "--color-canvas-default": s.bg,
      "--color-canvas-overlay": s.surfaceHigh,
      "--color-canvas-inset": s.railBg,
      "--color-canvas-subtle": s.surface,
      "--color-fg-default": s.fg,
      "--color-fg-muted": s.fgMuted,
      "--color-fg-subtle": s.fgSubtle,
      "--color-fg-on-emphasis": emphasisFg,
      "--color-border-default": s.borderColor,
      "--color-border-muted": s.borderMuted,
      "--color-accent-fg": s.accent,
      "--color-accent-emphasis": s.accent,
      "--color-accent-muted": withAlpha(s.accent, 0.4),
      "--color-accent-subtle": withAlpha(s.accent, 0.15),
      "--color-success-fg": s.green,
      "--color-success-emphasis": s.green,
      "--color-danger-fg": s.red,
      "--color-danger-emphasis": s.red,
      "--color-attention-fg": s.yellow,
      "--color-attention-emphasis": s.yellow,
      "--color-done-fg": s.magenta,
      "--color-neutral-muted": s.borderMuted,
      "--color-neutral-emphasis": s.fgMuted,
      "--color-btn-bg": s.surface,
      "--color-btn-hover-bg": s.surfaceHigh,
      "--color-btn-primary-bg": s.green,
      "--color-btn-primary-hover-bg": shade(s.green, s.dir * 0.1),
    };
  },
});
