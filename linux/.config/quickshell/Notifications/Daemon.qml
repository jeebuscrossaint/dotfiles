import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.Config
import qs.Services

// Replaces fnott. Only one process can own org.freedesktop.Notifications, so
// unlike the launcher this one is not additive -- fnott has to be gone from the
// autostart list before this can take the bus name.
Scope {
	id: root

	// osd(1) notifications are pulled out of the banner stack and drawn as a
	// centred HUD instead. Matching on app_name is why the osd script needed no
	// change at all -- it has always passed `-a osd`.
	readonly property var osdNotif: {
		const all = server.trackedNotifications.values;
		for (let i = 0; i < all.length; i++)
			if (all[i].appName === "osd")
				return all[i];
		return null;
	}

	readonly property var banners: {
		const out = [];
		const all = server.trackedNotifications.values;
		for (let i = 0; i < all.length; i++)
			if (all[i].appName !== "osd")
				out.push(all[i]);
		return out;
	}

	Hud {
		notif: root.osdNotif
	}

	NotificationServer {
		id: server

		// Everything the banner below can actually render. Claiming a capability
		// the shell ignores is worse than not claiming it: clients send markup
		// or actions and then watch them vanish.
		keepOnReload: false
		bodySupported: true
		bodyMarkupSupported: true
		imageSupported: true
		actionsSupported: false

		// osd(1) relies on `notify-send -r` collapsing repeats onto one popup, so
		// a held volume key updates a single banner instead of stacking fifteen.
		// That is handled by the server itself; the model below just reflects it.
		onNotification: notif => {
			History.push(notif);
			notif.tracked = true;
		}
	}

	PanelWindow {
		id: win

		visible: root.banners.length > 0

		anchors.top: true
		anchors.right: true
		// fnott's edge-margin-vertical / -horizontal, kept so the stack does not
		// move when the daemon changes underneath it.
		margins.top: 10
		margins.right: 10

		implicitWidth: Style.notifWidth
		implicitHeight: Math.max(1, stack.implicitHeight)
		color: "transparent"

		WlrLayershell.layer: WlrLayer.Overlay
		WlrLayershell.namespace: "qs-notifications"
		// Never take focus. A notification stealing the keyboard mid-game is
		// exactly the failure the launcher already ran into.
		WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
		exclusionMode: ExclusionMode.Ignore

		Behavior on implicitHeight {
			NumberAnimation {
				duration: Style.durResize
				easing.type: Easing.Bezier
				easing.bezierCurve: Style.macStd
			}
		}

		Column {
			id: stack

			anchors.fill: parent
			spacing: Style.notifSpacing

			Repeater {
				model: root.banners

				Banner {
					required property var modelData

					notif: modelData
					width: stack.width
				}
			}
		}
	}
}
