import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.Config
import qs.Services
import qs.Widgets

// The command-palette window: search field over a sectioned result list.
//
// Shared by Spotlight and by the dmenu-style Picker, which differ only in where
// their rows come from and what Return does with one. Every row is
//   { title, subtitle, icon, run }
// and a section caption is { header }.
Scope {
	id: root

	property bool open: false
	property string query: ""
	property int selected: 0
	property string placeholder: "Search"
	property string namespace: "qs-palette"
	property var rows: []

	signal dismissed

	function reset(): void {
		root.query = "";
		root.selected = 0;
	}

	// Section headers share the model with the rows, so every move has to step
	// over them -- landing on one would leave Return with nothing to press.
	function step(dir: int): void {
		let i = root.selected + dir;
		while (i >= 0 && i < root.rows.length && root.rows[i].header !== undefined)
			i += dir;
		if (i >= 0 && i < root.rows.length)
			root.selected = i;
	}

	function firstRow(): int {
		for (let i = 0; i < root.rows.length; i++)
			if (root.rows[i].header === undefined)
				return i;
		return 0;
	}

	function activate(): void {
		const row = root.rows[root.selected];
		if (row && row.run)
			row.run();
	}

	function dismiss(): void {
		root.open = false;
		root.dismissed();
	}

	onRowsChanged: root.selected = root.firstRow()

	PanelWindow {
		id: win

		screen: Screens.focused

		// Kept alive through the closing animation instead of being torn down
		// with the open flag, otherwise dismissal just blinks out of existence.
		visible: root.open || card.opacity > 0.01

		// Sized to the panel, NOT fullscreen. A fullscreen transparent overlay
		// would put the compositor's layer blur over the entire screen; this way
		// the frost is exactly the panel. The cost is that click-outside has to
		// come from the focus grab below rather than a backdrop MouseArea.
		anchors.top: true
		margins.top: Math.round(win.screen.height * Style.spotlightTop)
		implicitWidth: Style.spotlightWidth
		implicitHeight: card.implicitHeight
		color: "transparent"

		WlrLayershell.layer: WlrLayer.Overlay
		// Matched by the blur layerrule in hyprland.lua. Renaming this without
		// renaming it there silently drops the glass.
		WlrLayershell.namespace: root.namespace
		WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
		exclusionMode: ExclusionMode.Ignore

		Behavior on implicitHeight {
			NumberAnimation {
				duration: Style.durResize
				easing.type: Easing.Bezier
				easing.bezierCurve: Style.macStd
			}
		}

		onVisibleChanged: {
			if (win.visible)
				input.forceActiveFocus();
		}

		// Dismiss on click-outside. Driven imperatively rather than bound to
		// root.open, because Hyprland writes `active` itself when it breaks
		// the grab and that would destroy the binding on the first dismissal.
		//
		// `armed` is the important part. A grab request can simply fail -- it
		// did, every time, with a fullscreen game holding focus -- and the
		// resulting active=false arrived while the panel was still opening,
		// closing it again within the frame. Only a grab that was actually held
		// and then lost counts as a click-outside.
		HyprlandFocusGrab {
			id: grab

			property bool armed: false

			windows: [win]
			onActiveChanged: {
				if (grab.active) {
					grab.armed = true;
				} else if (grab.armed) {
					grab.armed = false;
					root.dismiss();
				}
			}
		}

		Connections {
			target: root

			function onOpenChanged() {
				grab.armed = false;
				grab.active = root.open;
			}
		}

		Card {
			id: card

			anchors.fill: parent
			implicitHeight: layout.implicitHeight

			opacity: root.open ? 1 : 0
			scale: root.open ? 1 : 0.96
			transformOrigin: Item.Top

			Behavior on opacity {
				NumberAnimation {
					duration: root.open ? Style.durEnter : Style.durExit
					easing.type: Easing.Bezier
					easing.bezierCurve: Style.macFade
				}
			}

			Behavior on scale {
				NumberAnimation {
					duration: root.open ? Style.durEnter : Style.durExit
					easing.type: Easing.Bezier
					easing.bezierCurve: Style.macOut
				}
			}

			Column {
				id: layout

				width: parent.width

				Item {
					width: parent.width
					height: 58

					StyledText {
						id: glyph

						anchors.verticalCenter: parent.verticalCenter
						x: Style.padding + 4
						text: ""
						font.family: Theme.fontMono
						font.pointSize: Theme.fontSize + 4
						color: Theme.dim
					}

					TextInput {
						id: input

						anchors.verticalCenter: parent.verticalCenter
						x: glyph.x + glyph.width + Style.gap
						width: parent.width - x - Style.padding

						color: Theme.fg
						font.family: Theme.fontSans
						font.pointSize: Theme.fontSize + 8
						selectionColor: Theme.accent
						selectedTextColor: Theme.bg
						renderType: Text.NativeRendering
						clip: true

						onTextChanged: root.query = input.text

						Connections {
							target: root

							function onQueryChanged() {
								if (root.query !== input.text)
									input.text = root.query;
							}
						}

						Keys.onEscapePressed: root.dismiss()
						Keys.onReturnPressed: root.activate()
						Keys.onEnterPressed: root.activate()

						Keys.onDownPressed: root.step(1)
						Keys.onUpPressed: root.step(-1)
						Keys.onTabPressed: root.step(1)
						Keys.onBacktabPressed: root.step(-1)

						StyledText {
							anchors.fill: parent
							verticalAlignment: Text.AlignVCenter
							visible: !input.text
							text: root.placeholder
							color: Theme.dim
							font: input.font
						}
					}
				}

				Rectangle {
					width: parent.width
					height: Style.hairline
					color: Theme.hairline
					visible: list.height > 0
				}

				ListView {
					id: list

					width: parent.width
					height: Math.min(contentHeight, Style.spotlightMaxRows * Style.rowHeight)
					model: root.rows
					clip: true
					currentIndex: root.selected
					highlightMoveDuration: 0
					// Keeps the selected row visible when the cursor walks past
					// the bottom of the visible rows.
					preferredHighlightBegin: 0
					preferredHighlightEnd: height
					highlightRangeMode: ListView.ApplyRange
					boundsBehavior: Flickable.StopAtBounds

					// One delegate for both kinds of row rather than a Loader per
					// item: inside a Loader's component the model roles are only
					// reachable by walking back up through `parent`, which is
					// exactly the sort of binding that breaks silently the next
					// time the tree changes shape.
					delegate: Item {
						id: row

						required property int index
						required property var modelData

						readonly property bool isHeader: row.modelData.header !== undefined
						readonly property bool active: !row.isHeader && row.index === root.selected

						width: list.width
						height: row.isHeader ? 26 : Style.rowHeight

						// Section captions are not selectable and are deliberately
						// quiet: they group, they do not compete with the results.
						StyledText {
							visible: row.isHeader
							anchors.left: parent.left
							anchors.leftMargin: Style.padding + 4
							anchors.bottom: parent.bottom
							anchors.bottomMargin: 3
							text: row.isHeader ? row.modelData.header : ""
							color: Theme.dim
							font.pointSize: Theme.fontSize - 2
						}

						Item {
							anchors.fill: parent
							visible: !row.isHeader

							Rectangle {
								anchors.fill: parent
								anchors.leftMargin: Style.gap
								anchors.rightMargin: Style.gap
								anchors.topMargin: 2
								anchors.bottomMargin: 2
								radius: Style.radiusRow
								color: row.active ? Theme.accent : "transparent"
							}

							IconImage {
								id: icon

								anchors.verticalCenter: parent.verticalCenter
								x: Style.padding + 4
								implicitSize: Style.iconSize
								asynchronous: true
								visible: source != ""
								source: row.isHeader ? "" : Icons.resolve(row.modelData.icon)
							}

							Column {
								anchors.verticalCenter: parent.verticalCenter
								x: icon.visible ? icon.x + icon.width + Style.gap : Style.padding + 4
								width: parent.width - x - Style.padding
								spacing: 0

								StyledText {
									width: parent.width
									text: row.isHeader ? "" : row.modelData.title
									// Accent fills the whole row when selected, so
									// the label flips to the background colour
									// rather than staying dark on a dark accent.
									color: row.active ? Theme.bg : Theme.fg
								}

								StyledText {
									width: parent.width
									visible: text.length > 0
									text: row.isHeader ? "" : (row.modelData.subtitle || "")
									font.pointSize: Theme.fontSize - 1
									color: row.active ? Theme.bg : Theme.dim
									opacity: row.active ? 0.75 : 1
								}
							}

							MouseArea {
								anchors.fill: parent
								hoverEnabled: true
								onEntered: root.selected = row.index
								onClicked: root.activate()
							}
						}
					}
				}
			}
		}
	}
}
