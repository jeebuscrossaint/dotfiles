
{pkgs, ...}: {
  wayland.windowManager.river = {
    enable = true;
    xwayland.enable = true;
    
    extraConfig = ''
      #!/bin/sh
      
      # Variables
      term="foot"
      term_alt="xterm"
      browser="zen-browser"
      browser_pw="zen-browser --private-window"
      editor="kitty nvim"
      explorer="pcmanfm"
      launcher="BEMENU_BACKEND=wayland bemenu-run"
      
      # Set keyboard repeat rate
      riverctl set-repeat 50 300
      
      # Set cursor theme and size
      riverctl xcursor-theme rose-pine-cursor 24
      
      # Set keyboard layout
      riverctl keyboard-layout us
      
      # Input configuration
      riverctl input pointer-* accel-profile flat
      riverctl input pointer-* pointer-accel 0
      riverctl input touchpad-* tap enabled
      riverctl input touchpad-* natural-scroll enabled
      riverctl input touchpad-* disable-while-typing enabled
      
      # Set border width (0 for minimal look like your Hyprland)
      riverctl border-width 0
      
      # Set background and border colors (letting Stylix handle this)
      # riverctl background-color 0x000000
      # riverctl border-color-focused 0xffffff
      # riverctl border-color-unfocused 0x000000
      
      # Enable numlock by default (if available)
      which numlockx && numlockx on
      
      # Window rules
      riverctl rule-add -app-id "mpv" float
      riverctl rule-add -title "Picture-in-Picture" float
      riverctl rule-add -app-id "zoom" float
      riverctl rule-add -app-id "foot" csd
      riverctl rule-add csd
      
      # Autostart applications
      riverctl spawn "systemctl --user start hyprpolkitagent"
      riverctl spawn "hypridle"
      riverctl spawn "swaync"
      riverctl spawn "copyq --start-server"
      riverctl spawn "wl-paste --type text --watch cliphist store"
      riverctl spawn "wl-paste --type image --watch cliphist store"
      riverctl spawn "udiskie &"
      riverctl spawn "dbus-update-activation-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      riverctl spawn "eww daemon"
      riverctl spawn "gamemoded"
      riverctl spawn "avizo-service"
      riverctl spawn "nm-applet"
      riverctl spawn "swww-daemon"
      
      # Set default layout and spawn layout manager
      riverctl default-layout rivertile
      rivertile -view-padding 0 -outer-padding 0 &
      
      # Key bindings - Applications
      riverctl map normal Super Q spawn "$term"
      riverctl map normal Super+Alt Q spawn "$term_alt"
      riverctl map normal Super D spawn "$launcher"
      riverctl map normal Super E spawn "$explorer"
      riverctl map normal Super B spawn "~/bruh.sh --dunst"
      riverctl map normal Super+Alt B spawn "$browser_pw"
      riverctl map normal Super G spawn "scripts/./wallpaper.sh"
      
      # Window management
      riverctl map normal Super C close
      riverctl map normal Super V toggle-float
      riverctl map normal Super F toggle-fullscreen
      riverctl map normal Super J toggle-focused-tags
      riverctl map normal Super P toggle-float
      riverctl map normal Super+Shift K spawn "riverctl close"
      riverctl map normal Super L spawn "scripts/./control.sh"
      
      # Focus movement (River uses different focus commands)
      riverctl map normal Super Left focus-view left
      riverctl map normal Super Right focus-view right  
      riverctl map normal Super Up focus-view up
      riverctl map normal Super Down focus-view down
      
      # Move windows
      riverctl map normal Super+Shift Left move left 100
      riverctl map normal Super+Shift Right move right 100
      riverctl map normal Super+Shift Up move up 100
      riverctl map normal Super+Shift Down move down 100
      
      # Resize windows
      riverctl map normal Super+Control Left resize horizontal -100
      riverctl map normal Super+Control Right resize horizontal 100
      riverctl map normal Super+Control Up resize vertical -100
      riverctl map normal Super+Control Down resize vertical 100
      
      # Screenshots
      riverctl map normal Super+Shift S spawn "hyprshot -m region"
      riverctl map normal Super+Shift+Alt S spawn "XDG_CURRENT_DESKTOP=sway flameshot gui"
      
      # Audio controls
      riverctl map normal None XF86AudioRaiseVolume spawn "volumectl -u up"
      riverctl map normal None XF86AudioLowerVolume spawn "volumectl -u down"
      riverctl map normal None XF86AudioMute spawn "volumectl toggle-mute"
      riverctl map normal None XF86AudioMicMute spawn "volumectl -m toggle-mute"
      riverctl map normal None XF86Launch3 spawn "playerctl play-pause"
      riverctl map normal None XF86AudioPlay spawn "playerctl play-pause"
      
      # Brightness controls
      riverctl map normal None XF86MonBrightnessUp spawn "lightctl up"
      riverctl map normal None XF86MonBrightnessDown spawn "lightctl down"
      
      # Gamma/Night light
      riverctl map normal Super F1 spawn "gammastep -O 2750 &"
      riverctl map normal Shift F1 spawn "pkill gammastep"
      
      # Tag management (River's version of workspaces)
      for i in $(seq 1 9); do
          tags=$((1 << ($i - 1)))
          
          # Focus tag
          riverctl map normal Super $i set-focused-tags $tags
          
          # Move window to tag
          riverctl map normal Super+Shift $i set-view-tags $tags
          
          # Move window to tag silently (toggle to tag and back)
          riverctl map normal Super+Alt $i set-view-tags $tags
      done
      
      # Toggle all tags
      all_tags=$(((1 << 32) - 1))
      riverctl map normal Super 0 set-focused-tags $all_tags
      
      # Special workspace equivalent (using tag 10)
      special_tag=$((1 << 9))
      riverctl map normal Super grave toggle-focused-tags $special_tag
      riverctl map normal Super+Alt grave set-view-tags $special_tag
      
      # Alt-Tab functionality
      riverctl map normal Alt Tab focus-view next
      riverctl map normal Alt+Shift Tab focus-view previous
      
      # Mouse bindings
      riverctl map-pointer normal Super BTN_LEFT move-view
      riverctl map-pointer normal Super BTN_RIGHT resize-view
      riverctl map-pointer normal Super+Shift BTN_LEFT move-view
      riverctl map-pointer normal Super+Shift BTN_RIGHT resize-view
      
      # Exit River
      riverctl map normal Super+Shift Delete exit
      
      # Focus follows mouse
      riverctl focus-follows-cursor normal
      
      # Set environment variables for spawned processes
      riverctl spawn 'export XCURSOR_SIZE=24'
      riverctl spawn 'export XCURSOR_THEME=rose-pine-cursor'
      riverctl spawn 'export XDG_CURRENT_DESKTOP=river'
      riverctl spawn 'export XDG_SESSION_DESKTOP=river'
      riverctl spawn 'export XDG_SESSION_TYPE=wayland'
      riverctl spawn 'export QT_QPA_PLATFORM=wayland'
      riverctl spawn 'export QT_WAYLAND_DISABLE_WINDOWDECORATION=1'
      riverctl spawn 'export WLR_BACKEND=vulkan'
      riverctl spawn 'export GDK_BACKEND=wayland'
      riverctl spawn 'export MOZ_ENABLE_WAYLAND=1'
      riverctl spawn 'export _JAVA_AWT_WM_NONREPARENTING=1'
      riverctl spawn 'export CLUTTER_BACKEND=wayland'
      riverctl spawn 'export WLR_NO_HARDWARE_CURSORS=1'
      riverctl spawn 'export HYPRCURSOR_THEME=rose-pine-hyprcursor'
      riverctl spawn 'export HYPRCURSOR_SIZE=24'
    '';
  };
  # Session variables for River
  home.sessionVariables = {
    XCURSOR_THEME = "rose-pine-cursor";
    XCURSOR_SIZE = "24";
    XDG_CURRENT_DESKTOP = "river";
    XDG_SESSION_DESKTOP = "river";
    XDG_SESSION_TYPE = "wayland";
  };
}
