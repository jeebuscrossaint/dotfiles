# Formats ~/.cache/conky-wx.json (Open-Meteo /v1/forecast) into conky's weather
# block.
#
# In a file, not inline in conky.conf, because conky silently truncates an exec
# command past roughly 200 characters -- no error, no partial output, just an
# empty block. That is the whole reason this file exists.
#
# Source changed from wttr.in to Open-Meteo on 2026-09-19. wttr.in is backed by
# WorldWeatherOnline, whose observations ran 1-2 HOURS stale -- measured: a file
# fetched 26 minutes earlier carried a 01:19 UTC observation at 03:04 UTC. No
# polling interval can fix that. Open-Meteo reports `interval: 900`, refreshes
# every 15 minutes, takes exact coordinates instead of guessing from the IP, and
# sets no rate limit that a 5-minute timer comes near.
#
# What that cost: Open-Meteo has no moon phase (computed here instead, from the
# date -- it is a function of time, not of weather) and no place name, so the
# location line shows the GRID POINT it actually answered for. That is the more
# useful line anyway, because the coordinates are NOT exact: weather-fetch gets
# them from IP geolocation, which is kilometre-scale, so this is where you check
# whether the panel is reporting on the right patch of sky.
#
# Two readings changed because Open-Meteo does not carry wttr's equivalents:
# thunder% -> CAPE, the actual instability number a storm comes out of, and fog%
# -> dew point spread, which is what fog forms out of when it closes on zero.
#
# Icons are Nerd Font glyphs. The table below is the SAME eight glyphs the
# wttr.in version used, remapped from wttr's codes onto WMO codes, so they are
# still the ones already checked against the font with fc-query; a codepoint the
# font lacks renders as a tofu box with no warning.
#
# The two section heads in here take conky.conf's form -- the name in the accent
# colour, then a dotted rule to column 55, and no leading icon, which is what
# separates a head from a reading -- so the weather's subsections look like the
# sections above them rather than like a second idea.
#
# Colour is by MEANING, not decoration: temperature by how hot, rain by how
# likely, UV by how much it will hurt -- so the block reads at a glance without
# parsing the numbers. Colour SLOTS rather than hex, so the palette lives in the
# conky config and follows coat. That also means the caller must use execpi:
# execi does not parse conky variables in its output and these would print raw.
# WMO descriptions are written out below rather than sliced, at most 19
# characters, which is what sets the panel width -- slicing lands mid-word
# ("Violent rain show"). The slice at the end is a backstop for a code WMO adds
# later, not the normal path.
def desc: {
  "0":"Clear",              "1":"Mainly clear",       "2":"Partly cloudy",
  "3":"Overcast",           "45":"Fog",               "48":"Rime fog",
  "51":"Light drizzle",     "53":"Drizzle",           "55":"Dense drizzle",
  "56":"Light icy drizzle", "57":"Dense icy drizzle",
  "61":"Light rain",        "63":"Rain",              "65":"Heavy rain",
  "66":"Light icy rain",    "67":"Heavy icy rain",
  "71":"Light snow",        "73":"Snow",              "75":"Heavy snow",
  "77":"Snow grains",
  "80":"Light rain shower", "81":"Rain showers",      "82":"Violent rain shower",
  "85":"Light snow shower", "86":"Heavy snow shower",
  "95":"Thunderstorm",      "96":"Thunderstorm, hail","99":"Severe thunderstorm"
}[tostring] // "wmo \(.)" | .[0:19];
def wxicon: {"0":"","1":"","2":"","3":"","45":"","48":"","51":"","53":"","55":"","56":"","57":"","61":"","63":"","65":"","66":"","67":"","71":"","73":"","75":"","77":"","80":"","81":"","82":"","85":"","86":"","95":"","96":"","99":""}[tostring] // "";
def n: tonumber? // 0;

# Weight, not hue, matching the panel: an ordinary reading is text, a quiet one
# drops to the dim tier, and only an extreme reaches the alert. Colouring every
# band meant a row changed colour two or three times and a mild reading was as
# loud as a dangerous one, so nothing stood out. Which values deserve it is
# decided here; conky.conf only holds the palette.
def tcol: if n >= 90 then "${color3}" else "${color}" end;
def pcol: if n >= 60 then "${color}" else "${color2}" end;
def uvcol: if n >= 8 then "${color3}" else "${color}" end;
# 2500 J/kg is where forecasters stop calling instability moderate. Below 1000
# there is nothing to build a storm out of, so it drops to the dim tier.
def capecol: if n >= 2500 then "${color3}" elif n >= 1000 then "${color}" else "${color2}" end;
def C: "${color}";
def A: "${color2}";

def f2c: ((n - 32) * 5 / 9) | round;
def mi: (n / 1609.344 * 10 | round) / 10;
def hrs: (n / 360 | round) / 10;
# "2026-09-19T23:00" -> "11:00P". Same compact form the wttr version produced.
def hm: .[11:16] as $t | ($t[0:2] | tonumber) as $H
  | (if $H == 0 then 12 elif $H > 12 then $H - 12 else $H end)
  | "\(.):\($t[3:5])\(if $H < 12 then "A" else "P" end)";
def dir16: ["N","NNE","NE","ENE","E","ESE","SE","SSE",
            "S","SSW","SW","WSW","W","WNW","NW","NNW"][(n / 22.5 + 0.5 | floor) % 16];

# Moon, from the date alone -- Open-Meteo has no astronomy beyond sun times, and
# the phase is a clock, not a forecast. JD 2451550.1 is the new moon of
# 2000-01-06; 29.530588853 days is the synodic month. This is the MEAN synodic
# approximation: it ignores the orbit's eccentricity, so it can sit up to about
# half a day off a real ephemeris near the quarters. Fine for a panel, not for
# planning an observation.
def moonp: ((now / 86400 + 2440587.5) - 2451550.1) / 29.530588853
  | . - floor;
def moonname: moonp
  | if   . < 0.0338 or . >= 0.9662 then "new"
    elif . < 0.2162 then "waxing crescent"
    elif . < 0.2838 then "first quarter"
    elif . < 0.4662 then "waxing gibbous"
    elif . < 0.5338 then "full"
    elif . < 0.7162 then "waning gibbous"
    elif . < 0.7838 then "last quarter"
    else "waning crescent" end;
def moonillum: ((1 - (6.283185307179586 * moonp | cos)) / 2 * 100) | round;

.current as $c
| .daily as $d
| .hourly as $h
| ($c.temperature_2m - $c.dew_point_2m | round) as $spread
| "\(A)\(C) \(.latitude), \(.longitude) · \(.elevation)m   \(A)\(C) \($c.time|hm)",
  "\(A)\(C) \($c.temperature_2m|tcol)\($c.temperature_2m|round)°F\(C) / \($c.temperature_2m|f2c)°C   \(A)\(C) feels \($c.apparent_temperature|tcol)\($c.apparent_temperature|round)°F\(C)   \(A)\($c.weather_code|wxicon)\(C) \($c.weather_code|desc)",
  "\(A)\(C) \($c.relative_humidity_2m)% hum · dew \($c.dew_point_2m|round)°F · cloud \($c.cloud_cover)%",
  "\(A)\(C) \($c.wind_direction_10m|dir16) \($c.wind_speed_10m|round) mph · gust \($c.wind_gusts_10m|round)   \(A)\(C) \($c.pressure_msl|round) mb",
  "\(A)\(C) uv \($c.uv_index|uvcol)\($c.uv_index|round)\(C) · \($d.sunshine_duration[0]|hrs)h sun   \(A)\(C) \($d.precipitation_probability_max[0]|pcol)\($d.precipitation_probability_max[0])% rain\(C)   \(A)\(C) \($c.visibility|mi) mi",
  "\(A)\(C) cape \($c.cape|capecol)\($c.cape|round)\(C) · spread \($spread)°F · precip \($c.precipitation | (. * 100 | round) / 100)\"",
  "\(A)\(C) \($d.sunrise[0]|hm)\(C) → \($d.sunset[0]|hm)\(C)   \(A)\(C) \(moonname) \(moonillum)%",
  "${color1}today ${color2}┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈\(C)",
  # Eight rows, every third hour of today, because the panel's HEIGHT is pinned
  # (see conky.conf) and wttr's 3-hourly block was eight rows. Open-Meteo is
  # hourly, so it is sampled rather than taken whole.
  (range(0; 8) | (. * 3) as $i
   | "  \(($h.time[$i][11:13] | tonumber | tostring | (" " * (2 - length)) + .)):00  \($h.temperature_2m[$i]|tcol)\($h.temperature_2m[$i]|round)°F\(C)  \($h.precipitation_probability[$i]|pcol)\($h.precipitation_probability[$i])%\(C)  \(A)\($h.weather_code[$i]|wxicon)\(C) \($h.weather_code[$i]|desc)"),
  "${color1}forecast ${color2}┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈\(C)",
  (range(0; 3) | . as $i
   | "  \($d.time[$i][5:10])  \($d.temperature_2m_min[$i]|tcol)\($d.temperature_2m_min[$i]|round)\(C)-\($d.temperature_2m_max[$i]|tcol)\($d.temperature_2m_max[$i]|round)°F\(C)  uv \($d.uv_index_max[$i]|uvcol)\($d.uv_index_max[$i]|round)\(C)  \($d.precipitation_probability_max[$i]|pcol)\($d.precipitation_probability_max[$i])%\(C)  \(A)\($d.weather_code[$i]|wxicon)\(C) \($d.weather_code[$i]|desc)")
