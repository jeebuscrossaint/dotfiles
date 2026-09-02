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
Singleton {
	id: root

	// Semantic roles. Widgets use these; the raw slots below exist for the rare
	// case that genuinely wants "the scheme's yellow" rather than "warning".
	readonly property color bg: json.role.bg
	readonly property color fg: json.role.fg
	readonly property color dim: json.role.dim
	readonly property color accent: json.role.accent
	readonly property color error: json.role.error
	readonly property color warning: json.role.warning
	readonly property color success: json.role.success

	readonly property bool isDark: json.scheme.isDark
	readonly property string schemeName: json.scheme.name

	readonly property string fontSans: json.font.sans
	readonly property string fontMono: json.font.mono
	readonly property int fontSize: json.font.sizePopup

	// Alpha over the background, precomputed as properties rather than exposed
	// as a function: a binding onto a function call never re-evaluates when the
	// scheme changes underneath it, so live retheming would silently stop
	// working for every surface that used one.
	//
	// The alphas are rice constants and deliberately NOT coat's opacity knobs.
	// Those are set to 1.0 in coat.yaml on purpose, and an opaque surface frosts
	// nothing -- the compositor blur behind these panels needs something to show
	// through. waybar's islands hardcode 0.85 for the same reason.
	readonly property color surface: withBg(0.72)
	readonly property color raised: withBg(0.55)
	readonly property color hairline: withFg(0.10)
	readonly property color scrim: withBg(0.35)

	function withBg(a: real): color {
		return Qt.rgba(json.bgRgb.r / 255, json.bgRgb.g / 255, json.bgRgb.b / 255, a);
	}

	function withFg(a: real): color {
		return Qt.rgba(json.fgRgb.r / 255, json.fgRgb.g / 255, json.fgRgb.b / 255, a);
	}

	FileView {
		// Same directory as this file: coat writes into the shell's own config
		// dir, which is what `coat apply quickshell` targets.
		path: `${Quickshell.shellDir}/coat.json`
		watchChanges: true
		// coat writes non-atomically, so a save can be observed mid-truncate.
		// The adapter keeps its last good values and the following change event
		// picks up the finished file; an error log for every theme switch is
		// just noise.
		printErrors: false

		// Defaults are a real, readable dark palette, not placeholders: they are
		// what the shell runs on before coat has ever been applied, and on any
		// machine where the file is missing.
		adapter: JsonAdapter {
			id: json

			property JsonObject scheme: JsonObject {
				property string name: "unthemed"
				property bool isDark: true
			}

			property JsonObject role: JsonObject {
				property color bg: "#16181d"
				property color fg: "#c9ccd3"
				property color dim: "#6b7280"
				property color accent: "#7aa2f7"
				property color error: "#f7768e"
				property color warning: "#e0af68"
				property color success: "#9ece6a"
			}

			property JsonObject bgRgb: JsonObject {
				property int r: 22
				property int g: 24
				property int b: 29
			}

			property JsonObject fgRgb: JsonObject {
				property int r: 201
				property int g: 204
				property int b: 211
			}

			property JsonObject font: JsonObject {
				property string sans: "sans-serif"
				property string mono: "monospace"
				property int sizePopup: 10
			}
		}
	}
}
