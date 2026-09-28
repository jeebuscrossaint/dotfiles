# Renders ~/todo.md for conky-todo.conf. ${execpi}, so the output is parsed:
# a literal $ in the file has to go out as $$.
#
# Long items WRAP with a hanging indent instead of being cut -- conky clips past
# the window edge mid-character.
BEGIN {
    if (width == 0) width = 48
    box = "\357\202\226"    # nf-fa-square_o
    tick = "\357\201\206"   # nf-fa-check_square_o
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

/^#+ / {
    sub(/^#+ +/, "", s)
    rule = ""
    for (i = length(s) + 1; i < width; i++) rule = rule "┈"
    print "${color1}" s " ${color2}" rule "${color}"
    next
}

s ~ /^[-*] \[[xX]\] / { emit(ind "${color2}" tick " ", substr(s, 7), ind "  ", "${color2}"); next }
s ~ /^[-*] \[ \] /    { emit(ind "${color2}" box " ${color}", substr(s, 7), ind "  ", ""); next }
s ~ /^[-*] /          { emit(ind "${color2}· ${color}", substr(s, 3), ind "  ", ""); next }
s == ""               { print ""; next }
                      { emit(ind, s, ind, "") }
