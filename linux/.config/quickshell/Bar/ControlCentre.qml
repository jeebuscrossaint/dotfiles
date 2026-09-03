import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import qs.Config
import qs.Widgets
import qs.Services

// Control Centre. Everything waybar kept in the bar itself -- the sliders, the
// load drawer, disk, temperature, fan, uptime, weather -- lives here instead,
// which is the macOS division: the menu bar stays a strip of glyphs and the
// knobs are one click behind it.
Scope {
	id: cc

	property bool open: false

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

	PanelWindow {
		id: win

		visible: cc.open || card.opacity > 0.01

		anchors.top: true
		anchors.right: true
		margins.top: Style.barHeight + 6
		margins.right: 8
		implicitWidth: 330
		implicitHeight: card.implicitHeight
		color: "transparent"

		WlrLayershell.layer: WlrLayer.Overlay
		WlrLayershell.namespace: "qs-control"
		WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
		exclusionMode: ExclusionMode.Ignore

		// Dismiss on click-outside, armed the same way the launcher's is: a grab
		// request that simply FAILS reports active=false, and unarmed that would
		// shut the panel in the frame it opened. A hover timeout was the first
		// attempt and it is worse -- it closes the panel while you are reading
		// it, and it never opens at all when the toggle is hit from a keybind.
		HyprlandFocusGrab {
			id: grab

			property bool armed: false

			windows: [win]
			onActiveChanged: {
				if (grab.active) {
					grab.armed = true;
				} else if (grab.armed) {
					grab.armed = false;
					cc.open = false;
				}
			}
		}

		Connections {
			target: cc

			function onOpenChanged() {
				grab.armed = false;
				grab.active = cc.open;
			}
		}

		Card {
			id: card

			anchors.fill: parent
			implicitHeight: body.implicitHeight + Style.padding * 2

			opacity: cc.open ? 1 : 0
			scale: cc.open ? 1 : 0.96
			transformOrigin: Item.TopRight

			Behavior on opacity {
				NumberAnimation {
					duration: cc.open ? Style.durEnter : Style.durExit
					easing.type: Easing.Bezier
					easing.bezierCurve: Style.macFade
				}
			}

			Behavior on scale {
				NumberAnimation {
					duration: cc.open ? Style.durEnter : Style.durExit
					easing.type: Easing.Bezier
					easing.bezierCurve: Style.macOut
				}
			}

			Column {
				id: body

				anchors.left: parent.left
				anchors.right: parent.right
				anchors.top: parent.top
				anchors.margins: Style.padding
				spacing: 10

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
					label: "CPU"
					value: Math.round(Sys.cpu) + "%  " + Sys.temperature + "°"
					fill: Sys.cpu / 100
					tint: Sys.temperature >= 90 ? Theme.error : Theme.accent
				}

				Meter {
					width: parent.width
					label: "Memory"
					// Swap on the same line as RAM, the way the waybar module had
					// it -- shown instead of RAM is the mistake that format-swap
					// makes, and it is why that module spelled it out inline.
					value: Sys.memUsedGiB.toFixed(1) + " / " + Sys.memTotalGiB.toFixed(0) + " GiB" + (Sys.swap >= 1 ? "   swap " + Math.round(Sys.swap) + "%" : "")
					fill: Sys.memory / 100
				}

				Meter {
					width: parent.width
					label: "Disk"
					value: Sys.diskFree
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
						text: Sys.fan
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
}
