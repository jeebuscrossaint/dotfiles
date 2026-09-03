import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Services.Mpris
import Quickshell.Services.UPower
import Quickshell.Wayland
import qs.Config
import qs.Widgets
import qs.Services

// Desktop widgets: the board you see when nothing is covering the desktop.
//
// It lives on the BACKGROUND layer, above the wallpaper and below every window,
// which is what makes it a desktop rather than an overlay -- there is nothing to
// summon and nothing to dismiss, it is simply what an empty screen looks like.
// macOS Sonoma does the same thing with its widgets.
//
// Card proportions follow the widget half of macOS Notification Centre rather
// than the dense dashboard look: rounded tiles with air, one idea each.
Scope {
	id: dash

	readonly property string greeting: {
		const h = clock.date.getHours();
		if (h < 5)
			return "Still up";
		if (h < 12)
			return "Good morning";
		if (h < 18)
			return "Good afternoon";
		return "Good evening";
	}

	readonly property var battery: UPower.displayDevice

	SystemClock {
		id: clock

		precision: SystemClock.Seconds
	}

	PanelWindow {
		id: win

		anchors.top: true
		anchors.bottom: true
		anchors.left: true
		anchors.right: true
		color: "transparent"

		// BACKGROUND, not Overlay: above the wallpaper, below every window. No
		// scrim and no keyboard focus -- this is scenery, not a dialog.
		WlrLayershell.layer: WlrLayer.Background
		WlrLayershell.namespace: "qs-dashboard"
		WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
		exclusionMode: ExclusionMode.Ignore

		Item {
			id: backdrop

			anchors.fill: parent

			// Desktop widgets sit directly on the wallpaper with no scrim behind
			// them, and Hyprland's layer blur does not reach a fullscreen layer,
			// so the cards carry their own contrast. 0.82 -- the value that works
			// for a blurred panel -- washed out completely over a bright
			// wallpaper.
			readonly property color cardColour: Theme.withBg(0.93)

			// A real grid, not three columns of whatever height their contents
			// came out as. macOS widgets are laid out in fixed units for exactly
			// this reason: ragged edges read as a bug even when nothing is wrong.
			readonly property int cellW: 320
			readonly property int rowTop: 160
			readonly property int rowBottom: 200

			Column {
				anchors.centerIn: parent
				spacing: 16

				Grid {
					columns: 3
					spacing: 16

					// ── Row one ─────────────────────────────────────────────
					Card {
						width: backdrop.cellW
						height: backdrop.rowTop
						color: backdrop.cardColour

						Column {
							anchors.centerIn: parent
							spacing: 2

							StyledText {
								anchors.horizontalCenter: parent.horizontalCenter
								text: dash.greeting + ", " + Quickshell.env("USER")
								color: Theme.dim
							}

							StyledText {
								anchors.horizontalCenter: parent.horizontalCenter
								text: Qt.formatDateTime(clock.date, "h:mm")
								font.pointSize: 46
								font.weight: Font.DemiBold
							}

							StyledText {
								anchors.horizontalCenter: parent.horizontalCenter
								text: Qt.formatDateTime(clock.date, "dddd, d MMMM")
								color: Theme.dim
							}
						}
					}

					Card {
						width: backdrop.cellW
						height: backdrop.rowTop
						color: backdrop.cardColour

						NowPlaying {
							anchors.left: parent.left
							anchors.right: parent.right
							anchors.margins: Style.padding
							anchors.verticalCenter: parent.verticalCenter
							visible: Mpris.players.values.length > 0
						}

						StyledText {
							anchors.centerIn: parent
							visible: Mpris.players.values.length === 0
							text: "Nothing playing"
							color: Theme.dim
						}
					}

					Card {
						width: backdrop.cellW
						height: backdrop.rowTop
						color: backdrop.cardColour

						Column {
							anchors.centerIn: parent
							width: parent.width - Style.padding * 2
							spacing: 2

							StyledText {
								anchors.horizontalCenter: parent.horizontalCenter
								text: Sys.weather.length > 0 ? Sys.weather : "—"
								font.family: Theme.fontMono
								font.pointSize: 32
								font.weight: Font.DemiBold
							}

							StyledText {
								anchors.horizontalCenter: parent.horizontalCenter
								// First line of wttrbar's tooltip is the current
								// condition; the hourly table belongs in the bar's
								// forecast panel, not here.
								text: Sys.weatherTip.split("\n")[0].replace(/<[^>]*>/g, "")
								color: Theme.dim
							}

							StyledText {
								width: parent.width
								horizontalAlignment: Text.AlignHCenter
								elide: Text.ElideRight
								text: Sys.weatherTip.split("\n").length > 4 ? Sys.weatherTip.split("\n")[4].replace(/<[^>]*>/g, "") : ""
								color: Theme.dim
								font.pointSize: Theme.fontSize - 1
							}
						}
					}

					// ── Row two ─────────────────────────────────────────────
					Card {
						width: backdrop.cellW
						height: backdrop.rowBottom
						color: backdrop.cardColour

						Calendar {
							anchors.left: parent.left
							anchors.right: parent.right
							anchors.verticalCenter: parent.verticalCenter
							anchors.margins: Style.padding
						}
					}

					Card {
						width: backdrop.cellW
						height: backdrop.rowBottom
						color: backdrop.cardColour

						Column {
							anchors.left: parent.left
							anchors.right: parent.right
							anchors.verticalCenter: parent.verticalCenter
							anchors.margins: Style.padding
							spacing: 6

							Meter {
								width: parent.width
								label: "CPU"
								value: Math.round(Sys.cpu) + "%  " + Sys.temperature + "°"
								fill: Sys.cpu / 100
							}

							Meter {
								width: parent.width
								label: "Memory"
								value: Sys.memUsedGiB.toFixed(1) + " / " + Sys.memTotalGiB.toFixed(0) + " GiB"
								fill: Sys.memory / 100
							}

							Meter {
								width: parent.width
								label: "Disk"
								value: Sys.diskFree
								fill: Sys.disk / 100
							}

							Item {
								width: parent.width
								height: 14

								StyledText {
									anchors.left: parent.left
									text: dash.battery ? "󰁹 " + Math.round(dash.battery.percentage * 100) + "%" : ""
									font.family: Theme.fontMono
									color: Theme.dim
									font.pointSize: Theme.fontSize - 1
								}

								StyledText {
									anchors.right: parent.right
									text: Sys.uptime
									font.family: Theme.fontMono
									color: Theme.dim
									font.pointSize: Theme.fontSize - 1
								}
							}
						}
					}

					Card {
						width: backdrop.cellW
						height: backdrop.rowBottom
						color: backdrop.cardColour

						Column {
							anchors.left: parent.left
							anchors.right: parent.right
							anchors.top: parent.top
							anchors.margins: Style.padding
							spacing: 4

							StyledText {
								text: History.items.length > 0 ? "While you were away" : "Nothing missed"
								color: Theme.dim
								font.pointSize: Theme.fontSize - 1
							}

							Repeater {
								model: History.items.slice(0, 4)

								StyledText {
									required property var modelData

									width: parent.width
									text: modelData.summary
									font.pointSize: Theme.fontSize - 1
								}
							}
						}
					}
				}

				// Toggles get their own strip under the grid rather than a cell
				// of their own: three buttons in a 320x200 tile is mostly air.
				Card {
					anchors.horizontalCenter: parent.horizontalCenter
					width: backdrop.cellW
					height: 62
					color: backdrop.cardColour

					Row {
						anchors.centerIn: parent
						spacing: 10

						Repeater {
							model: [
								{ glyph: "󰖩", key: "wifi" },
								{ glyph: "󰂯", key: "bt" },
								{ glyph: "󰂛", key: "dnd" }
							]

							Rectangle {
								required property var modelData

								readonly property bool on: {
									if (modelData.key === "wifi")
										return Networking.wifiEnabled;
									if (modelData.key === "bt")
										return Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled;
									return History.dnd;
								}

								width: 54
								height: 40
								radius: 10
								color: on ? Theme.accent : Theme.withFg(0.12)

								StyledText {
									anchors.centerIn: parent
									text: modelData.glyph
									font.family: Theme.fontMono
									font.pointSize: Theme.fontSize + 3
									color: parent.on ? Theme.bg : Theme.fg
								}

								TapHandler {
									onTapped: {
										if (modelData.key === "wifi")
											Networking.wifiEnabled = !Networking.wifiEnabled;
										else if (modelData.key === "bt" && Bluetooth.defaultAdapter)
											Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
										else
											History.dnd = !History.dnd;
									}
								}
							}
						}
					}
				}
			}
		}
	}
}
