# Launch Hyprland inside a single D-Bus session so the whole graphical session
# shares one session bus — same as sway.fish. Without it, artix-pipewire-launcher
# can't start WirePlumber (it requires a session bus), so there are no audio
# sinks and no sound; portals and D-Bus app remotes also misbehave.
#
# Hyprland runs through `start-hyprland` (the shipped watchdog wrapper): this
# silences Hyprland's "launched without start-hyprland" warning and auto-restarts
# the compositor if it ever crashes. start-hyprland does NOT set up a session bus
# on its own, so dbus-run-session still wraps it. Args after `--` reach Hyprland.
function hyprland --wraps start-hyprland --description 'Hyprland (start-hyprland watchdog) in a dbus session'
    if set -q DBUS_SESSION_BUS_ADDRESS
        # Already inside a session bus (e.g. nested) — just run the watchdog.
        exec start-hyprland -- $argv
    else
        exec dbus-run-session -- start-hyprland -- $argv
    end
end
