pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

// Which display the user is actually looking at.
//
// Anything transient -- the OSD HUD, Mission Control, a popover, the region
// picker -- belongs on the focused monitor rather than on whichever one
// Quickshell happened to pick. Persistent chrome is different: the bar is a
// Variants over every screen, because a monitor with no bar is a monitor with
// no clock.
//
// Matched by NAME because Hyprland's monitor objects and Quickshell's
// ShellScreens are unrelated types with no mapping between them.
Singleton {
	id: screens

	readonly property var focused: {
		const monitor = Hyprland.focusedMonitor;
		if (!monitor)
			return null;
		const all = Quickshell.screens;
		for (let i = 0; i < all.length; i++)
			if (all[i].name === monitor.name)
				return all[i];
		return null;
	}
}
