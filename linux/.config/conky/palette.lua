-- The palette both conky panels draw from: coat's colours, plus the two things
-- that have to happen to them before they are usable.
--
-- Shared rather than copied into each config because they are the same theme
-- seen twice -- the readout on the right and the process tree on the left -- and
-- a ramp that drifted out of sync between them would be a bug you could only see
-- by looking at the wallpaper. Each config dofile()s this INSTEAD of
-- coat-colors.lua; the fallback for a missing or half-written coat file lives
-- here now, so the configs do not each carry one.
--
-- Not guarded at the call site the way coat-colors.lua was: coat rewrites that
-- file live and a config reload can catch it mid-write, but nothing writes this
-- one, so there is no window to lose to.

local ok, c = pcall(dofile, os.getenv("HOME") .. "/.config/conky/coat-colors.lua")
if not ok or type(c) ~= "table" then
    c = { font = "monospace", size_desktop = 8, size_popups = 10, size_terminal = 9,
          base00 = "1C1C1C", base03 = "505050", base05 = "D0D0D0",
          base08 = "F28B82", base09 = "F8C98A", base0A = "F7E08A",
          base0B = "A3D9A5", base0C = "8AD8D8", base0D = "8AB4F8",
          base0E = "C58AF8" }
end
c.font_size = c.font_size or c.size_desktop

local function chan(hex, i) return tonumber(hex:sub(i * 2 - 1, i * 2), 16) end

-- WCAG relative luminance, so "readable" means the same number here as it does
-- anywhere else and can be checked against a contrast table.
local function lum(hex)
    local l = 0
    for i, w in ipairs({ 0.2126, 0.7152, 0.0722 }) do
        local v = chan(hex, i) / 255
        l = l + w * (v <= 0.04045 and v / 12.92 or ((v + 0.055) / 1.055) ^ 2.4)
    end
    return l
end

local function contrast(a, b)
    local x, y = lum(a) + 0.05, lum(b) + 0.05
    return x > y and x / y or y / x
end

function c.mix(a, b, t)
    local hex = ""
    for i = 1, 3 do
        local x, y = chan(a, i), chan(b, i)
        hex = hex .. string.format("%02X", math.floor(x + (y - x) * t + 0.5))
    end
    return hex
end

-- Drag a colour toward the foreground until it clears `floor` against base00.
--
-- Necessary because an accent slot is picked to look right in a text editor,
-- where it sits on a solid background at whatever contrast the author liked --
-- and both panels draw straight onto the WALLPAPER. Dimmed Monokai's base0D is
-- 2.3:1 and its base0E is 1.3:1; used raw, half the process tree and every meter
-- on the readout would be a smudge. Toward base05 rather than toward white
-- because base05 is the scheme's own idea of readable and works in both variants
-- -- a light scheme darkens here, and nothing about this needs to know which it
-- got. The hue survives as far as the floor allows, which is the most of it that
-- can be kept.
function c.lift(hex, floor)
    for i = 0, 20 do
        local try = c.mix(hex, c.base05, i / 20)
        if contrast(try, c.base00) >= floor then return try end
    end
    return c.base05
end

-- n colours from `hex` down to `floor`, evenly spaced in CONTRAST against the
-- background rather than in mix fraction. Those are not the same thing: half the
-- way to the background is nowhere near half the way down the contrast, so an
-- even mix bunches the visible difference into the first step or two and then
-- flattens, and on a scheme with a narrow foreground the tail lands on the floor
-- and comes out as one colour repeated. Spacing by contrast spends the range the
-- scheme actually has, whatever that is.
function c.fade(hex, floor, n)
    local top, out = contrast(hex, c.base00), {}
    if floor > top then floor = top end
    for i = 0, n - 1 do
        local want = top + (floor - top) * (n > 1 and i / (n - 1) or 0)
        local step = hex
        for k = 0, 100 do
            step = c.mix(hex, c.base00, k / 100)
            if contrast(step, c.base00) <= want then break end
        end
        out[i + 1] = step
    end
    return out
end

return c
