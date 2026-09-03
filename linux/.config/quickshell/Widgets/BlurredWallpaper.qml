import QtQuick
import QtQuick.Effects
import qs.Config
import qs.Services

// A blurred copy of the current wallpaper, drawn by the shell rather than by the
// compositor.
//
// Hyprland's layer blur applies to a layer's whole rectangle and does not reach
// a fullscreen one, so any overlay that covers the screen gets no frost from it.
// This gives that back: same look, no dependence on a layerrule, and it works on
// a session lock surface too, where there is nothing behind to blur.
Item {
	id: backdrop

	// 0 = sharp, 1 = fully blurred.
	property real amount: 1
	// Negative darkens. macOS dims as it blurs.
	property real dim: -0.15
	// Painted under the image so a missing wallpaper is the theme background
	// rather than a hole.
	property color fallback: Theme.bg

	Rectangle {
		anchors.fill: parent
		color: backdrop.fallback
	}

	Image {
		id: source

		anchors.fill: parent
		source: Wallpaper.url
		fillMode: Image.PreserveAspectCrop
		asynchronous: true
		cache: true
		// Hidden: MultiEffect draws it. Showing both would double the cost and
		// paint the sharp copy over the blurred one.
		visible: false
		// And layer.enabled is what makes a hidden Image usable as an effect
		// source at all -- without it MultiEffect has nothing to sample.
		layer.enabled: true
	}

	MultiEffect {
		anchors.fill: parent
		source: source
		visible: source.status === Image.Ready
		blurEnabled: true
		blurMax: 64
		blur: backdrop.amount
		brightness: backdrop.dim

		Behavior on blur {
			NumberAnimation {
				duration: Style.durEnter
				easing.type: Easing.Bezier
				easing.bezierCurve: Style.macStd
			}
		}
	}
}
