import Quickshell
import "Bar"
import "Desktop"
import "Dock"
import "Launcher"
import "Lock"
import "Preview"
import "Screenshot"
import "Notifications"

// Components are added here one at a time and only once they beat what they
// replace. fnott and fuzzel are gone -- Spotlight is the launcher, Picker is the
// dmenu for scripts, Daemon is the notification server. waybar and hyprlock are
// still the real thing; the last attempt at a QML shell died from trying to do
// everything at once.
ShellRoot {
	ScreenCorners {}
	Dashboard {}
	MissionControl {}
	Bar {}
	Dock {}
	Lock {}
	Region {}
	QuickLook {}
	Spotlight {}
	Picker {}
	Daemon {}
}
