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

// The day's first screen: a board of widget cards over the blurred desktop.
//
// macOS's own version of this is the widget half of Notification Centre, so the
// cards follow those proportions rather than the dense dashboard look -- rounded
// tiles with a lot of air, one idea each.
//
// It shows itself once a day, on the first shell start after midnight, which is
// the moment it is actually for. After that it is mod+A.
Scope {
	id: dash

	property bool open: false

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

	IpcHandler {
		target: "dashboard"

		function toggle(): void { dash.open = !dash.open; }
		function open(): void { dash.open = true; }
		function close(): void { dash.open = false; }
	}

	// Once a day, unprompted. The stamp is the local date, so the trigger is the
	// first launch after midnight rather than "every N hours".
	FileView {
		id: stamp

		path: Quickshell.statePath("dashboard-shown")
		blockLoading: true
		printErrors: false

		onLoaded: dash.considerAutoShow()
		onLoadFailed: dash.considerAutoShow()
	}

	function considerAutoShow(): void {
		const today = Qt.formatDateTime(new Date(), "yyyy-MM-dd");
		let last = "";
		try {
			last = stamp.text().trim();
		} catch (e) {
		}
		if (last === today)
			return;
		stamp.setText(today);
		dash.open = true;
	}

	PanelWindow {
		id: win

		visible: dash.open || backdrop.opacity > 0.01

		anchors.top: true
		anchors.bottom: true
		anchors.left: true
		anchors.right: true
		color: "transparent"

		WlrLayershell.layer: WlrLayer.Overlay
		WlrLayershell.namespace: "qs-dashboard"
		WlrLayershell.keyboardFocus: dash.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
		exclusionMode: ExclusionMode.Ignore

		Rectangle {
			id: backdrop

			anchors.fill: parent
			// Heavy, and not relying on the compositor: Hyprland's layer blur
			// does not appear to reach a fullscreen overlay, so the dim has to
			// carry the separation on its own. macOS dims hard here regardless.
			color: Theme.withBg(0.92)
			opacity: dash.open ? 1 : 0
			focus: true

			Behavior on opacity {
				NumberAnimation {
					duration: dash.open ? Style.durEnter : Style.durExit
					easing.type: Easing.Bezier
					easing.bezierCurve: Style.macFade
				}
			}

			Keys.onEscapePressed: dash.open = false

			MouseArea {
				anchors.fill: parent
				onClicked: dash.open = false
			}

			Row {
				anchors.centerIn: parent
				spacing: 16

				// ── Column one: the day itself ──────────────────────────────
				Column {
					spacing: 16

					Card {
						width: 300
						implicitHeight: 150

						Column {
							anchors.centerIn: parent
							spacing: 2

							StyledText {
								text: dash.greeting + ", " + Quickshell.env("USER")
								color: Theme.dim
								font.pointSize: Theme.fontSize
							}

							StyledText {
								text: Qt.formatDateTime(clock.date, "h:mm")
								font.pointSize: 46
								font.weight: Font.DemiBold
							}

							StyledText {
								text: Qt.formatDateTime(clock.date, "dddd, d MMMM")
								color: Theme.dim
							}
						}
					}

					Card {
						width: 300
						implicitHeight: cal.implicitHeight + Style.padding * 2

						Calendar {
							id: cal

							anchors.left: parent.left
							anchors.right: parent.right
							anchors.top: parent.top
							anchors.margins: Style.padding
						}
					}
				}

				// ── Column two: what is playing and what the machine is doing ─
				Column {
					spacing: 16

					Card {
						width: 330
						implicitHeight: 100

						NowPlaying {
							anchors.left: parent.left
							anchors.right: parent.right
							anchors.margins: Style.padding
							anchors.verticalCenter: parent.verticalCenter
						}

						StyledText {
							anchors.centerIn: parent
							visible: Mpris.players.values.length === 0
							text: "Nothing playing"
							color: Theme.dim
						}
					}

					Card {
						width: 330
						implicitHeight: stats.implicitHeight + Style.padding * 2

						Column {
							id: stats

							anchors.left: parent.left
							anchors.right: parent.right
							anchors.top: parent.top
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
								height: 16

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
				}

				// ── Column three: outside, and what you missed ──────────────
				Column {
					spacing: 16

					Card {
						width: 300
						implicitHeight: 170

						Column {
							anchors.centerIn: parent
							spacing: 2

							StyledText {
								anchors.horizontalCenter: parent.horizontalCenter
								text: Sys.weather.length > 0 ? Sys.weather : "—"
								font.family: Theme.fontMono
								font.pointSize: 30
								font.weight: Font.DemiBold
							}

							StyledText {
								anchors.horizontalCenter: parent.horizontalCenter
								// First line of wttrbar's tooltip is the current
								// condition; the rest is the hourly table, which
								// belongs in the bar's forecast panel, not here.
								text: Sys.weatherTip.split("\n")[0].replace(/<[^>]*>/g, "")
								color: Theme.dim
							}

							Item {
								width: 1
								height: 8
							}

							StyledText {
								anchors.horizontalCenter: parent.horizontalCenter
								text: Sys.weatherTip.split("\n").length > 4 ? Sys.weatherTip.split("\n")[4].replace(/<[^>]*>/g, "") : ""
								color: Theme.dim
								font.pointSize: Theme.fontSize - 1
							}
						}
					}

					Card {
						width: 300
						implicitHeight: 74

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
									height: 42
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

					Card {
						width: 300
						implicitHeight: 140

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
								model: History.items.slice(0, 3)

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
			}
		}

		onVisibleChanged: {
			if (win.visible)
				backdrop.forceActiveFocus();
		}
	}
}
