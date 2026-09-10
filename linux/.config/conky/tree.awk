# Colours pstree by DEPTH, for conky.
#
# Real depth, not indent width. pstree puts a parent and its first child on the
# same line -- "runsv───login───fish" is three depths in one line -- and the
# indent of a continuation line is the width of the ancestor NAMES above it, so
# nothing about a line's leading whitespace tells you how deep it is. So the
# columns are learned instead: a name's column is registered with its depth the
# first time that column is drawn, and because pstree walks depth-first, the
# column of a "├─child" is always registered by the earlier "parent─┬─child"
# line that opened it. Within a line each connector run means one level down.
#
# Branch characters are coloured as the child they lead into, and a "│" rail as
# the level it belongs to, so a rail keeps one colour down its whole length.
#
# Emits ${colorN} rather than hex so the ramp lives in the conky config with the
# rest of the theme, which means it follows coat. The caller must use ${execpi},
# not ${execi} -- execi does not parse conky variables in its output and the
# colour codes would print literally.
#
# Truncation happens here, not in cut(1): cut -c counts BYTES, so it clips
# mid-character on the three-byte box drawing, and it cannot see the colour codes
# either. gawk in a UTF-8 locale counts characters.
BEGIN {
    if (width == 0) width = 104
    if (slots == 0) slots = 8      # color2..color9; deeper than that shares the floor
    box = "│├└─┬┐┘"
}
{
    line = substr($0, 1, width)
    n = length(line)
    out = ""
    seen = 0
    depth = 0
    for (i = 1; i <= n; ) {
        ch = substr(line, i, 1)
        if (ch == " ") { out = out ch; i++; continue }
        if (index(box, ch) > 0) {
            if (ch == "│") {
                out = out col(rail[i]) ch
                i++
                continue
            }
            # A connector or a "├─"/"└─": runs unbroken into the name it opens.
            for (j = i; j <= n && index(box, substr(line, j, 1)) > 0; j++) ;
            out = out col(seen ? depth + 1 : known(j)) substr(line, i, j - i)
            i = j
            continue
        }
        # A name. Its depth is one below the last name on this line, or -- if it
        # is the first -- whatever this column was registered as.
        depth = seen ? depth + 1 : known(i)
        seen = 1
        first = depth
        colmap[i] = depth
        if (i >= 3) rail[i - 2] = depth
        for (j = i; j <= n && index(box, substr(line, j, 1)) == 0; j++) ;
        out = out col(depth) substr(line, i, j - i)
        i = j
    }
    print out "${color}"
}

# An unregistered column only happens on the root line (nothing registered yet)
# or past a truncation, where the previous line's depth is the best guess.
function known(c)
{
    return (c in colmap) ? colmap[c] : (c == 1 ? 0 : first)
}

function col(d)
{
    if (d == "" || d < 0) d = 0
    if (d >= slots) d = slots - 1
    return "${color" (d + 2) "}"
}
