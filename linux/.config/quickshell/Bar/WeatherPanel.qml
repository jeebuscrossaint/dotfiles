import QtQuick
import Quickshell
import Quickshell.Io
import qs.Config
import qs.Widgets
import qs.Services

// The forecast behind the weather item. wttrbar already produces all of this as
// its tooltip -- waybar just rendered it on hover -- so nothing here re-fetches
// or re-parses anything; the panel is the tooltip with somewhere to live.
Popover {
	id: weather

	panelWidth: 360

	IpcHandler {
		target: "weather"

		function toggle(): void { weather.open = !weather.open; }
		function open(): void { weather.open = true; }
		function close(): void { weather.open = false; }
	}

	Column {
		id: col

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		spacing: 8

		StyledText {
			text: Sys.weather.length > 0
				? (Sys.weatherPlace.length > 0 ? Sys.weatherPlace + "  " : "") + Sys.weather
				: "Weather unavailable"
			font.weight: Font.DemiBold
		}

		Rectangle {
			width: col.width
			height: Style.hairline
			color: Theme.hairline
		}

		Flickable {
			width: col.width
			// Three days of hourly rows is far taller than any panel should be.
			height: Math.min(forecast.implicitHeight, 420)
			contentHeight: forecast.implicitHeight
			clip: true
			boundsBehavior: Flickable.StopAtBounds

			StyledText {
				id: forecast

				width: parent.width
				// RichText inside <pre>, and both halves matter. StyledText
				// collapses newlines AND runs of spaces, which turned 33 lines
				// of forecast into one and destroyed the column alignment it is
				// built out of. <pre> preserves both, and rich text still honours
				// the <b> wttrbar puts around each day heading.
				text: "<pre style=\"font-family:'" + Theme.fontMono + "'\">" + Sys.weatherTip + "</pre>"
				textFormat: Text.RichText
				wrapMode: Text.NoWrap
				// MONOSPACE, unlike the rest of the shell. The forecast is a
				// column-aligned table of times, glyphs and temperatures; in SF
				// Pro the columns stagger and it reads as noise.
				font.family: Theme.fontMono
				font.pointSize: Theme.fontSize - 1
				lineHeight: 1.25
				color: Theme.fg
			}
		}
	}
}
