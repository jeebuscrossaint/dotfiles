pragma Singleton

import QtQuick
import Quickshell

// Notification history.
//
// Records are plain JS objects, deliberately -- NOT the Notification objects
// themselves. Those are destroyed the moment they are untracked (which is what
// RetainableLock exists to defer), so keeping the object would mean holding a
// lock open forever on every notification the machine has ever shown. Copying
// the four fields that get displayed costs nothing and cannot dangle.
Singleton {
	id: history

	// In memory only. It is a session log, not a mailbox -- surviving a shell
	// restart would mean a store to write, prune and migrate, for notifications
	// that were already read.
	property var items: []

	readonly property int limit: 60

	// Do Not Disturb. Notifications still land in the history -- that is where
	// macOS puts the ones it held back -- they just never appear as a banner.
	property bool dnd: false

	function push(notif: var): void {
		// osd is the volume/brightness HUD. Logging "󰕾 60%" sixty times because
		// a volume key was held would bury everything worth keeping.
		if (notif.appName === "osd")
			return;

		const next = history.items.slice();
		next.unshift({
			summary: notif.summary,
			body: notif.body,
			appName: notif.appName,
			icon: notif.image !== "" ? notif.image : notif.appIcon,
			at: Date.now()
		});
		history.items = next.slice(0, history.limit);
	}

	function clear(): void {
		history.items = [];
	}
}
