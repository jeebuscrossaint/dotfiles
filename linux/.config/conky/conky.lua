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

-- mmsg readouts, in Lua instead of ${execi ... | jq}.
--
-- The tag list and the focused appid were two ${execi 2} pipelines, and each one
-- was sh -> mmsg -> jq. jq is a ~20ms process start to pull three fields out of
-- one line, paid twice every two seconds, forever: measured with `strace -f -e
-- trace=execve`, those two lines were 1.0 jq/s and 1.7 sh/s, and stripping every
-- ${execi} from the panel took it from 11.2% of a core to 2.9%. Parsing here
-- drops the jq and one shell per call; io.popen still goes through sh, so mmsg
-- itself is the floor.
--
-- Cached on wall-clock seconds rather than run per tick, because update_interval
-- is 0.5 and this only needs to be as fresh as the old execi 2 was.
local cache = {}

local function cached(key, seconds, fn)
    local c = cache[key]
    local now = os.time()
    if c and (now - c.at) < seconds then return c.val end
    local ok, val = pcall(fn)
    if not ok then val = (c and c.val) or "" end
    cache[key] = { at = now, val = val }
    return val
end

local function slurp(cmd)
    local p = io.popen(cmd .. " 2>/dev/null", "r")
    if not p then return nil end
    local s = p:read("*a")
    p:close()
    return s
end

-- conky_tags() -> "[1] 2 3" — active in brackets, urgent with a bang, and tags
-- with no clients omitted. Matches what the jq program emitted.
--
-- The object pattern is field-ORDER dependent, which is safe here only because
-- mango emits these keys in a fixed order from a struct. `"tags":%[(.-)%]` takes
-- the FIRST monitor's array and nothing else -- the jq was .all_tags[0].tags[],
-- and a tag object contains no bracket, so the non-greedy match ends in the right
-- place.
function conky_tags()
    return cached("tags", 2, function()
        local s = slurp("mmsg get all-tags")
        if not s then return "" end
        local body = s:match('"tags":%[(.-)%]')
        if not body then return "" end
        local out = {}
        for idx, act, urg, _, cnt in body:gmatch(
            '"index":(%d+),"is_active":(%a+),"is_urgent":(%a+),"layout":"(%a*)","client_count":(%d+)') do
            if act == "true" or tonumber(cnt) > 0 then
                if urg == "true" then out[#out + 1] = "!" .. idx
                elseif act == "true" then out[#out + 1] = "[" .. idx .. "]"
                else out[#out + 1] = idx end
            end
        end
        return table.concat(out, " ")
    end)
end

-- conky_appid() -> the focused window's appid, "-" when nothing is focused.
function conky_appid()
    return cached("appid", 2, function()
        local s = slurp("mmsg get focusing-client")
        return (s and s:match('"appid":"(.-)"')) or "-"
    end)
end

-- conky_vol() -> the default sink's volume as an integer percent.
--
-- NOT ${pa_sink_volume}, which conky does have (this build lists PulseAudio),
-- because conky opens that connection ONCE at parse time and there is no retry:
-- the panel is started by mango's exec-once supervisor, which wins the race
-- against pipewire-pulse on a cold boot, and a conky that loses it renders the
-- variable as the literal text "${pa_sink_volume}" for the rest of the session
-- -- then libpulse takes the process down from under it:
--   pulseaudio.cc:251 cannot connect to pulseaudio server
--   Assertion 'pd' failed at pulsecore/pdispatch.c:306 ... Aborting.
-- which is a crash inside the client library, so no amount of config avoids it.
-- Asking wpctl per read has no connection to lose and recovers on its own the
-- moment the server is up. It is also the same tool ~/.local/bin/osd uses to SET
-- the volume, so the two agree by construction.
--
-- Muted reads as 0 rather than as the level behind the mute, because the bar
-- beside it is a picture of how loud this machine is and a muted machine is not.
function conky_vol()
    return cached("vol", 2, function()
        local s = slurp("wpctl get-volume @DEFAULT_AUDIO_SINK@")
        if not s then return "0" end
        if s:find("MUTED", 1, true) then return "0" end
        local v = tonumber(s:match("Volume:%s*([%d.]+)"))
        if not v then return "0" end
        return tostring(math.floor(v * 100 + 0.5))
    end)
end

-- Battery, mains and governor, read straight from sysfs.
--
-- These were ${execi} shell-outs, and every one of them only opened a file: two
-- awks over current_now/voltage_now, a cat|sed over ACAD/online, an awk over
-- charge_full, a cat over cycle_count, a cat over scaling_governor. At their
-- intervals that is a shell plus a child roughly every second and a half,
-- forever, to read numbers Lua reads with no process at all. Same move that took
-- the panel from 11.2% of a core to 2.9% when the mmsg pipelines went -- see
-- conky_tags -- and the same cache, so the read rate matches the old interval
-- rather than the tick rate.
--
-- The paths are passed in rather than found here: conky.conf resolves BAT0/BAT1
-- and AC/ACAD at load, and this file is loaded once for both panels. The cache
-- key carries the path for the same reason -- a fixed key would serve one
-- battery's reading for another's, which is exactly what a second battery is.

local function read_num(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local v = tonumber(f:read("*l") or "")
    f:close()
    return v
end

-- conky_watts(dir) -> "12.4 W". power_now where the firmware reports energy,
-- current_now x voltage_now where it reports charge; both are µ-units, hence 1e6
-- and 1e12. Empty when neither is present rather than "0.0 W", which would be a
-- reading.
function conky_watts(dir)
    return cached("watts:" .. dir, 5, function()
        local p = read_num(dir .. "/power_now")
        if p then return string.format("%.1f W", p / 1e6) end
        local c, v = read_num(dir .. "/current_now"), read_num(dir .. "/voltage_now")
        if c and v then return string.format("%.1f W", c * v / 1e12) end
        return ""
    end)
end

function conky_volts(dir)
    return cached("volts:" .. dir, 10, function()
        local v = read_num(dir .. "/voltage_now")
        return v and string.format("%.2f V", v / 1e6) or ""
    end)
end

-- conky_health(dir) -> "94%". charge_* on a battery that reports charge,
-- energy_* on one that reports energy.
function conky_health(dir)
    return cached("health:" .. dir, 600, function()
        for _, unit in ipairs({ "charge", "energy" }) do
            local full = read_num(dir .. "/" .. unit .. "_full")
            local design = read_num(dir .. "/" .. unit .. "_full_design")
            if full and design and design > 0 then
                return string.format("%.0f%%", 100 * full / design)
            end
        end
        return ""
    end)
end

function conky_cycles(dir)
    return cached("cycles:" .. dir, 600, function()
        local n = read_num(dir .. "/cycle_count")
        return n and tostring(math.floor(n)) or ""
    end)
end

-- conky_mains(path) -> "AC" or "batt", from power_supply/*/online.
function conky_mains(path)
    return cached("mains:" .. path, 5, function()
        local n = read_num(path)
        if n == nil then return "" end
        return n == 1 and "AC" or "batt"
    end)
end

function conky_governor()
    return cached("governor", 60, function()
        local f = io.open("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor", "r")
        if not f then return "" end
        local v = f:read("*l") or ""
        f:close()
        return v
    end)
end
