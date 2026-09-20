# Formats ~/.cache/conky-wx.json into conky's weather block.
#
# In a file, not inline in conky.conf, because conky silently truncates an exec
# command past roughly 200 characters -- no error, no partial output, just an
# empty block. That is the whole reason this file exists.
#
# Source is Open-Meteo, merged by weather-fetch with air quality and NWS alerts.
# It replaced wttr.in on 2026-09-19: wttr's observations measured 1-2 HOURS
# stale, which no polling interval can fix. Open-Meteo reports `interval: 900`.
#
# Scope is TODAY. Every reading Open-Meteo publishes for right now is drawn, and
# the hours ahead run to midnight and stop -- no multi-day forecast. Depth on the
# present instead of reach into a future that is mostly guesswork was the call;
# the panel's height cannot buy both. Days are one `forecast_days` away in
# weather-fetch if that ever changes.
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
# 2500 J/kg is where forecasters stop calling instability moderate; below 1000
# there is nothing to build a storm out of. A lifted index under -4 is the number
# read as strongly unstable, above 0 the air will not lift on its own at all.
def capecol: if n >= 2500 then "${color3}" elif n >= 1000 then "${color}" else "${color2}" end;
def licol: if n <= -4 then "${color3}" elif n <= 0 then "${color}" else "${color2}" end;
def C: "${color}";
def A: "${color2}";

def f2c: ((n - 32) * 5 / 9) | round;
def d1: (n * 10 | round) / 10;
def d2: (n * 100 | round) / 100;
# Open-Meteo switches ALL lengths to imperial when precipitation_unit=inch, so
# visibility, freezing_level_height and boundary_layer_height all arrive in FEET.
# Check current_units in the response, not the docs. (elevation stays metres --
# it is response metadata, not a unit-switched reading.)
def mi: (n / 5280 * 10 | round) / 10;
def hm: .[11:16] as $t | ($t[0:2] | tonumber) as $H
  | (if $H == 0 then 12 elif $H > 12 then $H - 12 else $H end)
  | "\(.):\($t[3:5])\(if $H < 12 then "A" else "P" end)";
def h12: (.[11:13] | tonumber) as $H
  | (if $H == 0 then 12 elif $H > 12 then $H - 12 else $H end)
  | "\(.)\(if $H < 12 then "A" else "P" end)";
def dur: (n / 3600 | floor) as $h | ((n % 3600) / 60 | floor) | "\($h)h\(.)m";
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
| (.aq.current // {}) as $q
| (.alerts.features // []) as $al
| (if (.loc.city // "") == "" then "\($w.latitude), \($w.longitude)"
   else "\(.loc.city), \(.loc.region_code // "")" end) as $place
| (($h.time | map(.[0:13]) | index($c.time[0:13])) // 0) as $i0
| "\(A)\(C) \($place)   \(A)\(C) \($c.time|hm)",
  "\(A)\(C) \($c.temperature_2m|tcol)\($c.temperature_2m|round)°F\(C) / \($c.temperature_2m|f2c)°C · feels \($c.apparent_temperature|tcol)\($c.apparent_temperature|round)°F\(C)   \(A)\($c.weather_code|wxicon)\(C) \($c.weather_code|desc)",
  "\(A)\(C) hi \($d.temperature_2m_max[0]|tcol)\($d.temperature_2m_max[0]|round)\(C) · lo \($d.temperature_2m_min[0]|round)°F · \($d.precipitation_probability_max[0]|pcol)\($d.precipitation_probability_max[0])% rain\(C)",
  "\(A)\(C) \($c.relative_humidity_2m)% hum · dew \($c.dew_point_2m|round)°F · spread \($c.temperature_2m - $c.dew_point_2m|round)° · vpd \($c.vapour_pressure_deficit|d2)",
  "\(A)\(C) \($c.wind_direction_10m|dir16) \($c.wind_speed_10m|round) g\($c.wind_gusts_10m|round) mph · 80m \($c.wind_speed_80m|round) · 180m \($c.wind_speed_180m|round)",
  "\(A)\(C) \($c.pressure_msl|round) mb msl · \($c.surface_pressure|round) sfc · \($c.visibility|mi) mi",
  "\(A)\(C) \($c.cloud_cover)% cloud \(A)·\(C) lo \($c.cloud_cover_low) · mid \($c.cloud_cover_mid) · hi \($c.cloud_cover_high)",
  "\(A)\(C) uv \($c.uv_index|uvcol)\($c.uv_index|round)\(C) · rad \($c.shortwave_radiation|round) \(A)(\(C)\($c.direct_radiation|round) dir · \($c.diffuse_radiation|round) dif\(A))\(C)",
  "\(A)\(C) cape \($c.cape|capecol)\($c.cape|round)\(C) · li \($c.lifted_index|licol)\($c.lifted_index|d1)\(C) · cin \($c.convective_inhibition|round) J/kg",
  "\(A)\(C) frz \($c.freezing_level_height|round) ft · pbl \($c.boundary_layer_height|round) ft · et0 \($c.et0_fao_evapotranspiration|d2)\"",
  "\(A)\(C) soil \($c.soil_temperature_0cm|round)°F/0cm · \($c.soil_temperature_6cm|round)°F/6cm · wet \($c.soil_moisture_0_to_1cm|d2)",
  "\(A)\(C) precip \($c.precipitation|d2)\" now · \($d.precipitation_sum[0]|d2)\" today over \($d.precipitation_hours[0]|round)h",
  (if ($q.us_aqi // null) == null then empty
   else "\(A)\(C) aqi \($q.us_aqi|aqicol)\($q.us_aqi)\(C) · pm2.5 \($q.pm2_5|d1) · pm10 \($q.pm10|d1) · o3 \($q.ozone|round)" end),
  "\(A)\(C) \($d.sunrise[0]|hm)\(C) → \($d.sunset[0]|hm) · \($d.daylight_duration[0]|dur)   \(A)\(C) \(moonname) \(moonillum)%",
  # Alerts draw ONLY when something is active -- a permanent "none active" row is
  # furniture on a panel that is mostly quiet. Capped at two because conky.conf
  # pins the panel height and it has to be the worst case.
  ($al[0:2][] | "\(A)${color3} \(.properties.event // "alert" | .[0:44])\(C)"),
  "${color1}hourly ${color2}┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈\(C)",
  # EVERY hour from now to midnight -- not every third, which was wttr's shape
  # carried over by mistake; Open-Meteo publishes hourly. Capped at 20 rows
  # because the panel height is pinned to the worst case, and the worst case is
  # reading this at 4am. Past that hour the cap never binds.
  (range(0; 20) | ($i0 + .) as $i | select($h.time[$i] != null)
   | "  \(($h.time[$i]|h12) | (" " * (3 - length)) + .)  \($h.temperature_2m[$i]|tcol)\($h.temperature_2m[$i]|round)°F\(C)  \($h.precipitation_probability[$i]|pcol)\($h.precipitation_probability[$i])%\(C)  \(A)\($h.weather_code[$i]|wxicon)\(C) \($h.weather_code[$i]|desc)")
