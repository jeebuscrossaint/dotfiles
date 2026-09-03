pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// The readouts waybar had native modules for. One long-running shell loop emits
// the whole set every two seconds and a SplitParser cuts it on the sentinel --
// deliberately NOT a Timer firing a Process per metric, which is six forks every
// tick for numbers that all come from the same two files.
Singleton {
	id: sys

	property real cpu: 0
	property var cores: []
	property real memory: 0
	property real swap: 0
	property real memUsedGiB: 0
	property real memTotalGiB: 0
	property real disk: 0
	property string diskFree: ""
	property int temperature: 0
	property string fan: ""
	property string uptime: ""
	property real brightness: 0

	// Whether power-profiles-daemon's D-Bus name is actually SERVED, not merely
	// activatable. Both names are activatable on this machine and neither can be
	// launched -- tuned is running but the tuned-ppd shim that provides the
	// interface is not -- and `PowerProfiles.profile` still reads Balanced
	// regardless, so the control looks live while doing nothing. Probed once,
	// because a segmented switch that silently ignores you is worse than one
	// that is not there.
	property bool powerProfiles: false

	// The NVMe drive has its own hwmon, nowhere near coretemp's, and waybar
	// carried it as a second temperature module with a 70 degree critical -- it
	// runs much closer to its limit than the CPU does.
	property int nvmeTemp: 0
	property real freqAvg: 0
	property real freqMax: 0
	property string load: ""
	property string diskUsed: ""
	property real swapUsedGiB: 0
	property real swapTotalGiB: 0
	property real netDown: 0
	property real netUp: 0

	property real prevRx: -1
	property real prevTx: -1

	// wttrbar's own output, verbatim -- same binary and same flags waybar ran.
	property string weather: ""
	property string weatherTip: ""

	// /proc/stat is cumulative since boot, so a percentage needs the delta
	// between two samples. Anything else reports the average since power-on,
	// which is a number that barely moves.
	property var prevIdle: ({})
	property var prevTotal: ({})

	function sample(key: string, idle: real, total: real): real {
		const di = idle - (sys.prevIdle[key] || 0);
		const dt = total - (sys.prevTotal[key] || 0);
		sys.prevIdle[key] = idle;
		sys.prevTotal[key] = total;
		if (dt <= 0)
			return 0;
		return Math.max(0, Math.min(100, 100 * (1 - di / dt)));
	}

	// Human byte rate, matching waybar's bandwidthDownBytes formatting closely
	// enough that the bar does not suddenly read differently.
	function rate(bytes: real): string {
		if (bytes < 1024)
			return Math.round(bytes) + " B/s";
		if (bytes < 1048576)
			return Math.round(bytes / 1024) + " K/s";
		return (bytes / 1048576).toFixed(1) + " M/s";
	}

	function parse(blob: string): void {
		const lines = blob.split("\n");
		let section = "";
		const cores = [];
		let memTotal = 0, memAvail = 0, swapTotal = 0, swapFree = 0;
		const bl = [];
		const freqs = [];
		let rx = 0, tx = 0;

		for (let i = 0; i < lines.length; i++) {
			const line = lines[i];
			if (line.startsWith("@")) {
				section = line.substring(1);
				continue;
			}
			if (line.length === 0)
				continue;

			if (section === "cpu" && line.startsWith("cpu")) {
				const f = line.split(/\s+/);
				const key = f[0];
				// user nice system idle iowait irq softirq steal
				let total = 0;
				for (let k = 1; k < f.length; k++)
					total += parseInt(f[k]) || 0;
				const idle = (parseInt(f[4]) || 0) + (parseInt(f[5]) || 0);
				const pct = sys.sample(key, idle, total);
				if (key === "cpu")
					sys.cpu = pct;
				else
					cores.push(pct);
			} else if (section === "mem") {
				const f = line.split(/\s+/);
				const v = parseInt(f[1]) || 0;
				if (line.startsWith("MemTotal")) memTotal = v;
				else if (line.startsWith("MemAvailable")) memAvail = v;
				else if (line.startsWith("SwapTotal")) swapTotal = v;
				else if (line.startsWith("SwapFree")) swapFree = v;
			} else if (section === "disk") {
				const f = line.split(/\s+/);
				if (f.length >= 5) {
					sys.disk = parseInt(f[4]) || 0;
					sys.diskFree = (parseInt(f[3]) / 1073741824).toFixed(0) + " GiB free";
					sys.diskUsed = (parseInt(f[2]) / 1073741824).toFixed(0) + " / "
						+ ((parseInt(f[2]) + parseInt(f[3])) / 1073741824).toFixed(0) + " GiB";
				}
			} else if (section === "temp") {
				sys.temperature = Math.round((parseInt(line) || 0) / 1000);
			} else if (section === "fan") {
				sys.fan = line;
			} else if (section === "up") {
				sys.uptime = line;
			} else if (section === "bl") {
				bl.push(parseInt(line) || 0);
			} else if (section === "nvmedev") {
				// hwmon numbering is not stable across boots, so the sensor is
				// found by NAME rather than by the hwmonN path waybar hardcoded.
				const bits = line.split(":");
				if (bits[0] === "nvme" && bits[1])
					sys.nvmeTemp = Math.round((parseInt(bits[1]) || 0) / 1000);
			} else if (section === "freq") {
				const mhz = parseFloat(line.split(":")[1]);
				if (!isNaN(mhz))
					freqs.push(mhz);
			} else if (section === "load") {
				sys.load = line.trim();
			} else if (section === "net") {
				// rx bytes is field 2, tx bytes field 10, counting the "iface:"
				// label as field 1.
				const f = line.trim().split(/[\s:]+/);
				rx += parseInt(f[1]) || 0;
				tx += parseInt(f[9]) || 0;
			}
		}

		if (cores.length > 0)
			sys.cores = cores;
		if (memTotal > 0) {
			sys.memory = 100 * (memTotal - memAvail) / memTotal;
			sys.memTotalGiB = memTotal / 1048576;
			sys.memUsedGiB = (memTotal - memAvail) / 1048576;
		}
		if (swapTotal > 0)
			sys.swap = 100 * (swapTotal - swapFree) / swapTotal;
		// current then max, in that order, because the glob expands
		// brightness before max_brightness alphabetically.
		if (bl.length >= 2 && bl[1] > 0)
			sys.brightness = bl[0] / bl[1];

		if (freqs.length > 0) {
			let total = 0, max = 0;
			for (let i = 0; i < freqs.length; i++) {
				total += freqs[i];
				max = Math.max(max, freqs[i]);
			}
			sys.freqAvg = total / freqs.length / 1000;
			sys.freqMax = max / 1000;
		}

		// Byte counters are cumulative, so the rate is a delta over the two
		// second tick. The first sample has nothing to subtract from.
		if (rx > 0) {
			if (sys.prevRx >= 0) {
				sys.netDown = Math.max(0, (rx - sys.prevRx) / 2);
				sys.netUp = Math.max(0, (tx - sys.prevTx) / 2);
			}
			sys.prevRx = rx;
			sys.prevTx = tx;
		}

		if (swapTotal > 0) {
			sys.swapUsedGiB = (swapTotal - swapFree) / 1048576;
			sys.swapTotalGiB = swapTotal / 1048576;
		}
	}

	Process {
		running: true
		command: ["sh", "-c", `while :; do
			echo "@cpu"; grep '^cpu' /proc/stat
			echo "@mem"; grep -E '^(MemTotal|MemAvailable|SwapTotal|SwapFree):' /proc/meminfo
			echo "@disk"; df -P -B1 / | tail -1
			echo "@temp"; cat /sys/devices/platform/coretemp.0/hwmon/hwmon*/temp1_input 2>/dev/null | head -1
			echo "@fan"; waybar-fan 2>/dev/null
			echo "@up"; waybar-uptime 2>/dev/null
			echo "@bl"; cat /sys/class/backlight/*/brightness /sys/class/backlight/*/max_brightness 2>/dev/null
			echo "@nvme"; cat /sys/class/hwmon/hwmon*/temp1_input 2>/dev/null | head -20
			echo "@nvmedev"; for h in /sys/class/hwmon/hwmon*; do echo "$(cat $h/name 2>/dev/null):$(cat $h/temp1_input 2>/dev/null)"; done
			echo "@freq"; grep '^cpu MHz' /proc/cpuinfo
			echo "@load"; cut -d" " -f1-3 /proc/loadavg
			echo "@net"; grep -E '^ *(wlan0|eth0|enp[0-9a-z]*):' /proc/net/dev
			echo "@end"
			sleep 2
		done`]

		stdout: SplitParser {
			splitMarker: "@end\n"
			onRead: blob => sys.parse(blob)
		}
	}

	// Same command and same flags waybar used, including the connectivity guard:
	// wttrbar hangs rather than failing when the network is down.
	Process {
		id: ppdProbe

		running: true
		command: ["busctl", "--system", "--timeout=3", "introspect", "net.hadess.PowerProfiles", "/net/hadess/PowerProfiles"]
		onExited: code => sys.powerProfiles = code === 0
	}

	Process {
		id: wttr

		command: ["sh", "-c", "curl -sf --max-time 10 -o /dev/null 'https://wttr.in/Orlando?format=j1' && exec wttrbar --location Orlando --fahrenheit --mph --ampm --nerd --hide-conditions --custom-indicator '{ICON} {temp_F}°'"]
		stdout: StdioCollector {
			id: wttrOut
		}
		onExited: code => {
			if (code !== 0)
				return;
			try {
				const j = JSON.parse(wttrOut.text);
				sys.weather = j.text || "";
				sys.weatherTip = j.tooltip || "";
			} catch (e) {
			}
		}
	}

	Timer {
		running: true
		repeat: true
		triggeredOnStart: true
		interval: 900000
		onTriggered: {
			wttr.running = false;
			wttr.running = true;
		}
	}
}
