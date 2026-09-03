import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Services.Mpris
import Quickshell.Bluetooth
import Quickshell.Networking
import qs.Config
import qs.Widgets
import qs.Services

// The menu bar. Full width, thin, translucent, blurred -- deliberately one
// surface rather than the row of separate island slabs waybar drew, because a
// continuous strip across the top is most of what makes a desktop read as macOS.
Scope {
	id: bar

	// The focused window's APP, not its title. macOS puts the application name
	// in bold at the left and leaves the document name to the window itself;
	// a 60-character title bar is the thing that never looks right.
	// `wayland` is null for XWayland windows -- Minecraft focused showed
	// "Desktop" -- so the class comes from Hyprland's own IPC object, which is
	// populated for X11 and Wayland alike.
	readonly property string activeClass: {
		const top = Hyprland.activeToplevel;
		if (!top)
			return "";
		if (top.wayland && top.wayland.appId)
			return top.wayland.appId;
		// ipc["class"], not ipc.class. `class` is a reserved word, and reading it
		// with dot notation silently yields nothing here -- which looked exactly
		// like Hyprland not reporting the window at all.
		const ipc = top.lastIpcObject;
		return ipc && ipc["class"] ? ipc["class"] : "";
	}

	readonly property var activeEntry: bar.activeClass === "" ? null : DesktopEntries.heuristicLookup(bar.activeClass)

	readonly property string activeApp: {
		if (bar.activeEntry)
			return bar.activeEntry.name;
		return bar.activeClass === "" ? "Desktop" : bar.activeClass;
	}

	// The focused window's title, with the app's own name trimmed off the end.
	// Every toolkit appends it -- "README.md — Firefox Developer Edition" -- and
	// with the app already shown in bold beside this, repeating it is noise.
	// waybar did the same thing with a table of per-app rewrite rules; deriving
	// it from the app name covers every app instead of the five that were listed.
	readonly property string activeTitle: {
		const top = Hyprland.activeToplevel;
		if (!top || !top.title)
			return "";

		let title = top.title;
		const app = bar.activeApp;
		for (const sep of [" — ", " - ", " – "]) {
			const tail = sep + app;
			if (title.endsWith(tail)) {
				title = title.substring(0, title.length - tail.length);
				break;
			}
		}
		if (title === app)
			return "";
		return title.length > 60 ? title.substring(0, 59) + "…" : title;
	}

	// Pipewire hands out node objects but does not keep their audio data live
	// until something declares an interest in them. Without this the volume
	// glyph is right once and then never updates again.
	PwObjectTracker {
		objects: [Pipewire.defaultAudioSink]
	}

	readonly property var sink: Pipewire.defaultAudioSink
	readonly property bool muted: bar.sink && bar.sink.audio ? bar.sink.audio.muted : false
	readonly property int volume: bar.sink && bar.sink.audio ? Math.round(bar.sink.audio.volume * 100) : 0

	// Networking.devices, not the Network type. `Network` describes a single
	// network, and reading `.connected` off the type itself reported offline
	// forever on a machine that was plainly connected.
	readonly property var netDevice: {
		const ds = Networking.devices.values;
		for (let i = 0; i < ds.length; i++)
			if (ds[i].connected)
				return ds[i];
		return null;
	}

	readonly property var wifi: {
		if (!bar.netDevice || bar.netDevice.type !== DeviceType.Wifi)
			return null;
		const ns = bar.netDevice.networks.values;
		for (let i = 0; i < ns.length; i++)
			if (ns[i].connected)
				return ns[i];
		return null;
	}

	readonly property var battery: UPower.displayDevice
	readonly property var player: {
		const ps = Mpris.players.values;
		for (let i = 0; i < ps.length; i++)
			if (ps[i].isPlaying)
				return ps[i];
		return ps.length > 0 ? ps[0] : null;
	}

	ControlCentre {
		id: control
	}

	NotificationCentre {
		id: notifications
	}

	WeatherPanel {
		id: forecast
	}

	NetworkMenu {
		id: wifiMenu
	}

	BluetoothMenu {
		id: btMenu
	}

	SystemMenu {
		id: system

		// Drops from under the Tux glyph rather than from the right-hand edge.
		anchorX: Style.gap
	}

	SystemClock {
		id: clock

		precision: SystemClock.Seconds
	}

	// One bar per monitor. Everything above is shared state -- clocks, services,
	// the panels -- and only the strip itself is per-screen. Without this the bar
	// exists on exactly one display, which is invisible on a single-monitor
	// laptop right up to the moment something is plugged in.
	Variants {
		model: Quickshell.screens

	PanelWindow {
		id: win

		required property var modelData

		screen: win.modelData

		anchors.top: true
		anchors.left: true
		anchors.right: true
		implicitHeight: Style.barHeight
		color: "transparent"

		WlrLayershell.layer: WlrLayer.Top
		WlrLayershell.namespace: "qs-bar"
		WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
		// Reserve the strip: windows tile underneath it rather than behind it.
		exclusionMode: ExclusionMode.Auto

		Rectangle {
			anchors.fill: parent
			color: Theme.surface

			// A single hairline along the bottom edge, no rounding and no gaps.
			// The bar is part of the screen, not a floating widget.
			Rectangle {
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.bottom: parent.bottom
				height: Style.hairline
				color: Theme.hairline
			}
		}

		// ── Left ────────────────────────────────────────────────────────────
		Row {
			anchors.left: parent.left
			anchors.leftMargin: Style.gap
			anchors.verticalCenter: parent.verticalCenter
			spacing: Style.gap

			StatusItem {
				interactive: true
				onClicked: system.open = !system.open

				StyledText {
					text: ""
					font.family: Theme.fontMono
					font.pointSize: Theme.fontSize + 1
					color: Theme.fg
				}
			}

			StatusItem {
				interactive: false

				StyledText {
					text: bar.activeApp
					font.weight: Font.DemiBold
					color: Theme.fg
				}
			}

			StatusItem {
				interactive: false
				visible: bar.activeTitle.length > 0

				StyledText {
					text: bar.activeTitle
					color: Theme.dim
				}
			}

			Item {
				width: Style.gap
				height: 1
			}

			Workspaces {}
		}

		// ── Right ───────────────────────────────────────────────────────────
		Row {
			anchors.right: parent.right
			anchors.rightMargin: Style.gap
			anchors.verticalCenter: parent.verticalCenter
			spacing: 2

			StatusItem {
				visible: bar.player !== null && bar.player.trackTitle.length > 0
				onClicked: {
					if (bar.player)
						bar.player.togglePlaying();
				}

				StyledText {
					// Truncated hard. A now-playing readout that grows with the
					// track name shoves everything else along the bar.
					text: {
						if (!bar.player)
							return "";
						const glyph = bar.player.isPlaying ? "󰎈" : "󰏤";
						// artist then title, and elided as one string rather than
						// per-field, so a long artist does not push the title out
						// entirely.
						const artist = bar.player.trackArtist;
						const label = artist.length > 0 ? artist + " - " + bar.player.trackTitle : bar.player.trackTitle;
						return glyph + "  " + (label.length > 38 ? label.substring(0, 37) + "…" : label);
					}
					color: bar.player && bar.player.isPlaying ? Theme.fg : Theme.dim
				}
			}

			StatusItem {
				onClicked: wifiMenu.open = !wifiMenu.open

				StyledText {
					text: {
						if (!bar.netDevice)
							return "󰤮 offline";
						const wired = bar.netDevice.type === DeviceType.Ethernet;
						const glyph = wired ? "󰈀" : "󰖩";
						const who = bar.wifi ? " " + bar.wifi.name + " " + Math.round(bar.wifi.signalStrength * (bar.wifi.signalStrength <= 1 ? 100 : 1)) + "%" : "";
						return glyph + who + "  󰇚 " + Sys.rate(Sys.netDown) + " 󰕒 " + Sys.rate(Sys.netUp);
					}
					font.family: Theme.fontMono
					color: bar.netDevice ? Theme.fg : Theme.dim
				}
			}

			StatusItem {
				visible: Bluetooth.defaultAdapter !== null
				onClicked: btMenu.open = !btMenu.open

				StyledText {
					text: {
						const a = Bluetooth.defaultAdapter;
						if (!a || !a.enabled)
							return "󰂲";
						const ds = Bluetooth.devices.values;
						for (let i = 0; i < ds.length; i++)
							if (ds[i].connected)
								return "󰂱";
						return "󰂯";
					}
					font.family: Theme.fontMono
					color: {
						const a = Bluetooth.defaultAdapter;
						if (!a || !a.enabled)
							return Theme.dim;
						return btMenu.open ? Theme.accent : Theme.fg;
					}
				}
			}

			StatusItem {
				onClicked: Quickshell.execDetached(["osd", "volume", "mute"])
				// Through osd, not straight at the Pipewire node: osd owns the
				// step size, the 150% ceiling and the HUD, and a second path to
				// the same setting would disagree with all three.
				onScrolled: delta => Quickshell.execDetached(["osd", "volume", delta > 0 ? "up" : "down"])

				StyledText {
					text: {
						if (bar.muted)
							return "󰝟 muted";
						const glyph = bar.volume < 34 ? "󰕿" : (bar.volume < 67 ? "󰖀" : "󰕾");
						return glyph + " " + bar.volume + "%";
					}
					font.family: Theme.fontMono
					color: bar.muted ? Theme.dim : Theme.fg
				}
			}

			StatusItem {
				onClicked: control.open = !control.open
				onScrolled: delta => Quickshell.execDetached(["osd", "brightness", delta > 0 ? "up" : "down"])

				StyledText {
					text: "󰃠 " + Math.round(Sys.brightness * 100) + "%"
					font.family: Theme.fontMono
					color: Theme.fg
				}
			}

			StatusItem {
				interactive: false
				visible: bar.battery && bar.battery.isLaptopBattery

				Row {
					spacing: 5

					StyledText {
						anchors.verticalCenter: parent.verticalCenter
						text: {
							if (!bar.battery)
								return "";
							const pct = bar.battery.percentage * 100;
							if (bar.battery.state === UPowerDeviceState.Charging)
								return "󰂄";
							if (pct > 80)
								return "󰁹";
							if (pct > 60)
								return "󰂀";
							if (pct > 40)
								return "󰁾";
							if (pct > 20)
								return "󰁻";
							return "󰁺";
						}
						font.family: Theme.fontMono
						color: {
							if (!bar.battery)
								return Theme.fg;
							const pct = bar.battery.percentage * 100;
							if (bar.battery.state === UPowerDeviceState.Charging)
								return Theme.success;
							if (pct <= 10)
								return Theme.error;
							if (pct <= 25)
								return Theme.warning;
							return Theme.fg;
						}
					}

					StyledText {
						anchors.verticalCenter: parent.verticalCenter
						text: {
							if (!bar.battery)
								return "";
							let out = Math.round(bar.battery.percentage * 100) + "%";
							// changeRate is signed by direction; the sign is
							// already carried by the charging glyph.
							const watts = Math.abs(bar.battery.changeRate);
							if (watts > 0.05)
								out += " " + watts.toFixed(1) + "W";
							const secs = bar.battery.state === UPowerDeviceState.Charging ? bar.battery.timeToFull : bar.battery.timeToEmpty;
							if (secs > 0)
								out += " " + Math.floor(secs / 3600) + "h" + Math.floor((secs % 3600) / 60) + "m";
							return out;
						}
						color: Theme.fg
					}
				}
			}

			StatusItem {
				visible: Sys.weather.length > 0
				onClicked: forecast.open = !forecast.open

				StyledText {
					// wttrbar's own indicator string, unchanged from waybar.
					text: Sys.weather
					font.family: Theme.fontMono
					color: forecast.open ? Theme.accent : Theme.fg
				}
			}

			StatusItem {
				onClicked: control.open = !control.open

				StyledText {
					text: ""
					font.family: Theme.fontMono
					color: control.open ? Theme.accent : Theme.fg
				}
			}

			StatusItem {
				onClicked: notifications.open = !notifications.open

				StyledText {
					// macOS order: weekday, month, day, then the time.
					text: Qt.formatDateTime(clock.date, "ddd d MMM  h:mm:ss AP")
					color: notifications.open ? Theme.accent : Theme.fg
				}
			}
		}
	}
	}
}
