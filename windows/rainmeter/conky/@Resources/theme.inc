; Shared by both panels. The fallbacks are palette.lua's, for when coat has not
; written coat.inc yet; the @Include comes LAST so coat's values win.
[Variables]
Font=SFMono Nerd Font Mono
SizeDesktop=11
SizeTerminal=11
Alpha=255
base00=1C1C1C
base03=505050
base05=D0D0D0
base08=F28B82
@Include=%USERPROFILE%\.config\rainmeter\coat.inc

; Readout lines are dim label + full-weight value, like conky.conf. The Lua
; scripts wrap spans in invisible marker characters, and these patterns colour
; what is between them -- per span, not per substring, so the same "92" can be
; red in one place and plain in another:
;   U+2061 .. U+2060  dim      (conky ${color2})
;   U+2062 .. U+2060  alert    (conky ${color3})
; All three are default-ignorable code points and render with zero width.
;
; readout.lua and day.lua MUST stay UTF-16 LE with a BOM. That BOM is the only
; thing that makes Rainmeter trade strings with a script as UTF-8; without it
; they go through the ANSI codepage and every glyph above turns to mojibake.
; (json.lua is plain ASCII on purpose: Lua's own dofile loads it.)
DimPattern=\x{2061}([^\x{2060}]*)\x{2060}
AlertPattern=\x{2062}([^\x{2060}]*)\x{2060}
