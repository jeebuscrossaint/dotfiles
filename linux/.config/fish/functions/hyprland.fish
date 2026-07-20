# Launch Hyprland inside a single D-Bus session so the whole graphical session
# shares one session bus — same as sway.fish. Without it, artix-pipewire-launcher
# can't start WirePlumber (it requires a session bus), so there are no audio
# sinks and no sound; portals and D-Bus app remotes also misbehave.
function hyprland --wraps Hyprland --description 'Hyprland wrapped in a dbus session'
    if set -q DBUS_SESSION_BUS_ADDRESS
        # Already inside a session bus (e.g. nested) — just run Hyprland.
        exec /usr/bin/Hyprland $argv
    else
        exec dbus-run-session -- /usr/bin/Hyprland $argv
    end
end
