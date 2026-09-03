import QtQuick
import qs.Config

// One right-hand menu-bar item. macOS highlights these on hover and on press
// rather than drawing them as separate slabs, which is the main visual
// difference from the waybar island row this replaces.
Item {
	id: item

	default property alias content: inner.data
	property bool interactive: true

	signal clicked
	signal scrolled(real delta)

	implicitWidth: inner.childrenRect.width + Style.gap * 2
	// A fixed height, NOT parent.height. Taking it from the Row makes the Row's
	// height depend on its children and the children's on the Row: the cycle
	// resolves to zero and the whole right-hand group vanishes. The left group
	// only survived it because the workspace pips carry a height of their own.
	implicitHeight: Style.barHeight

	Rectangle {
		anchors.fill: parent
		anchors.topMargin: 2
		anchors.bottomMargin: 2
		radius: 5
		color: item.interactive && hover.hovered ? Theme.withFg(0.12) : "transparent"
	}

	Item {
		id: inner

		anchors.centerIn: parent
		implicitWidth: childrenRect.width
		implicitHeight: childrenRect.height
	}

	HoverHandler {
		id: hover

		enabled: item.interactive
	}

	TapHandler {
		enabled: item.interactive
		onTapped: item.clicked()
	}

	WheelHandler {
		enabled: item.interactive
		// Vertical only: a horizontal flick on a trackpad should not change the
		// volume by accident.
		acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
		onWheel: event => item.scrolled(event.angleDelta.y)
	}
}
