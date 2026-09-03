pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// How often, and how recently, each app was launched from the launcher.
//
// Fuzzy score alone ranks by how well the letters match, which is why every
// launcher without this feels subtly wrong: typing "fi" should put the browser
// you open twenty times a day above a settings panel that happens to match
// better on paper.
Singleton {
	id: frecency

	// id -> { n: launches, last: epoch ms }
	property var entries: ({})

	// Recency buckets rather than a continuous decay curve. The exact shape does
	// not matter -- what matters is that a thing used today outranks a thing used
	// fifty times last year, and that the boost cannot dwarf the match itself.
	function score(id: string): real {
		const e = frecency.entries[id];
		if (!e)
			return 0;

		const days = (Date.now() - e.last) / 86400000;
		const recency = days < 1 ? 1.0 : (days < 7 ? 0.7 : (days < 30 ? 0.4 : 0.15));
		// Capped: past a couple of dozen launches, more launches should not keep
		// pushing an app further up.
		return Math.min(e.n, 24) * recency;
	}

	function bump(id: string): void {
		if (!id)
			return;
		const next = Object.assign({}, frecency.entries);
		const prev = next[id] || { n: 0, last: 0 };
		next[id] = { n: prev.n + 1, last: Date.now() };
		frecency.entries = next;
		store.setText(JSON.stringify(next));
	}

	// Most-used apps, for an empty query -- macOS Spotlight shows top hits
	// rather than a blank panel.
	function top(limit: int): var {
		const ids = Object.keys(frecency.entries);
		ids.sort((a, b) => frecency.score(b) - frecency.score(a));
		return ids.slice(0, limit);
	}

	FileView {
		id: store

		path: Quickshell.statePath("frecency.json")
		// Read once at startup; every write goes through bump(), so there is
		// nothing to watch for.
		blockLoading: true
		printErrors: false

		onLoaded: {
			try {
				frecency.entries = JSON.parse(store.text()) || ({});
			} catch (e) {
				frecency.entries = ({});
			}
		}
	}
}
