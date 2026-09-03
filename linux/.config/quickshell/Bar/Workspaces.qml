import QtQuick
import Quickshell.Hyprland
import qs.Config

// Pips, not numbered buttons. macOS has no workspace row in the menu bar at all,
// so this is the smallest thing that still answers "where am I" without turning
// the left side into a tag bar.
Row {
	id: row

	spacing: 6
	anchors.verticalCenter: parent.verticalCenter

	WheelHandler {
		// e+1 / e-1, exactly what the waybar module bound to scroll.
		onWheel: event => Hyprland.dispatch(event.angleDelta.y > 0 ? "workspace e+1" : "workspace e-1")
	}

	Repeater {
		model: Hyprland.workspaces

		Rectangle {
			required property var modelData

			width: modelData.focused ? 18 : 7
			height: 7
			radius: 3.5
			anchors.verticalCenter: parent.verticalCenter
			color: modelData.focused ? Theme.accent : (modelData.urgent ? Theme.error : Theme.withFg(0.25))

			Behavior on width {
				NumberAnimation {
					duration: Style.durExit
					easing.type: Easing.Bezier
					easing.bezierCurve: Style.macOut
				}
			}

			Behavior on color {
				ColorAnimation {
					duration: Style.durExit
				}
			}

			TapHandler {
				onTapped: Hyprland.dispatch("workspace " + modelData.id)
			}
		}
	}
}
