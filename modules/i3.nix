{ config, lib, pkgs, ... }:

{
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3;
    
    config = {
      modifier = "Mod4";
      
      terminal = "alacritty";
      menu = "rofi -show drun";
      
      gaps = {
        inner = 10;
        outer = 0;
        smartGaps = true;
      };
      
      window = {
        border = 2;
        hideEdgeBorders = "none";
        commands = [
          { command = "border pixel 2"; criteria = { class = ".*"; }; }
          { command = "floating enable"; criteria = { class = "rofi"; }; }
          { command = "floating enable"; criteria = { class = "zoom"; }; }
        ];
      };
      
      floating = {
        modifier = "Mod4";
        criteria = [
          { class = "rofi"; }
          { class = "zoom"; }
        ];
      };
      
      bars = [
        {
          statusCommand = "i3status-rs";
          position = "bottom";
        }
      ];
      
      keybindings = lib.mkOptionDefault {
        # Main keybindings
        "Mod4+q" = "exec kitty";
        "Mod4+c" = "kill";
        "Mod4+p" = "floating toggle";
        "Mod4+d" = "exec rofi -show drun";
        "Mod4+g" = "exec ";
        "Mod4+l" = "exec xsecurelock";
        "Mod4+b" = "exec zen";
        "Mod4+shift+s" = "exec flameshot gui";
        
        # Window management
        "Mod4+Left" = "focus left";
        "Mod4+Down" = "focus down";
        "Mod4+Up" = "focus up";
        "Mod4+Right" = "focus right";
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
        "XF86AudioRaiseVolume" = "exec --no-startup-id ~/go/bin/volumectl up";
        "XF86AudioLowerVolume" = "exec --no-startup-id ~/go/bin/volumectl down";
        "XF86Launch3" = "exec --no-startup-id playerctl play-pause";
        "XF86AudioMicMute" = "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        "XF86MonBrightnessUp" = "exec --no-startup-id brightnessctl set +5%";
        "XF86MonBrightnessDown" = "exec --no-startup-id brightnessctl set 5%-";
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
        { command = "dex --autostart --environment i3"; notification = false; }
        { command = "xss-lock --transfer-sleep-lock -- xsecurelock"; notification = false; }
        { command = "nm-applet"; notification = false; }
        { command = "timedatectl set-local-rtc 1 --adjust-system-clock"; notification = false; }
        { command = "udiskie"; notification = false; always = false; }
        { command = "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"; notification = false; }
        { command = "xclip"; notification = false; }
        { command = "xdotool key --clearmodifiers Num_Lock"; notification = false; }
        { command = ".config/lemonbar/lemon.sh"; notification = false; }
        { command = "autotiling"; notification = false; }
        { command = "rog-control-center"; notification = false; }
        { command = "gamescope"; notification = false; }
        { command = "/usr/bin/pipewire & /usr/bin/pipewire-pulse & /usr/bin/wireplumber"; notification = false; }
        { command = "numlockx"; notification = false; }
        { command = "dunst"; notification = false; }
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
}
