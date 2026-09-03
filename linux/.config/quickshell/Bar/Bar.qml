import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Services.Mpris
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
	readonly property var activeEntry: {
		const top = Hyprland.activeToplevel;
		if (!top || !top.wayland || !top.wayland.appId)
			return null;
		return DesktopEntries.heuristicLookup(top.wayland.appId);
	}

	readonly property string activeApp: {
		if (bar.activeEntry)
			return bar.activeEntry.name;
		const top = Hyprland.activeToplevel;
		return top && top.wayland ? top.wayland.appId : "Desktop";
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

	SystemClock {
		id: clock

		precision: SystemClock.Seconds
	}

	PanelWindow {
		id: win

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
				onClicked: Quickshell.execDetached(["qs", "ipc", "call", "spotlight", "toggle"])

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
						const t = bar.player.trackTitle;
						const glyph = bar.player.isPlaying ? "󰎈" : "󰏤";
						return glyph + "  " + (t.length > 34 ? t.substring(0, 33) + "…" : t);
					}
					color: bar.player && bar.player.isPlaying ? Theme.fg : Theme.dim
				}
			}

			StatusItem {
				interactive: false

				StyledText {
					text: {
						if (!Network.connected)
							return "󰤮";
						return Network.device && Network.device.type === DeviceType.Ethernet ? "󰈀" : "󰖩";
					}
					font.family: Theme.fontMono
					color: Network.connected ? Theme.fg : Theme.dim
				}
			}

			StatusItem {
				onClicked: Quickshell.execDetached(["osd", "volume", "mute"])

				StyledText {
					text: {
						if (bar.muted)
							return "󰝟";
						if (bar.volume < 34)
							return "󰕿";
						if (bar.volume < 67)
							return "󰖀";
						return "󰕾";
					}
					font.family: Theme.fontMono
					color: bar.muted ? Theme.dim : Theme.fg
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
						text: bar.battery ? Math.round(bar.battery.percentage * 100) + "%" : ""
						color: Theme.fg
					}
				}
			}

			StatusItem {
				visible: Sys.weather.length > 0
				interactive: false

				StyledText {
					// wttrbar's own indicator string, unchanged from waybar.
					text: Sys.weather
					font.family: Theme.fontMono
					color: Theme.fg
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
				interactive: false

				StyledText {
					// macOS order: weekday, month, day, then the time.
					text: Qt.formatDateTime(clock.date, "ddd d MMM  h:mm AP")
					color: Theme.fg
				}
			}
		}
	}
}
