import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.Config
import qs.Services
import qs.Widgets

Scope {
	id: dock

	// Pinned apps, by desktop entry id. This is the list to edit -- it is kept
	// as code rather than as another watched JSON file because it changes about
	// twice a year and a whole config surface for it would be ceremony.
	readonly property var pinned: ["kitty", "firefox-developer-edition", "vesktop", "org.prismlauncher.PrismLauncher", "org.pwmt.zathura", "btop"]

	property real hoverX: -1000


	// Hidden at rest, and that is not a preference -- it is the whole reason the
	// dock is allowed to exist here. Parked, it reserves no screen space and
	// paints no pixels, which matters twice on this machine: 86px of a 1600px
	// panel is a lot to spend on something you look at for a second at a time,
	// and a static bright row sitting at the bottom of an OLED all day is how
	// you burn it in.
	property bool revealed: false

	// The dock item a right-click menu is open for, and where to put it.
	property var menuItem: null
	property real menuX: 0

	// Whether the blurred window is mapped at all. Kept separate from `revealed`
	// so the slide-out has somewhere to finish before the surface goes away.
	property bool mapped: false

	function wake(): void {
		hideTimer.stop();
		dock.mapped = true;
		dock.revealed = true;
	}

	// Running windows grouped by app. Hyprland's own toplevel list rather than
	// the wlr toplevel manager: 0.3.1 exports no ToplevelManager singleton, and
	// the Hyprland objects carry the window address, which is what focusing one
	// actually needs.
	readonly property var running: {
		const byApp = ({});
		const tops = Hyprland.toplevels.values;
		for (let i = 0; i < tops.length; i++) {
			const top = tops[i];
			if (!top.wayland || !top.wayland.appId)
				continue;
			const id = top.wayland.appId;
			if (!byApp[id])
				byApp[id] = [];
			byApp[id].push(top);
		}
		return byApp;
	}

	readonly property var items: {
		const out = [];
		const seen = ({});

		for (let i = 0; i < dock.pinned.length; i++) {
			const entry = DesktopEntries.byId(dock.pinned[i]);
			if (!entry)
				continue;
			out.push({ entry: entry, appId: entry.startupClass || dock.pinned[i] });
			seen[dock.pinned[i]] = true;
		}

		// Running apps that are not pinned get appended, the way macOS puts
		// unpinned running apps after the divider.
		for (const id in dock.running) {
			const entry = DesktopEntries.heuristicLookup(id);
			if (!entry || seen[entry.id])
				continue;
			let alreadyPinned = false;
			for (let k = 0; k < out.length; k++)
				if (out[k].entry === entry)
					alreadyPinned = true;
			if (alreadyPinned)
				continue;
			out.push({ entry: entry, appId: id });
		}

		return out;
	}

	function windowsFor(item: var): var {
		// Match on the running key first, then fall back to a heuristic lookup
		// landing on the same entry -- appId and desktop entry id agree far less
		// often than you would hope (kitty does, firefox-developer-edition does
		// not).
		if (dock.running[item.appId])
			return dock.running[item.appId];
		for (const id in dock.running)
			if (DesktopEntries.heuristicLookup(id) === item.entry)
				return dock.running[id];
		return [];
	}

	function launch(item: var): void {
		Quickshell.execDetached({
			command: item.entry.command,
			workingDirectory: item.entry.workingDirectory || Quickshell.env("HOME")
		});
	}

	function quit(item: var): void {
		// Every window of the app, not just the first: "Quit" on macOS closes
		// the application, and closing one of three windows would look broken.
		const wins = dock.windowsFor(item);
		for (let i = 0; i < wins.length; i++)
			Hypr.closeWindow(wins[i].address);
	}

	function activate(item: var): void {
		const wins = dock.windowsFor(item);
		if (wins.length > 0) {
			Hypr.focusWindow(wins[0].address);
			return;
		}
		Quickshell.execDetached({
			command: item.entry.command,
			workingDirectory: item.entry.workingDirectory || Quickshell.env("HOME")
		});
	}

	// TWO windows, and the split is not tidiness -- it is the only way the parked
	// dock can be invisible.
	//
	// Hyprland's layer blur applies to the whole layer RECTANGLE, not to the
	// pixels the surface actually paints. A single window with the card slid off
	// the bottom still frosted a dock-sized patch of wallpaper, permanently, in
	// exactly the spot the dock was supposed to have vacated. An input mask does
	// not help: it changes what receives clicks, not what gets blurred. So the
	// blurred window is unmapped while hidden, and the hover trigger lives in a
	// separate 3px window that is not in the blur rule at all.
	PanelWindow {
		id: trigger

		screen: Screens.focused
		anchors.bottom: true
		anchors.left: true
		anchors.right: true
		// 4px, not 1. The pointer physically stops at the screen edge so a
		// hair-thin strip does work in practice, but anything thinner is fiddly
		// to hit deliberately and impossible to hit with a warped cursor.
		implicitHeight: 4
		color: "transparent"

		WlrLayershell.layer: WlrLayer.Top
		WlrLayershell.namespace: "qs-dock-trigger"
		WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
		exclusionMode: ExclusionMode.Ignore

		HoverHandler {
			id: edge
		}
	}

	PanelWindow {
		id: win

		// Only mapped while it is on screen or sliding off it.
		visible: dock.mapped

		screen: Screens.focused
		anchors.bottom: true
		implicitWidth: card.implicitWidth
		implicitHeight: 80
		color: "transparent"

		WlrLayershell.layer: WlrLayer.Top
		WlrLayershell.namespace: "qs-dock"
		WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
		// Reserves nothing. Windows tile all the way to the bottom edge.
		exclusionMode: ExclusionMode.Ignore

		HoverHandler {
			id: over
		}

		Card {
			id: card

			x: (parent.width - width) / 2
			// Slides down out of the window; the window is bottom-anchored, so
			// anything below y = height is off-screen.
			y: dock.revealed ? 0 : parent.height
			implicitWidth: row.implicitWidth + Style.gap * 2
			implicitHeight: 68

			Behavior on y {
				NumberAnimation {
					duration: Style.durEnter
					easing.type: Easing.Bezier
					easing.bezierCurve: Style.macOut
				}
			}

			Row {
				id: row

				anchors.centerIn: parent
				height: parent.height
				spacing: 6

				Repeater {
					model: dock.items

					Item {
						id: slot

						required property var modelData

						readonly property var wins: dock.windowsFor(slot.modelData)
						readonly property bool isRunning: slot.wins.length > 0
						readonly property real centre: slot.x + slot.width / 2

						// macOS magnification: the hovered icon grows most and
						// its neighbours taper off, rather than one icon popping
						// on its own.
						readonly property real magnify: {
							if (!hover.hovered)
								return 1;
							const d = Math.abs(slot.centre - dock.hoverX);
							return 1 + 0.42 * Math.max(0, 1 - d / 120);
						}

						width: 52
						height: parent.height

						IconImage {
							anchors.horizontalCenter: parent.horizontalCenter
							anchors.bottom: parent.bottom
							anchors.bottomMargin: 12
							implicitSize: 44
							asynchronous: true
							source: Icons.resolve(slot.modelData.entry.icon)

							scale: slot.magnify
							// Grows upward out of the dock rather than through
							// its own centre, which keeps the row of icons on one
							// line while one of them swells.
							transformOrigin: Item.Bottom

							Behavior on scale {
								NumberAnimation {
									duration: 120
									easing.type: Easing.Bezier
									easing.bezierCurve: Style.macOut
								}
							}
						}

						Rectangle {
							anchors.horizontalCenter: parent.horizontalCenter
							anchors.bottom: parent.bottom
							anchors.bottomMargin: 4
							width: 4
							height: 4
							radius: 2
							visible: slot.isRunning
							color: Theme.withFg(0.65)
						}

						TapHandler {
							onTapped: dock.activate(slot.modelData)
						}

						TapHandler {
							acceptedButtons: Qt.RightButton
							onTapped: {
								// The dock window is centred and as wide as its
								// card, so the icon's screen x is the dock's left
								// edge plus its offset inside the row.
								const screenW = win.screen ? win.screen.width : 0;
								dock.menuX = (screenW - row.width) / 2 + slot.x + slot.width / 2;
								dock.menuItem = slot.modelData;
							}
						}
					}
				}
			}

			HoverHandler {
				id: hover

				onPointChanged: dock.hoverX = hover.point.position.x - (card.width - row.width) / 2
			}
		}
	}

	PanelWindow {
		id: itemMenu

		visible: dock.menuItem !== null

		screen: Screens.focused
		anchors.bottom: true
		anchors.left: true
		// Above the dock, and clamped so a menu on the first or last icon does
		// not hang off the edge of the screen.
		margins.bottom: 84
		margins.left: Math.max(8, Math.min(dock.menuX - itemMenu.implicitWidth / 2,
			(itemMenu.screen ? itemMenu.screen.width : 0) - itemMenu.implicitWidth - 8))

		implicitWidth: 200
		implicitHeight: menuBody.implicitHeight + Style.padding * 2
		color: "transparent"

		WlrLayershell.layer: WlrLayer.Overlay
		// qs-popover so it picks up the same blur rule as every other panel.
		WlrLayershell.namespace: "qs-popover"
		WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
		exclusionMode: ExclusionMode.Ignore

		HyprlandFocusGrab {
			id: menuGrab

			property bool armed: false

			windows: [itemMenu]
			onActiveChanged: {
				if (menuGrab.active) {
					menuGrab.armed = true;
				} else if (menuGrab.armed) {
					menuGrab.armed = false;
					dock.menuItem = null;
				}
			}
		}

		Connections {
			target: dock

			function onMenuItemChanged() {
				menuGrab.armed = false;
				menuGrab.active = dock.menuItem !== null;
				if (dock.menuItem === null)
					hideTimer.restart();
			}
		}

		Card {
			anchors.fill: parent

			Column {
				id: menuBody

				anchors.left: parent.left
				anchors.right: parent.right
				anchors.top: parent.top
				anchors.margins: Style.padding
				spacing: 2

				StyledText {
					width: parent.width
					text: dock.menuItem ? dock.menuItem.entry.name : ""
					font.weight: Font.DemiBold
					elide: Text.ElideRight
				}

				Rectangle {
					width: parent.width
					height: Style.hairline
					color: Theme.hairline
				}

				Item {
					width: 1
					height: 3
				}

				MenuRow {
					width: parent.width
					glyph: ""
					label: "New Window"
					onTriggered: {
						if (dock.menuItem)
							dock.launch(dock.menuItem);
						dock.menuItem = null;
					}
				}

				MenuRow {
					width: parent.width
					visible: dock.menuItem !== null && dock.windowsFor(dock.menuItem).length > 0
					glyph: ""
					label: "Quit"
					danger: true
					onTriggered: {
						if (dock.menuItem)
							dock.quit(dock.menuItem);
						dock.menuItem = null;
					}
				}
			}
		}
	}

	// Reveal is instant; hiding waits, or the dock flickers away the moment the
	// pointer crosses a gap between two icons. Unmapping waits for the slide to
	// finish so the window is not torn out from under its own animation.
	Timer {
		id: hideTimer

		interval: 450
		onTriggered: {
			if (dock.menuItem === null)
				dock.revealed = false;
		}
	}

	Timer {
		id: unmapTimer

		interval: Style.durEnter + 80
		onTriggered: dock.mapped = false
	}

	Connections {
		target: edge

		function onHoveredChanged() {
			if (edge.hovered)
				dock.wake();
		}
	}

	Connections {
		target: over

		function onHoveredChanged() {
			if (over.hovered)
				dock.wake();
			else
				hideTimer.restart();
		}
	}

	onRevealedChanged: {
		if (dock.revealed)
			unmapTimer.stop();
		else
			unmapTimer.restart();
	}
}
