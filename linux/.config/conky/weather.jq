# Formats ~/.cache/conky-wx.json (wttr.in ?format=j1) into conky's weather block.
#
# In a file, not inline in conky.conf, because conky silently truncates an exec
# command past roughly 200 characters -- no error, no partial output, just an
# empty block. That is the whole reason this file exists.
.current_condition[0] as $c
| .weather as $w
| .nearest_area[0] as $a
| $w[0].astronomy[0] as $as
| ($w[0].hourly | map(select((.time|tonumber/100|floor) <= (now|strflocaltime("%H")|tonumber))) | last // $w[0].hourly[0]) as $h
| "loc   \($a.areaName[0].value), \($a.region[0].value)",
  "coord \($a.latitude), \($a.longitude)",
  "obs   \($c.observation_time)",
  "",
  "temp  \($c.temp_F)°F / \($c.temp_C)°C",
  "feels \($c.FeelsLikeF)°F / \($c.FeelsLikeC)°C",
  "sky   \($c.weatherDesc[0].value)",
  "dew   \($h.DewPointF)°F    heat idx \($h.HeatIndexF)°F",
  "hum   \($c.humidity)%      cloud \($c.cloudcover)%",
  "uv    \($c.uvIndex)        vis \($c.visibilityMiles) mi",
  "wind  \($c.winddir16Point) \($c.winddirDegree)° \($c.windspeedMiles) mph",
  "gust  \($h.WindGustMiles) mph",
  "baro  \($c.pressure) mb / \($c.pressureInches) inHg",
  "rain  \($c.precipInches)\" now   \($h.chanceofrain)% chance",
  "risk  thunder \($h.chanceofthunder)%  fog \($h.chanceoffog)%",
  "sun   \($h.chanceofsunshine)% sunshine  \($w[0].sunHour)h daylight",
  "",
  "rise  \($as.sunrise|ltrimstr("0"))   set \($as.sunset|ltrimstr("0"))",
  "moon  \($as.moon_phase) \($as.moon_illumination)%",
  "mrise \($as.moonrise|ltrimstr("0"))   set \($as.moonset|ltrimstr("0"))",
  "",
  "today hourly",
  ($w[0].hourly[] | "  \((.time|tonumber/100|floor|tostring|(" "*(2-length))+.)):00 \(.tempF)°F  rain \(.chanceofrain)%  \(.weatherDesc[0].value)"),
  "",
  "forecast",
  ($w[] | "  \(.date[5:10])  \(.mintempF)-\(.maxtempF)°F avg \(.avgtempF)°F  uv \(.uvIndex)",
          "          \(.hourly[4].weatherDesc[0].value), rain \(.hourly[4].chanceofrain)%")
