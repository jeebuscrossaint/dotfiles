import QtQuick
import qs.Config

// The one translucent surface every component sits on. No drop shadow: a layer
// surface is sized exactly to its content, so an effect drawn outside the panel
// bounds is clipped away by the compositor. Depth comes from the blur behind and
// the hairline edge instead, which is closer to how macOS does it anyway.
Rectangle {
	color: Theme.surface
	radius: Style.radiusPanel
	border.width: Style.hairline
	border.color: Theme.hairline
	antialiasing: true
}
