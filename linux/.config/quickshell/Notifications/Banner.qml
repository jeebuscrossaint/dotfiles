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
	// it is the whole reason that script can get away with having no daemon of
	// its own -- the level meter has to come from here.
	readonly property int level: notif.hints["value"] !== undefined ? notif.hints["value"] : -1
	readonly property bool hasLevel: level >= 0
	readonly property bool critical: notif.urgency === NotificationUrgency.Critical

	implicitHeight: body.implicitHeight + Style.padding * 2

	// A notification icon can arrive as an absolute path, a file:// or data: url,
	// a pixmap the server already turned into an image:// url, or a bare icon
	// theme name. Anything that ends up being a theme NAME has to be resolved
	// with iconPath's check flag: without it, a name the theme does not have
	// comes back as a url that renders Qt's magenta missing-image checkerboard
	// instead of as nothing.
	//
	// image://icon/ is unwrapped rather than passed through, and that is the
	// case that matters in practice. `notify-send -i firefox` travels as the
	// image-path HINT, not as app_icon, and Quickshell rewrites the hint to
	// image://icon/firefox without ever asking whether the theme has it -- so
	// the one path that looks pre-resolved is the one that is not. (The theme
	// here only has firefox-developer-edition.)
	function resolveIcon(spec: string): string {
		if (spec === "")
			return "";
		if (spec.startsWith("image://icon/"))
			return Quickshell.iconPath(spec.substring("image://icon/".length), true);
		if (spec.startsWith("/") || spec.startsWith("file:") || spec.startsWith("image:") || spec.startsWith("data:"))
			return spec;
		return Quickshell.iconPath(spec, true);
	}

	// Critical stays until it is acknowledged. Everything else follows the
	// client's own timeout, falling back to fnott's five seconds so the desktop
	// does not suddenly feel different.
	Timer {
		running: !banner.critical
		interval: banner.notif.expireTimeout > 0 ? banner.notif.expireTimeout : 5000
		onTriggered: banner.notif.tracked = false
	}

	Column {
		id: body

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.margins: Style.padding
		spacing: 4

		Row {
			width: parent.width
			spacing: Style.gap

			IconImage {
				id: icon

				anchors.verticalCenter: parent.verticalCenter
				implicitSize: Style.iconSize
				asynchronous: true
				visible: source != ""
				source: {
					// image first: it is a pixmap or path the client pushed over
					// the bus (album art, a screenshot) and beats an app icon.
					// It is ALSO where libnotify puts `notify-send -i`, as a
					// bare theme name -- which is why both go through the same
					// resolver instead of image being used raw.
					if (banner.notif.image !== "")
						return banner.resolveIcon(banner.notif.image);
					return banner.resolveIcon(banner.notif.appIcon);
				}
			}

			Column {
				width: parent.width - (icon.visible ? icon.width + Style.gap : 0)
				spacing: 1

				StyledText {
					width: parent.width
					text: banner.notif.summary
					color: banner.critical ? Theme.error : Theme.fg
				}

				StyledText {
					width: parent.width
					visible: text.length > 0
					text: banner.notif.body
					// Clients send Pango-ish markup and the spec allows it, so
					// the server advertises support; rendering it as plain text
					// would leak <b> tags into the banner.
					textFormat: Text.StyledText
					wrapMode: Text.Wrap
					maximumLineCount: 4
					// NOT Theme.dim. base03 is a fine secondary on an opaque
					// terminal background, but this surface is translucent and
					// over a light wallpaper the body simply disappeared.
					// fnott used base05 here for the same reason.
					color: Theme.fg
					opacity: 0.75
					font.pointSize: Theme.fontSize - 1
				}
			}
		}

		// Level meter. Sized like fnott's progress-bar-height so an OSD looks
		// the same as it did before the swap.
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

	MouseArea {
		anchors.fill: parent
		acceptedButtons: Qt.LeftButton | Qt.RightButton
		onClicked: banner.notif.tracked = false
	}

	// Entry only. There is no exit animation yet: the Notification object is
	// destroyed the moment it is untracked, which takes the delegate with it.
	// Doing it properly means holding the object with Retainable, and that is
	// not worth blocking the swap on.
	opacity: 0
	x: 40

	Component.onCompleted: {
		banner.opacity = 1;
		banner.x = 0;
	}

	Behavior on opacity {
		NumberAnimation {
			duration: Style.durEnter
			easing.type: Easing.Bezier
			easing.bezierCurve: Style.macFade
		}
	}

	Behavior on x {
		NumberAnimation {
			duration: Style.durEnter
			easing.type: Easing.Bezier
			easing.bezierCurve: Style.macOut
		}
	}
}
