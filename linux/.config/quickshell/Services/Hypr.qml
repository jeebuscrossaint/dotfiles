pragma Singleton

import QtQuick
import Quickshell

// Every dispatch the shell makes goes through here, and it emits LUA.
//
// Hyprland is configured in Lua on this machine, which changes the dispatch
// contract completely -- and silently. Both Quickshell's Hyprland.dispatch and
// `hyprctl dispatch` hand their argument to the Lua interpreter as
// `return hl.dispatch(<text>)`, so a plain command is Lua source and fails:
//
//   "workspace 7"                    -> ')' expected near '7'
//   "\"workspace 7\""                -> expected a dispatcher (e.g.
//                                       hl.dsp.window.close())
//   "hl.dsp.focus({ workspace = 7 })" -> works
//
// It wants a Lua dispatcher OBJECT. The failures appear only in Quickshell's own
// log or hyprctl's exit code, so workspace clicks, workspace scroll and
// click-to-focus were all no-ops that looked like working code.
Singleton {
	function lua(expression: string): void {
		Quickshell.execDetached(["hyprctl", "dispatch", expression]);
	}

	// Accepts a number (workspace 3) or a relative selector ("e+1").
	function focusWorkspace(spec: var): void {
		const arg = typeof spec === "number" ? spec : '"' + spec + '"';
		lua("hl.dsp.focus({ workspace = " + arg + " })");
	}

	function focusWindow(address: string): void {
		lua('hl.dsp.focus({ window = "address:' + address + '" })');
	}

	function closeWindow(address: string): void {
		lua('hl.dsp.window.close({ window = "address:' + address + '" })');
	}
}
