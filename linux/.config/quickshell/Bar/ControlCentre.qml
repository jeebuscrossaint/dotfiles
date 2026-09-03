import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import qs.Config
import qs.Widgets
import qs.Services

// Control Centre. Everything waybar kept in the bar itself -- the sliders, the
// load drawer, disk, temperature, fan, uptime -- lives here instead, which is
// the macOS division: the menu bar stays a strip of glyphs and the knobs are one
// click behind it.
Popover {
	id: cc

	panelWidth: 330

	PwObjectTracker {
		objects: [Pipewire.defaultAudioSink]
	}

	readonly property var sink: Pipewire.defaultAudioSink

	IpcHandler {
		target: "control"

		function toggle(): void { cc.open = !cc.open; }
		function open(): void { cc.open = true; }
		function close(): void { cc.open = false; }
	}

	Column {
		id: body

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		spacing: 10

		NowPlaying {
			width: parent.width
		}

		Rectangle {
			width: parent.width
			height: Style.hairline
			color: Theme.hairline
			visible: parent.children[0].visible
		}

		Slider {
			width: parent.width
			glyph: cc.sink && cc.sink.audio && cc.sink.audio.muted ? "󰝟" : "󰕾"
			value: cc.sink && cc.sink.audio ? cc.sink.audio.volume : 0
			onMoved: v => {
				if (cc.sink && cc.sink.audio)
					cc.sink.audio.volume = v;
			}
		}

		Slider {
			width: parent.width
			glyph: "󰃟"
			value: Sys.brightness
			// brightnessctl rather than a sysfs write: the backlight node
			// is root-owned, and this is the same path the osd script
			// already relies on.
			onMoved: v => Quickshell.execDetached(["brightnessctl", "--quiet", "set", Math.max(1, Math.round(v * 100)) + "%"])
		}

		// Power profiles, macOS's Low Power Mode with the middle ground Linux
		// actually has. Backed by tuned-ppd here, which speaks the
		// power-profiles-daemon interface -- I had assumed nothing did, because
		// `powerprofilesctl` is not on PATH. The D-Bus name is what matters.
		Row {
			width: parent.width
			spacing: 6
			visible: Sys.powerProfiles

			Repeater {
				model: [
					{ label: "Low Power", value: PowerProfile.PowerSaver },
					{ label: "Balanced", value: PowerProfile.Balanced },
					{ label: "High", value: PowerProfile.Performance }
				]

				Rectangle {
					required property var modelData

					readonly property bool active: PowerProfiles.profile === modelData.value

					width: (parent.width - 12) / 3
					height: 28
					radius: 7
					color: active ? Theme.accent : Theme.withFg(0.12)
					// Performance is not offered on every machine; greying it out
					// beats letting it be selected and silently ignored.
					opacity: modelData.value === PowerProfile.Performance && !PowerProfiles.hasPerformanceProfile ? 0.4 : 1

					StyledText {
						anchors.centerIn: parent
						text: modelData.label
						font.pointSize: Theme.fontSize - 1
						color: parent.active ? Theme.bg : Theme.fg
					}

					TapHandler {
						enabled: modelData.value !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile
						onTapped: PowerProfiles.profile = modelData.value
					}
				}
			}
		}

		Rectangle {
			width: parent.width
			height: Style.hairline
			color: Theme.hairline
		}

		// Per-core bars, kept from the waybar cpu module. Sixteen threads
		// at a glance says something a single averaged percentage cannot:
		// one pegged core looks nothing like an evenly busy machine.
		Row {
			width: parent.width
			height: 22
			spacing: 2

			Repeater {
				model: Sys.cores

				Rectangle {
					required property var modelData

					width: (body.width - (Sys.cores.length - 1) * 2) / Math.max(1, Sys.cores.length)
					height: parent.height
					radius: 2
					color: Theme.withFg(0.12)

					Rectangle {
						anchors.bottom: parent.bottom
						width: parent.width
						height: Math.max(2, parent.height * modelData / 100)
						radius: 2
						color: modelData > 85 ? Theme.error : Theme.accent

						Behavior on height {
							NumberAnimation {
								duration: 400
								easing.type: Easing.Bezier
								easing.bezierCurve: Style.macStd
							}
						}
					}
				}
			}
		}

		Meter {
			width: parent.width
			label: "CPU  " + Sys.freqAvg.toFixed(1) + " GHz avg, " + Sys.freqMax.toFixed(1) + " peak"
			value: Math.round(Sys.cpu) + "%  " + Sys.temperature + "°"
			fill: Sys.cpu / 100
			// waybar's temperature module went critical at 90.
			tint: Sys.temperature >= 90 ? Theme.error : Theme.accent

			TapHandler {
				onTapped: Quickshell.execDetached({ command: ["kitty", "btop"], workingDirectory: Quickshell.env("HOME") })
			}
		}

		Meter {
			width: parent.width
			label: "Memory"
			value: Sys.memUsedGiB.toFixed(1) + " / " + Sys.memTotalGiB.toFixed(0) + " GiB"
			fill: Sys.memory / 100

			TapHandler {
				onTapped: Quickshell.execDetached({ command: ["kitty", "btop"], workingDirectory: Quickshell.env("HOME") })
			}
		}

		Meter {
			width: parent.width
			label: "Swap"
			visible: Sys.swapTotalGiB > 0
			value: Sys.swapUsedGiB.toFixed(1) + " / " + Sys.swapTotalGiB.toFixed(0) + " GiB"
			fill: Sys.swap / 100
		}

		Meter {
			width: parent.width
			label: "Disk  " + Sys.diskFree
			value: Sys.diskUsed
			fill: Sys.disk / 100
		}

		Rectangle {
			width: parent.width
			height: Style.hairline
			color: Theme.hairline
		}

		Item {
			width: parent.width
			height: 18

			StyledText {
				anchors.left: parent.left
				// NVMe runs far closer to its limit than the CPU does -- waybar
				// gave it a 70 degree critical against the CPU's 90 -- and it had
				// no home at all in the first version of this panel.
				text: Sys.fan + (Sys.nvmeTemp > 0 ? "   󰋊 " + Sys.nvmeTemp + "°" : "")
				font.family: Theme.fontMono
				color: Sys.nvmeTemp >= 70 ? Theme.error : Theme.dim
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

		// Load gets its own line. On one row with the fan and the uptime the
		// three ran into each other -- the whole point of a load average is that
		// it is three numbers, and it is the widest thing in the panel.
		StyledText {
			width: parent.width
			visible: Sys.load.length > 0
			text: "load  " + Sys.load
			font.family: Theme.fontMono
			color: Theme.dim
			font.pointSize: Theme.fontSize - 1
		}
	}
}
