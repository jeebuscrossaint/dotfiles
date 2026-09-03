import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Greetd

// The login window, laid out exactly like the shell's lock screen so login and
// lock are one design.
//
// SELF-CONTAINED on purpose, and that is not a style choice. greetd runs this as
// the `greeter` user, before anyone has logged in, and $HOME is mode 700 -- so
// none of the shell's qs.Config / qs.Widgets / coat.json is readable from here.
// Everything it needs is in this one file, including the palette, which means it
// does NOT follow coat: a scheme change has to be copied down by hand. Making it
// follow would need coat to write a world-readable palette to a root-owned path.
ShellRoot {
	id: greeter

	// Kept in step with coat's classic-dark by hand. See the note above.
	readonly property color bg: "#151515"
	readonly property color fg: "#D0D0D0"
	readonly property color dim: "#505050"
	readonly property color accent: "#6A9FB5"
	readonly property color error: "#AC4142"

	readonly property string uiFont: "SFProText Nerd Font"

	// The user to log in. There is one human on this machine, so there is no
	// user list to draw -- macOS shows exactly this when it has one account.
	readonly property string account: "amarnath"

	// The CURRENT wallpaper, not a hand-picked copy. ~/.local/bin/awww drops the
	// image it just set into /var/lib/greeter on every change, because $HOME is
	// mode 700 and nothing under it is reachable from the greeter user -- file
	// permissions on the image itself do not help, since traversal needs +x on
	// every parent directory.
	//
	// The extension is part of the filename because Qt picks the image format
	// from it. Tried in order, first one that loads wins.
	readonly property var wallpapers: [
		"file:///var/lib/greeter/wallpaper.jpg",
		"file:///var/lib/greeter/wallpaper.jpeg",
		"file:///var/lib/greeter/wallpaper.png",
		"file:///var/lib/greeter/wallpaper.webp",
		"file:///usr/share/backgrounds/login.jpg",
		"file:///usr/share/hypr/wall0.png"
	]

	property int paperIndex: 0
	property string buffer: ""
	property string status: ""
	property bool failed: false
	property bool prompting: false
	property bool busy: false

	function submit(): void {
		if (greeter.busy || greeter.buffer.length === 0)
			return;
		greeter.busy = true;
		greeter.status = "";
		// createSession starts the conversation; the password goes back through
		// the authMessage handler below.
		Greetd.createSession(greeter.account);
	}

	Connections {
		target: Greetd

		function onAuthMessage(message: string, isSecret: bool, responseRequired: bool) {
			if (responseRequired)
				Greetd.respond(greeter.buffer);
		}

		function onAuthFailure(message: string) {
			greeter.busy = false;
			greeter.failed = true;
			greeter.buffer = "";
			greeter.status = "Incorrect password";
			shake.restart();
		}

		function onError(message: string) {
			greeter.busy = false;
			greeter.failed = true;
			greeter.status = message;
		}

		function onStateChanged() {
			if (Greetd.state !== GreetdState.ReadyToLaunch)
				return;

			// PATH is set here, not left to greetd. greetd's login environment
			// does not include ~/.local/bin, and almost every keybind in
			// hyprland.lua runs a script from there -- osd, lock, menu-run,
			// screenshot. They fail silently, which looks exactly like "no
			// keybinds work". A TTY login only worked because fish had already
			// prepended it before exec'ing the compositor.
			Greetd.launch(["sh", "-c", "export PATH=\"$HOME/.local/bin:$HOME/.cargo/bin:$PATH\"; exec Hyprland"]);
		}
	}

	SystemClock {
		id: clock

		precision: SystemClock.Seconds
	}

	// FloatingWindow, NOT PanelWindow, and this is the whole reason the greeter
	// came up black under cage:
	//
	//   WARN: Failed to initialize layershell integration
	//
	// cage is a kiosk compositor and does not implement wlr-layer-shell, so a
	// PanelWindow has no surface to draw into. A plain xdg-toplevel does, and
	// cage fullscreens its single window by definition -- which is exactly the
	// geometry a greeter wants anyway. It also gets keyboard focus as a normal
	// toplevel, so the layershell focus mode is not needed either.
	FloatingWindow {
		id: win

		visible: true
		color: greeter.bg

		Image {
			id: paper

			anchors.fill: parent
			source: greeter.wallpapers[greeter.paperIndex]
			fillMode: Image.PreserveAspectCrop
			visible: false
			// Required for MultiEffect to have anything to sample.
			layer.enabled: true
			// Walk the candidate list rather than showing a broken image.
			onStatusChanged: {
				if (status === Image.Error && greeter.paperIndex + 1 < greeter.wallpapers.length)
					greeter.paperIndex += 1;
			}
		}

		// Sharp until you start typing, then blurred -- the macOS behaviour, and
		// the same code path the lock screen uses.
		MultiEffect {
			anchors.fill: parent
			source: paper
			visible: paper.status === Image.Ready
			blurEnabled: true
			blurMax: 64
			blur: greeter.prompting ? 0.78 : 0
			brightness: greeter.prompting ? -0.15 : 0

			Behavior on blur {
				NumberAnimation {
					duration: 300
				}
			}

			Behavior on brightness {
				NumberAnimation {
					duration: 300
				}
			}
		}

		Column {
			anchors.horizontalCenter: parent.horizontalCenter
			y: parent.height * 0.09
			spacing: 0

			Text {
				anchors.horizontalCenter: parent.horizontalCenter
				text: Qt.formatDateTime(clock.date, "dddd, d MMMM")
				font.family: greeter.uiFont
				font.pointSize: 15
				color: "white"
				opacity: 0.9
			}

			Text {
				anchors.horizontalCenter: parent.horizontalCenter
				text: Qt.formatDateTime(clock.date, "h:mm")
				font.family: greeter.uiFont
				font.pointSize: 96
				font.weight: Font.DemiBold
				color: "white"
			}
		}

		Column {
			anchors.horizontalCenter: parent.horizontalCenter
			anchors.bottom: parent.bottom
			anchors.bottomMargin: parent.height * 0.042
			spacing: 10

			Rectangle {
				anchors.horizontalCenter: parent.horizontalCenter
				width: 96
				height: 96
				radius: 48
				color: Qt.rgba(1, 1, 1, 0.18)
				border.width: 1
				border.color: Qt.rgba(1, 1, 1, 0.25)

				Text {
					anchors.centerIn: parent
					text: greeter.account.charAt(0).toUpperCase()
					font.family: greeter.uiFont
					font.pointSize: 38
					color: "white"
				}
			}

			Text {
				anchors.horizontalCenter: parent.horizontalCenter
				text: greeter.account
				font.family: greeter.uiFont
				font.pointSize: 13
				font.weight: Font.DemiBold
				color: "white"
			}

			Item {
				id: field

				anchors.horizontalCenter: parent.horizontalCenter
				width: 230
				height: 36
				opacity: greeter.prompting ? 1 : 0
				visible: opacity > 0.01

				Behavior on opacity {
					NumberAnimation {
						duration: 300
					}
				}

				SequentialAnimation {
					id: shake

					loops: 2

					NumberAnimation {
						target: field
						property: "anchors.horizontalCenterOffset"
						to: 9
						duration: 45
					}
					NumberAnimation {
						target: field
						property: "anchors.horizontalCenterOffset"
						to: -9
						duration: 45
					}
					NumberAnimation {
						target: field
						property: "anchors.horizontalCenterOffset"
						to: 0
						duration: 45
					}
				}

				Rectangle {
					anchors.fill: parent
					radius: height / 2
					color: Qt.rgba(0, 0, 0, 0.45)
					border.width: 1
					border.color: greeter.failed ? greeter.error : Qt.rgba(1, 1, 1, 0.3)
				}

				Text {
					anchors.centerIn: parent
					visible: greeter.buffer.length === 0 && !greeter.busy
					text: "Enter Password"
					font.family: greeter.uiFont
					font.pointSize: 12
					color: Qt.rgba(1, 1, 1, 0.5)
				}

				Row {
					anchors.centerIn: parent
					spacing: 6
					visible: greeter.buffer.length > 0 && !greeter.busy

					Repeater {
						model: Math.min(greeter.buffer.length, 16)

						Rectangle {
							width: 7
							height: 7
							radius: 3.5
							color: "white"
						}
					}
				}

				Text {
					anchors.centerIn: parent
					visible: greeter.busy
					text: "Signing in…"
					font.family: greeter.uiFont
					font.pointSize: 12
					color: Qt.rgba(1, 1, 1, 0.6)
				}
			}

			Text {
				anchors.horizontalCenter: parent.horizontalCenter
				text: greeter.status
				font.family: greeter.uiFont
				font.pointSize: 12
				color: greeter.error
				opacity: greeter.status.length > 0 ? 1 : 0
			}
		}

		// The surface owns the keyboard, so keys are taken here rather than in a
		// focused text field -- nothing to focus, nothing that can be revealed.
		Item {
			anchors.fill: parent
			focus: true

			Keys.onPressed: event => {
				if (greeter.busy)
					return;

				greeter.prompting = true;

				if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
					greeter.submit();
				} else if (event.key === Qt.Key_Backspace) {
					greeter.buffer = event.modifiers & Qt.ControlModifier ? "" : greeter.buffer.slice(0, -1);
				} else if (event.key === Qt.Key_Escape) {
					greeter.buffer = "";
				} else if (event.text.length > 0 && !/[\x00-\x1F\x7F]/.test(event.text)) {
					greeter.failed = false;
					greeter.status = "";
					greeter.buffer += event.text;
				}
				event.accepted = true;
			}
		}
	}
}
