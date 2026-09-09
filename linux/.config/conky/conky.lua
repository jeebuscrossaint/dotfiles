-- ~/.config/conky/conky.lua — text bars and sparklines for conky.
--
-- These exist because conky's Wayland backend implements almost none of the X11
-- drawing calls: ${cpubar}, ${membar}, ${fs_bar} and ${cpugraph} are draw
-- operations, and hitting one does not warn or skip -- it ENDS THE RENDER, so
-- everything below it vanishes. The console_bar_fill / console_graph_ticks
-- settings that would make the built-ins emit Unicode are console-mode only.
--
-- So the bars and graphs are built out of characters instead, which is just text
-- and renders anywhere. Every block used here was checked against the actual
-- font file (fc-query on SFMonoNerdFontMono) rather than assumed.

local ticks = { "\u{2581}", "\u{2582}", "\u{2583}", "\u{2584}",
                "\u{2585}", "\u{2586}", "\u{2587}", "\u{2588}" }
local FILL, EMPTY = "\u{2588}", "\u{2591}"

local function num(v)
    return tonumber(v) or tonumber(conky_parse(tostring(v))) or 0
end

-- conky_bar(pct, width) -> "██████░░░░"
function conky_bar(pct, width)
    local p, w = num(pct), tonumber(width) or 10
    if p < 0 then p = 0 elseif p > 100 then p = 100 end
    local f = math.floor(p * w / 100 + 0.5)
    return FILL:rep(f) .. EMPTY:rep(w - f)
end

-- Rolling history per key, so several sparklines can coexist.
local hist = {}

-- conky_spark(key, value, width) -> "▁▂▃▅▂▁▂▃"
--
-- Scaled to the window's own maximum rather than a fixed ceiling: network speed
-- and CPU share no sensible axis, and a fixed one leaves most traces flat on the
-- floor. `scale` pins it instead when an absolute reading is wanted.
function conky_spark(key, value, width, scale)
    local w = tonumber(width) or 12
    local h = hist[key]
    if not h then h = {}; hist[key] = h end
    h[#h + 1] = num(value)
    while #h > w do table.remove(h, 1) end

    local max = tonumber(scale) or 0
    if max <= 0 then
        for _, x in ipairs(h) do if x > max then max = x end end
    end
    if max <= 0 then max = 1 end

    local out = {}
    for _ = 1, w - #h do out[#out + 1] = " " end
    for _, x in ipairs(h) do
        local i = math.floor(x / max * 7 + 0.5) + 1
        if i < 1 then i = 1 elseif i > 8 then i = 8 end
        out[#out + 1] = ticks[i]
    end
    return table.concat(out)
end

-- Eighth-width blocks, so a bar can land between characters instead of snapping
-- to whole cells. At width 12 that is 96 steps rather than 12.
local eighths = { "\u{258F}", "\u{258E}", "\u{258D}", "\u{258C}",
                  "\u{258B}", "\u{258A}", "\u{2589}", "\u{2588}" }

-- conky_fbar(pct, width) -> "███████▍░░░░"
function conky_fbar(pct, width)
    local p, w = num(pct), tonumber(width) or 10
    if p < 0 then p = 0 elseif p > 100 then p = 100 end
    local units = p * w * 8 / 100
    local whole = math.floor(units / 8)
    local rem = math.floor(units % 8)
    local out = FILL:rep(whole)
    if whole < w and rem > 0 then
        out = out .. eighths[rem]
        whole = whole + 1
    end
    return out .. EMPTY:rep(w - whole)
end

-- A corner block walking round the compass, one step per update. Braille is the
-- usual spinner and this font has NONE of it -- 0 of 256 codepoints -- so the
-- quadrant blocks do the job instead. Checked with fc-query, not assumed.
local frames = { "\u{2598}", "\u{259D}", "\u{2597}", "\u{2596}" }
local tick = 0

function conky_spin()
    tick = tick + 1
    return frames[(tick % #frames) + 1]
end

-- Alternates between two colours per update, for a value that wants attention.
--
-- Returns the whole ${color ...} directive, not a bare hex, and the caller must
-- use ${lua_parse} rather than ${lua}. Wrapping it the other way round --
-- ${color ${lua pulse A B}} -- does NOT work: conky does not evaluate a nested
-- variable inside ${color}'s argument, so the colour parser is handed the
-- literal text and logs "can't parse color '${lua pulse ...}'" every tick.
function conky_pulse(a, b)
    return "${color " .. ((tick % 2 == 0) and a or b) .. "}"
end

-- conky_cava(width) -> "▁▃▆█▅▂ ▁▄▇▃▁"
--
-- Reads the newest frame cava left in ~/.cache/cava.state. Returns empty when
-- the file is absent, which is the normal state when the writer is not running --
-- an audio visualiser is not worth an error message on the desktop.
function conky_cava(width)
    local w = tonumber(width) or 28
    local f = io.open(os.getenv("HOME") .. "/.cache/cava.state", "r")
    if not f then return "" end
    local line = f:read("*l")
    f:close()
    if not line then return "" end

    local out = {}
    for v in line:gmatch("%d+") do
        local i = tonumber(v) or 0
        out[#out + 1] = (i < 1) and " " or ticks[math.min(i, 8)]
        if #out >= w then break end
    end
    return table.concat(out)
end
