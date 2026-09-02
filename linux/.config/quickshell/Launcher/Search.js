.pragma library

// Subsequence scoring, the same shape fuzzel/fzf use: every character of the
// query must appear in order, and the score is driven by WHERE the matches land
// rather than how many there are. Without the position bonuses "gimp" ranks
// "Kdenlive Video Editor" above GIMP purely because the letters are in there
// somewhere.
function score(query, text) {
	if (!query) return 0;
	if (!text) return -1;

	const q = query.toLowerCase();
	const s = text.toLowerCase();

	let at = 0;
	let total = 0;
	let run = 0;

	for (let i = 0; i < q.length; i++) {
		const found = s.indexOf(q[i], at);
		if (found < 0) return -1;

		if (found === 0) {
			total += 12;                     // start of the string
		} else if (/[^a-z0-9]/.test(s[found - 1])) {
			total += 8;                      // start of a word
		} else if (found === at) {
			run += 1;                        // adjacent to the previous match
			total += 4 + Math.min(run, 6);
		} else {
			run = 0;
		}

		total += 1;
		total -= Math.min(found - at, 6) * 0.5;
		at = found + 1;
	}

	if (s === q) total += 30;
	else if (s.indexOf(q) === 0) total += 20;

	// Shorter names win ties: typing "term" should land on "Terminal" and not on
	// "Terminal Emulator Settings".
	return total - s.length * 0.05;
}

// Fields are weighted rather than concatenated so that a keyword hit can never
// outrank a name hit.
const FIELDS = [
	["name", 1.0],
	["genericName", 0.6],
	["command", 0.5],
	["keywords", 0.4],
	["comment", 0.3],
];

function best(query, entry) {
	let top = -1;
	for (let i = 0; i < FIELDS.length; i++) {
		const key = FIELDS[i][0];
		let value = entry[key];
		if (value === undefined || value === null) continue;
		// command is a string list and keywords can be one too.
		if (Array.isArray(value)) value = value.join(" ");
		const s = score(query, String(value));
		if (s >= 0) top = Math.max(top, s * FIELDS[i][1]);
	}
	return top;
}

function rank(entries, query) {
	if (!query) return [];

	const scored = [];
	for (let i = 0; i < entries.length; i++) {
		const entry = entries[i];
		if (entry.noDisplay) continue;
		const s = best(query, entry);
		if (s >= 0) scored.push({ entry: entry, score: s });
	}

	scored.sort(function (a, b) {
		if (b.score !== a.score) return b.score - a.score;
		return a.entry.name.localeCompare(b.entry.name);
	});

	return scored.map(function (x) { return x.entry; });
}
