import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Config
import qs.Widgets

// Region picker: a drop-in replacement for `slurp`.
//
// It prints the same "X,Y WxH" that slurp does, so `screenshot` and
// `screenshot-edit` keep working unchanged -- the selection UI is the only part
// that changes. macOS dims everything outside the selection and shows live
// dimensions, which slurp does not.
//
// The answer goes back over a FIFO the caller made, for the same reason the
// dmenu Picker does it: an IPC call cannot block waiting for a human.
Scope {
	id: region

	property bool active: false
	property string fifo: ""

	property real startX: 0
	property real startY: 0
	property real curX: 0
	property real curY: 0
	property bool dragging: false

	readonly property int selX: Math.round(Math.min(region.startX, region.curX))
	readonly property int selY: Math.round(Math.min(region.startY, region.curY))
	readonly property int selW: Math.round(Math.abs(region.curX - region.startX))
	readonly property int selH: Math.round(Math.abs(region.curY - region.startY))

	function answer(geometry: string): void {
		if (!region.active)
			return;
		region.active = false;
		region.dragging = false;
		Quickshell.execDetached(["sh", "-c", 'printf "%s\\n" "$1" > "$2"', "sh", geometry, region.fifo]);
	}

	function finish(): void {
		// Anything under a few pixels is a stray click, not a selection. grim
		// fails on a zero-size region, so this must not be passed through.
		if (region.selW < 4 || region.selH < 4) {
			region.answer("");
			return;
		}
		region.answer(region.selX + "," + region.selY + " " + region.selW + "x" + region.selH);
	}

	IpcHandler {
		target: "region"

		// The caller passes the FIFO to write the geometry to.
		function pick(fifoPath: string): void {
			region.fifo = fifoPath;
			region.dragging = false;
			region.startX = 0;
			region.startY = 0;
			region.curX = 0;
			region.curY = 0;
			region.active = true;
		}

		function cancel(): void {
			region.answer("");
		}
	}

	PanelWindow {
		id: win

		visible: region.active

		anchors.top: true
		anchors.bottom: true
		anchors.left: true
		anchors.right: true
		color: "transparent"

		WlrLayershell.layer: WlrLayer.Overlay
		WlrLayershell.namespace: "qs-region"
		// Needs the keyboard for Escape and the pointer for the drag.
		WlrLayershell.keyboardFocus: region.active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
		exclusionMode: ExclusionMode.Ignore

		Item {
			id: canvas

			anchors.fill: parent
			focus: true

			Keys.onEscapePressed: region.answer("")
			Keys.onReturnPressed: region.finish()

			// Four panes around the selection rather than one dim rect with a
			// hole: QML has no cut-out, and stacking a "clear" rectangle over a
			// dim one still composites. This leaves the selection genuinely
			// untouched, which is the point -- you are choosing what to capture,
			// so it has to look like itself.
			Rectangle {
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.top: parent.top
				height: region.dragging ? region.selY : parent.height
				color: Theme.withBg(0.45)
			}

			Rectangle {
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.bottom: parent.bottom
				y: region.dragging ? region.selY + region.selH : parent.height
				height: region.dragging ? Math.max(0, parent.height - (region.selY + region.selH)) : 0
				color: Theme.withBg(0.45)
			}

			Rectangle {
				visible: region.dragging
				x: 0
				y: region.selY
				width: region.selX
				height: region.selH
				color: Theme.withBg(0.45)
			}

			Rectangle {
				visible: region.dragging
				x: region.selX + region.selW
				y: region.selY
				width: Math.max(0, parent.width - (region.selX + region.selW))
				height: region.selH
				color: Theme.withBg(0.45)
			}

			Rectangle {
				visible: region.dragging
				x: region.selX
				y: region.selY
				width: region.selW
				height: region.selH
				color: "transparent"
				border.width: 1
				border.color: Theme.accent
			}

			// Live dimensions, flipped inside the selection when it is near the
			// top edge so the readout never falls off screen.
			Card {
				visible: region.dragging && region.selW > 0
				x: Math.min(Math.max(0, region.selX), canvas.width - width)
				y: region.selY > 30 ? region.selY - 28 : region.selY + region.selH + 8
				implicitWidth: dims.implicitWidth + 16
				implicitHeight: 22
				radius: 6

				StyledText {
					id: dims

					anchors.centerIn: parent
					text: region.selW + " × " + region.selH
					font.family: Theme.fontMono
					font.pointSize: Theme.fontSize - 1
				}
			}

			StyledText {
				anchors.horizontalCenter: parent.horizontalCenter
				y: 60
				visible: !region.dragging
				text: "Drag to select · Escape to cancel"
				color: "white"
				font.pointSize: Theme.fontSize + 2
			}

			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.CrossCursor

				onPressed: mouse => {
					region.startX = mouse.x;
					region.startY = mouse.y;
					region.curX = mouse.x;
					region.curY = mouse.y;
					region.dragging = true;
				}

				onPositionChanged: mouse => {
					if (!region.dragging)
						return;
					region.curX = mouse.x;
					region.curY = mouse.y;
				}

				onReleased: region.finish()
			}
		}
	}
}
