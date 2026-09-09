# Formats ~/.cache/conky-wx.json (wttr.in ?format=j1) into conky's weather block.
#
# In a file, not inline in conky.conf, because conky silently truncates an exec
# command past roughly 200 characters -- no error, no partial output, just an
# empty block. That is the whole reason this file exists.
#
# Icons are Nerd Font glyphs, each checked against the font with fc-query before
# use; a codepoint the font lacks renders as a tofu box with no warning.
#
# Descriptions are cut to 18 characters. wttr.in emits things like "Patchy light
# rain in area with thunder", which ran past the right edge of the window and was
# clipped mid-word. Truncating here is better than widening the window to fit the
# worst case, since the window is sized for a desktop widget rather than the
# longest string the API happens to return.
def desc: .weatherDesc[0].value | .[0:18];
def hm: ltrimstr("0") | sub(" (?<a>[AP])M$"; "\(.a)");

.current_condition[0] as $c
| .weather as $w
| .nearest_area[0] as $a
| $w[0].astronomy[0] as $as
| ($w[0].hourly | map(select((.time|tonumber/100|floor) <= (now|strflocaltime("%H")|tonumber))) | last // $w[0].hourly[0]) as $h
| " \($a.areaName[0].value), \($a.region[0].value)    \($c.observation_time|hm)",
  " \($c.temp_F)°F / \($c.temp_C)°C    feels \($c.FeelsLikeF)°F    \($c|desc)",
  " \($c.humidity)% hum · dew \($h.DewPointF)°F · cloud \($c.cloudcover)%",
  " \($c.winddir16Point) \($c.windspeedMiles) mph · gust \($h.WindGustMiles)    \($c.pressure) mb",
  " uv \($c.uvIndex) · \($w[0].sunHour)h sun    \($h.chanceofrain)% rain    \($c.visibilityMiles) mi",
  " thunder \($h.chanceofthunder)% · fog \($h.chanceoffog)% · precip \($c.precipInches)\"",
  " \($as.sunrise|hm) → \($as.sunset|hm)    \($as.moon_phase) \($as.moon_illumination)%",
  "────────────────────────────────────────────",
  " today",
  ($w[0].hourly[] | "  \((.time|tonumber/100|floor|tostring|(" "*(2-length))+.)):00  \(.tempF)°F  \(.chanceofrain)%  \(.|desc)"),
  "────────────────────────────────────────────",
  " forecast",
  ($w[] | "  \(.date[5:10])  \(.mintempF)-\(.maxtempF)°F  uv \(.uvIndex)  \(.hourly[4].chanceofrain)%  \(.hourly[4]|desc)")
