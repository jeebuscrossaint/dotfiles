import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.Config
import qs.Services
import qs.Widgets

// The volume / brightness / keyboard-backlight HUD: a centred rounded square
// with one large glyph and a segmented bar, the way macOS draws it.
//
// It is fed by NOTIFICATIONS, not by a daemon of its own. ~/.local/bin/osd still
// just calls notify-send, exactly as it did under fnott, and the shell routes
// anything with app_name "osd" here instead of into the banner stack. That keeps
// the property the osd script was built around -- nothing to restart when the
// theme changes, nothing to keep alive -- while giving it a real HUD.
Scope {
	id: hud

	property Notification notif: null

	readonly property int level: {
		if (!hud.notif)
			return -1;
		return hud.notif.hints["value"] !== undefined ? hud.notif.hints["value"] : -1;
	}

	// osd writes "<glyph>  <text>". Nerd Font icons live above the BMP, so the
	// glyph is a surrogate PAIR -- and splitting it in half renders the
	// missing-glyph diamond rather than the icon.
	//
	// The pair is detected by hand instead of with Array.from, which is the
	// obvious answer and the wrong one here: on a string coming from Qt it
	// iterates UTF-16 code UNITS, so it hands back the lone high surrogate. The
	// codepoints logged as db80,df0c -- two halves of U+F030C.
	readonly property var parts: {
		if (!hud.notif)
			return ["", ""];

		const text = hud.notif.summary;
		if (text.length === 0)
			return ["", ""];

		const first = text.charCodeAt(0);
		const width = first >= 0xD800 && first <= 0xDBFF && text.length > 1 ? 2 : 1;
		return [text.substring(0, width), text.substring(width).trim()];
	}

	// Deliberately shorter than the notification's own five seconds. A HUD is an
	// acknowledgement, not a message, and it sits in the middle of the screen.
	Timer {
		running: hud.notif !== null
		interval: 1300
		onTriggered: {
			if (hud.notif)
				hud.notif.tracked = false;
		}
	}

	PanelWindow {
		id: win

		// On the display being used, not whichever one Quickshell picked.
		screen: Screens.focused

		// Both clauses matter. With only the opacity test the window is never
		// created in the first place -- opacity starts at 0, so nothing renders,
		// so the fade that would raise it above the threshold never ticks.
		visible: hud.notif !== null || card.opacity > 0.01

		// No anchors at all: an unanchored layer surface is centred, which is
		// where this belongs.
		implicitWidth: 200
		implicitHeight: 200
		color: "transparent"

		WlrLayershell.layer: WlrLayer.Overlay
		WlrLayershell.namespace: "qs-hud"
		WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
		exclusionMode: ExclusionMode.Ignore

		Card {
			id: card

			anchors.fill: parent
			radius: 22

			opacity: hud.notif ? 1 : 0
			scale: hud.notif ? 1 : 0.92

			Behavior on opacity {
				NumberAnimation {
					duration: hud.notif ? Style.durEnter : Style.durExit
					easing.type: Easing.Bezier
					easing.bezierCurve: Style.macFade
				}
			}

			Behavior on scale {
				NumberAnimation {
					duration: hud.notif ? Style.durEnter : Style.durExit
					easing.type: Easing.Bezier
					easing.bezierCurve: Style.macOut
				}
			}

			StyledText {
				anchors.centerIn: parent
				anchors.verticalCenterOffset: hud.level >= 0 ? -14 : 0
				text: hud.parts[0]
				font.family: Theme.fontMono
				font.pointSize: 52
				color: Theme.fg
			}

			// Text only when there is no bar to say it -- "Night light 4000K"
			// needs words, "70%" does not.
			StyledText {
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.bottom: parent.bottom
				anchors.bottomMargin: 22
				width: parent.width - 24
				horizontalAlignment: Text.AlignHCenter
				visible: hud.level < 0
				text: hud.parts[1]
				color: Theme.dim
				font.pointSize: Theme.fontSize - 1
			}

			// Sixteen segments, not a continuous bar. It is what macOS draws and
			// it makes a single keypress visible as a discrete step.
			Row {
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.bottom: parent.bottom
				anchors.bottomMargin: 26
				spacing: 3
				visible: hud.level >= 0

				Repeater {
					model: 16

					Rectangle {
						required property int index

						width: 7
						height: 7
						radius: 1.5
						// Ceil, so any non-zero level lights at least one block:
						// a HUD that shows nothing at 3% looks broken.
						color: index < Math.ceil(Math.min(hud.level, 100) / 100 * 16) ? Theme.fg : Theme.withFg(0.2)

						Behavior on color {
							ColorAnimation {
								duration: 120
							}
						}
					}
				}
			}
		}
	}
}
