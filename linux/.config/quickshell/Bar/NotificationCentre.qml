import QtQuick
import Quickshell
import Quickshell.Io
import qs.Config
import qs.Widgets
import qs.Services

// The panel behind the clock: a month calendar over the notification history.
// macOS puts both here, and the history half is not decoration -- until it
// existed, a dismissed notification was simply gone.
Popover {
	id: nc

	panelWidth: 340

	IpcHandler {
		target: "notifications"

		function toggle(): void { nc.open = !nc.open; }
		function open(): void { nc.open = true; }
		function close(): void { nc.open = false; }
	}

	Column {
		id: body

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		spacing: 8

		Calendar {
			width: parent.width
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
