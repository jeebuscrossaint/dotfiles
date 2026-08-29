// Outlook Web pack — full tier.
//
// Outlook runs THREE token generations side by side:
//   Fluent v9 semantic tokens (shared with Teams, see coat-fluent.js)
//   the legacy Office palette -- --themePrimary alone has ~376 uses and paints
//     the blue subject lines
//   a legacy chrome set that still paints real surfaces: --neutralSecondarySurface
//     (the message list), --neutralTertiarySurface and --headerBackground
//
// Token research is omarchy-webapp-theme's (MIT, Scott Jones), verified against
// a live mailbox: 984 custom properties, no iframes, effectively no shadow DOM,
// so plain var overrides reach everything. The values are coat's.
//
// Light/dark needs no automation -- Outlook follows the system preference, which
// the MAIN-world shim flips on every `coat apply`.

// ─────────────────────────────────────────────────── the dark-mode transform ──
//
// Outlook converts light HTML mail to dark ITSELF, before our tokens get a say.
// It rewrites every colour inline with !important and records what the sender
// originally specified in data-ogsb ("original get style background"). A plain
// white email becomes a flat neutral, which on a tinted scheme reads as a grey
// slab floating inside the themed reading pane -- the transform has no idea we
// repainted the surface around it.
//
// data-ogsb also draws the line between "backdrop" and "the sender's design":
//   original white, or absent entirely  -> PAPER. Outlook invented this surface;
//     retinting it is what stops the clash and costs the email nothing.
//   original an actual colour           -> the sender drew that deliberately.
//     Leave it; collapsing it onto our background erases the message's structure.
//
// Two tiers rather than one cliff: senders also band sections in off-whites
// (#f4f4f4, #f8f8f8), which Outlook turns into their own neutral greys. Those
// get a small step off the pane IN THE SCHEME'S HUE, so the banding survives
// without the neutral clash.
const PAPER_LUMINANCE = 0.95;
const NEAR_PAPER_LUMINANCE = 0.85;

function outlookPaperTarget(rgb, surfaces) {
  if (!rgb) return null;
  const lum = relLuminance(rgb);
  if (lum >= PAPER_LUMINANCE) return surfaces.paper;
  if (lum >= NEAR_PAPER_LUMINANCE) return surfaces.nearPaper;
  return null;
}

// data-ogsb holds whatever the SENDER wrote, in whatever colour syntax they
// wrote it: "white", "#FFF", "rgb(255,255,255)". Let the browser normalise it
// rather than hand-parsing -- hexToRgb understands hex only, so a bare keyword
// returns null and every "white" signature fails the paper test.
let outlookColorProbe = null;

function resolveOutlookColor(value) {
  if (!outlookColorProbe) return hexToRgb(value);
  outlookColorProbe.style.color = "";
  outlookColorProbe.style.color = value; // invalid syntax leaves it empty
  if (!outlookColorProbe.style.color) return null;
  const computed = getComputedStyle(outlookColorProbe).color;
  const m = /rgba?\((\d+),\s*(\d+),\s*(\d+)/.exec(computed);
  return m ? { r: +m[1], g: +m[2], b: +m[3] } : null;
}

// The transform has a SECOND mechanism, used in the composer and quoted replies:
// a per-message substitution table of inline custom properties keyed by the
// colour being replaced --
//   --darkColor_rgb_255__255__255_: rgb(41, 41, 41)
// -- which elements then reference. Overriding the paper entry retints every
// consumer at once, which is why signatures stay neutral if only the data-ogsb
// path is handled. The name carries the ORIGINAL colour, so the same
// paper-vs-design test applies.
function substitutionTarget(name, surfaces) {
  if (name.includes("_white_")) return surfaces.paper;
  const m = name.match(/rgb_(\d+)__(\d+)__(\d+)_?$/);
  if (!m) return null;
  return outlookPaperTarget({ r: +m[1], g: +m[2], b: +m[3] }, surfaces);
}

function retintSubstitutionTable(surfaces) {
  for (const el of document.querySelectorAll('[style*="--darkColor"]')) {
    // Collect first: setProperty() while iterating el.style is asking for
    // trouble, and most elements here are consumers with nothing to change.
    const edits = [];
    for (let i = 0; i < el.style.length; i++) {
      const name = el.style[i];
      if (!name.startsWith("--darkColor")) continue;
      const target = substitutionTarget(name, surfaces);
      if (target) edits.push([name, target]);
    }
    // Their entries carry no priority, so inline-important beats them.
    for (const [name, target] of edits) el.style.setProperty(name, target, "important");
  }
}

// The calendar's "now" marker: a dashed line with a round knob at its left edge.
// Outlook draws both from --themePrimary, which we map to the accent -- so the
// one marker you scan the grid for ends up the colour of everything else on it.
//
// This cannot be done in the stylesheet. Re-scoping --themePrimary to the day
// grid also recolours the SELECTED TIME SLOT, which reads the same token and
// lives in the same grid. The marker's own classes are hashed, so what is stable
// is its SHAPE: inside the grid there is exactly one element with a circular
// ::before (the knob) and exactly one with a dashed top border (the line), and
// they are siblings. Anchor on the circle, paint it and its dashed sibling.
function retintNowMarker(color) {
  if (!color) return;
  const grid = document.querySelector(
    '[data-app-section^="calendar-view"][class*="inDayContentChild"]'
  );
  if (!grid) return;
  for (const el of grid.querySelectorAll("div")) {
    const before = getComputedStyle(el, "::before");
    if (!before || before.content === "none") continue;
    const radius = before.borderRadius || "";
    if (!(radius.includes("100%") || radius.includes("50%"))) continue;
    if (before.backgroundColor === "rgba(0, 0, 0, 0)") continue;
    el.style.setProperty("background-color", color, "important");
    const parent = el.parentElement;
    if (!parent) continue;
    for (const sib of parent.children) {
      if (sib === el) continue;
      if (getComputedStyle(sib).borderTopStyle !== "dashed") continue;
      sib.style.setProperty("border-top-color", color, "important");
    }
  }
}

function retintPaper(s, nowMarker) {
  // Exactly the reading pane's colour, NOT a step off it. The body fills the
  // pane edge to edge, so any offset reads as a mismatched slab rather than as
  // elevation -- the email should look printed ON the pane.
  const surfaces = { paper: s.bg, nearPaper: shade(s.bg, s.dir * 0.03) };

  retintSubstitutionTable(surfaces);
  retintNowMarker(nowMarker);

  // Received mail: the transform writes the resolved colour straight onto the
  // element and records the original in data-ogsb. No var to intercept.
  for (const root of document.querySelectorAll('[id^="UniqueMessageBody"]')) {
    const full = root.getBoundingClientRect().width;
    if (!full) continue;
    for (const el of [root, ...root.querySelectorAll("[data-ogsb]")]) {
      if (!el.hasAttribute("data-ogsb")) continue;
      const original = el.getAttribute("data-ogsb");
      let target;
      if (original) {
        // A recorded original settles it -- size must NOT enter into it here.
        // Signature and quoted-reply paragraphs are white-on-paper but only ~85%
        // of body width, and a width test drops them, leaving grey bands down
        // the bottom of every reply.
        target = outlookPaperTarget(resolveOutlookColor(original), surfaces);
      } else {
        // No original: Outlook invented the fill. Only a full-width surface is a
        // backdrop -- it invents fills for link chips and buttons too, and those
        // are the sender's controls, not paper.
        target = el.getBoundingClientRect().width >= full * 0.9 ? surfaces.paper : null;
      }
      if (!target) continue;
      el.style.setProperty("background-color", target, "important");
    }
  }
}

let paperObserver = null;
let paperQueued = false;

function watchPaper(s, nowMarker) {
  if (!document.body) return;
  // Create the probe BEFORE the observer exists: it has to be in the document
  // to have a computed style, and appending it afterwards would feed our own
  // insertion back in as a mutation.
  if (!outlookColorProbe) {
    outlookColorProbe = document.createElement("span");
    outlookColorProbe.style.display = "none";
    document.body.appendChild(outlookColorProbe);
  }
  retintPaper(s, nowMarker);
  if (paperObserver) paperObserver.disconnect();
  // childList/subtree ONLY. Our repaint writes the style attribute, so observing
  // attributes would feed our own change straight back in as a mutation loop.
  paperObserver = new MutationObserver(() => {
    if (paperQueued) return;
    paperQueued = true;
    requestAnimationFrame(() => {
      paperQueued = false;
      retintPaper(s, nowMarker);
    });
  });
  paperObserver.observe(document.body, { childList: true, subtree: true });
}

// ──────────────────────────────────────────────────────────────────── pack ──

CoatTheme.register({
  id: "outlook",

  cssVars(theme, s) {
    return Object.assign({}, fluentVars(theme, s), {
      // ----- legacy Office palette -----
      // The busiest generation: --themePrimary paints the blue subject lines,
      // and the Lighter/LighterAlt end supplies the message-list selection
      // washes, so selection is themed through the token layer, not by selector.
      "--themePrimary": s.accent,
      "--themeSecondary": shade(s.accent, s.dir * 0.06),
      "--themeTertiary": shade(s.accent, s.dir * 0.12),
      "--themeDarkAlt": shade(s.accent, -s.dir * 0.06),
      "--themeDark": shade(s.accent, -s.dir * 0.12),
      "--themeDarker": shade(s.accent, -s.dir * 0.18),
      "--themeLight": withAlpha(s.accent, 0.28),
      "--themeLighter": s.selectedBg,
      "--themeLighterAlt": s.hoverBg,

      // ----- legacy chrome -----
      // --neutralPrimarySurface paints the list header ("Focused / Other", the
      // sort controls) and the "Other Emails" summary row -- all generated class
      // names, so the token was the only way in.
      "--neutralPrimarySurface": s.bg,
      "--neutralSecondarySurface": s.sidebarBg,
      "--neutralTertiarySurface": s.railBg,
      "--neutralLight": s.railBg,
      "--neutralLighter": s.sidebarBg,
      // The calendar grid's past / out-of-range slots. Outlook offsets them
      // slightly from the live area rather than matching it, so keep a gentle
      // offset -- collapsing them makes past and upcoming hours identical.
      "--neutralLighterAlt": shade(s.bg, s.dir * 0.03),
      "--headerBackground": s.railBg,
      "--headerBackgroundSearch": s.railBg,
      "--headerButtonsBackground": s.railBg,
      "--headerButtonsBackgroundSearch": s.railBg,

      // ----- suite-header ink -----
      // The header's foreground family ships as #000000 across the board
      // (--headerTextIcons drives the waffle, the mail and settings glyphs, the
      // avatar ring). Outlook's stock header is a saturated brand fill, so
      // black-on-blue works for THEM; on a themed bar it lands near 1.9:1 and the
      // icons all but vanish. Mapping only the backgrounds leaves the ink black,
      // so the ink has to move with it.
      //
      // fgStrong, not fg: the rail is a step off the page, so plain fg drops under
      // the AA floor on low-headroom schemes -- and chrome glyphs should read as
      // firmly as the app's own ink anyway.
      "--headerTextIcons": s.fgStrong,
      "--headerBrandText": s.fgStrong,
      "--headerSearchIcon": s.fgStrong,
      "--headerSearchBoxBackground": s.bg,
      "--headerSearchBoxIcon": s.fgMuted,
      "--headerSearchPlaceholderText": s.fgMuted,
      // Filled search button and unread badge are emphasis fills, so their ink
      // is the background colour, not the foreground.
      "--headerSearchButtonBackground": s.accent,
      "--headerSearchButtonIcon": s.bg,
      "--headerSearchFilters": s.accent,
      "--headerBadgeBackground": s.accent,
      "--headerBadgeText": s.bg,
      "--headerButtonsBackgroundHover": s.hoverBg,
      "--headerButtonsBackgroundSearchHover": s.hoverBg,
      "--headerSearchButtonBackgroundHover": shade(s.accent, -s.dir * 0.06),
      "--headerSearchFiltersHover": s.hoverBg,
    });
  },

  // The message-list rows are the one surface the token layer cannot reach:
  // they paint from --white. That token is NOT the literal its name suggests --
  // Outlook swaps it with --black by mode -- but it is still spent on icon fills
  // and on text over brand-coloured buttons, so remapping it at :root inverts
  // contrast where it matters. Redefine it only inside Outlook's stable
  // data-app-section regions; custom properties inherit, so everything in those
  // regions picks up the theme surface while --white stays literal elsewhere.
  apply(theme, s) {
    let style = document.getElementById("coat-outlook-rows");
    if (!style) {
      style = document.createElement("style");
      style.id = "coat-outlook-rows";
      (document.head || document.documentElement).appendChild(style);
    }

    const listBand = shade(s.bg, s.dir * 0.04);
    // Recessive scrollbar: present when you look for it, not competing with the
    // list. Alpha, so it works over whichever surface it lands on.
    const thumb = withAlpha(s.fg, 0.15);
    const thumbHover = withAlpha(s.fg, 0.3);
    // Unthemed Outlook draws the now-marker red, and that reads as "now"
    // precisely because nothing else in the grid is red. Pick a scheme slot
    // that is actually distinct from the accent -- see highlightAgainst().
    const nowMarker = highlightAgainst(s);

    const regions = [
      '[data-app-section="MessageList"]',
      '[data-app-section="NavigationPane"]',
      '[data-app-section="Ribbon"]',
      '[data-app-section="MailReadCompose"]',
      '[data-app-section="ConversationContainer"]',
      '[data-app-section="CalendarModule"]',
      '[data-app-section="CalendarModuleSurface"]',
      '[data-app-section="CalendarSurfaceNavigationToolbar"]',
      '[data-app-section^="Surface_"]',
      '[data-app-section^="calendar-view"]',
    ].join(", ");

    style.textContent = [
      regions + " { --white: " + s.bg + "; }",
      '[role="option"] { background-color: ' + s.bg + " !important; }",
      '[role="option"]:hover { background-color: ' + s.hoverBg + " !important; }",
      '[role="option"][aria-selected="true"] { background-color: ' + s.selectedBg + " !important; }",
      // The list's scroll container and date group headers sit behind the rows
      // and pick up the same literal white.
      '[role="listbox"], [role="grid"] { background-color: ' + s.bg + " !important; }",

      // Date-group headers ("Today", "Yesterday") paint from Background3 -- and
      // so does the folder pane, so the two come out identical while sitting
      // next to each other, reading as one slab rather than two panels. They
      // share the token, so redefine it just inside the message list.
      //
      // The descendant arm is NOT redundant: the engine writes cssVars as
      // "html, html * { ... !important }", so every element already carries its
      // own important copy and a declaration on the section alone never
      // inherits down. Re-declaring on descendants wins on specificity --
      // (0,1,0) for the attribute selector plus universal, against (0,0,1).
      '[data-app-section="MessageList"], [data-app-section="MessageList"] * {' +
        "  --colorNeutralBackground3: " + listBand + " !important;" +
        "  --neutralSecondarySurface: " + listBand + " !important;" +
        "}",

      // Outlook points the scrollbar thumb at --colorNeutralStroke1, a
      // foreground wash built for BORDERS, which makes the bar the brightest
      // thing in a quiet list. Give it its own recessive value instead of
      // dragging every border darker with it.
      "html, body { scrollbar-color: " + thumb + " transparent; }",
      "::-webkit-scrollbar-track { background: transparent !important; }",
      "::-webkit-scrollbar-thumb { background-color: " + thumb + " !important; border-radius: 4px !important; }",
      "::-webkit-scrollbar-thumb:hover { background-color: " + thumbHover + " !important; }",
    ].join("\n");

    watchPaper(s, nowMarker);
  },
});
