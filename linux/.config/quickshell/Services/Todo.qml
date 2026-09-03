pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// The todo list, backed by ~/todo.md in GitHub-flavoured checkbox syntax.
//
// A plain markdown file rather than a JSON store the shell owns, because the
// same list has to be editable in nvim -- a todo you can only tick from a
// desktop widget is a todo you stop using. `watchChanges` means an edit in the
// editor shows up on the desktop without a reload, and vice versa.
Singleton {
	id: todo

	// { text, done, line } -- `line` is the index in the file, so a toggle can
	// rewrite exactly one line and leave headings, blanks and any prose in the
	// file untouched.
	property var items: []

	readonly property int remaining: {
		let n = 0;
		for (let i = 0; i < todo.items.length; i++)
			if (!todo.items[i].done)
				n += 1;
		return n;
	}

	function parse(): void {
		const out = [];
		const lines = file.text().split("\n");
		for (let i = 0; i < lines.length; i++) {
			// Leading whitespace allowed so nested items are still picked up.
			const m = lines[i].match(/^\s*- \[( |x|X)\] (.*)$/);
			if (m)
				out.push({ text: m[2], done: m[1] !== " ", line: i });
		}
		todo.items = out;
	}

	function toggle(index: int): void {
		const item = todo.items[index];
		if (!item)
			return;

		const lines = file.text().split("\n");
		const line = lines[item.line];
		if (line === undefined)
			return;

		lines[item.line] = item.done
			? line.replace(/- \[[xX]\]/, "- [ ]")
			: line.replace(/- \[ \]/, "- [x]");

		// Writing the file is what updates `items`: the FileView is watching it,
		// so the reload reparses and the widget follows. No second source of
		// truth to keep in step.
		file.setText(lines.join("\n"));
	}

	FileView {
		id: file

		path: `${Quickshell.env("HOME")}/todo.md`
		watchChanges: true
		blockLoading: true
		printErrors: false

		onLoaded: todo.parse()
		onFileChanged: todo.parse()
	}
}
