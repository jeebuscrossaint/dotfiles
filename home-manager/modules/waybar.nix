{
  programs.waybar = {
    enable = false;
    settings = {
      mainBar = {
        position = "bottom";
        height = 5;
        modules-left = ["hyprland/workspaces" "sway/workspaces"];
        modules-center = ["hyprland/window" "sway/window"];
        modules-right = ["cpu" "custom/separator" "temperature" "custom/separator" "memory" "custom/separator" "load" "custom/separator" "user" "custom/separator" "battery" "custom/separator" "wireplumber" "custom/separator" "clock" "custom/separator" "network" "custom/separator" "privacy" "tray"];

        "hyprland/workspaces" = {};
        "sway/workspaces" = {};
        "hyprland/window" = {};
        "sway/window" = {};
        "custom/separator" = {
          format = "";
          tooltip = false;
        };
        cpu = {
          interval = 1;
          format = "CPU: {usage}%";
        };
        temperature = {
          interval = 10;
          format = "Temp: {temperatureF}°F";
        };
        memory = {
          interval = 1;
          format = "Mem: {percentage}% Swap: {swapPercentage}%";
        };
        load = {
          interval = 5;
          format = "Load: {load1} / {load5} / {load15}";
        };
        user = {
          interval = 60;
          format = "Uptime: {work_H} hours, {work_M} minutes";
          icon = false;
        };
        battery = {
          interval = 60;
          format = "Bat: {capacity}%";
          format-charging = "Bat: {capacity}%, Charging, Health: {health}%";
          format-discharging = "Bat: {capacity}%, Discharging, Health: {health}%";
          format-full = "Bat: {capacity}%, Full, Health: {health}%";
          format-plugged = "Bat: {capacity}%, Plugged, Health: {health}%";
        };
        wireplumber = {
          format = "Vol: {volume}%";
          format-muted = "Vol: Muted";
        };
        clock = {
          interval = 1;
          format = "{:%Y-%m-%d %H:%M:%S}";
          tooltip = false;
        };
        network = {
          interval = 60;
          format-wifi = "{essid} ({signalStrength}%)";
          format-ethernet = "{ifname}";
          format-disconnected = "Disconnected";
          tooltip-format = "{ifname} via {gwaddr} | IP: {ipaddr}/{cidr}";
          tooltip-format-wifi = "{essid} ({signalStrength}%) | {ifname} via {gwaddr} | IP: {ipaddr}/{cidr} | Frequency: {frequency}GHz";
        };
        privacy = {
          icon-spacing = 4;
          icon-size = 18;
          transition-duration = 250;
          modules = [
            {
              type = "screenshare";
              tooltip = true;
              tooltip-icon-size = 24;
            }
            {
              type = "audio-out";
              tooltip = true;
              tooltip-icon-size = 24;
            }
            {
              type = "audio-in";
              tooltip = true;
              tooltip-icon-size = 24;
            }
          ];
        };
        tray = {
          icon-size = 16;
          spacing = 3;
        };
        /*
        idle_inhibitor = {
        	format = "{icon}";
        	format-icons = {
        		activated = "";
        		deactivated = "";
        	};
        };
        power-profiles-daemon = {
        	format = "{icon}";
        	tooltip-format = "Power profile: {profile}\nDriver: {driver}";
        	tooltip = true;
        	format-icons = {
        		default = "";
        		performance = "";
        		balanced = "";
        		power-saver = "";
        	};
        };
        */
        /*
        bluetooth = {
        	format = "BT: {status}";
        	tooltip-format = "{controller_alias} | Address: {controller_address} | {num_connections} connected\n{device_enumerate}";
        	tooltip-format-connected = "{controller_alias} | Address: {controller_address} | {num_connections} connected\n\nConnected devices:\n{device_enumerate}";
        	tooltip-format-enumerate-connected = "{device_alias} | {device_address}";
        };
        */
      };
    };
    style = ''
      * {
      	border-radius: 0;
      	font-size: 11px;
      }

      #workspaces button {
      	padding: 0 0px;
      	margin: 0 1px;
      	min-width: 16px;
      	font-size: 11px;
      }
    '';
  };
}
