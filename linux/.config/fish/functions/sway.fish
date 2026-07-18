# Launch sway inside a single D-Bus session so the whole graphical session
# shares one session bus. Without this, apps autolaunch separate buses and
# Firefox's "open URL in existing window" remote (a D-Bus name) can't be found,
# giving the "Firefox is already running, but is not responding" error.
function sway --wraps sway --description 'sway wrapped in a dbus session'
    if set -q DBUS_SESSION_BUS_ADDRESS
        # Already inside a session bus (e.g. nested) — just run sway.
        exec /usr/bin/sway $argv
    else
        exec dbus-run-session -- /usr/bin/sway $argv
    end
end
