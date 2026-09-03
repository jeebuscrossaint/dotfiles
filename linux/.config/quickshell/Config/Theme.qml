pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Everything coat owns: palette and fonts. Nothing else in the shell is allowed
// to name a colour literally.
//
// The file is JSON watched by a FileView rather than a generated QML singleton,
// because QML source is only re-read on a full shell reload. This way `coat
// apply` repaints a running shell mid-frame.
//
// Parsed BY HAND rather than through JsonAdapter, and that is the whole point of
// this file working at all. With an adapter the initial read populates correctly
// and a later reload does not: the file is re-read, the adapter is not
// re-applied, and the theme silently never changes until the shell restarts.
// That is exactly how it behaved -- an in-place edit of coat.json moved nothing,
// while restarting picked it up. Todo and History always used manual parsing and
// always worked live, which is what gave it away.
Singleton {
	id: root

	// Defaults are a real, readable dark palette, not placeholders: they are
	// what the shell runs on before coat has ever been applied, and on any
	// machine where the file is missing or unparseable.
	property color bg: "#16181d"
	property color fg: "#c9ccd3"
	property color dim: "#6b7280"
	property color accent: "#7aa2f7"
	property color error: "#f7768e"
	property color warning: "#e0af68"
	property color success: "#9ece6a"

	property bool isDark: true
	property string schemeName: "unthemed"

	property string fontSans: "sans-serif"
	property string fontMono: "monospace"
	property int fontSize: 10

	// Kept as separate channels because Qt.rgba() takes floats, and rebuilding a
	// translucent tint from a hex string on every binding is wasteful.
	property int bgR: 22
	property int bgG: 24
	property int bgB: 29
	property int fgR: 201
	property int fgG: 204
	property int fgB: 211

	// Alpha over the background, as properties rather than function calls: a
	// binding onto a function never re-evaluates when the scheme changes
	// underneath it, so live retheming would stop working for every surface that
	// used one.
	//
	// The alphas are rice constants and deliberately NOT coat's opacity knobs.
	// Those are 1.0 in coat.yaml on purpose, and an opaque surface frosts
	// nothing -- the compositor blur behind these panels needs something to show
	// through.
	readonly property color surface: root.withBg(0.82)
	readonly property color raised: root.withBg(0.55)
	readonly property color hairline: root.withFg(0.10)
	readonly property color scrim: root.withBg(0.35)

	function withBg(a: real): color {
		return Qt.rgba(root.bgR / 255, root.bgG / 255, root.bgB / 255, a);
	}

	function withFg(a: real): color {
		return Qt.rgba(root.fgR / 255, root.fgG / 255, root.fgB / 255, a);
	}

	function reload(text: string): void {
		let j;
		try {
			j = JSON.parse(text);
		} catch (e) {
			// coat writes non-atomically, so a save can be observed mid-truncate.
			// Keeping the last good palette and waiting for the next change event
			// is better than flashing the fallback.
			return;
		}
		if (!j || !j.role)
			return;

		root.bg = j.role.bg;
		root.fg = j.role.fg;
		root.dim = j.role.dim;
		root.accent = j.role.accent;
		root.error = j.role.error;
		root.warning = j.role.warning;
		root.success = j.role.success;

		if (j.scheme) {
			root.isDark = j.scheme.isDark;
			root.schemeName = j.scheme.name;
		}

		if (j.bgRgb) {
			root.bgR = j.bgRgb.r;
			root.bgG = j.bgRgb.g;
			root.bgB = j.bgRgb.b;
		}
		if (j.fgRgb) {
			root.fgR = j.fgRgb.r;
			root.fgG = j.fgRgb.g;
			root.fgB = j.fgRgb.b;
		}

		if (j.font) {
			root.fontSans = j.font.sans;
			root.fontMono = j.font.mono;
			root.fontSize = j.font.sizePopup;
		}
	}

	readonly property string coatPath: `${Quickshell.shellDir}/coat.json`

	// FileView is used ONLY as a change notifier here, and the content is read
	// with `cat`. That is deliberate, after trying the alternatives:
	//
	//   JsonAdapter          populates on the first read and is never
	//                        re-applied on a reload
	//   text() on change     returns the CACHED contents; FileView only
	//                        re-reads when the path changes
	//   blockLoading         makes the read synchronous, not fresh
	//   bouncing the path    two assignments in one tick coalesce, so nothing
	//                        is re-read
	//
	// Every one of those left the shell insisting on the previous palette while
	// coat.json on disk plainly said otherwise -- the theme only ever changed
	// when the shell restarted. onFileChanged itself is reliable; it is the
	// content that goes stale. One fork per theme switch is a rounding error
	// against a feature that did not work.
	FileView {
		id: watcher

		path: root.coatPath
		watchChanges: true
		printErrors: false

		onLoaded: reader.read()
		onFileChanged: reader.read()
	}

	Process {
		id: reader

		running: true
		command: ["cat", root.coatPath]
		stdout: StdioCollector {
			id: out
		}
		onExited: code => {
			if (code === 0)
				root.reload(out.text);
		}

		function read(): void {
			reader.running = false;
			reader.running = true;
		}
	}
}
