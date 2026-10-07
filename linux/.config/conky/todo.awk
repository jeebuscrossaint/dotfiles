# Renders ~/todo.md under the weather in conky-left.conf. ${execpi}, so the output is parsed:
# a literal $ in the file has to go out as $$.
#
# Long items WRAP with a hanging indent instead of being cut -- conky clips past
# the window edge mid-character.
BEGIN {
    if (width == 0) width = 48
    pad = "     "
    label = pad
}

function emit(pre, text, hang, colour,    room, cut) {
    room = width - length(hang)
    while (length(text) > room) {
        cut = room
        while (cut > 1 && substr(text, cut, 1) != " ") cut--
        if (cut <= 1) cut = room
        print pre colour substr(text, 1, cut - (substr(text, cut, 1) == " ")) "${color}"
        text = substr(text, cut + 1)
        sub(/^ +/, "", text)
        pre = hang
    }
    print pre colour text "${color}"
}

{
    gsub(/\$/, "$$")
    match($0, /^ */)
    ind = substr($0, 1, RLENGTH)
    s = substr($0, RLENGTH + 1)
}

# A heading becomes the dim label on the line after it, like the other panels.
/^#+ / {
    sub(/^#+ +/, "", s)
    label = length(s) < 5 ? "${color2}" s substr(pad, 1, 5 - length(s)) "${color}" : "${color2}" s "${color}\n" pad
    next
}

function lead() { l = label; label = pad; return l }

s ~ /^[-*] \[[xX]\] / { emit(lead() ind, substr(s, 7), pad ind, "${color2}"); next }
s ~ /^[-*] \[ \] /    { emit(lead() ind, substr(s, 7), pad ind, ""); next }
s ~ /^[-*] /          { emit(lead() ind, substr(s, 3), pad ind, ""); next }
s == ""               { next }
                      { emit(lead() ind, s, pad ind, "") }
