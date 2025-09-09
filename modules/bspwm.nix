{
  pkgs,
  lib,
  ...
}: {
  xsession.windowManager.bspwm = {
    enable = true;

    monitors = {
      "HDMI-A-1" = ["1" "2" "3" "4" "5"];
      "eDP-1" = ["6" "7" "8" "9" "10"];
    };

    settings = {
      # Window appearance
      border_width = 0;
      window_gap = 0;
      split_ratio = 0.50;
      borderless_monocle = true;
      gapless_monocle = true;
      single_monocle = false;

      # Focus behavior
      focus_follows_pointer = true;
      pointer_follows_focus = false;
      pointer_follows_monitor = true;

      # Mouse behavior
      click_to_focus = "button1";
      swallow_first_click = false;

      # Window management
      automatic_scheme = "spiral";
      initial_polarity = "second_child";
      removal_adjustment = true;

      # Preselection
      presel_feedback = true;

      # External rules command
      external_rules_command = "";

      # History
      history_aware_focus = false;
    };

    rules = {
      "firefox" = {
        desktop = "^2";
      };
      "discord" = {
        desktop = "^3";
      };
      "Steam" = {
        desktop = "^4";
      };
      "mpv" = {
        state = "floating";
        focus = true;
      };
      "Rofi" = {
        state = "floating";
        center = true;
      };
      "fuzzel" = {
        state = "floating";
        center = true;
      };
      "Pcmanfm" = {
        state = "floating";
      };
      "Pavucontrol" = {
        state = "floating";
      };
      "Blueberry.py" = {
        state = "floating";
      };
      "Gparted" = {
        state = "floating";
      };
      "copyq" = {
        state = "floating";
      };
      "Picture-in-Picture" = {
        state = "floating";
        sticky = true;
      };
    };

    startupPrograms = [
      # Compositor
      "picom -b"

      # Wallpaper
      "feh --bg-scale ~/.config/wallpaper.jpg || nitrogen --restore"

      # System services
      "systemctl --user start polkit-gnome-authentication-agent-1"
      "dunst "
      "copyq --start-server"
      "udiskie "
      # Gaming and system optimization
      "gamemoded"

      # Auto-tiling (if you want it)
      # "autotiling-rs &"

      # Bar (if you're using a status bar)
      # "polybar main &"

      # Mouse and touchpad setup
      "xinput set-prop 'pointer' 'libinput Accel Profile Enabled' 0, 1"
      "xinput set-prop 'touchpad' 'libinput Accel Profile Enabled' 0, 1"
      "xinput set-prop 'touchpad' 'libinput Natural Scrolling Enabled' 1"
      "xinput set-prop 'touchpad' 'libinput Tapping Enabled' 1"
      "xinput set-prop 'touchpad' 'libinput Disable While Typing Enabled' 1"

      # Set cursor theme
      "xsetroot -cursor_name left_ptr"

      # Numlock
      "numlockx on"

      # Screen configuration
      "xrandr --output HDMI-A-1 --mode 1920x1080 --rate 60 --pos 0x0 --output eDP-1 --mode 2560x1600 --rate 240 --pos 0x1080"
    ];

    extraConfig = ''
      # Custom bspwm configuration
      bspc config remove_disabled_monitors true
      bspc config remove_unplugged_monitors true
      bspc config merge_overlapping_monitors true

      # Colors (will be overridden by stylix if enabled)
      bspc config normal_border_color   "#3c3836"
      bspc config active_border_color   "#665c54"
      bspc config focused_border_color  "#fe8019"
      bspc config presel_feedback_color "#83a598"

      # Multi-monitor setup
      if xrandr | grep "HDMI-A-1 connected"; then
        bspc monitor HDMI-A-1 -d 1 2 3 4 5
        bspc monitor eDP-1 -d 6 7 8 9 10
      else
        bspc monitor eDP-1 -d 1 2 3 4 5 6 7 8 9 10
      fi

      # Window rules for specific applications
      bspc rule -a "Zathura" state=tiled
      bspc rule -a "Gimp" desktop='^8' follow=on
      bspc rule -a "Chromium" desktop='^2'
      bspc rule -a "mplayer2" state=floating
      bspc rule -a "Kupfer.py" focus=on
      bspc rule -a "Screenkey" manage=off
      bspc rule -a "Conky" manage=off
      bspc rule -a "stalonetray" manage=off
    '';
  };
}
