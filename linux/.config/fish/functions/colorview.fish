# Print a swatch of a hex colour using a truecolor background cell.
function colorview --argument hex
    set hex (string replace -r '^#?' '' -- $hex)
    set r (string sub -s 1 -l 2 $hex)
    set g (string sub -s 3 -l 2 $hex)
    set b (string sub -s 5 -l 2 $hex)
    printf "\033[48;2;%d;%d;%dm     \033[0m %s\n" \
        (printf "%d" "0x$r") \
        (printf "%d" "0x$g") \
        (printf "%d" "0x$b") \
        $hex
end
