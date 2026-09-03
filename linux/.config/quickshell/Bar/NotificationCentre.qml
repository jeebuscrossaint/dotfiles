import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.Config
import qs.Widgets
import qs.Services

// The panel behind the clock: a month calendar over the notification history.
// macOS puts both here, and the history half is not decoration -- until now a
// dismissed notification was simply gone, which is the one thing fnott's
// corner-popup model and this one shared.
Scope {
	id: nc

	property bool open: false

	// First of the month, and how many days it has. Day 0 of the NEXT month is
	// the last day of this one, which is the standard way to avoid a leap-year
	// table.
	readonly property date today: clock.date
	readonly property int firstWeekday: new Date(nc.today.getFullYear(), nc.today.getMonth(), 1).getDay()
	readonly property int daysInMonth: new Date(nc.today.getFullYear(), nc.today.getMonth() + 1, 0).getDate()

	SystemClock {
		id: clock

		precision: SystemClock.Minutes
	}

	IpcHandler {
		target: "notifications"

		function toggle(): void { nc.open = !nc.open; }
		function open(): void { nc.open = true; }
		function close(): void { nc.open = false; }
	}

	PanelWindow {
		id: win

		visible: nc.open || card.opacity > 0.01

		anchors.top: true
		anchors.right: true
		margins.top: Style.barHeight + 6
		margins.right: 8
		implicitWidth: 340
		implicitHeight: card.implicitHeight
		color: "transparent"

		WlrLayershell.layer: WlrLayer.Overlay
		WlrLayershell.namespace: "qs-notification-centre"
		WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
		exclusionMode: ExclusionMode.Ignore

		// Armed focus grab, same as everywhere else: a grab request that fails
		// reports active=false, and unarmed that closes the panel in the frame
		// it opened.
		HyprlandFocusGrab {
			id: grab

			property bool armed: false

			windows: [win]
			onActiveChanged: {
				if (grab.active) {
					grab.armed = true;
				} else if (grab.armed) {
					grab.armed = false;
					nc.open = false;
				}
			}
		}

		Connections {
			target: nc

			function onOpenChanged() {
				grab.armed = false;
				grab.active = nc.open;
			}
		}

		Card {
			id: card

			anchors.fill: parent
			implicitHeight: body.implicitHeight + Style.padding * 2

			opacity: nc.open ? 1 : 0
			scale: nc.open ? 1 : 0.96
			transformOrigin: Item.TopRight

			Behavior on opacity {
				NumberAnimation {
					duration: nc.open ? Style.durEnter : Style.durExit
					easing.type: Easing.Bezier
					easing.bezierCurve: Style.macFade
				}
			}

			Behavior on scale {
				NumberAnimation {
					duration: nc.open ? Style.durEnter : Style.durExit
					easing.type: Easing.Bezier
					easing.bezierCurve: Style.macOut
				}
			}

			Column {
				id: body

				anchors.left: parent.left
				anchors.right: parent.right
				anchors.top: parent.top
				anchors.margins: Style.padding
				spacing: 8

				StyledText {
					text: Qt.formatDateTime(nc.today, "MMMM yyyy")
					font.weight: Font.DemiBold
				}

				Grid {
					width: parent.width
					columns: 7
					spacing: 0

					Repeater {
						model: ["S", "M", "T", "W", "T", "F", "S"]

						StyledText {
							required property var modelData

							width: body.width / 7
							horizontalAlignment: Text.AlignHCenter
							text: modelData
							color: Theme.dim
							font.pointSize: Theme.fontSize - 2
						}
					}

					// Leading blanks so the 1st lands under its weekday.
					Repeater {
						model: nc.firstWeekday

						Item {
							width: body.width / 7
							height: 26
						}
					}

					Repeater {
						model: nc.daysInMonth

						Item {
							required property int index

							readonly property bool isToday: index + 1 === nc.today.getDate()

							width: body.width / 7
							height: 26

							Rectangle {
								anchors.centerIn: parent
								width: 22
								height: 22
								radius: 11
								visible: parent.isToday
								color: Theme.accent
							}

							StyledText {
								anchors.centerIn: parent
								text: index + 1
								color: parent.isToday ? Theme.bg : Theme.fg
								font.pointSize: Theme.fontSize - 1
							}
						}
					}
				}

				Rectangle {
					width: parent.width
					height: Style.hairline
					color: Theme.hairline
				}

				Item {
					width: parent.width
					height: 18

					StyledText {
						anchors.left: parent.left
						anchors.verticalCenter: parent.verticalCenter
						text: History.items.length > 0 ? "Notifications" : "No Notifications"
						color: Theme.dim
						font.pointSize: Theme.fontSize - 1
					}

					StyledText {
						anchors.right: parent.right
						anchors.verticalCenter: parent.verticalCenter
						visible: History.items.length > 0
						text: "Clear"
						color: Theme.accent
						font.pointSize: Theme.fontSize - 1

						TapHandler {
							onTapped: History.clear()
						}
					}
				}

				ListView {
					width: parent.width
					// Capped, not unbounded: sixty records would otherwise make
					// a panel taller than the screen.
					height: Math.min(contentHeight, 260)
					model: History.items
					clip: true
					boundsBehavior: Flickable.StopAtBounds
					spacing: 4

					delegate: Rectangle {
						required property var modelData

						width: ListView.view.width
						implicitHeight: entry.implicitHeight + 12
						radius: Style.radiusRow
						color: Theme.withFg(0.06)

						Column {
							id: entry

							anchors.left: parent.left
							anchors.right: parent.right
							anchors.verticalCenter: parent.verticalCenter
							anchors.margins: 8
							spacing: 1

							StyledText {
								width: parent.width
								text: modelData.summary
								font.pointSize: Theme.fontSize - 1
								font.weight: Font.DemiBold
							}

							StyledText {
								width: parent.width
								visible: text.length > 0
								text: modelData.body
								textFormat: Text.StyledText
								wrapMode: Text.Wrap
								maximumLineCount: 2
								font.pointSize: Theme.fontSize - 2
								color: Theme.fg
								opacity: 0.7
							}
						}
					}
				}
			}
		}
	}
}
