# Simplified Sway configuration for Home Manager with SwayFX features
{pkgs, ...}: {
  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.swayfx-unwrapped;
    checkConfig = false;
    xwayland = true;

    config = {
      # Gaps
      gaps = {
        inner = 0;
        outer = 0;
        smartGaps = false;
        smartBorders = "on";
      };

      # Window appearance
      window = {
        titlebar = false;
        border = 1;
      };

      # Inputs
      input = {
        "type:touchpad" = {
          natural_scroll = "disabled";
        };
      };

      # Focus behavior
      focus = {
        followMouse = "yes";
      };

      # Modifier key
      modifier = "Mod4";

      # Default programs
      menu = "BEMENU_BACKEND=wayland bemenu-run";
      terminal = "foot";

      # Bar configuration
      bars = [
        {
          command = "swaybar";
          statusCommand = "env RUST_BACKTRACE=1 RUST_LOG=swayr=debug swayrbar 2> /tmp/swayrbar.log";
          position = "bottom";
          #          height = 20;
        }
      ];

      # Floating modifier
      floating.modifier = "Mod4";

      # Key bindings
      keybindings = let
        modifier = "Mod4";
      in {
        # Basic bindings
        "${modifier}+q" = "exec foot";
        "${modifier}+d" = "exec /bin/sh -c bemenu-run";
        "${modifier}+c" = "kill";
        "${modifier}+Shift+c" = "reload";
        "${modifier}+l" = "exec swaylock -C ~/.config/swaylock/config";
        "${modifier}+g" = "exec new-wallpaper";

        # Focus bindings
        "${modifier}+left" = "focus left";
        "${modifier}+down" = "focus down";
        "${modifier}+up" = "focus up";
        "${modifier}+right" = "focus right";

        # Move bindings
        "${modifier}+Shift+Left" = "move left";
        "${modifier}+Shift+Down" = "move down";
        "${modifier}+Shift+Up" = "move up";
        "${modifier}+Shift+Right" = "move right";

        # Workspace bindings
        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace number 9";
        "${modifier}+0" = "workspace number 10";

        # Move to workspace bindings
        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9";
        "${modifier}+Shift+0" = "move container to workspace number 10";

        # Layout bindings
        "${modifier}+Shift+v" = "floating toggle";
        "${modifier}+b" = "splith";
        "${modifier}+v" = "splitv";
        "${modifier}+s" = "layout stacking";
        "${modifier}+w" = "layout tabbed";
        "${modifier}+e" = "layout toggle split";
        "${modifier}+f" = "fullscreen";
        "${modifier}+space" = "focus mode_toggle";
        "${modifier}+a" = "focus parent";
        "${modifier}+r" = "mode resize";

        # Media keys
        "XF86AudioRaiseVolume" = "exec volumectl up";
        "XF86AudioLowerVolume" = "exec volumectl down";
        "XF86AudioMute" = "exec volumectl toggle-mute";
        "XF86AudioMicMute" = "exec volumectl -m toggle-mute";
        "XF86Launch3" = "exec playerctl play-pause";
        "XF86AudioPlay" = "exec playerctl play-pause";
        "XF86MonBrightnessUp" = "exec lightctl up";
        "XF86MonBrightnessDown" = "exec lightctl down";

        # Screenshot
        "${modifier}+Shift+s" = "exec grim -g \"$(slurp)\" - | tee ~/Pictures/screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png | wl-copy";
      };

      # Resize mode
      modes = {
        resize = {
          "left" = "resize shrink width 20px";
          "up" = "resize shrink height 20px";
          "right" = "resize grow width 20px";
          "down" = "resize grow height 20px";
          "Return" = "mode default";
          "Escape" = "mode default";
        };
      };

      # Startup programs
      startup = [
        {
          command = "numlockwl";
          always = false;
        }
        {
          command = "fnott";
          always = false;
        }
        {
          command = "udiskie";
          always = false;
        }
        {
          command = "nm-applet";
          always = false;
        }
        {
          command = "autotiling-rs";
          always = false;
        }
        {
          command = "copyq --start-server";
          always = false;
        }
        {
          command = "wl-paste --type text --watch cliphist store";
          always = false;
        }
        {
          command = "wl-paste --type image --watch cliphist store";
          always = false;
        }
        {
          command = "swaybg";
          always = false;
        }
        {
          command = "dbus-update-activation-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP";
          always = false;
        }
        {
          command = "gamemoded";
          always = false;
        }
        {
          command = "avizo-service";
          always = false;
        }
        {
          command = "swayidle";
          always = false;
        }
        {
          command = "swaync";
          always = false;
        }
      ];

      # Output configuration
      output = {
        "*" = {
          #bg = "#000000 solid_color";
        };
      };
    };

    # SwayFX-specific configuration using extraConfig
    extraConfig = ''
      # Window blur effects
      #blur enable
      #blur_xray disable
      #blur_passes 2
      #blur_radius 5
      #blur_noise 0.02
      #blur_brightness 1.0
      #blur_contrast 1.0
      #blur_saturation 1.0

      # Corner radius for windows
      #corner_radius 10

      # Window shadows
      #shadows enable
      #shadows_on_csd enable
      #shadow_blur_radius 20
      #shadow_color #0000007F
      #shadow_offset 0 0
      #shadow_inactive_color #0000004F

      # Dim unfocused windows
      #default_dim_inactive 0.1
      #dim_inactive_colors.unfocused #000000FF
      #dim_inactive_colors.urgent #900000FF

      # Titlebar separator
      #titlebar_separator enable

      # Scratchpad minimize (recommended to keep disabled)
      #scratchpad_minimize disable

      # Layer effects for panels/bars
      layer_effects "waybar" {
          blur enable
          blur_xray enable
          blur_ignore_transparent enable
          shadows enable
          corner_radius 10
      }

      layer_effects "gtk-layer-shell" {
          blur enable
          shadows enable
          corner_radius 8
      }

      # Example of per-window dim settings
      for_window [app_id="firefox"] dim_inactive 0.05
      for_window [class="steam"] dim_inactive 0.0
    '';

    extraOptions = ["--unsupported-gpu"];

    # System integration
    systemd = {
      enable = true;
      xdgAutostart = true;
    };
  };
}
