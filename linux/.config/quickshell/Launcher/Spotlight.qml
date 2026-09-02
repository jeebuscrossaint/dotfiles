import Quickshell
import Quickshell.Io

// Spotlight: the application launcher and everything else Results can find.
Scope {
	id: root

	Results {
		id: finder

		query: pal.query
		onActivated: pal.open = false
	}

	Palette {
		id: pal

		placeholder: "Spotlight Search"
		namespace: "qs-spotlight"
		rows: finder.flat
	}

	// NOT show/hide: `qs ipc` has subcommands by those names and swallows them
	// before the handler is ever consulted, which looks exactly like a silently
	// ignored call.
	IpcHandler {
		target: "spotlight"

		function toggle(): void {
			if (pal.open) {
				pal.open = false;
			} else {
				pal.reset();
				pal.open = true;
			}
		}

		function open(): void {
			pal.reset();
			pal.open = true;
		}

		function close(): void {
			pal.open = false;
		}

		// Opens with the field prefilled, which is also how the mode prefixes are
		// reached from a keybind: `qs ipc call spotlight search "c "` is the
		// clipboard picker.
		function search(text: string): void {
			pal.reset();
			pal.query = text;
			pal.open = true;
		}
	}
}
