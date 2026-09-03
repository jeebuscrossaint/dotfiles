import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland
import qs.Config
import qs.Widgets
import qs.Services

// The lock screen. macOS layout: big clock high on the screen, avatar and name
// centred, password pill under them, all over the blurred wallpaper.
//
// PAM was verified standalone before any of this was written, because the
// failure mode here is not a broken widget, it is a machine you cannot get back
// into. `hyprlock` is still installed and still what hypridle calls; this is
// bound to mod+L only until it has earned the rest.
Scope {
	id: lock

	property bool active: false
	property string buffer: ""
	property string status: ""
	property bool failed: false

	// macOS keeps the wallpaper SHARP at rest and only blurs once you start
	// entering a password -- the blur is focus, not decoration. The user widget
	// sits at the bottom until then, and the field crossfades in.
	property bool prompting: false


	function begin(): void {
		lock.buffer = "";
		lock.status = "";
		lock.failed = false;
		lock.prompting = false;
		lock.active = true;
	}

	function submit(): void {
		if (pam.active)
			return;
		// Empty submissions are dropped here rather than sent. PAM does reject
		// them -- verified against this machine's config, which is `auth include
		// login` -- but a lock screen should not be spending round trips to find
		// that out, and it should not depend on the PAM stack to say no.
		if (lock.buffer.length === 0)
			return;
		lock.status = "";
		pam.active = true;
	}

	IpcHandler {
		target: "lock"

		function lock(): void { lock.begin(); }

		// Escape hatch, and a deliberate one. A lock that has never been run
		// before could strand the machine; this cannot be reached from the
		// locked screen itself, only from an existing session (SSH, another
		// TTY) -- and anyone with that can already act as this user, so it
		// weakens nothing that was not already open.
		function unlock(): void { lock.active = false; }
	}


	PamContext {
		id: pam

		// The system's existing locker config, already set up to authenticate
		// this user.
		config: "hyprlock"

		onResponseRequiredChanged: {
			if (!pam.responseRequired)
				return;
			pam.respond(lock.buffer);
			lock.buffer = "";
		}

		onCompleted: result => {
			if (result === PamResult.Success) {
				lock.active = false;
				return;
			}
			lock.failed = true;
			lock.status = result === PamResult.MaxTries ? "Too many attempts" : "Incorrect password";
			shake.restart();
		}

		onError: err => {
			lock.failed = true;
			lock.status = "Authentication unavailable";
		}
	}

	SystemClock {
		id: clock

		precision: SystemClock.Seconds
	}

	// Just an existence check for the avatar; the image itself is loaded by the
	// surface below.
	FileView {
		id: faceFile

		property bool exists: false

		path: `${Quickshell.env("HOME")}/.face`
		blockLoading: true
		printErrors: false
		onLoaded: faceFile.exists = true
		onLoadFailed: faceFile.exists = false
	}

	WlSessionLock {
		id: session

		locked: lock.active

		WlSessionLockSurface {
			id: surface

			color: Theme.bg

			Image {
				id: paper

				anchors.fill: parent
				// From the shared service, not a query fired at lock time: that raced
		// the surface appearing and the lock came up on a flat background
		// instead of the wallpaper.
		source: Wallpaper.url
				fillMode: Image.PreserveAspectCrop
				asynchronous: true
				visible: false
				// layer.enabled is what makes a hidden Image usable as a
				// MultiEffect source. Without it the effect has nothing to
				// sample: the image loaded (status Ready) and the lock still
				// came up on a flat background.
				layer.enabled: true
			}

			// The wallpaper is blurred in the shell rather than by the
			// compositor: a session lock surface is the top of the stack with
			// nothing behind it to frost, so the layer blur rule that every other
			// panel relies on does nothing here.
			MultiEffect {
				anchors.fill: parent
				source: paper
				visible: paper.status === Image.Ready
				blurEnabled: true
				blurMax: 64
				// Sharp until the prompt appears, then a 300ms fade to a 50px
				// radius at 0.85 brightness -- the numbers Sonoma uses.
				blur: lock.prompting ? 0.78 : 0
				brightness: lock.prompting ? -0.15 : 0

				Behavior on blur {
					NumberAnimation {
						duration: 300
						easing.type: Easing.Bezier
						easing.bezierCurve: Style.macStd
					}
				}

				Behavior on brightness {
					NumberAnimation {
						duration: 300
					}
				}
			}

			// Only stands in for the wallpaper when there is none to show.
			Rectangle {
				anchors.fill: parent
				visible: paper.status !== Image.Ready
				color: Theme.bg
			}

			Column {
				anchors.horizontalCenter: parent.horizontalCenter
				// 9% from the top, per Sonoma's DATETIME_TOP_FRACTION.
				y: parent.height * 0.09
				spacing: 0

				// Date ABOVE the time, the way iOS and the Sonoma lock screen
				// stack them -- the other way round reads as a status bar.
				StyledText {
					anchors.horizontalCenter: parent.horizontalCenter
					text: Qt.formatDateTime(clock.date, "dddd, d MMMM")
					font.pointSize: Theme.fontSize + 5
					font.weight: Font.Medium
					color: "white"
					opacity: 0.9
				}

				StyledText {
					anchors.horizontalCenter: parent.horizontalCenter
					text: Qt.formatDateTime(clock.date, "h:mm")
					font.pointSize: 96
					font.weight: Font.DemiBold
					color: "white"
				}
			}

			// Notification cards, which macOS shows on the lock screen and this
			// did not. They come from the shell's own history rather than the
			// live server, so what accumulated while the screen was locked is
			// still here when you look at it -- a banner that expired during
			// the lock would otherwise be gone unseen.
			Column {
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.top: parent.top
				anchors.topMargin: parent.height * 0.34
				width: 420
				spacing: 8
				visible: History.items.length > 0 && !lock.prompting

				Repeater {
					model: History.items.slice(0, 3)

					Rectangle {
						required property var modelData

						width: parent.width
						implicitHeight: text.implicitHeight + 20
						radius: 14
						// Its own translucency rather than Theme.surface: this
						// sits on a wallpaper, not on a blurred panel.
						color: Qt.rgba(0, 0, 0, 0.42)

						Column {
							id: text

							anchors.left: parent.left
							anchors.right: parent.right
							anchors.verticalCenter: parent.verticalCenter
							anchors.margins: 12
							spacing: 1

							StyledText {
								width: parent.width
								text: modelData.summary
								font.weight: Font.DemiBold
								color: "white"
								elide: Text.ElideRight
							}

							StyledText {
								width: parent.width
								visible: text.length > 0
								text: modelData.body
								textFormat: Text.StyledText
								wrapMode: Text.Wrap
								maximumLineCount: 2
								font.pointSize: Theme.fontSize - 1
								color: "white"
								opacity: 0.75
							}
						}
					}
				}

				StyledText {
					anchors.horizontalCenter: parent.horizontalCenter
					visible: History.items.length > 3
					text: (History.items.length - 3) + " more"
					color: "white"
					opacity: 0.6
					font.pointSize: Theme.fontSize - 1
				}
			}

			Column {
				id: prompt

				anchors.horizontalCenter: parent.horizontalCenter
				// Bottom, not centre. Sonoma puts the password prompt's centre at
				// 95.75% of screen height and stacks the avatar and name above it.
				anchors.bottom: parent.bottom
				anchors.bottomMargin: parent.height * 0.042
				spacing: 10

				Rectangle {
					anchors.horizontalCenter: parent.horizontalCenter
					width: 96
					height: 96
					radius: 48
					color: Theme.withFg(0.18)
					border.width: 1
					border.color: Theme.withFg(0.25)

					Image {
						id: face

						anchors.fill: parent
						anchors.margins: 1
						// Guarded on the file existing: Image logs a warning per
						// frame for a source it cannot open, and most people have
						// no ~/.face.
						source: faceFile.exists ? "file://" + Quickshell.env("HOME") + "/.face" : ""
						fillMode: Image.PreserveAspectCrop
						asynchronous: true
						visible: false
					}

					// Circular crop. Without the mask the avatar is a square
					// sitting inside a round plate.
					MultiEffect {
						anchors.fill: parent
						anchors.margins: 1
						source: face
						visible: face.status === Image.Ready
						maskEnabled: true
						maskSource: mask
					}

					Rectangle {
						id: mask

						anchors.fill: parent
						radius: width / 2
						visible: false
						layer.enabled: true
					}

					StyledText {
						anchors.centerIn: parent
						visible: face.status !== Image.Ready
						text: (Quickshell.env("USER") || "?").charAt(0).toUpperCase()
						font.pointSize: 38
						color: "white"
					}
				}

				StyledText {
					anchors.horizontalCenter: parent.horizontalCenter
					text: Quickshell.env("USER")
					font.pointSize: Theme.fontSize + 3
					font.weight: Font.DemiBold
					color: "white"
				}

				Item {
					id: field

					anchors.horizontalCenter: parent.horizontalCenter
					width: 230
					height: 36
					opacity: lock.prompting ? 1 : 0
					visible: opacity > 0.01

					Behavior on opacity {
						NumberAnimation {
							duration: 300
							easing.type: Easing.Bezier
							easing.bezierCurve: Style.macFade
						}
					}

					// Shake on a wrong password, the way macOS does. It is the
					// only feedback that reads instantly without being read.
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
						color: Theme.withBg(0.55)
						border.width: 1
						border.color: lock.failed ? Theme.error : Theme.withFg(0.3)
					}

					StyledText {
						anchors.centerIn: parent
						visible: lock.buffer.length === 0 && !pam.active
						text: "Enter Password"
						color: Theme.withFg(0.5)
						font.pointSize: Theme.fontSize - 1
					}

					// Dots, not a TextInput. The surface owns the keyboard and
					// keys are handled below, so there is nothing to focus and
					// nothing that could ever be revealed.
					Row {
						anchors.centerIn: parent
						spacing: 6
						visible: lock.buffer.length > 0

						Repeater {
							model: Math.min(lock.buffer.length, 16)

							Rectangle {
								width: 7
								height: 7
								radius: 3.5
								color: "white"
							}
						}
					}

					StyledText {
						anchors.centerIn: parent
						visible: pam.active
						text: "Checking…"
						color: Theme.withFg(0.6)
						font.pointSize: Theme.fontSize - 1
					}
				}

				StyledText {
					anchors.horizontalCenter: parent.horizontalCenter
					text: lock.status
					color: Theme.error
					font.pointSize: Theme.fontSize - 1
					opacity: lock.status.length > 0 ? 1 : 0

					Behavior on opacity {
						NumberAnimation {
							duration: Style.durExit
						}
					}
				}
			}

			// The surface owns the keyboard for the whole session, so keys are
			// taken here rather than in a focused text field.
			Item {
				anchors.fill: parent
				focus: true

				Keys.onPressed: event => {
					if (pam.active)
						return;

					// First key wakes the prompt: blur fades in, field crossfades
					// in. Before that the screen is just wallpaper and a clock.
					lock.prompting = true;

					if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
						lock.submit();
					} else if (event.key === Qt.Key_Backspace) {
						lock.buffer = event.modifiers & Qt.ControlModifier ? "" : lock.buffer.slice(0, -1);
					} else if (event.key === Qt.Key_Escape) {
						lock.buffer = "";
					} else if (event.text.length > 0 && !/[\x00-\x1F\x7F]/.test(event.text)) {
						lock.failed = false;
						lock.status = "";
						lock.buffer += event.text;
					}
					event.accepted = true;
				}
			}
		}
	}
}
