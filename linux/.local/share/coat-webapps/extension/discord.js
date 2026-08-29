// Discord pack — declarative tier.
//
// Discord's current token generation is an elevation ladder:
//   --background-base-lowest   server rail + channel sidebar (deepest chrome)
//   --background-base-lower    chat pane + member list (the reading surface)
//   --background-base-low      user panel
//   --background-surface-high/-higher/-highest  popovers, modals
//   --background-mod-*         hover/selection overlays
// plus semantic chat tokens, the mention pair, a numeric brand ladder
// (--brand-260..600, 500 = primary) and --text-link. The older
// --background-primary/secondary/tertiary generation is gone from current builds.
//
// Token names come from omarchy-webapp-theme's enumeration of the live app
// (MIT, Scott Jones); the values are coat's.
//
// Light/dark: set Discord's Appearance -> Theme to "Sync with computer". The
// MAIN-world matchMedia shim is what makes that follow coat.

CoatTheme.register({
  id: "discord",
  cssVars(theme, s) {
    return {
      // The chat pane is the reading surface, so it gets base00 exactly. The
      // rail and channel list share one token in Discord and take the recessed
      // accent-tinted chrome.
      "--background-base-lowest": s.railBg,
      "--background-base-lower": s.bg,
      "--background-base-low": s.surface,
      "--background-surface-high": s.surface,
      "--background-surface-higher": s.surfaceHigh,
      "--background-surface-highest": s.surfaceHigher,

      // Hover / selection overlays, layered over the surfaces above.
      "--background-mod-subtle": s.borderMuted,
      "--background-mod-muted": s.borderColor,
      "--background-mod-normal": s.hoverBg,
      "--background-mod-strong": s.selectedBg,

      "--chat-background": s.bg,
      "--chat-background-default": s.bg,
      "--channel-background-default": s.bg,
      "--channeltextarea-background": s.surface,

      "--text-normal": s.fg,
      "--text-muted": s.fgMuted,
      "--text-link": s.accent,
      "--interactive-normal": s.fgMuted,
      "--interactive-hover": s.fg,
      "--interactive-active": s.fgStrong,

      // Mentions carry the accent rather than Discord's blurple/yellow.
      "--mention-background": withAlpha(s.accent, 0.22),
      "--mention-foreground": s.accent,

      // Brand ladder -> accent. Higher number = darker in Discord's scale.
      "--brand-260": shade(s.accent, 0.16),
      "--brand-360": shade(s.accent, 0.08),
      "--brand-500": s.accent,
      "--brand-560": shade(s.accent, -0.06),
      "--brand-600": shade(s.accent, -0.12),
      "--text-brand": s.accent,

      // The ping badge keeps its urgency, in the scheme's own red. Only the
      // badge token is touched -- it shares a value with the danger/critical
      // family, which has to stay recognisable.
      "--badge-notification-background": s.red,
    };
  },
});
