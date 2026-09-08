# Formats ~/.cache/conky-wx.json (wttr.in ?format=j1) into conky's weather block.
#
# In a file, not inline in conky.conf, because conky silently truncates an exec
# command past roughly 200 characters -- no error, no partial output, just an
# empty block. That is the whole reason this file exists.
#
# The icons are Nerd Font glyphs, each one checked against the actual font with
# fc-query before being used. A codepoint the font lacks renders as a tofu box
# and there is no warning for that either.
.current_condition[0] as $c
| .weather as $w
| .nearest_area[0] as $a
| $w[0].astronomy[0] as $as
| ($w[0].hourly | map(select((.time|tonumber/100|floor) <= (now|strflocaltime("%H")|tonumber))) | last // $w[0].hourly[0]) as $h
| " \($a.areaName[0].value), \($a.region[0].value)",
  " \($a.latitude), \($a.longitude)    \($c.observation_time)",
  "",
  " \($c.temp_F)°F / \($c.temp_C)°C    feels \($c.FeelsLikeF)°F",
  " \($c.weatherDesc[0].value)",
  " \($c.humidity)% hum · dew \($h.DewPointF)°F · cloud \($c.cloudcover)%",
  " \($c.winddir16Point) \($c.winddirDegree)° \($c.windspeedMiles) mph · gust \($h.WindGustMiles)",
  " \($c.pressure) mb / \($c.pressureInches) inHg    \($c.visibilityMiles) mi",
  " uv \($c.uvIndex) · \($w[0].sunHour)h sun    \($h.chanceofrain)% rain",
  " thunder \($h.chanceofthunder)% · fog \($h.chanceoffog)% · precip \($c.precipInches)\"",
  "",
  " \($as.sunrise|ltrimstr("0")) → \($as.sunset|ltrimstr("0"))",
  " \($as.moon_phase) \($as.moon_illumination)% · \($as.moonrise|ltrimstr("0")) → \($as.moonset|ltrimstr("0"))",
  "",
  " today",
  ($w[0].hourly[] | "  \((.time|tonumber/100|floor|tostring|(" "*(2-length))+.)):00  \(.tempF)°F  \(.chanceofrain)%  \(.weatherDesc[0].value)"),
  "",
  " forecast",
  ($w[] | "  \(.date[5:10])  \(.mintempF)-\(.maxtempF)°F  avg \(.avgtempF)°F  uv \(.uvIndex)",
          "           \(.hourly[4].chanceofrain)%  \(.hourly[4].weatherDesc[0].value)")
