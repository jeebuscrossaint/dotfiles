{
  inputs,
  config,
  pkgs,
  ...
}: {
  programs.i3status-rust = {
    enable = true;

    bars = {
      # Use "default" as the name - creates config-default.toml
      default = {
        blocks = [
          {
            block = "cpu";
            interval = 2;
            format = " $icon $utilization ";
          }
          {
            block = "disk_space";
            path = "/";
            info_type = "available";
            interval = 30;
            warning = 20.0;
            alert = 10.0;
            format = " $icon $available.eng(w:2) ";
          }
          {
            block = "memory";
            format = " $icon $mem_used_percents.eng(w:2) ";
            format_alt = " $icon $swap_used_percents.eng(w:2) ";
            interval = 5;
          }
          {
            block = "load";
            interval = 2;
            format = " $icon $1m.eng(w:4) ";
          }
          {
            block = "sound";
            format = " $icon $volume ";
            click = [
              {
                button = "left";
                cmd = "pavucontrol";
              }
            ];
          }
          {
            block = "net";
            device = "^wl.*";
            format = " $icon $signal_strength $ssid ";
            interval = 5;
          }
          {
            block = "battery";
            interval = 10;
            format = " $icon $percentage ";
          }
          {
            block = "time";
            interval = 60;
            format = " $icon $timestamp.datetime(f:'%a %d/%m %H:%M') ";
          }
        ];

        icons = "awesome6";
      };
    };
  };

  # Create a symlink from config-default.toml to config.toml
  xdg.configFile."i3status-rust/config.toml".source =
    config.xdg.configFile."i3status-rust/config-default.toml".source;
}
