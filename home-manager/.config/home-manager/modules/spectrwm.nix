{ config, pkgs, lib, ... }:

{
  xsession.windowManager.spectrwm = {
    enable = false;
    settings = {
      # GENERAL SETTINGS
      workspace_limit = 10;
      focus_mode = "manual";
      focus_close = "previous";
      focus_close_wrap = true;
      focus_default = "last";
      spawn_position = "next";
      workspace_clamp = true;
      warp_focus = true;
      warp_pointer = true;

      # WINDOW DECORATION
      border_width = 1;
      color_focus = "rgb:5f/87/af";
      color_focus_maximized = "rgb:5f/87/af";
      color_unfocus = "rgb:44/44/44";
      color_unfocus_maximized = "rgb:44/44/44";
      region_padding = 4;
      tile_gap = 4;

      # BAR SETTINGS
      bar_enabled = true;
      bar_border_width = 1;
      "bar_border[1]" = "rgb:28/28/28";
      "bar_border_unfocus[1]" = "rgb:28/28/28";
      "bar_color[1]" = "rgb:28/28/28";
      "bar_color_selected[1]" = "rgb:00/80/80";
      "bar_font[1]" = "Hack:pixelsize=14:antialias=true";
      "bar_font_color[1]" = "rgb:a0/a0/a0";
      "bar_font_color_selected" = "rgb:ff/ff/ff";
      "bar_delay" = 5;
      "bar_action" = "${pkgs.conky}/bin/conky";
      "bar_justify" = "center";
      "bar_format" = "+|L+1<+N:+I +S +W +|R+A %a %b %d [%R]";
      "stack_enabled" = true;
      "clock_enabled" = true;
      "clock_format" = "%a %b %d %R %Z %Y";
      "iconic_enabled" = false;
      "maximize_hide_bar" = false;
      "window_class_enabled" = true;
      "window_instance_enabled" = true;
      "window_name_enabled" = true;
      "verbose_layout" = false;
      "urgent_enabled" = true;
    };

    # KEYBINDINGS
    bindings = {
      "term" = "Mod+Return";
      "menu" = "Mod+v";
      "search" = "Mod+f";
      "name_workspace" = "Mod+Shift+slash";
      "iconify" = "Mod+w";
      "uniconify" = "Mod+Shift+w";
      "quit" = "Mod+Shift+q";
      "restart" = "Mod+q";
      "lock" = "Mod+Shift+Delete";
      "initscr" = "Mod+Shift+i";
      "wind_del" = "Mod+x";
      "wind_kill" = "Mod+Shift+x";
      "float_toggle" = "Mod+t";
      "cycle_layout" = "Mod+space";
      "flip_layout" = "Mod+Shift+backslash";
      "bar_toggle" = "Mod+b";
      "focus_main" = "Mod+m";
      "focus_next" = "Mod+j";
      "focus_prev" = "Mod+k";
      "focus_urgent" = "Mod+u";
      "ws_1" = "Mod+1";
      "ws_2" = "Mod+2";
      "ws_3" = "Mod+3";
      "ws_4" = "Mod+4";
      "ws_5" = "Mod+5";
      "ws_6" = "Mod+6";
      "ws_7" = "Mod+7";
      "ws_8" = "Mod+8";
      "ws_9" = "Mod+9";
      "ws_10" = "Mod+0";
      "mvws_1" = "Mod+Shift+1";
      "mvws_2" = "Mod+Shift+2";
      "mvws_3" = "Mod+Shift+3";
      "mvws_4" = "Mod+Shift+4";
      "mvws_5" = "Mod+Shift+5";
      "mvws_6" = "Mod+Shift+6";
      "mvws_7" = "Mod+Shift+7";
      "mvws_8" = "Mod+Shift+8";
      "mvws_9" = "Mod+Shift+9";
      "mvws_10" = "Mod+Shift+0";
      "ws_next" = "Mod+Right";
      "ws_prev" = "Mod+Left";
      "ws_next_all" = "Mod+Up";
      "ws_prev_all" = "Mod+Down";
      "ws_prior" = "Mod+a";
      "rg_1" = "Mod+KP_End";
      "rg_2" = "Mod+KP_Down";
      "rg_3" = "Mod+KP_Next";
      "rg_4" = "Mod+KP_Left";
      "rg_5" = "Mod+KP_Begin";
      "rg_6" = "Mod+KP_Right";
      "rg_7" = "Mod+KP_Home";
      "rg_8" = "Mod+KP_Up";
      "rg_9" = "Mod+KP_Prior";
      "mvrg_1" = "Mod+Shift+KP_End";
      "mvrg_2" = "Mod+Shift+KP_Down";
      "mvrg_3" = "Mod+Shift+KP_Next";
      "mvrg_4" = "Mod+Shift+KP_Left";
      "mvrg_5" = "Mod+Shift+KP_Begin";
      "mvrg_6" = "Mod+Shift+KP_Right";
      "mvrg_7" = "Mod+Shift+KP_Home";
      "mvrg_8" = "Mod+Shift+KP_Up";
      "mvrg_9" = "Mod+Shift+KP_Prior";
      "rg_next" = "Mod+Shift+Right";
      "rg_prev" = "Mod+Shift+Left";
      "maximize_toggle" = "Mod+e";
      "width_grow" = "Mod+equal";
      "width_shrink" = "Mod+minus";
      "height_grow" = "Mod+Shift+equal";
      "height_shrink" = "Mod+Shift+minus";
      "move_left" = "Mod+bracketleft";
      "move_right" = "Mod+bracketright";
      "move_up" = "Mod+Shift+bracketleft";
      "move_down" = "Mod+Shift+bracketright";
    };

    # PROGRAMS
    programs = {
      "term" = "${pkgs.alacritty}/bin/alacritty";
      "menu" = "${pkgs.rofi}/bin/rofi -show drun";
      "screenshot_all" = "${pkgs.scrot}/bin/scrot";
      "screenshot_wind" = "${pkgs.scrot}/bin/scrot -u";
      "lock" = "${pkgs.i3lock}/bin/i3lock -c 000000";
      "browser" = "${pkgs.firefox}/bin/firefox";
      "file_manager" = "${pkgs.pcmanfm}/bin/pcmanfm";
      "editor" = "${pkgs.vscode}/bin/code";
    };

    # QUIRKS (window rules)
    quirks = {
      "Firefox:Navigator" = "TRANSSZ";
      "Firefox:Dialog" = "FLOAT";
      "Gimp:gimp" = "FLOAT + ANYWHERE";
      "mpv:mpv" = "FLOAT + FOCUSPREV";
      "Pavucontrol:pavucontrol" = "FLOAT";
      "Xmessage:xmessage" = "FLOAT";
      "XClock:xclock" = "FLOAT";
      "Virt-manager:virt-manager" = "FLOAT";
      "libreoffice-writer:libreoffice" = "FLOAT";
      "libreoffice-calc:libreoffice" = "FLOAT";
      "libreoffice-impress:libreoffice" = "FLOAT";
    };
  };
}
