# Formats ~/.cache/conky-wx.json (wttr.in ?format=j1) into conky's weather block.
#
# In a file, not inline in conky.conf, because conky silently truncates an exec
# command past roughly 200 characters -- no error, no partial output, just an
# empty block. That is the whole reason this file exists.
#
# Icons are Nerd Font glyphs, each checked against the font with fc-query before
# use; a codepoint the font lacks renders as a tofu box with no warning.
#
# Colour is by MEANING, not decoration: temperature by how hot, rain by how
# likely, UV by how much it will hurt -- so the block reads at a glance without
# parsing the numbers. Colour SLOTS rather than hex, so the palette lives in the
# conky config and follows coat. That also means the caller must use execpi:
# execi does not parse conky variables in its output and these would print raw.
def desc: .weatherDesc[0].value | .[0:18];
def n: tonumber? // 0;

# 3 hot, 4 warm, 5 mild, 6 cool, 7 cold
def tcol: if n >= 90 then "${color3}" elif n >= 78 then "${color4}"
          elif n >= 65 then "${color5}" elif n >= 45 then "${color6}"
          else "${color7}" end;
def pcol: if n >= 60 then "${color7}" elif n >= 30 then "${color6}" else "${color2}" end;
def uvcol: if n >= 8 then "${color3}" elif n >= 6 then "${color4}"
           elif n >= 3 then "${color5}" else "${color6}" end;
def C: "${color}";
def A: "${color1}";
def hm: ltrimstr("0") | sub(" (?<a>[AP])M$"; "\(.a)");
def wxicon: {"113":"","116":"","119":"","122":"","143":"","176":"","179":"","182":"","185":"","200":"","227":"","230":"","248":"","260":"","263":"","266":"","281":"","284":"","293":"","296":"","299":"","302":"","305":"","308":"","311":"","314":"","317":"","320":"","323":"","326":"","329":"","332":"","335":"","338":"","350":"","353":"","356":"","359":"","362":"","365":"","368":"","371":"","374":"","377":"","386":"","389":"","392":"","395":""}[.weatherCode] // "";

.current_condition[0] as $c
| .weather as $w
| .nearest_area[0] as $a
| $w[0].astronomy[0] as $as
| ($w[0].hourly | map(select((.time|tonumber/100|floor) <= (now|strflocaltime("%H")|tonumber))) | last // $w[0].hourly[0]) as $h
| "\(A)\(C) \($a.areaName[0].value), \($a.region[0].value)   \(A)\(C) \($c.observation_time|hm)",
  "\(A)\(C) \($c.temp_F|tcol)\($c.temp_F)°F\(C) / \($c.temp_C)°C   \(A)\(C) feels \($c.FeelsLikeF|tcol)\($c.FeelsLikeF)°F\(C)   \(A)\($c|wxicon)\(C) \($c|desc)",
  "\(A)\(C) \($c.humidity)% hum · dew \($h.DewPointF)°F · cloud \($c.cloudcover)%",
  "\(A)\(C) \($c.winddir16Point) \($c.windspeedMiles) mph · gust \($h.WindGustMiles)   \(A)\(C) \($c.pressure) mb",
  "\(A)\(C) uv \($c.uvIndex|uvcol)\($c.uvIndex)\(C) · \($w[0].sunHour)h sun   \(A)\(C) \($h.chanceofrain|pcol)\($h.chanceofrain)% rain\(C)   \(A)\(C) \($c.visibilityMiles) mi",
  "\(A)\(C) thunder \($h.chanceofthunder|pcol)\($h.chanceofthunder)%\(C) · fog \($h.chanceoffog)% · precip \($c.precipInches)\"",
  "\(A)\(C) ${color5}\($as.sunrise|hm)\(C) → ${color4}\($as.sunset|hm)\(C)   \(A)\(C) \($as.moon_phase) \($as.moon_illumination)%",
  "${color2}──────────────────────────────────────────────────────────────────────────────────────────\(C)",
  "\(A)\(C) today",
  ($w[0].hourly[] | "  \((.time|tonumber/100|floor|tostring|(" "*(2-length))+.)):00  \(.tempF|tcol)\(.tempF)°F\(C)  \(.chanceofrain|pcol)\(.chanceofrain)%\(C)  \(A)\(.|wxicon)\(C) \(.|desc)"),
  "${color2}──────────────────────────────────────────────────────────────────────────────────────────\(C)",
  "\(A)\(C) forecast",
  ($w[] | "  \(.date[5:10])  \(.mintempF|tcol)\(.mintempF)\(C)-\(.maxtempF|tcol)\(.maxtempF)°F\(C)  uv \(.uvIndex|uvcol)\(.uvIndex)\(C)  \(.hourly[4].chanceofrain|pcol)\(.hourly[4].chanceofrain)%\(C)  \(A)\(.hourly[4]|wxicon)\(C) \(.hourly[4]|desc)")
