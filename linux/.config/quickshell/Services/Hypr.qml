pragma Singleton

import QtQuick
import Quickshell

// Dispatch wrapper. Everything in the shell that moves a window or a workspace
// goes through here.
//
// It shells out to hyprctl rather than using Quickshell's Hyprland.dispatch, and
// that is not laziness -- Hyprland.dispatch is unusable against this config.
// Hyprland is configured in LUA here, so a dispatch arrives at the Lua
// interpreter as `return hl.dispatch(<text>)`:
//
//   "focuswindow address:0x1234"    -> Lua syntax error, ')' expected
//   "\"focuswindow address:0x1234\"" -> parses, then "expected a dispatcher
//                                       (e.g. hl.dsp.window.close())"
//
// So it wants a Lua dispatcher OBJECT, and there is no string form that
// satisfies it. hyprctl talks to the same socket but does not route through Lua,
// so it takes the plain command. The cost is one fork per click, which is
// nothing next to silently doing nothing -- these failures only ever surfaced in
// Quickshell's own log.
Singleton {
	function dispatch(command: string): void {
		Quickshell.execDetached(["hyprctl", "dispatch"].concat(command.split(" ")));
	}
}
