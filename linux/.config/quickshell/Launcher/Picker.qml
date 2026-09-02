import Quickshell
import Quickshell.Io
import "Search.js" as Search

// dmenu mode, for `~/.local/bin/menu`. Scripts pipe choices in and read the
// selection back, exactly as they did under fuzzel --dmenu -- the point of
// keeping that seam is that no caller has to know which launcher is underneath.
//
// The answer goes back over a FIFO the script created. An IPC call cannot block
// waiting for a human, so `menu` fires the call, then sits in `cat` on the FIFO
// until this writes to it. Escape and click-outside write an empty line, which
// is how the caller learns the pick was cancelled.
Scope {
	id: picker

	property string fifo: ""
	property var items: []
	property bool pending: false

	readonly property var rows: {
		if (picker.items.length === 0)
			return [];

		const hits = pal.query.length > 0 ? Search.rank(picker.items, pal.query) : picker.items;
		const out = [];
		for (let i = 0; i < Math.min(hits.length, 200); i++) {
			const hit = hits[i];
			out.push({
				title: hit.name,
				subtitle: "",
				icon: "",
				run: function () {
					picker.answer(hit.name);
				}
			});
		}
		return out;
	}

	function answer(text: string): void {
		if (!picker.pending)
			return;
		picker.pending = false;
		pal.open = false;

		// printf via sh rather than a FileView write: opening a FIFO for writing
		// blocks until a reader is there, and blocking the shell's own thread on
		// that would freeze every other component.
		Quickshell.execDetached(["sh", "-c", 'printf "%s\\n" "$1" > "$2"', "sh", text, picker.fifo]);
	}

	Palette {
		id: pal

		namespace: "qs-picker"
		rows: picker.rows
		onDismissed: picker.answer("")
	}

	FileView {
		id: source

		// Read synchronously: the list is already on disk before the IPC call is
		// made, and there is nothing to show until it is parsed.
		blockLoading: true
	}

	IpcHandler {
		target: "picker"

		// Cancels an open pick from outside, which is the only way a stuck
		// picker can be cleared without a mouse -- the caller is blocked in
		// `cat` on the FIFO until something answers it.
		function close(): void {
			picker.answer("");
		}

		function open(itemsPath: string, fifoPath: string, prompt: string): void {
			source.path = itemsPath;

			const lines = source.text().split("\n");
			const out = [];
			for (let i = 0; i < lines.length; i++)
				if (lines[i].length > 0)
					out.push({ name: lines[i] });

			picker.items = out;
			picker.fifo = fifoPath;
			picker.pending = true;

			pal.reset();
			pal.placeholder = prompt.length > 0 ? prompt : "Select";
			pal.open = true;
		}
	}
}
