# Formats ~/.cache/conky-wx.json into conky's weather block.
#
# In a file, not inline in conky.conf, because conky silently truncates an exec
# command past roughly 200 characters -- no error, no partial output, just an
# empty block. That is the whole reason this file exists.
#
# Source is Open-Meteo, merged by weather-fetch with an AQI and NWS alerts. It
# replaced wttr.in on 2026-09-19: wttr's observations measured 1-2 HOURS stale,
# which no polling interval can fix. Open-Meteo reports `interval: 900`.
#
# Scope is deliberately a WEATHER SITE, not a sounding: what it is doing now, the
# hours ahead, the days ahead. It briefly carried CAPE, lifted index, soil
# temperatures, radiation and a 15-minute nowcast, and the panel stopped being
# readable at a glance -- which is the only thing a desktop readout is for.
#
# The hourly block runs FORWARD FROM NOW, not from midnight. Anchored on the
# calendar day it spent most of the afternoon listing hours that had already
# happened.
#
# Icons are Nerd Font glyphs, each already checked against the font with
# fc-query; a codepoint the font lacks renders as a tofu box with no warning.
# Descriptions are written out at most 19 characters rather than sliced, which is
# what sets the panel width -- slicing lands mid-word ("Violent rain show").
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

# Weight, not hue: an ordinary reading is text, a quiet one drops to the dim
# tier, and only an extreme reaches the alert -- so one thing stands out rather
# than everything shouting. conky.conf holds the palette; this decides which
# values earn it.
def tcol: if n >= 90 then "${color3}" else "${color}" end;
def pcol: if n >= 60 then "${color}" else "${color2}" end;
def uvcol: if n >= 8 then "${color3}" else "${color}" end;
def aqicol: if n >= 100 then "${color3}" elif n >= 50 then "${color}" else "${color2}" end;
def C: "${color}";
def A: "${color2}";

def f2c: ((n - 32) * 5 / 9) | round;
# Open-Meteo switches ALL lengths to imperial when precipitation_unit=inch, so
# visibility arrives in FEET. Check current_units in the response, not the docs.
def mi: (n / 5280 * 10 | round) / 10;
# "2026-09-20T14:00" -> "2:00P", and -> "2P" for the compact hourly column.
def hm: .[11:16] as $t | ($t[0:2] | tonumber) as $H
  | (if $H == 0 then 12 elif $H > 12 then $H - 12 else $H end)
  | "\(.):\($t[3:5])\(if $H < 12 then "A" else "P" end)";
def h12: (.[11:13] | tonumber) as $H
  | (if $H == 0 then 12 elif $H > 12 then $H - 12 else $H end)
  | "\(.)\(if $H < 12 then "A" else "P" end)";
def dir16: ["N","NNE","NE","ENE","E","ESE","SE","SSE",
            "S","SSW","SW","WSW","W","WNW","NW","NNW"][(n / 22.5 + 0.5 | floor) % 16];

# Moon, from the date alone -- Open-Meteo has no astronomy beyond sun times, and
# the phase is a clock, not a forecast. JD 2451550.1 is the new moon of
# 2000-01-06; 29.530588853 days is the synodic month. Mean synodic, so it can sit
# up to about half a day off a real ephemeris near the quarters.
def moonp: ((now / 86400 + 2440587.5) - 2451550.1) / 29.530588853 | . - floor;
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

.wx as $w
| $w.current as $c
| $w.daily as $d
| $w.hourly as $h
| (.aq.current.us_aqi // null) as $aqi
| (.alerts.features // []) as $al
| (if (.loc.city // "") == "" then "\($w.latitude), \($w.longitude)"
   else "\(.loc.city), \(.loc.region_code // "")" end) as $place
# Index of the hour containing "now", so the block runs forward instead of from
# midnight. Falls back to 0 if the array does not cover it.
| (($h.time | map(.[0:13]) | index($c.time[0:13])) // 0) as $i0
| "\(A)\(C) \($place)   \(A)\(C) \($c.time|hm)",
  "\(A)\(C) \($c.temperature_2m|tcol)\($c.temperature_2m|round)°F\(C) / \($c.temperature_2m|f2c)°C · feels \($c.apparent_temperature|tcol)\($c.apparent_temperature|round)°F\(C)   \(A)\($c.weather_code|wxicon)\(C) \($c.weather_code|desc)",
  "\(A)\(C) hi \($d.temperature_2m_max[0]|tcol)\($d.temperature_2m_max[0]|round)\(C) · lo \($d.temperature_2m_min[0]|round)°F · \($d.precipitation_probability_max[0]|pcol)\($d.precipitation_probability_max[0])% rain\(C)",
  "\(A)\(C) \($c.relative_humidity_2m)% hum · dew \($c.dew_point_2m|round)°F   \(A)\(C) \($c.wind_direction_10m|dir16) \($c.wind_speed_10m|round) g\($c.wind_gusts_10m|round) mph",
  "\(A)\(C) \($c.pressure_msl|round) mb · \($c.visibility|mi) mi · uv \($c.uv_index|uvcol)\($c.uv_index|round)\(C)\(if $aqi == null then "" else " · aqi \($aqi|aqicol)\($aqi)\(C)" end)",
  "\(A)\(C) \($d.sunrise[0]|hm)\(C) → \($d.sunset[0]|hm)   \(A)\(C) \(moonname) \(moonillum)%",
  # Alerts draw ONLY when something is active -- a permanent "none active" row is
  # a line of furniture on a panel that is mostly quiet. Capped at two because
  # conky.conf pins the panel height and it has to be the worst case.
  ($al[0:2][] | "\(A)${color3} \(.properties.event // "alert" | .[0:44])\(C)"),
  "${color1}hourly ${color2}┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈\(C)",
  (range(0; 8) | ($i0 + . * 3) as $i | select($h.time[$i] != null)
   | "  \(($h.time[$i]|h12) | (" " * (3 - length)) + .)  \($h.temperature_2m[$i]|tcol)\($h.temperature_2m[$i]|round)°F\(C)  \($h.precipitation_probability[$i]|pcol)\($h.precipitation_probability[$i])%\(C)  \(A)\($h.weather_code[$i]|wxicon)\(C) \($h.weather_code[$i]|desc)"),
  "${color1}forecast ${color2}┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈\(C)",
  (range(0; 3) | . as $i
   | "  \($d.time[$i] | strptime("%Y-%m-%d") | mktime | strftime("%a"))  \($d.temperature_2m_min[$i]|round)-\($d.temperature_2m_max[$i]|tcol)\($d.temperature_2m_max[$i]|round)°F\(C)  uv \($d.uv_index_max[$i]|uvcol)\($d.uv_index_max[$i]|round)\(C)  \($d.precipitation_probability_max[$i]|pcol)\($d.precipitation_probability_max[$i])%\(C)  \(A)\($d.weather_code[$i]|wxicon)\(C) \($d.weather_code[$i]|desc)")
