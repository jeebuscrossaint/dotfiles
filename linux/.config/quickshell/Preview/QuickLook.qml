import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Config
import qs.Widgets
import qs.Services

// Quick Look: spacebar-style file preview.
//
// There is no Linux equivalent of this and it is one of the few macOS features
// that is genuinely missed -- looking at a file without launching the app that
// owns it. Driven from `~/.local/bin/quicklook <path>`, so yazi, a keybind or a
// script can all reach it.
//
// Images render directly, PDFs go through pdftoppm (already installed for
// zathura), text is read straight off disk, and anything else falls back to
// what `file` and `stat` know. The fallback matters: a preview that shows
// nothing for a video is worse than one that says what the file is.
Scope {
	id: quick

	property string path: ""
	property string kind: ""
	property string info: ""
	property string pdfPage: ""

	readonly property bool active: quick.path.length > 0

	readonly property string name: {
		const parts = quick.path.split("/");
		return parts[parts.length - 1];
	}

	// By extension rather than by `file`, so the right widget is chosen before
	// any subprocess has run and the panel never flickers through a fallback.
	function classify(p: string): string {
		const ext = p.split(".").pop().toLowerCase();
		if (["png", "jpg", "jpeg", "webp", "gif", "bmp", "avif", "svg"].indexOf(ext) !== -1)
			return "image";
		if (ext === "pdf")
			return "pdf";
		if (["txt", "md", "json", "yaml", "yml", "toml", "ini", "conf", "log", "csv",
			"sh", "bash", "fish", "py", "rs", "c", "h", "cpp", "hpp", "qml", "js",
			"ts", "lua", "tex", "typ", "nix", "el", "vim"].indexOf(ext) !== -1)
			return "text";
		return "other";
	}

	function show(p: string): void {
		quick.pdfPage = "";
		quick.info = "";
		quick.kind = quick.classify(p);
		quick.path = p;

		stat.running = false;
		stat.running = true;

		if (quick.kind === "pdf") {
			pdf.running = false;
			pdf.running = true;
		}
	}

	function close(): void {
		quick.path = "";
	}

	IpcHandler {
		target: "quicklook"

		function show(path: string): void { quick.show(path); }
		function close(): void { quick.close(); }
		function toggle(path: string): void {
			if (quick.active)
				quick.close();
			else
				quick.show(path);
		}
	}

	// Size and type, for the header and for the "other" fallback.
	Process {
		id: stat

		command: ["sh", "-c", 'printf "%s · %s" "$(du -h "$1" 2>/dev/null | cut -f1)" "$(file -b "$1" 2>/dev/null | cut -c1-60)"', "sh", quick.path]
		stdout: StdioCollector {
			id: statOut
		}
		onExited: quick.info = statOut.text.trim()
	}

	// First page only. Rendered to the cache dir under a fixed name, so repeated
	// previews do not litter -- and at 1200px wide, which is plenty for a panel
	// and much faster than rendering at native resolution.
	Process {
		id: pdf

		command: ["sh", "-c",
			'out="${XDG_CACHE_HOME:-$HOME/.cache}/quickshell-quicklook"; ' +
			'rm -f "$out.png"; pdftoppm -png -r 100 -f 1 -l 1 -scale-to-x 1200 -scale-to-y -1 "$1" "$out" >/dev/null 2>&1; ' +
			'if [ -f "$out-1.png" ]; then mv "$out-1.png" "$out.png"; fi; ' +
			'[ -f "$out.png" ] && printf "%s" "$out.png"',
			"sh", quick.path]
		stdout: StdioCollector {
			id: pdfOut
		}
		onExited: {
			const p = pdfOut.text.trim();
			quick.pdfPage = p.length > 0 ? "file://" + p : "";
		}
	}

	FileView {
		id: textFile

		path: quick.kind === "text" ? quick.path : ""
		blockLoading: true
		printErrors: false
	}

	PanelWindow {
		id: win

		screen: Screens.focused
		visible: quick.active || card.opacity > 0.01

		anchors.top: true
		anchors.bottom: true
		anchors.left: true
		anchors.right: true
		color: "transparent"

		WlrLayershell.layer: WlrLayer.Overlay
		WlrLayershell.namespace: "qs-quicklook"
		WlrLayershell.keyboardFocus: quick.active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
		exclusionMode: ExclusionMode.Ignore

		Item {
			anchors.fill: parent
			focus: true

			Keys.onEscapePressed: quick.close()
			// Space closes it as well as opens it, which is the whole gesture on
			// macOS.
			Keys.onSpacePressed: quick.close()

			Rectangle {
				anchors.fill: parent
				color: Theme.withBg(0.6)
				opacity: card.opacity

				MouseArea {
					anchors.fill: parent
					onClicked: quick.close()
				}
			}

			Card {
				id: card

				anchors.centerIn: parent
				width: Math.min(parent.width - 200, 1100)
				height: Math.min(parent.height - 160, 800)
				radius: 14

				opacity: quick.active ? 1 : 0
				scale: quick.active ? 1 : 0.97

				Behavior on opacity {
					NumberAnimation {
						duration: quick.active ? Style.durEnter : Style.durExit
						easing.type: Easing.Bezier
						easing.bezierCurve: Style.macFade
					}
				}

				Behavior on scale {
					NumberAnimation {
						duration: quick.active ? Style.durEnter : Style.durExit
						easing.type: Easing.Bezier
						easing.bezierCurve: Style.macOut
					}
				}

				// Clicks inside the panel must not fall through to the scrim's
				// dismiss handler.
				MouseArea {
					anchors.fill: parent
				}

				Column {
					anchors.fill: parent
					anchors.margins: Style.padding
					spacing: 8

					Item {
						width: parent.width
						height: 24

						StyledText {
							anchors.left: parent.left
							anchors.right: meta.left
							anchors.rightMargin: Style.gap
							text: quick.name
							font.weight: Font.DemiBold
							elide: Text.ElideMiddle
						}

						StyledText {
							id: meta

							anchors.right: parent.right
							text: quick.info
							color: Theme.dim
							font.pointSize: Theme.fontSize - 1
						}
					}

					Rectangle {
						width: parent.width
						height: Style.hairline
						color: Theme.hairline
					}

					Item {
						width: parent.width
						height: parent.height - 40

						Image {
							anchors.fill: parent
							visible: quick.kind === "image" || quick.kind === "pdf"
							source: {
								if (quick.kind === "image")
									return quick.path.length > 0 ? "file://" + quick.path : "";
								return quick.pdfPage;
							}
							fillMode: Image.PreserveAspectFit
							asynchronous: true
							// Big source images scaled into a panel alias badly
							// without this.
							mipmap: true
						}

						Flickable {
							anchors.fill: parent
							visible: quick.kind === "text"
							contentHeight: body.implicitHeight
							contentWidth: width
							clip: true
							boundsBehavior: Flickable.StopAtBounds

							StyledText {
								id: body

								width: parent.width
								// Capped: a preview is a look, not a reader, and
								// a 200k-line log would take the panel down.
								text: quick.kind === "text" ? textFile.text().split("\n").slice(0, 400).join("\n") : ""
								font.family: Theme.fontMono
								font.pointSize: Theme.fontSize - 1
								wrapMode: Text.NoWrap
								textFormat: Text.PlainText
							}
						}

						StyledText {
							anchors.centerIn: parent
							visible: quick.kind === "other"
							horizontalAlignment: Text.AlignHCenter
							// `file` already said what it is; repeating the name
							// would be the only other thing to show.
							text: quick.info.length > 0 ? quick.info : "No preview"
							color: Theme.dim
						}
					}
				}
			}
		}
	}
}
