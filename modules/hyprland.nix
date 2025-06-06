{
  pkgs,
  lib,
  ...
}: {
  wayland.windowManager.hyprland = {
    enable = false;
    systemd.enable = true;
    xwayland.enable = true;

    settings = {
      # Monitor configuration
      monitor = ",preferred,auto,1";
      workspace = ", special";

      # Autostart applications
      "exec-once" = [
        "hypridle"
        "swaync"
        "copyq --start-server"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "udiskie &"
        "/usr/libexec/hyprpolkitagent"
        "swww-daemon"
        "hyprpaper"
        "dbus-update-activation-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "eww daemon"
        "gamemoded"
        #"hyprpm reload -n"
        "hyprlux"
        "avizo-service"
        "rog-control-center"
        "nm-applet"
        "waybar --config ~/.config/waybar/config.json --style ~/.config/waybar/style.css"
        "/usr/bin/pipewire & /usr/bin/pipewire-pulse & /usr/bin/wireplumber"
      ];

      # Environment variables
      env = [
        "XCURSOR_SIZE,24"
        "XCURSOR_THEME,WhiteSur-cursor"
      ];

      # Input configuration
      input = {
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";
        numlock_by_default = true;
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          "tap-to-click" = true;
        };
        sensitivity = 0;
        accel_profile = "flat";
      };

      # General settings
      general = {
        gaps_in = 10;
        gaps_out = 20;
        border_size = 2;
        # Removed color settings to avoid conflicts with Stylix
        layout = "dwindle";
        allow_tearing = 1;
      };

      # Debug settings
      "debug:disable_logs" = false;
      "debug:enable_stdout_logs" = true;
      "debug:colored_stdout_logs" = true;

      # Decoration settings
      decoration = {
        shadow = {
          enabled = true;
          range = 11;
          render_power = 10;
          sharp = false;
          ignore_window = true;
          # Removed color settings to avoid conflicts with Stylix
          scale = 1.0;
        };
        rounding = 5;
        active_opacity = 1.0;
        inactive_opacity = 0.9;
        dim_strength = 0.15;
        dim_around = 0;
        dim_inactive = false;
        blur = {
          enabled = true;
          size = 7;
          passes = 2;
          vibrancy = 0;
          vibrancy_darkness = 1;
          new_optimizations = "on";
          noise = 0;
          contrast = 1;
          brightness = 1;
          xray = true;
          ignore_opacity = true;
          special = false;
        };
      };

      # Animation settings
      animations = {
        enabled = true;
        bezier = [
          "main, 0.21, 1, 0.21, 1.05"
          "linear, 0.0, 0.0, 1.0, 1.0"
          "easeInSine, 0.12, 0.0, 0.39, 0.0"
          "easeOutSine, 0.61, 1.0, 0.88, 1.0"
          "easeInOutSine, 0.37, 0.0, 0.63, 1.0"
          "easeInQuad, 0.11, 0.0, 0.50, 0.0"
          "easeOutQuad, 0.50, 1.0, 0.89, 1.0"
          "easeInOutQuad, 0.44, 0.0, 0.56, 1.0"
          "easeInCubic, 0.32, 0.0, 0.67, 0.0"
          "easeOutCubic, 0.33, 1.0, 0.68, 1.0"
          "easeInOutCubic, 0.65, 0.0, 0.35, 1.0"
          "easeInQuart, 0.50, 0.0, 0.75, 0.0"
          "easeOutQuart, 0.25, 1.0, 0.50, 1.0"
          "easeInOutQuart, 0.76, 0.0, 0.24, 1.0"
          "easeInQuint, 0.64, 0.0, 0.78, 0.0"
          "easeOutQuint, 0.22, 1.0, 0.36, 1.0"
          "easeInOutQuint, 0.83, 0.0, 0.17, 1.0"
          "easeInExpo, 0.70, 0.0, 0.84, 0.0"
          "easeOutExpo, 0.16, 1.0, 0.30, 1.0"
          "easeInOutExpo, 0.87, 0.0, 0.13, 1.0"
          "easeInCirc, 0.55, 0.0, 1.00, 0.45"
          "easeOutCirc, 0.00, 0.55, 0.45, 1.00"
          "easeInOutCirc, 0.85, 0.0, 0.15, 1.0"
          "easeInBack, 0.36, 0.0, 0.66, -0.56"
          "easeOutBack, 0.34, 1.56, 0.64, 1.0"
          "easeInOutBack, 0.68, -0.6, 0.32, 1.6"
          "slow, 0, 0.85, 0.3, 1"
          "overshot, 0.13, 0.99, 0.29, 1.1"
          "apparate, 0, 1.0, 0, 1.0"
        ];
        animation = [
          "windows, 1, 2, easeOutExpo, slidefade"
          "windowsMove, 1, 3, easeOutExpo, slidefade"
          "border, 1, 5, default"
          "borderangle, 1, 50, default, loop"
          "fade, 1, 3, easeOutExpo"
          "workspaces, 1, 3, easeOutExpo, slide"
          "specialWorkspace, 1, 6, apparate, slidefade"
        ];
      };

      # Misc settings
      misc = {
        # Removed background_color to avoid conflicts with Stylix
        disable_hyprland_logo = true;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
        enable_swallow = false;
        swallow_regex = "^(kitty)$";
        vrr = 0;
      };

      # Dwindle layout
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Gestures
      gestures = {
        workspace_swipe = "on";
        workspace_swipe_fingers = 3;
        workspace_swipe_forever = true;
      };

      "windowrulev2" = [
        "noblur,title:^(Picture-in-Picture)$"
        "nodim,title:^(Picture-in-Picture)$"
        "opacity 1.0 override 1.0 override,title:^(Picture-in-Picture)$"
        "noblur,class:^(zoom)$"
        "nodim,class:^(zoom)$"
        "opacity 1.0 override 1.0 override,class:^(zoom)$"
        "noblur,class:^(mpv)$"
        "nodim,class:^(mpv)$"
        "noanim,class:^(wofi)$"
        "opacity 1.0 override 1.0 override,class:^(mpv)$"
        "animation slide, class:Rofi$"
        "animation slide, class:^(fuzzel)&"
        "opacity 0.0 override 0.0 override,class:^(xwaylandvideobridge)$"
        "noanim,class:^(xwaylandvideobridge)$"
        "nofocus,class:^(xwaylandvideobridge)$"
        "noinitialfocus,class:^(xwaylandvideobridge)$"
        "opacity 0.9, title:^(neo)?vim\\s+~"
        "opacity 0.9, title:^nvim\\s+~"
        "opacity 0.9, title:^Discord"
        "opacity 0.9, class:vesktop"
        "opacity 0.9, class:Code - Insiders"
        "opacity 0.9, class:jetbrains-*"
        "opacity 0.9, class:kitty"
        "opacity 0.9, class:Alacritty"
        "opacity 0.9, class:foot"
      ];

      # Application variables
      "$term" = "foot";
      "$term_alt" = "xterm";
      "$browser" = "zen-browser";
      "$browser_pw" = "zen-browser --private-window";
      "$editor" = "kitty nvim";
      "$explorer" = "nautilus";
      "$notepad" = "gedit";
      "$clipboard" = "copyq show";
      "$discord" = "discord";
      "$launcher" = "bemenu-run";

      # Modifier keys
      "$mainMod" = "SUPER";
      "$altMod" = "SUPERALT";
      "$shiftMod" = "SUPERSHIFT";
      "$ctrlMod" = "SUPERCTRL";

      # Key bindings
      bind = [
        "$mainMod, Q, exec, $term"
        "$altMod, Q, exec, $term_alt"
        "$mainMod, C, killactive,"
        "$mainMod, V, togglefloating,"
        "$mainMod, P, pseudo,"
        "$mainMod, J, togglesplit,"
        "SUPER, D, exec, $launcher"
        "SUPER, F, fullscreen, 1"
        "$shiftMod, F, fullscreen, 0"
        "SUPER, E, exec, $explorer"
        "SUPERSHIFT, S, exec, XDG_CURRENT_DESKTOP=sway flameshot gui"
        "SUPER, F1, exec, gammastep -O 2750 &"
        "SUPER, B, exec, $browser"
        "$shiftMod, K, exec, hyprctl kill"
        "$altMod, B, exec, $browser_pw"
        "SHIFT, F1, exec, pkill gammastep"
        "$shiftMod, S, exec, hyprshot -m region"
        ", XF86AudioRaiseVolume, exec, volumectl -u up"
        ", XF86AudioLowerVolume, exec, volumectl -u down"
        ", XF86AudioMute, exec, volumectl toggle-mute"
        ", XF86AudioMicMute, exec, volumectl -m toggle-mute"
        ", XF86Launch3, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86MonBrightnessUp, exec, lightctl up"
        ", XF86MonBrightnessDown, exec, lightctl down"
        "$mainMod, L, exec, scripts/./control.sh"
        "SUPER, G, exec, scripts/./wallpaper.sh"
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$altMod, 1, movetoworkspacesilent, 1"
        "$altMod, 2, movetoworkspacesilent, 2"
        "$altMod, 3, movetoworkspacesilent, 3"
        "$altMod, 4, movetoworkspacesilent, 4"
        "$altMod, 5, movetoworkspacesilent, 5"
        "$altMod, 6, movetoworkspacesilent, 6"
        "$altMod, 7, movetoworkspacesilent, 7"
        "$altMod, 8, movetoworkspacesilent, 8"
        "$altMod, 9, movetoworkspacesilent, 9"
        "$shiftMod, Delete, exit"
        "SUPERSHIFT, left, movewindow, l"
        "SUPERSHIFT, right, movewindow, r"
        "SUPERSHIFT, up, movewindow, u"
        "SUPERSHIFT, down, movewindow, d"
        "$mainMod, 0, togglespecialworkspace,"
        "$mainMod, ALT, movetoworkspacesilent, special"
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
        "$ctrlMod, right, resizeactive, 10 0"
        "$ctrlMod, left, resizeactive, -10 0"
        "$ctrlMod, up, resizeactive, 0 -10"
        "$ctrlMod, down, resizeactive, 0 10"
        "ALT, Tab, cyclenext,"
        "ALT, Tab, bringactivetotop,"
      ];

      # Bind with modifiers
      "binde" = [
        ", code:123, exec, wpctl set-volume -1 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
        ", code:122, exec, wpctl set-volume -1 1.5 @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      # Bind with mouse
      "bindm" = [
        "SUPERSHIFT, mouse:272, movewindow"
        "SUPERSHIFT, mouse:273, resizewindow"
      ];

      # Custom environment variables
      custom = {
        env = [
          "XCURSOR_SIZE,24"
          "XCURSOR_THEME,WhiteSur-cursor"
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          "QT_QPA_PLATFORM,wayland"
          "QT_QPA_PLATFORMTHEME,qt6ct"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
          "WLR_BACKEND,vulkan"
          "GDK_BACKEND,wayland"
          "MOZ_ENABLE_WAYLAND,1"
          "_JAVA_AWT_WM_NONREPARENTING,1"
          "CLUTTER_BACKEND,wayland"
          "WLR_NO_HARDWARE_CURSORS,1"
          "AQ_DRM_DEVICES,/dev/dri/card1:/dev/dri/card2"
          "HYPRCURSOR_THEME,rose-pine-hyprcursor"
          "HYPRCURSOR_SIZE,24"
        ];
      };
    };
  };
}
