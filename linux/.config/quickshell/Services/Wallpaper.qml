pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// The current wallpaper's path, so the shell can draw its own blurred copy.
//
// Hyprland's layer blur does not reach a fullscreen layer, which is why Mission
// Control had to fall back to a flat scrim. Rendering a blurred copy of the
// wallpaper inside the shell sidesteps the compositor entirely -- the trick the
// bigger rices use for exactly this.
Singleton {
	id: wallpaper

	property string path: ""

	readonly property string url: wallpaper.path.length > 0 ? "file://" + wallpaper.path : ""

	function refresh(): void {
		query.running = false;
		query.running = true;
	}

	Process {
		id: query

		running: true
		// awww is the wallpaper daemon's CLI; `query` reports what each output is
		// currently displaying.
		command: ["sh", "-c", "awww query 2>/dev/null | head -1 | sed 's/.*currently displaying: image: //'"]
		stdout: StdioCollector {
			id: out
		}
		onExited: {
			const p = out.text.trim();
			wallpaper.path = p.startsWith("/") ? p : "";
		}
	}

	// The wallpaper changes when the theme does, and there is no signal for it,
	// so this re-reads on a slow timer. Cheap: one fork a minute.
	Timer {
		running: true
		repeat: true
		interval: 60000
		onTriggered: wallpaper.refresh()
	}
}
