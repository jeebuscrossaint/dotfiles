# Formats ~/.cache/conky-wx.json (wttr.in ?format=j1) into conky's weather block.
#
# In a file, not inline in conky.conf, because conky silently truncates an exec
# command past roughly 200 characters -- no error, no partial output, just an
# empty block. That is the whole reason this file exists.
.current_condition[0] as $c
| .weather as $w
| "now   \($c.temp_F)°F    feels \($c.FeelsLikeF)°F",
  "sky   \($c.weatherDesc[0].value)",
  "hum   \($c.humidity)%     uv \($c.uvIndex)   cloud \($c.cloudcover)%",
  "wind  \($c.winddir16Point) \($c.windspeedMiles) mph",
  "baro  \($c.pressure) mb   vis \($c.visibility) mi",
  "sun   \($w[0].astronomy[0].sunrise|ltrimstr("0")) - \($w[0].astronomy[0].sunset|ltrimstr("0"))",
  "moon  \($w[0].astronomy[0].moon_phase)",
  ($w[] | "\(.date[5:10]) \(.mintempF)-\(.maxtempF)°F  \(.hourly[4].weatherDesc[0].value)")
