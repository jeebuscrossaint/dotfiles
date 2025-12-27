{
  config,
  lib,
  pkgs,
  ...
}: {
  # Disable other window managers
  xsession.windowManager.i3.enable = false;
  xsession.windowManager.xmonad.enable = false;
  xsession.windowManager.awesome.enable = false;

  xsession.windowManager.spectrwm = {
    enable = true;

    settings = {
      # Use Super key as modifier
      modkey = "Mod4";
      
      # Workspace settings
      workspace_limit = 10;
      
      # Focus settings
      focus_mode = "default";
      focus_close = "next";
      focus_close_wrap = 1;
      focus_default = "last";
      
      # Window settings
      border_width = 2;
      disable_border = 0;
      
      # Bar settings
      bar_enabled = 1;
      bar_at_bottom = 1;
      bar_border_width = 0;
      bar_color = "#000000";
      bar_font_color = "#ffffff";
      bar_font = "monospace:size=10";
      bar_action = "${config.home.homeDirectory}/.config/lemonbar/lemon.sh";
      bar_justify = "left";
      bar_format = "+N:+I +S <+D>+4<%a %b %d %R %Z %Y+8<+A+4<+V";
      
      # Stack settings
      stack_enabled = 1;
      
      # Terminal
      term_width = 0;
      
      # Dialog box size ratio
      dialog_ratio = "0.6";
      
      # Disable window decorations
      iconic_enabled = 0;
      maximize_hide_bar = 0;
      window_class_enabled = 1;
      window_instance_enabled = 1;
      window_name_enabled = 1;
    };

    programs = {
      term = "xterm";
      menu = "bemenu-run";
      lock = "xsecurelock";
      screenshot_all = "flameshot gui";
    };

    # Unbind default keys we want to override
    unbindings = [
      "MOD+Shift+Return"
      "MOD+Return"
      "M+h"
      "M+l"
    ];

    bindings = {
      # Main keybindings
      "term" = "MOD+q";
      "wind_kill" = "MOD+c";
      "float_toggle" = "MOD+p";
      "menu" = "MOD+d";
      "lock" = "MOD+l";
      "screenshot_all" = "MOD+Shift+s";
      
      # Custom programs
      "bruh" = "MOD+b";
      
      # Window focus
      "focus_left" = "MOD+Left";
      "focus_down" = "MOD+Down";
      "focus_up" = "MOD+Up";
      "focus_right" = "MOD+Right";
      
      # Window movement
      "swap_left" = "MOD+Shift+Left";
      "swap_down" = "MOD+Shift+Down";
      "swap_up" = "MOD+Shift+Up";
      "swap_right" = "MOD+Shift+Right";
      
      # Layout management
      "layout_max" = "MOD+f";
      "layout_vertical" = "MOD+v";
      "layout_horizontal" = "MOD+h";
      "flip_layout" = "MOD+space";
      "cycle_layout" = "MOD+Shift+space";
      
      # Workspace switching (1-9)
      "ws_1" = "MOD+1";
      "ws_2" = "MOD+2";
      "ws_3" = "MOD+3";
      "ws_4" = "MOD+4";
      "ws_5" = "MOD+5";
      "ws_6" = "MOD+6";
      "ws_7" = "MOD+7";
      "ws_8" = "MOD+8";
      "ws_9" = "MOD+9";
      
      # Move window to workspace
      "mvws_1" = "MOD+Shift+1";
      "mvws_2" = "MOD+Shift+2";
      "mvws_3" = "MOD+Shift+3";
      "mvws_4" = "MOD+Shift+4";
      "mvws_5" = "MOD+Shift+5";
      "mvws_6" = "MOD+Shift+6";
      "mvws_7" = "MOD+Shift+7";
      "mvws_8" = "MOD+Shift+8";
      "mvws_9" = "MOD+Shift+9";
      
      # Restart/Quit
      "restart" = "MOD+Shift+r";
      "quit" = "MOD+Shift+e";
    };

    quirks = {
      "rofi:rofi" = "FLOAT";
      "zoom:zoom" = "FLOAT";
    };
  };

  # Create autostart script
  home.file.".config/spectrwm/autostart.sh" = {
    text = ''
      #!/bin/sh
      
      # Autostart applications
      dex --autostart --environment spectrwm &
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
      unclutter &
      
      # Set environment variables
      export QT_QPA_PLATFORMTHEME=qt6ct
      export GDK_BACKEND=x11
      export MOZ_ENABLE_WAYLAND=0
      export CLUTTER_BACKEND=x11
      export QT_QPA_PLATFORM=x11
    '';
    executable = true;
  };

  # Create bruh.sh keybinding script wrapper
  home.file.".config/spectrwm/bruh.sh" = {
    text = ''
      #!/bin/sh
      ${config.home.homeDirectory}/bruh.sh --dunst
    '';
    executable = true;
  };

  # Add custom program bindings to config
  xdg.configFile."spectrwm/spectrwm.conf".text = lib.mkAfter ''
    # Custom program bindings
    program[bruh] = ${config.home.homeDirectory}/.config/spectrwm/bruh.sh
    
    # Autostart script
    autorun = ws[1]:${config.home.homeDirectory}/.config/spectrwm/autostart.sh
  '';
}