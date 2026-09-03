import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Config
import qs.Services
import qs.Widgets

// Mission Control: every window at once, live.
//
// The thumbnails are real ScreencopyView captures rather than icons or static
// grabs, so a playing video is playing in the overview. That is the whole point
// of the gesture -- you recognise a window by what is in it, not by its title.
Scope {
	id: mission

	property bool open: false

	readonly property var windows: {
		if (!mission.open)
			return [];
		const out = [];
		const tops = Hyprland.toplevels.values;
		for (let i = 0; i < tops.length; i++)
			if (tops[i].wayland)
				out.push(tops[i]);
		return out;
	}

	// Roughly square grid, biased wider because screens are.
	readonly property int columns: Math.max(1, Math.ceil(Math.sqrt(mission.windows.length * 1.4)))

	function focusWindow(top: var): void {
		mission.open = false;
		Hypr.dispatch("focuswindow address:" + top.address);
	}

	IpcHandler {
		target: "mission"

		function toggle(): void { mission.open = !mission.open; }
		function open(): void { mission.open = true; }
		function close(): void { mission.open = false; }
	}

	PanelWindow {
		id: win

		visible: mission.open || backdrop.opacity > 0.01

		anchors.top: true
		anchors.bottom: true
		anchors.left: true
		anchors.right: true
		color: "transparent"

		WlrLayershell.layer: WlrLayer.Overlay
		WlrLayershell.namespace: "qs-mission"
		// Fullscreen and modal, unlike every other panel here -- Escape has to
		// reach it, and clicking a thumbnail has to not fall through to the
		// window underneath.
		WlrLayershell.keyboardFocus: mission.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
		exclusionMode: ExclusionMode.Ignore

		Rectangle {
			id: backdrop

			anchors.fill: parent
			// Heavy. macOS dims the desktop hard behind Mission Control, and at
			// 0.55 the terminal text underneath was still perfectly readable --
			// which makes the thumbnails compete with it instead of replacing it.
			color: Theme.withBg(0.82)
			opacity: mission.open ? 1 : 0
			focus: true

			Behavior on opacity {
				NumberAnimation {
					duration: mission.open ? Style.durEnter : Style.durExit
					easing.type: Easing.Bezier
					easing.bezierCurve: Style.macFade
				}
			}

			Keys.onEscapePressed: mission.open = false

			MouseArea {
				anchors.fill: parent
				onClicked: mission.open = false
			}

			StyledText {
				anchors.centerIn: parent
				visible: mission.windows.length === 0
				text: "No windows"
				color: Theme.dim
				font.pointSize: Theme.fontSize + 4
			}

			Grid {
				id: grid

				anchors.centerIn: parent
				width: parent.width - 120
				columns: mission.columns
				spacing: 24

				Repeater {
					model: mission.windows

					Item {
						id: cell

						required property var modelData

						readonly property real cellW: (grid.width - (grid.columns - 1) * grid.spacing) / grid.columns

						width: cell.cellW
						// 16:10, matching the panel, so thumbnails do not letterbox
						// against each other.
						height: cell.cellW * 0.625 + 26

						Card {
							anchors.top: parent.top
							anchors.left: parent.left
							anchors.right: parent.right
							height: cell.cellW * 0.625
							radius: 10
							clip: true

							scale: cellHover.hovered ? 1.03 : 1
							border.color: cellHover.hovered ? Theme.accent : Theme.hairline

							Behavior on scale {
								NumberAnimation {
									duration: 120
									easing.type: Easing.Bezier
									easing.bezierCurve: Style.macOut
								}
							}

							ScreencopyView {
								anchors.fill: parent
								anchors.margins: 2
								captureSource: cell.modelData.wayland
								live: true
								paintCursor: false
							}
						}

						StyledText {
							anchors.bottom: parent.bottom
							anchors.left: parent.left
							anchors.right: parent.right
							horizontalAlignment: Text.AlignHCenter
							text: cell.modelData.title
							color: cellHover.hovered ? Theme.fg : Theme.dim
							font.pointSize: Theme.fontSize - 1
						}

						HoverHandler {
							id: cellHover
						}

						TapHandler {
							onTapped: mission.focusWindow(cell.modelData)
						}
					}
				}
			}
		}

		onVisibleChanged: {
			if (win.visible)
				backdrop.forceActiveFocus();
		}
	}
}
