import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Config

// A panel hanging off the menu bar. Control Centre, Notification Centre and the
// Tux menu are all this plus content -- the window, the dismissal and the
// open/close animation were being copy-pasted per panel, which is how three
// panels quietly end up dismissing three slightly different ways.
Scope {
	id: pop

	property bool open: false
	// Screen x of the left edge, for a panel that drops from something on the
	// left of the bar. Negative means right-aligned instead, which is where the
	// status items are.
	property int anchorX: -1
	property int panelWidth: 240

	// Most panels want no keyboard at all -- they are glyph rows, and grabbing
	// the keyboard from whatever you were typing in is hostile. The Wi-Fi picker
	// is the exception: entering a password needs keys, so it asks for them only
	// while its prompt is open.
	property bool keyboard: false

	default property alias content: holder.data

	signal dismissed

	function close(): void {
		pop.open = false;
		pop.dismissed();
	}

	PanelWindow {
		id: win

		visible: pop.open || card.opacity > 0.01

		anchors.top: true
		anchors.left: pop.anchorX >= 0
		anchors.right: pop.anchorX < 0
		margins.top: Style.barHeight + 6
		margins.left: pop.anchorX >= 0 ? pop.anchorX : 0
		margins.right: 8

		implicitWidth: pop.panelWidth
		implicitHeight: card.implicitHeight
		color: "transparent"

		WlrLayershell.layer: WlrLayer.Overlay
		WlrLayershell.namespace: "qs-popover"
		WlrLayershell.keyboardFocus: pop.keyboard ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
		exclusionMode: ExclusionMode.Ignore

		// Armed, like every other grab in the shell: a request that simply FAILS
		// reports active=false, and unarmed that shuts the panel in the frame it
		// opened.
		HyprlandFocusGrab {
			id: grab

			property bool armed: false

			windows: [win]
			onActiveChanged: {
				if (grab.active) {
					grab.armed = true;
				} else if (grab.armed) {
					grab.armed = false;
					pop.close();
				}
			}
		}

		Connections {
			target: pop

			function onOpenChanged() {
				grab.armed = false;
				grab.active = pop.open;
			}
		}

		Card {
			id: card

			anchors.fill: parent
			implicitHeight: holder.implicitHeight + Style.padding * 2

			opacity: pop.open ? 1 : 0
			scale: pop.open ? 1 : 0.96
			// Grows out of the bar item it belongs to rather than out of its own
			// middle.
			transformOrigin: pop.anchorX >= 0 ? Item.TopLeft : Item.TopRight

			Behavior on opacity {
				NumberAnimation {
					duration: pop.open ? Style.durEnter : Style.durExit
					easing.type: Easing.Bezier
					easing.bezierCurve: Style.macFade
				}
			}

			Behavior on scale {
				NumberAnimation {
					duration: pop.open ? Style.durEnter : Style.durExit
					easing.type: Easing.Bezier
					easing.bezierCurve: Style.macOut
				}
			}

			Item {
				id: holder

				anchors.left: parent.left
				anchors.right: parent.right
				anchors.top: parent.top
				anchors.margins: Style.padding
				implicitHeight: childrenRect.height
			}
		}
	}
}
