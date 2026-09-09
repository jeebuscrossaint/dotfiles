# Colours pstree by depth, for conky.
#
# Depth is how far the branch characters run before the process name starts, so
# it is measured off the drawing itself rather than recomputed from pids. The
# prefix is box-drawing plus spaces; everything from the first character that is
# neither is the name.
#
# Emits ${colorN} rather than hex so the palette lives in the conky config with
# the rest of the theme, which means it follows coat. The caller must use
# ${execpi}, not ${execi} -- execi does not parse conky variables in its output
# and the colour codes would print literally.
#
# gawk in a UTF-8 locale counts characters here, not bytes; with LC_ALL=C the box
# characters are three bytes each and every depth lands in the last bucket.
BEGIN { n = split("1 7 6 5 4 8 3 2", pal, " ") }
{
    match($0, /^[ │├└─┬┘┐]*/)
    d = int(RLENGTH / 6)
    if (d >= n) d = n - 1
    print "${color" pal[d + 1] "}" $0
}
