import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.Config
import qs.Widgets
import "Search.js" as Search

Scope {
	id: root

	property bool open: false
	property string query: ""
	property int selected: 0

	readonly property var results: Search.rank(DesktopEntries.applications.values, query)

	function show(): void {
		root.query = "";
		root.selected = 0;
		root.open = true;
	}

	function hide(): void {
		root.open = false;
	}

	function toggle(): void {
		if (root.open) root.hide();
		else root.show();
	}

	function launch(entry: var): void {
		if (!entry)
			return;
		root.hide();

		// DesktopEntry.command is the already-parsed argv, so no shell is
		// involved and filenames with spaces survive. Terminal entries carry no
		// terminal of their own -- that is the launcher's job per the desktop
		// entry spec.
		const argv = entry.runInTerminal ? ["kitty", "-e"].concat(entry.command) : entry.command;
		const opts = { command: argv };
		if (entry.workingDirectory)
			opts.workingDirectory = entry.workingDirectory;
		Quickshell.execDetached(opts);
	}

	// `qs ipc call spotlight toggle`. The Hyprland keybind goes through this
	// rather than through GlobalShortcut so the same entry point works from a
	// script and from a terminal while the thing is being built.
	IpcHandler {
		target: "spotlight"

		// NOT show/hide: `qs ipc` has subcommands by those names and swallows
		// them before the handler is ever consulted, which looks exactly like a
		// silently ignored call.
		function toggle(): void { root.toggle(); }
		function open(): void { root.show(); }
		function close(): void { root.hide(); }

		// Opens with the field prefilled. `qs ipc call spotlight search steam`.
		function search(text: string): void {
			root.show();
			root.query = text;
		}
	}

	PanelWindow {
		id: win

		// Kept alive through the closing animation instead of being torn down
		// with the open flag, otherwise dismissal just blinks out of existence.
		visible: root.open || card.opacity > 0.01

		// Sized to the panel, NOT fullscreen. A fullscreen transparent overlay
		// would put the compositor's layer blur over the entire screen; this way
		// the frost is exactly the panel. The cost is that click-outside has to
		// come from the focus grab below rather than from a backdrop MouseArea.
		anchors.top: true
		margins.top: Math.round(win.screen.height * Style.spotlightTop)
		implicitWidth: Style.spotlightWidth
		implicitHeight: card.implicitHeight
		color: "transparent"

		WlrLayershell.layer: WlrLayer.Overlay
		// Matched by the blur layerrule in hyprland.lua. Renaming this without
		// renaming it there silently drops the glass.
		WlrLayershell.namespace: "qs-spotlight"
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
		// root.open, because Hyprland writes `active` itself when it breaks the
		// grab and that would destroy the binding on the first dismissal.
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
					root.hide();
				}
			}
		}

		Connections {
			target: root

			function onOpenChanged() {
				if (root.open) {
					grab.armed = false;
					grab.active = true;
				} else {
					grab.armed = false;
					grab.active = false;
				}
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
						text: ""
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

						onTextChanged: {
							root.query = input.text;
							root.selected = 0;
						}

						// Rebuilt on every open, so the field is empty when it
						// comes back rather than holding the last search.
						Connections {
							target: root

							function onQueryChanged() {
								if (root.query !== input.text)
									input.text = root.query;
							}
						}

						Keys.onEscapePressed: root.hide()
						Keys.onReturnPressed: root.launch(root.results[root.selected])
						Keys.onEnterPressed: root.launch(root.results[root.selected])

						Keys.onDownPressed: root.selected = Math.min(root.selected + 1, root.results.length - 1)
						Keys.onUpPressed: root.selected = Math.max(root.selected - 1, 0)
						Keys.onTabPressed: root.selected = root.results.length ? (root.selected + 1) % root.results.length : 0

						StyledText {
							anchors.fill: parent
							verticalAlignment: Text.AlignVCenter
							visible: !input.text
							text: "Spotlight Search"
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
					height: Math.min(root.results.length, Style.spotlightMaxRows) * Style.rowHeight
					model: root.results
					clip: true
					currentIndex: root.selected
					highlightMoveDuration: 0
					// Keeps the selected row visible when the cursor walks past
					// the bottom of the eight rows on screen.
					preferredHighlightBegin: 0
					preferredHighlightEnd: height
					highlightRangeMode: ListView.ApplyRange
					boundsBehavior: Flickable.StopAtBounds

					delegate: Item {
						id: row

						required property int index
						required property var modelData

						width: list.width
						height: Style.rowHeight

						Rectangle {
							anchors.fill: parent
							anchors.leftMargin: Style.gap
							anchors.rightMargin: Style.gap
							anchors.topMargin: 2
							anchors.bottomMargin: 2
							radius: Style.radiusRow
							color: row.index === root.selected ? Theme.accent : "transparent"
						}

						IconImage {
							id: icon

							anchors.verticalCenter: parent.verticalCenter
							x: Style.padding + 4
							implicitSize: Style.iconSize
							asynchronous: true
							source: Quickshell.iconPath(row.modelData.icon, "application-x-executable")
						}

						Column {
							anchors.verticalCenter: parent.verticalCenter
							x: icon.x + icon.width + Style.gap
							width: parent.width - x - Style.padding
							spacing: 0

							StyledText {
								width: parent.width
								text: row.modelData.name
								// Accent fills the whole row when selected, so the
								// label flips to the background colour rather than
								// staying dark-on-accent.
								color: row.index === root.selected ? Theme.bg : Theme.fg
							}

							StyledText {
								width: parent.width
								visible: text.length > 0
								text: row.modelData.comment || row.modelData.genericName || ""
								font.pointSize: Theme.fontSize - 1
								color: row.index === root.selected ? Theme.bg : Theme.dim
								opacity: row.index === root.selected ? 0.75 : 1
							}
						}

						MouseArea {
							anchors.fill: parent
							hoverEnabled: true
							onEntered: root.selected = row.index
							onClicked: root.launch(row.modelData)
						}
					}
				}
			}
		}
	}
}
