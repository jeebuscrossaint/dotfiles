pragma Singleton

import QtQuick
import Quickshell

// One icon resolver for the whole shell.
//
// An icon reference can arrive as an absolute path, a file:// or data: url, a
// pixmap the notification server already turned into an image:// url, or a bare
// icon theme name. Anything that ends up being a NAME has to go through
// iconPath's check flag: without it a name the theme does not have comes back as
// a url that renders Qt's magenta missing-image checkerboard instead of nothing.
//
// image://icon/ is unwrapped rather than passed through, and that is the case
// that actually bites. `notify-send -i` travels as the image-path HINT, not as
// app_icon, and Quickshell rewrites the hint to image://icon/<name> without ever
// asking whether the theme has it -- so the one form that looks pre-resolved is
// the one that is not.
//
// Quickshell.hasThemeIcon is NOT usable here: it answers false for names that do
// resolve, and true for the empty string.
Singleton {
	function resolve(spec: string): string {
		if (!spec)
			return "";
		if (spec.startsWith("image://icon/"))
			return Quickshell.iconPath(spec.substring("image://icon/".length), true);
		// A bare absolute path has to be made into a file:// url. QML resolves a
		// relative-looking source against the component's own url, and for a
		// component compiled into the Quickshell binary that is a qrc: path --
		// so /usr/lib/.../nsys-ui.png was looked up as qrc:/usr/lib/...
		if (spec.startsWith("/"))
			return "file://" + spec;
		if (spec.startsWith("file:") || spec.startsWith("image:") || spec.startsWith("data:"))
			return spec;
		return Quickshell.iconPath(spec, true);
	}
}
