import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import qs.Config
import qs.Widgets
import qs.Services

// Wi-Fi, all of it: join, rejoin, disconnect, forget, radio toggle, and
// credential entry for both PSK and WPA2-Enterprise. Nothing hands off to
// nmtui.
//
// Enterprise is the case that matters here -- UCF_WPA2 and eduroam are both
// 802.1X -- and it needs an identity as well as a secret, which is why the
// prompt has two fields rather than one.
Popover {
	id: net

	panelWidth: 310
	// Only while a prompt is up. A menu that took the keyboard just for being
	// open would swallow whatever you were mid-sentence in.
	keyboard: net.prompt !== null

	property var prompt: null
	// 0 = identity, 1 = password. PSK networks skip straight to 1.
	property int focusField: 1
	property string identity: ""
	property string password: ""

	function begin(network: var): void {
		if (network.active) {
			Wifi.leave(network);
			net.close();
			return;
		}

		if (network.saved || network.open) {
			Wifi.join(network, "", "");
			net.close();
			return;
		}

		net.identity = "";
		net.password = "";
		net.focusField = network.enterprise ? 0 : 1;
		net.prompt = network;
	}

	function submit(): void {
		if (!net.prompt)
			return;
		// Identity is required for 802.1X; joining without one just fails
		// slowly, so the prompt keeps focus instead.
		if (net.prompt.enterprise && net.identity.length === 0) {
			net.focusField = 0;
			return;
		}
		Wifi.join(net.prompt, net.identity, net.password);
		net.identity = "";
		net.password = "";
		net.prompt = null;
		net.close();
	}

	// Rescan while open, and only while open. Left running, the radio rescans
	// forever for a list nobody is reading.
	Timer {
		running: net.open && net.prompt === null
		repeat: true
		triggeredOnStart: true
		interval: 8000
		onTriggered: Wifi.refresh()
	}

	onOpenChanged: {
		if (!net.open) {
			net.prompt = null;
			net.identity = "";
			net.password = "";
		}
	}

	IpcHandler {
		target: "wifi"

		function toggle(): void { net.open = !net.open; }
		function open(): void { net.open = true; }
		function close(): void { net.open = false; }
	}

	Column {
		id: col

		anchors.left: parent.left
		anchors.right: parent.right
		spacing: 2

		Item {
			width: col.width
			height: 20

			StyledText {
				anchors.left: parent.left
				text: "Wi-Fi"
				font.weight: Font.DemiBold
			}

			StyledText {
				anchors.right: parent.right
				text: Networking.wifiEnabled ? "On" : "Off"
				color: Networking.wifiEnabled ? Theme.accent : Theme.dim
				font.pointSize: Theme.fontSize - 1

				TapHandler {
					onTapped: Wifi.radio(!Networking.wifiEnabled)
				}
			}
		}

		Item {
			width: 1
			height: 4
		}

		// ── Credential prompt ───────────────────────────────────────────────
		Column {
			width: col.width
			spacing: 5
			visible: net.prompt !== null

			StyledText {
				width: parent.width
				text: net.prompt ? net.prompt.ssid : ""
				font.weight: Font.DemiBold
				elide: Text.ElideRight
			}

			StyledText {
				width: parent.width
				visible: net.prompt !== null && net.prompt.enterprise
				text: "802.1X — PEAP / MSCHAPv2"
				color: Theme.dim
				font.pointSize: Theme.fontSize - 2
			}

			// Identity, enterprise only. Shown as plain text: a username is not
			// a secret and hiding it only makes typos invisible.
			Rectangle {
				width: parent.width
				height: 28
				radius: 7
				visible: net.prompt !== null && net.prompt.enterprise
				color: Theme.withFg(0.10)
				border.width: 1
				border.color: net.focusField === 0 ? Theme.accent : Theme.hairline

				StyledText {
					anchors.left: parent.left
					anchors.leftMargin: 9
					anchors.right: parent.right
					anchors.rightMargin: 9
					anchors.verticalCenter: parent.verticalCenter
					text: net.identity.length > 0 ? net.identity : "Identity"
					color: net.identity.length > 0 ? Theme.fg : Theme.dim
					font.pointSize: Theme.fontSize - 1
				}

				TapHandler {
					onTapped: net.focusField = 0
				}
			}

			Rectangle {
				width: parent.width
				height: 28
				radius: 7
				color: Theme.withFg(0.10)
				border.width: 1
				border.color: net.focusField === 1 ? Theme.accent : Theme.hairline

				Row {
					anchors.left: parent.left
					anchors.leftMargin: 9
					anchors.verticalCenter: parent.verticalCenter
					spacing: 5
					visible: net.password.length > 0

					Repeater {
						model: Math.min(net.password.length, 24)

						Rectangle {
							width: 6
							height: 6
							radius: 3
							anchors.verticalCenter: parent.verticalCenter
							color: Theme.fg
						}
					}
				}

				StyledText {
					anchors.left: parent.left
					anchors.leftMargin: 9
					anchors.verticalCenter: parent.verticalCenter
					visible: net.password.length === 0
					text: "Password"
					color: Theme.dim
					font.pointSize: Theme.fontSize - 1
				}

				TapHandler {
					onTapped: net.focusField = 1
				}
			}

			StyledText {
				width: parent.width
				text: net.prompt && net.prompt.enterprise ? "Tab switches field · Return joins" : "Return joins · Escape cancels"
				color: Theme.dim
				font.pointSize: Theme.fontSize - 2
			}
		}

		// ── Network list ────────────────────────────────────────────────────
		Repeater {
			model: net.prompt === null ? Wifi.networks : []

			Item {
				id: row

				required property var modelData

				width: col.width
				implicitHeight: 28

				Rectangle {
					anchors.fill: parent
					anchors.leftMargin: -6
					anchors.rightMargin: -6
					radius: 5
					color: hover.hovered ? Theme.accent : "transparent"
				}

				StyledText {
					id: mark

					anchors.left: parent.left
					anchors.verticalCenter: parent.verticalCenter
					width: 20
					text: row.modelData.active ? "󰄬" : (row.modelData.open ? "󰤨" : "󰤪")
					font.family: Theme.fontMono
					color: hover.hovered ? Theme.bg : Theme.dim
				}

				StyledText {
					anchors.left: mark.right
					anchors.leftMargin: 4
					anchors.right: strength.left
					anchors.rightMargin: 6
					anchors.verticalCenter: parent.verticalCenter
					text: row.modelData.ssid + (row.modelData.enterprise ? "  ·  802.1X" : "")
					elide: Text.ElideRight
					color: hover.hovered ? Theme.bg : Theme.fg
				}

				StyledText {
					id: strength

					anchors.right: forget.left
					anchors.rightMargin: 6
					anchors.verticalCenter: parent.verticalCenter
					text: row.modelData.signal + "%"
					color: hover.hovered ? Theme.bg : Theme.dim
					font.pointSize: Theme.fontSize - 2
				}

				// Forget, on saved networks only, and only on hover -- a
				// permanent row of delete buttons invites the accident.
				StyledText {
					id: forget

					anchors.right: parent.right
					anchors.verticalCenter: parent.verticalCenter
					width: row.modelData.saved ? 14 : 0
					visible: row.modelData.saved && hover.hovered
					text: "✕"
					color: Theme.bg
					font.pointSize: Theme.fontSize - 2

					TapHandler {
						onTapped: Wifi.forget(row.modelData)
					}
				}

				HoverHandler {
					id: hover
				}

				TapHandler {
					onTapped: net.begin(row.modelData)
				}
			}
		}

		StyledText {
			width: col.width
			visible: Wifi.networks.length === 0 && net.prompt === null
			text: Networking.wifiEnabled ? "Scanning…" : "Wi-Fi is off"
			color: Theme.dim
			font.pointSize: Theme.fontSize - 1
		}

		StyledText {
			width: col.width
			visible: Wifi.error.length > 0
			text: Wifi.error
			wrapMode: Text.Wrap
			color: Theme.error
			font.pointSize: Theme.fontSize - 2
		}
	}

	// Keys are taken on the panel, not in a TextInput: the password never lives
	// in a focusable, selectable, copyable field.
	Item {
		anchors.fill: parent
		focus: net.prompt !== null

		Keys.onPressed: event => {
			if (!net.prompt)
				return;

			if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
				net.submit();
			} else if (event.key === Qt.Key_Escape) {
				net.prompt = null;
			} else if (event.key === Qt.Key_Tab) {
				if (net.prompt.enterprise)
					net.focusField = net.focusField === 0 ? 1 : 0;
			} else if (event.key === Qt.Key_Backspace) {
				const clear = event.modifiers & Qt.ControlModifier;
				if (net.focusField === 0)
					net.identity = clear ? "" : net.identity.slice(0, -1);
				else
					net.password = clear ? "" : net.password.slice(0, -1);
			} else if (event.text.length > 0 && !/[\x00-\x1F\x7F]/.test(event.text)) {
				if (net.focusField === 0)
					net.identity += event.text;
				else
					net.password += event.text;
			}

			event.accepted = true;
		}
	}
}
