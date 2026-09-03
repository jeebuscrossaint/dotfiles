import QtQuick
import Quickshell
import qs.Config

// A month grid with today ringed. Shared by Notification Centre and the
// dashboard.
Column {
	id: cal

	readonly property date today: clock.date
	// Day 0 of the NEXT month is the last day of this one, which avoids a
	// leap-year table.
	readonly property int firstWeekday: new Date(cal.today.getFullYear(), cal.today.getMonth(), 1).getDay()
	readonly property int daysInMonth: new Date(cal.today.getFullYear(), cal.today.getMonth() + 1, 0).getDate()

	spacing: 6

	SystemClock {
		id: clock

		precision: SystemClock.Minutes
	}

	StyledText {
		text: Qt.formatDateTime(cal.today, "MMMM yyyy")
		font.weight: Font.DemiBold
	}

	Grid {
		width: cal.width
		columns: 7
		spacing: 0

		Repeater {
			model: ["S", "M", "T", "W", "T", "F", "S"]

			StyledText {
				required property var modelData

				width: cal.width / 7
				horizontalAlignment: Text.AlignHCenter
				text: modelData
				color: Theme.dim
				font.pointSize: Theme.fontSize - 2
			}
		}

		// Leading blanks so the 1st lands under its weekday.
		Repeater {
			model: cal.firstWeekday

			Item {
				width: cal.width / 7
				height: 26
			}
		}

		Repeater {
			model: cal.daysInMonth

			Item {
				required property int index

				readonly property bool isToday: index + 1 === cal.today.getDate()

				width: cal.width / 7
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
}
