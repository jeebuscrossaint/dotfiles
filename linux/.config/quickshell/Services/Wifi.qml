pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Wi-Fi actions, driven through nmcli.
//
// Quickshell's Networking service can join a PSK network and reuse a saved
// profile, and that is all -- there is no API to CREATE a connection, so
// WPA2-Enterprise is out of reach through it. That matters here more than
// anywhere: UCF_WPA2 and eduroam are both WPA2 802.1X with PEAP/MSCHAPv2, so
// the enterprise path is the primary one on this machine, not an edge case.
//
// nmcli can do all of it, which is also how the larger Quickshell rices solve
// this. The service stays deliberately small: list, join, leave, forget, radio.
//
// Passwords are passed as nmcli arguments and are therefore briefly visible in
// the process list. The alternatives are a root-owned keyfile or an interactive
// tty, both worse to manage; on a single-user laptop this is the right trade,
// but it is a trade.
Singleton {
	id: wifi

	// { ssid, security, signal, active, saved, enterprise }
	property var networks: []
	property bool busy: false
	property string error: ""

	signal changed

	// nmcli -t escapes colons inside fields as "\:", so a plain split on ":"
	// tears SSIDs containing one in half.
	function splitTerse(line: string): var {
		const out = [];
		let field = "";
		for (let i = 0; i < line.length; i++) {
			if (line[i] === "\\" && i + 1 < line.length) {
				field += line[i + 1];
				i += 1;
			} else if (line[i] === ":") {
				out.push(field);
				field = "";
			} else {
				field += line[i];
			}
		}
		out.push(field);
		return out;
	}

	function refresh(): void {
		listProc.running = false;
		listProc.running = true;
	}

	function run(args: var): void {
		wifi.busy = true;
		wifi.error = "";
		actionProc.command = ["nmcli"].concat(args);
		actionProc.running = false;
		actionProc.running = true;
	}

	function join(net: var, identity: string, password: string): void {
		// A saved profile already holds the credentials -- bringing it up is
		// both faster and avoids asking for a password the machine has.
		if (net.saved) {
			wifi.run(["connection", "up", "id", net.ssid]);
			return;
		}

		if (net.enterprise) {
			// `device wifi connect` cannot express EAP, so the profile is built
			// explicitly. peap/mschapv2 matches what already works here.
			wifi.run(["connection", "add", "type", "wifi", "con-name", net.ssid, "ifname", "*", "ssid", net.ssid,
				"--", "wifi-sec.key-mgmt", "wpa-eap", "802-1x.eap", "peap", "802-1x.phase2-auth", "mschapv2",
				"802-1x.identity", identity, "802-1x.password", password]);
			return;
		}

		if (password.length > 0)
			wifi.run(["device", "wifi", "connect", net.ssid, "password", password]);
		else
			wifi.run(["device", "wifi", "connect", net.ssid]);
	}

	function leave(net: var): void {
		wifi.run(["connection", "down", "id", net.ssid]);
	}

	function forget(net: var): void {
		wifi.run(["connection", "delete", "id", net.ssid]);
	}

	function radio(on: bool): void {
		wifi.run(["radio", "wifi", on ? "on" : "off"]);
	}

	// Saved profiles first, so the list can tell "join" from "rejoin".
	Process {
		id: savedProc

		running: true
		command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]
		stdout: StdioCollector {
			id: savedOut
		}
		onExited: {
			const names = [];
			const lines = savedOut.text.split("\n");
			for (let i = 0; i < lines.length; i++) {
				const f = wifi.splitTerse(lines[i]);
				if (f.length >= 2 && f[1] === "802-11-wireless")
					names.push(f[0]);
			}
			wifi.savedNames = names;
			wifi.refresh();
		}
	}

	property var savedNames: []

	Process {
		id: listProc

		command: ["nmcli", "-t", "-f", "IN-USE,SSID,SECURITY,SIGNAL", "device", "wifi", "list"]
		stdout: StdioCollector {
			id: listOut
		}
		onExited: {
			const seen = ({});
			const out = [];
			const lines = listOut.text.split("\n");

			for (let i = 0; i < lines.length; i++) {
				const f = wifi.splitTerse(lines[i]);
				if (f.length < 4)
					continue;
				const ssid = f[1];
				// Hidden networks come back with an empty SSID and cannot be
				// joined by name anyway.
				if (ssid.length === 0)
					continue;
				// One row per SSID: a campus network is a dozen APs, and the
				// strongest is the only one worth offering.
				if (seen[ssid])
					continue;
				seen[ssid] = true;

				out.push({
					ssid: ssid,
					security: f[2],
					signal: parseInt(f[3]) || 0,
					active: f[0] === "*",
					saved: wifi.savedNames.indexOf(ssid) !== -1,
					// 802.1X needs an identity as well as a secret.
					enterprise: f[2].indexOf("802.1X") !== -1,
					open: f[2].length === 0 || f[2] === "--"
				});
			}

			out.sort((a, b) => (b.active ? 1 : 0) - (a.active ? 1 : 0) || b.signal - a.signal);
			wifi.networks = out;
		}
	}

	Process {
		id: actionProc

		stderr: StdioCollector {
			id: actionErr
		}
		onExited: code => {
			wifi.busy = false;
			if (code !== 0)
				wifi.error = actionErr.text.trim().split("\n")[0] || "nmcli failed";
			// Re-read saved profiles too: a join creates one and a forget
			// removes one.
			savedProc.running = false;
			savedProc.running = true;
			wifi.changed();
		}
	}
}
