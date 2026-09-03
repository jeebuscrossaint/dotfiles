import QtQuick
import qs.Config

// A macOS Control Centre slider: a tall rounded track that fills from the left
// with the glyph sitting inside it, rather than a thin line with a knob on it.
// The whole bar is the control, which is why it can be this large and still not
// look clumsy.
Item {
	id: slider

	property real value: 0
	property string glyph: ""
	property bool enabled: true

	signal moved(real value)

	implicitHeight: 30

	Rectangle {
		id: track

		anchors.fill: parent
		radius: height / 2
		color: Theme.withFg(0.12)
		clip: true

		Rectangle {
			width: Math.max(parent.height, parent.width * Math.max(0, Math.min(1, slider.value)))
			height: parent.height
			radius: parent.radius
			color: slider.enabled ? Theme.accent : Theme.withFg(0.25)

			Behavior on width {
				enabled: !drag.active

				NumberAnimation {
					duration: Style.durExit
					easing.type: Easing.Bezier
					easing.bezierCurve: Style.macOut
				}
			}
		}

		StyledText {
			anchors.left: parent.left
			anchors.leftMargin: 9
			anchors.verticalCenter: parent.verticalCenter
			text: slider.glyph
			font.family: Theme.fontMono
			// Sits on top of the filled portion at the left-hand end, so it has
			// to read against the accent rather than against the track.
			color: Theme.bg
		}
	}

	DragHandler {
		id: drag

		target: null
		xAxis.enabled: true
		yAxis.enabled: false
		onCentroidChanged: {
			if (drag.active)
				slider.moved(Math.max(0, Math.min(1, drag.centroid.position.x / slider.width)));
		}
	}

	TapHandler {
		onTapped: point => slider.moved(Math.max(0, Math.min(1, point.position.x / slider.width)))
	}
}
