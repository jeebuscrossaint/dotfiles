import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import qs.Config
import qs.Widgets

// Wi-Fi picker. Connecting goes through nmcli rather than the service's own
// connectWithPsk: a network the machine has never seen needs a password, and a
// text field on a layer that deliberately takes no keyboard focus is a bigger
// job than it looks. Known networks connect in place; anything else hands over
// to nmtui, which is where that flow already lived.
Popover {
	id: net

	panelWidth: 300

	readonly property var device: {
		const ds = Networking.devices.values;
		for (let i = 0; i < ds.length; i++)
			if (ds[i].type === DeviceType.Wifi)
				return ds[i];
		return null;
	}

	readonly property var networks: {
		if (!net.device)
			return [];
		const out = net.device.networks.values.slice();
		// Strongest first, but whatever is connected pins to the top.
		out.sort((a, b) => (b.connected ? 1 : 0) - (a.connected ? 1 : 0) || b.signalStrength - a.signalStrength);
		return out.slice(0, 12);
	}

	// Scan only while the picker is open. Left on, the radio rescans forever for
	// a list nobody is looking at, which costs battery on a laptop; left off,
	// the list is just the network already connected.
	Binding {
		target: net.device
		property: "scannerEnabled"
		value: net.open
		when: net.device !== null
	}

	IpcHandler {
		target: "wifi"

		function toggle(): void { net.open = !net.open; }
		function open(): void { net.open = true; }
		function close(): void { net.open = false; }
	}

	Column {
		id: col

		anchors.left: parent.left
		anchors.right: parent.right
		spacing: 2

		StyledText {
			text: "Wi-Fi"
			font.weight: Font.DemiBold
		}

		Item {
			width: 1
			height: 4
		}

		Repeater {
			model: net.networks

			MenuRow {
				required property var modelData

				width: col.width
				// signalStrength is 0..1.
				glyph: modelData.connected ? "󰄬" : ""
				label: modelData.name + "   " + Math.round(modelData.signalStrength * 100) + "%"
				onTriggered: {
					net.close();
					if (modelData.connected)
						return;
					if (modelData.known)
						Quickshell.execDetached(["nmcli", "connection", "up", "id", modelData.name]);
					else
						Quickshell.execDetached({ command: ["kitty", "nmtui"], workingDirectory: Quickshell.env("HOME") });
				}
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
			glyph: "󰒓"
			label: "Network Settings"
			onTriggered: {
				net.close();
				Quickshell.execDetached({ command: ["kitty", "nmtui"], workingDirectory: Quickshell.env("HOME") });
			}
		}
	}
}
