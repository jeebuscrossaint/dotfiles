import QtQuick
import qs.Config

// One labelled readout with a fill bar. The Control Centre equivalent of the
// waybar load drawer: same numbers, but visible at a glance instead of behind a
// hover transition.
Item {
	id: meter

	property string label: ""
	property string value: ""
	property real fill: 0
	property color tint: Theme.accent

	implicitHeight: 32

	StyledText {
		id: name

		anchors.left: parent.left
		anchors.top: parent.top
		text: meter.label
		color: Theme.dim
		font.pointSize: Theme.fontSize - 1
	}

	StyledText {
		anchors.right: parent.right
		anchors.top: parent.top
		text: meter.value
		color: Theme.fg
		font.pointSize: Theme.fontSize - 1
	}

	Rectangle {
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		anchors.bottomMargin: 6
		height: 4
		radius: 2
		color: Theme.withFg(0.12)

		Rectangle {
			width: parent.width * Math.max(0, Math.min(1, meter.fill))
			height: parent.height
			radius: parent.radius
			color: meter.tint

			Behavior on width {
				NumberAnimation {
					duration: 400
					easing.type: Easing.Bezier
					easing.bezierCurve: Style.macStd
				}
			}
		}
	}
}
