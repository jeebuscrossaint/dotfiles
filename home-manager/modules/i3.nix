{
  config,
  lib,
  pkgs,
  ...
}:
{
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3;

    config = {
      modifier = "Mod4";

      terminal = "kitty";
      menu = "rofi -show drun";

      gaps = {
        inner = 20;
        outer = 10;
        smartGaps = true;
        smartBorders = "on";
      };

      window = {
        border = 1;
        hideEdgeBorders = "none";
        commands = [
          {
            command = "border pixel 7";
            criteria = {
              class = ".*";
            };
          }
          {
            command = "floating enable";
            criteria = {
              class = "rofi";
            };
          }
          {
            command = "floating enable";
            criteria = {
              class = "zoom";
            };
          }
          {
            command = "floating enable";
            criteria = {
              class = "pavucontrol";
            };
          }
        ];
      };

      floating = {
        modifier = "Mod4";
        criteria = [
          { class = "rofi"; }
          { class = "zoom"; }
          { class = "pavucontrol"; }
        ];
      };

      # Bar with i3status-rust
      bars = [
        # {
          # position = "bottom";
          # statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-default.toml";
          # trayOutput = "primary";
          # fonts = {
            # names = [ "Hasklug Nerd Font Mono" ];
            # size = 11.0;
          # };
        # }
      ];

      keybindings = lib.mkOptionDefault {
        # Basic applications
        "Mod4+q" = "exec kitty";
        "Mod4+Shift+q" = "exec xterm";
        "Mod4+d" = "exec rofi -show drun";
        "Mod4+c" = "kill";
        "Mod4+Shift+c" = "reload";
        "Mod4+l" = "exec xsecurelock";
        "Mod4+g" = "exec new-wallpaper";
        "Mod4+b" = "exec ~/dotfiles/bruh.sh --dunst";

        # Screenshot with flameshot
        "Mod4+Shift+s" = "exec flameshot gui";

        # Toggle bar
        "Mod4+Shift+b" = "bar mode toggle";

        # Window management - arrow keys
        "Mod4+Left" = "focus left";
        "Mod4+Down" = "focus down";
        "Mod4+Up" = "focus up";
        "Mod4+Right" = "focus right";

        # Move windows - arrow keys with Shift
        "Mod4+Shift+Left" = "move left";
        "Mod4+Shift+Down" = "move down";
        "Mod4+Shift+Up" = "move up";
        "Mod4+Shift+Right" = "move right";

        # Layout management
        "Mod4+h" = "split h";
        "Mod4+v" = "split v";
        "Mod4+f" = "fullscreen toggle";
        "Mod4+s" = "layout stacking";
        "Mod4+w" = "layout tabbed";
        "Mod4+e" = "layout toggle split";
        "Mod4+space" = "focus mode_toggle";
        "Mod4+Shift+space" = "floating toggle";
        "Mod4+a" = "focus parent";

        # Media keys
        "XF86AudioRaiseVolume" = "exec --no-startup-id volumectl up";
        "XF86AudioLowerVolume" = "exec --no-startup-id volumectl down";
        "XF86AudioMute" = "exec --no-startup-id volumectl toggle-mute";
        "XF86AudioMicMute" = "exec --no-startup-id volumectl -m toggle-mute";
        "XF86Launch3" = "exec --no-startup-id playerctl play-pause";
        "XF86AudioPlay" = "exec --no-startup-id playerctl play-pause";
        "XF86MonBrightnessUp" = "exec --no-startup-id lightctl up";
        "XF86MonBrightnessDown" = "exec --no-startup-id lightctl down";

        # Touchpad toggle
        "XF86TouchpadToggle" = "exec --no-startup-id ~/.config/i3/toggle-touchpad.sh";
      };

      modes = {
        resize = {
          "Left" = "resize shrink width 10 px or 10 ppt";
          "Down" = "resize grow height 10 px or 10 ppt";
          "Up" = "resize shrink height 10 px or 10 ppt";
          "Right" = "resize grow width 10 px or 10 ppt";
          "Return" = "mode default";
          "Escape" = "mode default";
        };
      };

      startup = [
        # Fast key repeat - matching mangowc (50ms rate, 200ms delay)
        {
          command = "xset r rate 200 50";
          notification = false;
          always = true;
        }
        {
          command = "dex --autostart --environment i3";
          notification = false;
        }
        {
          command = "xss-lock --transfer-sleep-lock -- xsecurelock";
          notification = false;
        }
        {
          command = "nm-applet";
          notification = false;
        }
        {
          command = "timedatectl set-local-rtc 1 --adjust-system-clock";
          notification = false;
        }
        {
          command = "udiskie";
          notification = false;
          always = false;
        }
        {
          command = "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1";
          notification = false;
        }
        {
          command = "xclip";
          notification = false;
        }
        {
          command = "xdotool key --clearmodifiers Num_Lock";
          notification = false;
        }
        {
          command = "autotiling";
          notification = false;
        }
        {
          command = "dunst";
          notification = false;
        }
        {
          command = "xrandr --output eDP-1 --mode 2560x1600 --rate 240.00 --primary --output HDMI-1-0 --mode 1920x1080 --rate 60.00 --right-of eDP-1";
          notification = false;
        }
        {
          command = "unclutter";
          notification = false;
        }
        {
          command = "picom -b";
          notification = false;
        }
      ];
    };

    extraConfig = ''
      # Set environment variables for correct theming
      exec --no-startup-id set QT_QPA_PLATFORMTHEME qt6ct
      exec --no-startup-id set GDK_BACKEND x11
      exec --no-startup-id set MOZ_ENABLE_WAYLAND 0
      exec --no-startup-id set CLUTTER_BACKEND x11
      exec --no-startup-id set QT_QPA_PLATFORM x11
    '';
  };

  # Touchpad toggle script
  home.file.".config/i3/toggle-touchpad.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      device=$(xinput list | grep -i touchpad | grep -oP 'id=\K\d+')
      if [ -n "$device" ]; then
        state=$(xinput list-props "$device" | grep "Device Enabled" | grep -oP ':\s*\K\d+')
        if [ "$state" = "1" ]; then
          xinput disable "$device"
          notify-send "Touchpad" "Disabled" -t 1000
        else
          xinput enable "$device"
          notify-send "Touchpad" "Enabled" -t 1000
        fi
      fi
    '';
  };
}
