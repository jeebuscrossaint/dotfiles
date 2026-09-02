import QtQuick
import Quickshell
import Quickshell.Io
import qs.Config
import "Search.js" as Search

// Everything the launcher can find, assembled into sections.
//
// Apps are synchronous -- DesktopEntries is already in memory. Everything else
// shells out, so those providers are debounced and land asynchronously; the
// section list rebuilds whenever any of them reports back.
Item {
	id: results

	property string query: ""

	readonly property string trimmed: query.trim()

	// Mode prefixes, in the spirit of Tahoe's Spotlight filters. Without one the
	// launcher searches apps, answers anything that looks like a sum, and offers
	// the web as a last resort.
	readonly property bool runMode: trimmed.startsWith(">")
	readonly property bool fileMode: trimmed.startsWith("f ")
	readonly property bool clipMode: trimmed.startsWith("c ") || trimmed === "c"
	readonly property bool calcMode: trimmed.startsWith("=")

	readonly property string term: {
		if (results.runMode || results.calcMode)
			return results.trimmed.substring(1).trim();
		if (results.fileMode || results.clipMode)
			return results.trimmed.substring(1).trim();
		return results.trimmed;
	}

	// An expression is worth handing to qalc if it has a digit and either an
	// operator or a unit conversion in it. Without the guard every app search
	// spawns a qalc, and "firefox" comes back as an error row.
	readonly property bool looksLikeMath: {
		if (results.calcMode)
			return results.term.length > 0;
		const t = results.trimmed;
		if (!/\d/.test(t))
			return false;
		return /[+\-*/^%()]/.test(t) || / (to|in) /.test(t);
	}

	property string calcAnswer: ""
	property var fileRows: []
	property var clipRows: []

	signal activated

	// ── Applications ────────────────────────────────────────────────────────
	//
	// Desktop ACTIONS are folded in beside their app rather than hidden behind
	// it: "New Private Window" is a thing you search for by name, and this is
	// the Linux shape of what Tahoe calls App Actions.
	readonly property var appItems: {
		const out = [];
		const apps = DesktopEntries.applications.values;
		for (let i = 0; i < apps.length; i++) {
			const app = apps[i];
			if (app.noDisplay)
				continue;

			out.push({
				name: app.name,
				genericName: app.genericName,
				comment: app.comment,
				keywords: app.keywords,
				command: app.command,
				entry: app,
				action: null
			});

			const actions = app.actions;
			for (let k = 0; k < actions.length; k++) {
				out.push({
					name: app.name + " — " + actions[k].name,
					genericName: actions[k].name,
					comment: "",
					keywords: "",
					command: actions[k].command,
					entry: app,
					action: actions[k]
				});
			}
		}
		return out;
	}

	readonly property var appRows: {
		if (results.runMode || results.fileMode || results.clipMode || results.calcMode)
			return [];

		const hits = Search.rank(results.appItems, results.term);
		const out = [];
		for (let i = 0; i < Math.min(hits.length, 8); i++) {
			const hit = hits[i];
			out.push({
				title: hit.name,
				subtitle: hit.action ? hit.entry.name : (hit.comment || hit.genericName || ""),
				icon: hit.entry.icon,
				glyph: "",
				run: function () {
					results.launch(hit.action ? hit.action.command : hit.entry.command, hit.entry);
				}
			});
		}
		return out;
	}

	// ── Sections ────────────────────────────────────────────────────────────
	readonly property var sections: {
		const out = [];

		if (results.runMode && results.term.length > 0) {
			out.push({
				title: "Run Command",
				rows: [
					{
						title: results.term,
						subtitle: "Run in a shell",
						icon: "",
						glyph: "",
						run: function () {
							results.exec(["sh", "-c", results.term]);
						}
					}
				]
			});
		}

		if (results.calcAnswer.length > 0) {
			out.push({
				title: "Calculator",
				rows: [
					{
						title: results.calcAnswer,
						subtitle: "Return to copy",
						icon: "",
						glyph: "",
						run: function () {
							results.exec(["wl-copy", "--", results.calcAnswer]);
						}
					}
				]
			});
		}

		if (results.appRows.length > 0)
			out.push({ title: "Applications", rows: results.appRows });

		if (results.fileRows.length > 0)
			out.push({ title: "Files", rows: results.fileRows });

		if (results.clipRows.length > 0)
			out.push({ title: "Clipboard", rows: results.clipRows });

		// Always last and always present, exactly like Spotlight's own web row:
		// if nothing above matched, there is still something to press Return on.
		if (!results.runMode && !results.clipMode && results.term.length > 0) {
			out.push({
				title: "Web Search",
				rows: [
					{
						title: "Search the web for “" + results.term + "”",
						subtitle: "duckduckgo.com",
						icon: "",
						glyph: "",
						run: function () {
							results.exec(["xdg-open", "https://duckduckgo.com/?q=" + encodeURIComponent(results.term)]);
						}
					}
				]
			});
		}

		return out;
	}

	// Flattened for the ListView: section headers ride in the same model as the
	// rows so one ListView can draw both, which is how the group headings stay
	// pinned to their group while the whole thing scrolls as one list.
	readonly property var flat: {
		const out = [];
		for (let i = 0; i < results.sections.length; i++) {
			out.push({ header: results.sections[i].title });
			const rows = results.sections[i].rows;
			for (let k = 0; k < rows.length; k++)
				out.push(rows[k]);
		}
		return out;
	}

	function launch(argv: var, entry: var): void {
		// workingDirectory is ALWAYS set, never left to inherit. A child of the
		// shell inherits the shell's cwd -- whatever directory `qs` happened to
		// be started in -- so zathura opened from the launcher came up browsing
		// ~/dotfiles. $HOME is what a launcher is supposed to hand over when the
		// entry has no Path= of its own.
		const cmd = entry && entry.runInTerminal ? ["kitty", "-e"].concat(argv) : argv;
		Quickshell.execDetached({
			command: cmd,
			workingDirectory: (entry && entry.workingDirectory) || Quickshell.env("HOME")
		});
		results.activated();
	}

	function exec(argv: var): void {
		Quickshell.execDetached({
			command: argv,
			workingDirectory: Quickshell.env("HOME")
		});
		results.activated();
	}

	// ── Async providers ─────────────────────────────────────────────────────
	//
	// One debounce for all three. Every keystroke would otherwise fork a qalc
	// and a find.
	Timer {
		id: debounce

		interval: 130
		onTriggered: {
			calc.reload();
			files.reload();
			clip.reload();
		}
	}

	onTermChanged: {
		results.calcAnswer = "";
		results.fileRows = [];
		results.clipRows = [];
		debounce.restart();
	}

	Process {
		id: calc

		// -t is terse: the answer alone, without echoing the expression back.
		command: ["qalc", "-t", "--", results.term]
		stdout: StdioCollector {
			id: calcOut
		}
		onExited: code => {
			const text = calcOut.text.trim();
			// qalc answers *something* for almost any input, including error
			// prose. Anything without a digit in it is not an answer.
			if (code === 0 && text.length > 0 && /\d/.test(text))
				results.calcAnswer = text;
		}

		function reload(): void {
			calc.running = false;
			if (results.looksLikeMath)
				calc.running = true;
		}
	}

	Process {
		id: files

		// fd when it is installed, find otherwise. find is given a depth cap and
		// a timeout because an unbounded walk of $HOME is not something to do on
		// a keystroke.
		command: ["sh", "-c", "if command -v fd >/dev/null 2>&1; then exec timeout 2 fd --type f --max-results 8 --exclude .git -- \"$1\" \"$HOME\"; else exec timeout 2 find \"$HOME\" -maxdepth 5 -iname \"*$1*\" -not -path '*/.*' -type f -print 2>/dev/null | head -8; fi", "sh", results.term]
		stdout: StdioCollector {
			id: filesOut
		}
		onExited: {
			const lines = filesOut.text.split("\n").filter(l => l.length > 0);
			const out = [];
			for (let i = 0; i < lines.length; i++) {
				const path = lines[i];
				out.push({
					title: path.split("/").pop(),
					subtitle: path.replace(Quickshell.env("HOME"), "~"),
					icon: "",
					glyph: "",
					run: function () {
						results.exec(["xdg-open", path]);
					}
				});
			}
			results.fileRows = out;
		}

		function reload(): void {
			files.running = false;
			// Only on request. A file walk on every app search is both slow and
			// noisy -- macOS has an index for this and we do not.
			if (results.fileMode && results.term.length > 1)
				files.running = true;
		}
	}

	Process {
		id: clip

		command: ["cliphist", "list"]
		stdout: StdioCollector {
			id: clipOut
		}
		onExited: {
			const lines = clipOut.text.split("\n").filter(l => l.length > 0);
			const items = [];
			for (let i = 0; i < lines.length; i++) {
				// cliphist emits "<id>\t<preview>".
				const tab = lines[i].indexOf("\t");
				if (tab < 0)
					continue;
				items.push({ id: lines[i].substring(0, tab), name: lines[i].substring(tab + 1) });
			}

			const hits = results.term.length > 0 ? Search.rank(items, results.term) : items.slice(0, 12);
			const out = [];
			for (let i = 0; i < Math.min(hits.length, 12); i++) {
				const hit = hits[i];
				out.push({
					title: hit.name,
					subtitle: "Copy to clipboard",
					icon: "",
					glyph: "",
					run: function () {
						results.exec(["sh", "-c", "cliphist decode " + hit.id + " | wl-copy"]);
					}
				});
			}
			results.clipRows = out;
		}

		function reload(): void {
			clip.running = false;
			if (results.clipMode)
				clip.running = true;
		}
	}
}
