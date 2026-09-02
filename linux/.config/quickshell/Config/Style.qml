pragma Singleton

import QtQuick
import Quickshell

// Geometry and motion. Deliberately not coat's job -- coat owns colour and type,
// and a scheme switch must never move anything.
Singleton {
	// The same four curves Hyprland animates windows with (hyprland.lua "macXxx"
	// beziers), restated in QML's [x1,y1,x2,y2,1,1] form. Sharing them is most of
	// what makes a shell read as part of the desktop instead of pasted on top:
	// a panel that eases differently from the windows around it looks wrong even
	// when nobody can say why.
	readonly property var macStd: [0.25, 0.10, 0.25, 1.00, 1, 1]
	readonly property var macOut: [0.25, 0.90, 0.32, 1.00, 1, 1]
	readonly property var macFade: [0.50, 0.50, 0.75, 1.00, 1, 1]
	readonly property var macMove: [0.32, 0.00, 0.06, 1.00, 1, 1]

	// Asymmetric on purpose. Opening is the part you watch, dismissal should be
	// out of the way before you have finished pressing Escape.
	readonly property int durEnter: 190
	readonly property int durExit: 130
	readonly property int durResize: 160

	readonly property int radiusPanel: 18
	readonly property int radiusRow: 8
	readonly property int hairline: 1

	readonly property int spotlightWidth: 660
	// Fraction of screen height above the panel. macOS parks Spotlight high but
	// not at the top edge; centring it vertically makes the results list jump
	// around as it grows.
	readonly property real spotlightTop: 0.18
	readonly property int spotlightMaxRows: 8

	// macOS banners are narrower than the 420 fnott used and the icon is much
	// bigger relative to the card -- that proportion is most of the look.
	readonly property int barHeight: 28

	readonly property int notifWidth: 380
	readonly property int notifIcon: 38
	readonly property int notifSpacing: 10

	readonly property int rowHeight: 46
	readonly property int iconSize: 30
	readonly property int padding: 14
	readonly property int gap: 10
}
