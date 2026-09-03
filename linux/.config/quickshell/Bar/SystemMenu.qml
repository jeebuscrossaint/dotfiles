import QtQuick
import Quickshell
import Quickshell.Io
import qs.Config
import qs.Widgets
import qs.Services

// The  menu, in Tux's clothing: machine identity at the top, session and power
// actions below.
//
// elogind, not systemd -- this is Artix on runit. `loginctl` is the right verb
// for all four and needs no sudo, because elogind grants them to the active
// seat's session.
Popover {
	id: menu

	panelWidth: 250

	// Every other panel in the shell is reachable over IPC; this one should be
	// too, so it can be bound to a key or driven from a script.
	IpcHandler {
		target: "system"

		function toggle(): void { menu.open = !menu.open; }
		function open(): void { menu.open = true; }
		function close(): void { menu.open = false; }
	}

	Column {
		id: col

		anchors.left: parent.left
		anchors.right: parent.right
		spacing: 2

		StyledText {
			// /etc/hostname, not $HOSTNAME. fish does not export it, so the
			// env lookup came back empty and this line read "amarnath@null".
			text: Quickshell.env("USER") + "@" + hostname.text().trim()
			font.weight: Font.DemiBold
		}

		FileView {
			id: hostname

			path: "/etc/hostname"
			blockLoading: true
			printErrors: false
		}

		StyledText {
			text: Sys.uptime.length > 0 ? "up " + Sys.uptime.replace(/^\S+\s*/, "") : ""
			visible: text.length > 0
			color: Theme.dim
			font.pointSize: Theme.fontSize - 1
		}

		Item {
			width: 1
			height: 6
		}

		Rectangle {
			width: col.width
			height: Style.hairline
			color: Theme.hairline
		}

		Item {
			width: 1
			height: 4
		}

		MenuRow {
			width: col.width
			glyph: ""
			label: "System Monitor"
			onTriggered: {
				menu.close();
				Quickshell.execDetached({ command: ["kitty", "btop"], workingDirectory: Quickshell.env("HOME") });
			}
		}

		MenuRow {
			width: col.width
			glyph: ""
			label: "Lock Screen"
			onTriggered: {
				menu.close();
				Quickshell.execDetached(["hyprlock"]);
			}
		}

		MenuRow {
			width: col.width
			glyph: "󰤄"
			label: "Sleep"
			onTriggered: {
				menu.close();
				Quickshell.execDetached(["loginctl", "suspend"]);
			}
		}

		Item {
			width: 1
			height: 4
		}

		Rectangle {
			width: col.width
			height: Style.hairline
			color: Theme.hairline
		}

		Item {
			width: 1
			height: 4
		}

		MenuRow {
			width: col.width
			glyph: "󰗽"
			label: "Log Out"
			onTriggered: {
				menu.close();
				Quickshell.execDetached(["hyprctl", "dispatch", "exit"]);
			}
		}

		MenuRow {
			width: col.width
			glyph: ""
			label: "Restart"
			danger: true
			onTriggered: {
				menu.close();
				Quickshell.execDetached(["loginctl", "reboot"]);
			}
		}

		MenuRow {
			width: col.width
			glyph: "⏻"
			label: "Shut Down"
			danger: true
			onTriggered: {
				menu.close();
				Quickshell.execDetached(["loginctl", "poweroff"]);
			}
		}
	}
}
