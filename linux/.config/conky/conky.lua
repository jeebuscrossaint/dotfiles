-- ~/.config/conky/conky.lua — ${lua ...} helpers for conky.conf.

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

-- conky_gw() -> "10.42.88.1", the gateway actually in use.
--
-- ${gw_ip} and ${gw_iface} both answer the literal string "multiple" whenever
-- more than one default route exists, which is the normal state on this laptop:
-- plugging in a cable does not drop wifi, it leaves it associated at a worse
-- metric, so there are two. Conky reports neither rather than the winner. The
-- kernel picks the LOWEST metric, so that is what is read here.
--
-- /proc/net/route is hex and little-endian: 0100A8C0 is 192.168.0.1, low byte
-- first. Destination 00000000 is the default route, and metric is field 7.
function conky_gw()
    local f = io.open("/proc/net/route", "r"); if not f then return "" end
    local best, best_metric
    for l in f:lines() do
        local iface, dest, gw, _, _, _, metric = l:match(
            "^(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)")
        if dest == "00000000" and gw and gw ~= "00000000" then
            local m = tonumber(metric) or 0
            if not best_metric or m < best_metric then
                best_metric, best = m, gw
            end
        end
    end
    f:close()
    if not best then return "" end
    local b = {}
    for i = 0, 3 do
        b[#b + 1] = tonumber(best:sub(i * 2 + 1, i * 2 + 2), 16)
    end
    return ("%d.%d.%d.%d"):format(b[4], b[3], b[2], b[1])
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
        -- 1.5 is osd's VOL_MAX, the level both readouts call 100%.
        return tostring(math.min(100, math.floor(v / 1.5 * 100 + 0.5)))
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
