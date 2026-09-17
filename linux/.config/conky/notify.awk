# Turns the notification bus into a log conky can tail.
#
# Caught off the bus as they are sent, not read back from the daemon. dunst does
# keep history (`dunstctl history`), but it is a JSON ring buffer capped at
# history_length and it is not a stream -- conky wants a file it can tail. mango
# starts the dbus-monitor that feeds this.
#
# A Notify call carries its strings in a fixed order: app_name, app_icon,
# summary, body. So n==1 is the app, n==3 the summary and n==4 the body, and the
# body is optional. Getting that off by one prints the body and drops the
# summary, which looks plausible enough to miss.
#
# fflush matters: without it awk buffers and the log only lands in chunks, so a
# notification can sit invisible for a long time.

/member=Notify/ { n = 0; app = ""; sum = "" }
/^   string/ {
    n++
    s = $0
    sub(/^   string "/, "", s)
    sub(/"$/, "", s)
    if (n == 1) app = s
    if (n == 3) sum = s
    if (n == 4) {
        line = sum
        if (s != "") line = line " · " s
        print strftime("%H:%M") "  " app "  " line
        fflush()
    }
}
