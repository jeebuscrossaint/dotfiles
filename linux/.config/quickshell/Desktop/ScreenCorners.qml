import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import qs.Config

// Rounded display corners, the way every Mac has had them since the notch.
//
// Pure black, which on this OLED means the pixels are simply off -- so unlike
// most always-on chrome this costs no power and cannot burn in. It also reserves
// nothing and, thanks to an empty input mask, never takes a click: the surface
// covers the whole screen but is invisible to the pointer.
Scope {
	id: corners

	// 16, not 12. A MacBook's display corners are noticeably rounder than a
	// phone's, and at 12 the effect reads as an artifact rather than as the
	// shape of the screen.
	readonly property int radius: 16

	Variants {
		model: Quickshell.screens

		PanelWindow {
			id: win

			required property var modelData

			screen: win.modelData

			anchors.top: true
			anchors.bottom: true
			anchors.left: true
			anchors.right: true
			color: "transparent"

			WlrLayershell.layer: WlrLayer.Overlay
			WlrLayershell.namespace: "qs-corners"
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
			exclusionMode: ExclusionMode.Ignore
			// Above everything, including fullscreen windows -- a rounded corner
			// that squares off when a video goes fullscreen is worse than none.
			aboveWindows: true

			// Empty region: the layer is fullscreen but transparent to input.
			// Without this it would swallow every click on the desktop.
			mask: Region {}

			Repeater {
				model: [
					{ x: 0, y: 0, rot: 0 },
					{ x: 1, y: 0, rot: 90 },
					{ x: 1, y: 1, rot: 180 },
					{ x: 0, y: 1, rot: 270 }
				]

				Shape {
					required property var modelData

					width: corners.radius
					height: corners.radius
					x: modelData.x === 0 ? 0 : win.width - corners.radius
					y: modelData.y === 0 ? 0 : win.height - corners.radius
					rotation: modelData.rot
					preferredRendererType: Shape.CurveRenderer
					antialiasing: true

					// The bit of the corner OUTSIDE the rounded arc: straight out
					// along both edges, then curved back. Filling that is what
					// makes the screen look rounded.
					ShapePath {
						fillColor: "black"
						strokeWidth: 0

						startX: 0
						startY: 0
						PathLine {
							x: corners.radius
							y: 0
						}
						PathArc {
							x: 0
							y: corners.radius
							radiusX: corners.radius
							radiusY: corners.radius
							direction: PathArc.Counterclockwise
						}
						PathLine {
							x: 0
							y: 0
						}
					}
				}
			}
		}
	}
}
