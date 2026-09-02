import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs.Config
import qs.Widgets

Card {
	id: banner

	required property Notification notif

	// notify-send -h int:value:N. osd(1) uses it for volume and brightness, and
	// it is the whole reason that script gets away with having no daemon of its
	// own -- the level meter has to come from here.
	readonly property int level: notif.hints["value"] !== undefined ? notif.hints["value"] : -1
	readonly property bool hasLevel: level >= 0
	readonly property bool critical: notif.urgency === NotificationUrgency.Critical

	// True once the server has closed the notification and only this lock is
	// keeping the object alive. Without the lock the object is destroyed on
	// close, the Repeater tears the delegate down with it, and the banner
	// vanishes mid-frame instead of sliding out.
	readonly property bool closing: lock.retained

	readonly property real arrival: Date.now()

	// Entered one tick after construction on purpose: QML applies a state that
	// is already true at creation WITHOUT running its transition, so binding
	// straight to `!closing` would snap the banner into place with no slide.
	property bool entered: false

	Component.onCompleted: banner.entered = true

	implicitHeight: body.implicitHeight + Style.padding * 2

	RetainableLock {
		id: lock

		object: banner.notif
		locked: true
	}

	function dismiss(): void {
		banner.notif.tracked = false;
	}

	// Critical stays until it is acknowledged, and hovering holds everything
	// else open -- reaching for a notification should not make it leave.
	Timer {
		running: !banner.critical && !banner.closing && !hover.hovered
		interval: banner.notif.expireTimeout > 0 ? banner.notif.expireTimeout : 5000
		onTriggered: banner.dismiss()
	}

	HoverHandler {
		id: hover
	}

	// Minute precision: the label only ever says now / 5m / 2h.
	SystemClock {
		id: clock

		precision: SystemClock.Minutes
	}

	Column {
		id: body

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.margins: Style.padding
		spacing: 6

		Row {
			width: parent.width
			spacing: Style.gap + 2

			IconImage {
				id: icon

				anchors.verticalCenter: parent.verticalCenter
				implicitSize: Style.notifIcon
				asynchronous: true
				visible: source != ""
				source: banner.notif.image !== "" ? banner.resolveIcon(banner.notif.image) : banner.resolveIcon(banner.notif.appIcon)
			}

			Column {
				width: parent.width - (icon.visible ? icon.width + parent.spacing : 0)
				spacing: 1

				Item {
					width: parent.width
					height: summary.implicitHeight

					StyledText {
						id: summary

						anchors.left: parent.left
						anchors.right: age.left
						anchors.rightMargin: Style.gap
						text: banner.notif.summary
						// The weight is doing real work: title bold over body
						// regular is the whole hierarchy of a macOS banner, and
						// without it the two lines read as one paragraph.
						font.weight: Font.DemiBold
						color: banner.critical ? Theme.error : Theme.fg
					}

					// Always "now" for a live banner, which is exactly what macOS
					// shows. It earns its keep the moment there is a notification
					// centre to scroll back through.
					StyledText {
						id: age

						anchors.right: parent.right
						anchors.baseline: summary.baseline
						text: banner.ageLabel
						color: Theme.dim
						font.pointSize: Theme.fontSize - 2
					}
				}

				StyledText {
					width: parent.width
					visible: text.length > 0
					text: banner.notif.body
					// Clients send Pango-ish markup and the server advertises
					// support for it, so rendering plain would leak <b> tags.
					textFormat: Text.StyledText
					wrapMode: Text.Wrap
					// Two lines, like macOS. Anything longer belongs in the app.
					maximumLineCount: 2
					// NOT Theme.dim. base03 is a fine secondary on an opaque
					// terminal background, but this surface is translucent and
					// over a light wallpaper the body simply disappeared.
					color: Theme.fg
					opacity: 0.75
					font.pointSize: Theme.fontSize - 1
				}
			}
		}

		// Level meter for the OSD.
		Rectangle {
			width: parent.width
			height: 4
			radius: 2
			visible: banner.hasLevel
			color: Theme.hairline

			Rectangle {
				width: parent.width * Math.min(banner.level, 100) / 100
				height: parent.height
				radius: parent.radius
				color: Theme.accent

				Behavior on width {
					NumberAnimation {
						duration: Style.durExit
						easing.type: Easing.Bezier
						easing.bezierCurve: Style.macOut
					}
				}
			}
		}
	}

	// Close affordance, top-left and only while hovered -- where macOS puts it.
	Rectangle {
		id: closer

		x: -6
		y: -6
		width: 20
		height: 20
		radius: 10
		color: Theme.raised
		border.width: Style.hairline
		border.color: Theme.hairline
		opacity: hover.hovered ? 1 : 0
		visible: opacity > 0.01

		Behavior on opacity {
			NumberAnimation {
				duration: Style.durExit
				easing.type: Easing.Bezier
				easing.bezierCurve: Style.macFade
			}
		}

		StyledText {
			anchors.centerIn: parent
			text: "✕"
			color: Theme.fg
			font.pointSize: Theme.fontSize - 3
		}

		MouseArea {
			anchors.fill: parent
			onClicked: banner.dismiss()
		}
	}

	MouseArea {
		anchors.fill: parent
		z: -1
		onClicked: banner.dismiss()
	}

	// Slide in from the right edge and back out the same way, which is the one
	// motion everybody recognises. `closing` drives the exit; when it finishes
	// the lock is released and the object is finally destroyed.
	opacity: 0
	x: width

	states: State {
		name: "shown"
		when: banner.entered && !banner.closing

		PropertyChanges {
			banner.opacity: 1
			banner.x: 0
		}
	}

	transitions: [
		Transition {
			to: "shown"

			NumberAnimation {
				properties: "x,opacity"
				duration: Style.durEnter
				easing.type: Easing.Bezier
				easing.bezierCurve: Style.macOut
			}
		},
		Transition {
			from: "shown"

			SequentialAnimation {
				NumberAnimation {
					properties: "x,opacity"
					duration: Style.durExit
					easing.type: Easing.Bezier
					easing.bezierCurve: Style.macStd
				}

				ScriptAction {
					script: lock.locked = false
				}
			}
		}
	]

	readonly property string ageLabel: {
		const mins = Math.floor((clock.date.getTime() - banner.arrival) / 60000);
		if (mins < 1)
			return "now";
		if (mins < 60)
			return mins + "m";
		return Math.floor(mins / 60) + "h";
	}

	// A notification icon can arrive as an absolute path, a file:// or data: url,
	// a pixmap the server already turned into an image:// url, or a bare icon
	// theme name. Anything that ends up being a theme NAME has to be resolved
	// with iconPath's check flag: without it, a name the theme does not have
	// comes back as a url that renders Qt's magenta missing-image checkerboard
	// instead of as nothing.
	//
	// image://icon/ is unwrapped rather than passed through, and that is the
	// case that matters in practice. `notify-send -i` travels as the image-path
	// HINT, not as app_icon, and Quickshell rewrites the hint to
	// image://icon/<name> without ever asking whether the theme has it -- so the
	// one form that looks pre-resolved is the one that is not.
	function resolveIcon(spec: string): string {
		if (spec === "")
			return "";
		if (spec.startsWith("image://icon/"))
			return Quickshell.iconPath(spec.substring("image://icon/".length), true);
		if (spec.startsWith("/") || spec.startsWith("file:") || spec.startsWith("image:") || spec.startsWith("data:"))
			return spec;
		return Quickshell.iconPath(spec, true);
	}
}
