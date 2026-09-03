import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import qs.Config
import qs.Widgets

// Bluetooth devices. `connected` is a writable property on the device, so
// toggling one is an assignment rather than a shelled-out bluetoothctl.
Popover {
	id: bt

	panelWidth: 290

	readonly property var adapter: Bluetooth.defaultAdapter

	readonly property var known: {
		const out = [];
		const ds = Bluetooth.devices.values;
		for (let i = 0; i < ds.length; i++)
			// Paired only. The full scan list is dozens of strangers' earbuds.
			if (ds[i].paired)
				out.push(ds[i]);
		out.sort((a, b) => (b.connected ? 1 : 0) - (a.connected ? 1 : 0));
		return out;
	}

	IpcHandler {
		target: "bluetooth"

		function toggle(): void { bt.open = !bt.open; }
		function open(): void { bt.open = true; }
		function close(): void { bt.open = false; }
	}

	Column {
		id: col

		anchors.left: parent.left
		anchors.right: parent.right
		spacing: 2

		StyledText {
			text: "Bluetooth"
			font.weight: Font.DemiBold
		}

		Item {
			width: 1
			height: 4
		}

		MenuRow {
			width: col.width
			glyph: bt.adapter && bt.adapter.enabled ? "󰂯" : "󰂲"
			label: bt.adapter && bt.adapter.enabled ? "On" : "Off"
			onTriggered: {
				if (bt.adapter)
					bt.adapter.enabled = !bt.adapter.enabled;
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
			visible: bt.known.length > 0
		}

		Item {
			width: 1
			height: 4
			visible: bt.known.length > 0
		}

		Repeater {
			model: bt.known

			MenuRow {
				required property var modelData

				width: col.width
				glyph: modelData.connected ? "󰄬" : ""
				label: modelData.name + (modelData.batteryAvailable ? "   " + Math.round(modelData.battery * 100) + "%" : "")
				onTriggered: modelData.connected = !modelData.connected
			}
		}

		StyledText {
			width: col.width
			visible: bt.known.length === 0
			text: "No paired devices"
			color: Theme.dim
			font.pointSize: Theme.fontSize - 1
		}
	}
}
