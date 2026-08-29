// coat web-app theming — colour maths. No DOM, no chrome APIs; every other
// file in the extension assumes these are in scope (content scripts listed in
// one manifest entry share one scope, so plain declarations are enough).

function hexToRgb(hex) {
  if (typeof hex !== "string") return null;
  let h = hex.trim().replace(/^#/, "");
  if (h.length === 3) h = h.split("").map((c) => c + c).join("");
  if (!/^[0-9a-fA-F]{6}$/.test(h)) return null;
  return {
    r: parseInt(h.slice(0, 2), 16),
    g: parseInt(h.slice(2, 4), 16),
    b: parseInt(h.slice(4, 6), 16),
  };
}

function rgbToHex({ r, g, b }) {
  const c = (v) => Math.max(0, Math.min(255, Math.round(v))).toString(16).padStart(2, "0");
  return "#" + c(r) + c(g) + c(b);
}

// WCAG 2.x relative luminance. Used both for the contrast solver and to decide
// dark vs light -- the scheme's own `variant` field is advisory and some
// schemes lie about it, the pixels do not.
function relLuminance({ r, g, b }) {
  const lin = (v) => {
    const s = v / 255;
    return s <= 0.03928 ? s / 12.92 : Math.pow((s + 0.055) / 1.055, 2.4);
  };
  return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b);
}

function contrastRatio(aHex, bHex) {
  const a = hexToRgb(aHex);
  const b = hexToRgb(bHex);
  if (!a || !b) return 1;
  const la = relLuminance(a);
  const lb = relLuminance(b);
  return (Math.max(la, lb) + 0.05) / (Math.min(la, lb) + 0.05);
}

// Straight sRGB interpolation. Not perceptual, deliberately: these are small
// nudges between two already-related colours, where Oklab's extra machinery
// buys nothing visible.
function mix(aHex, bHex, t) {
  const a = hexToRgb(aHex);
  const b = hexToRgb(bHex);
  if (!a || !b) return aHex;
  const k = Math.max(0, Math.min(1, t));
  return rgbToHex({
    r: a.r + (b.r - a.r) * k,
    g: a.g + (b.g - a.g) * k,
    b: a.b + (b.b - a.b) * k,
  });
}

// Positive lightens toward white, negative darkens toward black. Callers pass
// `dir * n` so one expression covers dark and light schemes.
function shade(hex, amount) {
  if (!amount) return hex;
  return mix(hex, amount > 0 ? "#ffffff" : "#000000", Math.abs(amount));
}

function withAlpha(hex, alpha) {
  const c = hexToRgb(hex);
  if (!c) return hex;
  const a = Math.max(0, Math.min(1, alpha));
  return `rgba(${c.r}, ${c.g}, ${c.b}, ${a.toFixed(3)})`;
}

// Composite a translucent ink over an opaque backdrop.
function composite(inkHex, bgHex, alpha) {
  const ink = hexToRgb(inkHex);
  const bg = hexToRgb(bgHex);
  if (!ink || !bg) return inkHex;
  return rgbToHex({
    r: bg.r + (ink.r - bg.r) * alpha,
    g: bg.g + (ink.g - bg.g) * alpha,
    b: bg.b + (ink.b - bg.b) * alpha,
  });
}

// Lowest alpha at which `ink` over EVERY backdrop in `bgs` still clears
// `target` contrast, or 1 if it never does.
//
// Muted text is an alpha rather than a baked-in mix so it keeps adapting to
// whatever surface it lands on -- but a flat fraction like 0.65 drops under the
// 4.5:1 AA floor on low-contrast schemes, so solve for the ratio instead of
// guessing the fraction.
function alphaForContrast(inkHex, bgs, target) {
  const backdrops = bgs.filter(Boolean);
  if (!backdrops.length) return 1;
  const ok = (a) => backdrops.every((bg) => contrastRatio(composite(inkHex, bg, a), bg) >= target);
  if (ok(1) === false) return 1;
  let lo = 0;
  let hi = 1;
  for (let i = 0; i < 12; i++) {
    const mid = (lo + hi) / 2;
    if (ok(mid)) hi = mid;
    else lo = mid;
  }
  // Ceil, not round: the search converges from above, so rounding the answer
  // DOWN to 2dp puts it back under the target it was solved for.
  return Math.min(1, Math.ceil(hi * 100) / 100);
}

// Rough perceptual distance, for "is this slot far enough from the accent to
// read as a different thing". Weighted sRGB rather than a real dE: the decision
// it feeds is a coarse one and this needs no colour-space conversion.
function colorDistance(aHex, bHex) {
  const a = hexToRgb(aHex);
  const b = hexToRgb(bHex);
  if (!a || !b) return 0;
  const rm = (a.r + b.r) / 2;
  const dr = a.r - b.r;
  const dg = a.g - b.g;
  const db = a.b - b.b;
  return Math.sqrt((2 + rm / 256) * dr * dr + 4 * dg * dg + (2 + (255 - rm) / 256) * db * db);
}
