import Quickshell
import "Launcher"

// Components are added here one at a time and only once they beat what they
// replace. waybar, fnott, fuzzel and hyprlock all keep running until then --
// a Quickshell layer coexists with them fine, and the last attempt at a QML
// shell died from doing everything at once.
ShellRoot {
	Spotlight {}
}
