{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.fht-compositor.homeModules.default
  ];

  programs.fht-compositor = {
    enable = true;

    settings = {
      autostart = [];
      env = {};

      input = {
        keyboard = {
          layout = "us";
          rules = "";
          repeat-rate = 50;
          repeat-delay = 250;
        };
        # Add `per-device` config here if needed
      };

      general = {
        cursor-warps = true;
        focus-new-windows = true;
        focus-follows-mouse = false;
        layouts = ["tile" "floating"];
        nmaster = 1;
        mwfact = 0.5;
        inner-gaps = 10;
        outer-gaps = 30;
      };

      decorations = {
        decoration-mode = "force-server-side";
        border = {
          thickness = 2;
          radius = 15;
          focused-color = "#6791c9";
          normal-color = "#222230";
        };
        shadow = {
          color = "black";
          floating-only = false;
        };
        blur = {
          disable = false;
          passes = 2;
          radius = 10;
          noise = 0.05;
        };
      };

      animations = {
        disable = false;
      };

      keybinds = {
        "Super-q" = "quit";
        "Super-Ctrl-r" = "reload-config";
        "Super-Return" = {
          action = "run-command";
          arg = "foot";
        };
        "Super-p" = {
          action = "run-command";
          arg = "rofi -show drun";
        };
        "Super-Shift-s" = {
          action = "run-command";
          arg = ''grim -g "`slurp -o`" - | wl-copy --type image/png'';
        };
        "Super-Alt-l" = {
          action = "run-command";
          arg = "gtklock";
        };
        XF86AudioRaiseVolume = {
          action = "run-command";
          arg = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+";
          allow-while-locked = true;
        };
        XF86AudioLowerVolume = {
          action = "run-command";
          arg = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-";
          allow-while-locked = true;
        };
        "Super-j" = "focus-next-window";
        "Super-k" = "focus-previous-window";
        "Super-Ctrl-j" = "focus-next-output";
        "Super-Ctrl-k" = "focus-previous-output";
        "Super-m" = "maximize-focused-window";
        "Super-f" = "fullscreen-focused-window";
        "Super-Shift-c" = "close-focused-window";
        "Super-Ctrl-Space" = "float-focused-window";
        "Super-Shift-j" = "swap-with-next-window";
        "Super-Shift-k" = "swap-with-previous-window";
        "Super-Space" = "select-next-layout";
        "Super-Shift-Space" = "select-previous-layout";
        "Super-h" = {
          action = "change-mwfact";
          arg = -0.1;
        };
        "Super-l" = {
          action = "change-mwfact";
          arg = 0.1;
        };
        "Super-Shift-h" = {
          action = "change-nmaster";
          arg = 1;
        };
        "Super-Shift-l" = {
          action = "change-nmaster";
          arg = -1;
        };
        "Super-i" = {
          action = "change-window-proportion";
          arg = 0.5;
        };
        "Super-o" = {
          action = "change-window-proportion";
          arg = -0.5;
        };

        # Workspaces
        "Super-1" = {
          action = "focus-workspace";
          arg = 0;
        };
        "Super-2" = {
          action = "focus-workspace";
          arg = 1;
        };
        "Super-3" = {
          action = "focus-workspace";
          arg = 2;
        };
        "Super-4" = {
          action = "focus-workspace";
          arg = 3;
        };
        "Super-5" = {
          action = "focus-workspace";
          arg = 4;
        };
        "Super-6" = {
          action = "focus-workspace";
          arg = 5;
        };
        "Super-7" = {
          action = "focus-workspace";
          arg = 6;
        };
        "Super-8" = {
          action = "focus-workspace";
          arg = 7;
        };
        "Super-9" = {
          action = "focus-workspace";
          arg = 8;
        };

        "Super-Shift-1" = {
          action = "send-to-workspace";
          arg = 0;
        };
        "Super-Shift-2" = {
          action = "send-to-workspace";
          arg = 1;
        };
        "Super-Shift-3" = {
          action = "send-to-workspace";
          arg = 2;
        };
        "Super-Shift-4" = {
          action = "send-to-workspace";
          arg = 3;
        };
        "Super-Shift-5" = {
          action = "send-to-workspace";
          arg = 4;
        };
        "Super-Shift-6" = {
          action = "send-to-workspace";
          arg = 5;
        };
        "Super-Shift-7" = {
          action = "send-to-workspace";
          arg = 6;
        };
        "Super-Shift-8" = {
          action = "send-to-workspace";
          arg = 7;
        };
        "Super-Shift-9" = {
          action = "send-to-workspace";
          arg = 8;
        };
      };

      mousebinds = {
        "Super-Left" = "swap-tile";
        "Super-Right" = "resize-tile";
      };

      # Optional: rules and layer-rules sections can be added similarly if you need them
    };
  };
}
