import QtQuick
import qs.Config

// One line of a menu-bar dropdown.
Item {
	id: row

	property string label: ""
	property string glyph: ""
	property bool danger: false

	signal triggered

	implicitHeight: 28

	Rectangle {
		anchors.fill: parent
		anchors.leftMargin: -6
		anchors.rightMargin: -6
		radius: 5
		color: hover.hovered ? Theme.accent : "transparent"
	}

	StyledText {
		id: glyphText

		anchors.left: parent.left
		anchors.verticalCenter: parent.verticalCenter
		width: 20
		text: row.glyph
		font.family: Theme.fontMono
		color: hover.hovered ? Theme.bg : (row.danger ? Theme.error : Theme.dim)
	}

	StyledText {
		anchors.left: glyphText.right
		anchors.leftMargin: 4
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		text: row.label
		color: hover.hovered ? Theme.bg : (row.danger ? Theme.error : Theme.fg)
	}

	HoverHandler {
		id: hover
	}

	TapHandler {
		onTapped: row.triggered()
	}
}
