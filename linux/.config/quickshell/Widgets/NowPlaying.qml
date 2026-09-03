import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.Config

// Now Playing, as macOS puts it at the top of Control Centre: art on the left,
// track and artist beside it, transport underneath.
Item {
	id: media

	// Prefer whatever is actually playing; fall back to the first player so a
	// paused track stays reachable instead of the panel emptying out.
	readonly property var player: {
		const ps = Mpris.players.values;
		for (let i = 0; i < ps.length; i++)
			if (ps[i].isPlaying)
				return ps[i];
		return ps.length > 0 ? ps[0] : null;
	}

	visible: media.player !== null
	implicitHeight: visible ? 62 : 0

	Rectangle {
		id: art

		width: 54
		height: 54
		radius: 8
		anchors.verticalCenter: parent.verticalCenter
		color: Theme.withFg(0.10)
		clip: true

		Image {
			anchors.fill: parent
			source: media.player ? media.player.trackArtUrl : ""
			fillMode: Image.PreserveAspectCrop
			asynchronous: true
			visible: status === Image.Ready
		}

		StyledText {
			anchors.centerIn: parent
			visible: !media.player || media.player.trackArtUrl === ""
			text: "󰎈"
			font.family: Theme.fontMono
			font.pointSize: Theme.fontSize + 4
			color: Theme.dim
		}
	}

	Column {
		anchors.left: art.right
		anchors.leftMargin: 10
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		spacing: 1

		StyledText {
			width: parent.width
			text: media.player ? media.player.trackTitle : ""
			font.weight: Font.DemiBold
		}

		StyledText {
			width: parent.width
			text: media.player ? media.player.trackArtist : ""
			color: Theme.dim
			font.pointSize: Theme.fontSize - 1
		}

		Row {
			spacing: 14
			topPadding: 3

			Repeater {
				model: [
					{ glyph: "󰒮", act: "previous" },
					{ glyph: "play", act: "toggle" },
					{ glyph: "󰒭", act: "next" }
				]

				StyledText {
					required property var modelData

					text: modelData.glyph === "play" ? (media.player && media.player.isPlaying ? "󰏤" : "󰐊") : modelData.glyph
					font.family: Theme.fontMono
					font.pointSize: Theme.fontSize + 2
					color: hover.hovered ? Theme.accent : Theme.fg

					HoverHandler {
						id: hover
					}

					TapHandler {
						onTapped: {
							if (!media.player)
								return;
							if (modelData.act === "previous")
								media.player.previous();
							else if (modelData.act === "next")
								media.player.next();
							else
								media.player.togglePlaying();
						}
					}
				}
			}
		}
	}
}
