# Formats ~/.cache/conky-wx.json (wttr.in ?format=j1) into conky's weather block.
#
# In a file, not inline in conky.conf, because conky silently truncates an exec
# command past roughly 200 characters -- no error, no partial output, just an
# empty block. That is the whole reason this file exists.
#
# Icons are Nerd Font glyphs, each checked against the font with fc-query before
# use; a codepoint the font lacks renders as a tofu box with no warning.
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
# wttr's descriptions run to 43 characters -- "Moderate or heavy snow in area
# with thunder" -- and this panel is 55 columns wide including everything left of
# them. Slicing a long one lands mid-word ("Moderate or heav"), so the long ones
# are NAMED AGAIN here instead, at most 19 characters, which is what sets the
# panel width. Anything not listed is already short enough and passes through; the
# slice at the end is a backstop for a description wttr adds later, not the normal
# path. Both spellings of the "nearby"/"possible" codes are listed because wttr
# has used each, and the values carry stray leading and trailing spaces, so the
# lookup is on a trimmed string.
def short: {
  "Patchy rain possible": "Patchy rain nearby",
  "Patchy snow possible": "Patchy snow nearby",
  "Patchy sleet possible": "Patchy sleet nearby",
  "Patchy freezing drizzle nearby": "Icy drizzle nearby",
  "Patchy freezing drizzle possible": "Icy drizzle nearby",
  "Thundery outbreaks in nearby": "Thundery outbreaks",
  "Thundery outbreaks possible": "Thundery outbreaks",
  "Patchy light drizzle": "Patchy drizzle",
  "Heavy freezing drizzle": "Heavy icy drizzle",
  "Moderate rain at times": "Rain at times",
  "Moderate or heavy freezing rain": "Heavy icy rain",
  "Moderate or heavy sleet": "Heavy sleet",
  "Patchy moderate snow": "Patchy snow",
  "Moderate or heavy rain shower": "Heavy rain shower",
  "Torrential rain shower": "Torrential rain",
  "Moderate or heavy sleet showers": "Heavy sleet shower",
  "Moderate or heavy snow showers": "Heavy snow showers",
  "Light showers of ice pellets": "Light ice pellets",
  "Moderate or heavy showers of ice pellets": "Heavy ice pellets",
  "Patchy light rain in area with thunder": "Light rain, thunder",
  "Moderate or heavy rain in area with thunder": "Heavy rain, thunder",
  "Patchy light snow in area with thunder": "Light snow, thunder",
  "Moderate or heavy snow in area with thunder": "Heavy snow, thunder"
};
def desc: (.weatherDesc[0].value | sub("^ +"; "") | sub(" +$"; "")) as $d
          | (short[$d] // $d) | .[0:19];
def n: tonumber? // 0;

# Weight, not hue, matching the panel: an ordinary reading is text, a quiet one
# drops to the dim tier, and only an extreme reaches the alert. Colouring every
# band meant a row changed colour two or three times and a mild reading was as
# loud as a dangerous one, so nothing stood out. Which values deserve it is
# decided here; conky.conf only holds the palette.
def tcol: if n >= 90 then "${color3}" else "${color}" end;
def pcol: if n >= 60 then "${color}" else "${color2}" end;
def uvcol: if n >= 8 then "${color3}" else "${color}" end;
def C: "${color}";
def A: "${color2}";
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
  "\(A)\(C) \($as.sunrise|hm)\(C) → \($as.sunset|hm)\(C)   \(A)\(C) \($as.moon_phase) \($as.moon_illumination)%",
  "${color1}today ${color2}┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈\(C)",
  ($w[0].hourly[] | "  \((.time|tonumber/100|floor|tostring|(" "*(2-length))+.)):00  \(.tempF|tcol)\(.tempF)°F\(C)  \(.chanceofrain|pcol)\(.chanceofrain)%\(C)  \(A)\(.|wxicon)\(C) \(.|desc)"),
  "${color1}forecast ${color2}┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈\(C)",
  ($w[] | "  \(.date[5:10])  \(.mintempF|tcol)\(.mintempF)\(C)-\(.maxtempF|tcol)\(.maxtempF)°F\(C)  uv \(.uvIndex|uvcol)\(.uvIndex)\(C)  \(.hourly[4].chanceofrain|pcol)\(.hourly[4].chanceofrain)%\(C)  \(A)\(.hourly[4]|wxicon)\(C) \(.hourly[4]|desc)")
