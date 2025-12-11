{
  config,
  lib,
  pkgs,
  ...
}: {
  # Disable other window managers
  xsession.windowManager.i3.enable = false;

  # Generate sxwm config
  home.file.".config/sxwmrc".text = ''
    # sxwm configuration
    # Based on your i3 config

    # General settings
    mod_key : super
    gaps : 0
    border_width : 0
    focused_border_colour : #ffffff
    unfocused_border_colour : #000000
    swap_border_colour : #fff4c0
    master_width : 60
    motion_throttle : 60
    resize_master_amount : 1
    resize_stack_amount : 20
    snap_distance : 5
    move_window_amount : 10
    resize_window_amount : 10
    new_win_focus : true
    warp_cursor : true
    floating_on_top : true
    new_win_master : false

    # Floating rules
    should_float : "rofi,zoom"

    # Startup script (consolidate all startup commands)
    exec : "${config.home.homeDirectory}/.config/sxwm/autostart.sh"

    # Main keybindings
    bind : mod + q : "kitty"
    bind : mod + c : close_window
    bind : mod + d : "rofi -show drun"
    bind : mod + l : "xsecurelock"
    bind : mod + b : "/home/amarnath/dotfiles/bruh.sh --dunst"
    bind : mod + shift + s : "flameshot gui"

    # Window focus
    bind : mod + Left : focus_prev
    bind : mod + Right : focus_next
    bind : mod + Down : focus_next
    bind : mod + Up : focus_prev

    # Window movement
    bind : mod + shift + Left : master_prev
    bind : mod + shift + Right : master_next
    bind : mod + shift + Down : master_next
    bind : mod + shift + Up : master_prev

    # Layout management
    bind : mod + f : fullscreen
    bind : mod + p : toggle_floating
    bind : mod + space : toggle_monocle
    bind : mod + shift + space : toggle_floating

    # Master/Stack resize
    bind : mod + h : master_decrease
    bind : mod + shift + h : master_increase

    # Monitor management
    bind : mod + period : focus_next_mon
    bind : mod + comma : focus_prev_mon
    bind : mod + shift + period : move_next_mon
    bind : mod + shift + comma : move_prev_mon

    # Media keys
    bind : XF86AudioRaiseVolume : "volumectl up"
    bind : XF86AudioLowerVolume : "volumectl down"
    bind : XF86Launch3 : "playerctl play-pause"
    bind : XF86AudioMicMute : "volumectl -m toggle-mute"
    bind : XF86MonBrightnessUp : "lightctl up"
    bind : XF86MonBrightnessDown : "lightctl down"

    # Workspace switching (1-9)
    workspace : mod + 1 : move 1
    workspace : mod + 2 : move 2
    workspace : mod + 3 : move 3
    workspace : mod + 4 : move 4
    workspace : mod + 5 : move 5
    workspace : mod + 6 : move 6
    workspace : mod + 7 : move 7
    workspace : mod + 8 : move 8
    workspace : mod + 9 : move 9

    # Move window to workspace
    workspace : mod + shift + 1 : swap 1
    workspace : mod + shift + 2 : swap 2
    workspace : mod + shift + 3 : swap 3
    workspace : mod + shift + 4 : swap 4
    workspace : mod + shift + 5 : swap 5
    workspace : mod + shift + 6 : swap 6
    workspace : mod + shift + 7 : swap 7
    workspace : mod + shift + 8 : swap 8
    workspace : mod + shift + 9 : swap 9

    # sxwm control
    bind : mod + shift + r : reload_config
    bind : mod + shift + e : quit
  '';

  # Create autostart script for all startup applications
  home.file.".config/sxwm/autostart.sh" = {
    text = ''
      #!/bin/sh
      
      # Autostart applications
      dex --autostart --environment sxwm &
      xss-lock --transfer-sleep-lock -- xsecurelock &
      nm-applet &
      timedatectl set-local-rtc 1 --adjust-system-clock &
      udiskie &
      /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
      xclip &
      xdotool key --clearmodifiers Num_Lock &
      ${config.home.homeDirectory}/.config/lemonbar/lemon.sh &
      autotiling &
      rog-control-center &
      gamescope &
      /usr/bin/pipewire &
      /usr/bin/pipewire-pulse &
      /usr/bin/wireplumber &
      numlockx &
      dunst &
      xrandr --output eDP-1 --mode 2560x1600 --rate 240.00 --primary --output HDMI-1-0 --mode 1920x1080 --rate 60.00 --above eDP-1 &
      display-update
      unclutter &
      picom --config ~/.config/picom/picom.conf &
    '';
    executable = true;
  };

  # Set environment variables
  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
    GDK_BACKEND = "x11";
    MOZ_ENABLE_WAYLAND = "0";
    CLUTTER_BACKEND = "x11";
    QT_QPA_PLATFORM = "x11";
  };
}
