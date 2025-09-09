{
  pkgs,
  lib,
  ...
}: {
  services.sxhkd = {
    enable = true;

    keybindings = {
      # Terminal
      "super + q" = "kitty";
      "super + alt + q" = "xterm";

      # Application launcher
      "super + d" = "BEMENU_BACKEND=x11 bemenu-run";

      # File manager
      "super + e" = "pcmanfm";

      # Browser
      "super + alt + b" = "zen-browser --private-window";

      # Screenshots
      "super + shift + s" = "flameshot gui || scrot -s ~/Pictures/screenshot-%Y-%m-%d_%H-%M-%S.png";

      # Volume control
      "XF86AudioRaiseVolume" = "volumectl -u up || amixer -q sset Master 5%+";
      "XF86AudioLowerVolume" = "volumectl -u down || amixer -q sset Master 5%-";
      "XF86AudioMute" = "volumectl toggle-mute || amixer -q sset Master toggle";
      "XF86AudioMicMute" = "volumectl -m toggle-mute || amixer -q sset Capture toggle";

      # Media controls
      "XF86Launch3" = "playerctl play-pause";
      "XF86AudioPlay" = "playerctl play-pause";
      "XF86AudioNext" = "playerctl next";
      "XF86AudioPrev" = "playerctl previous";

      # Brightness control
      "XF86MonBrightnessUp" = "lightctl up || xbacklight -inc 10";
      "XF86MonBrightnessDown" = "lightctl down || xbacklight -dec 10";

      # Screen temperature
      "super + F1" = "gammastep -O 2750 &";
      "shift + F1" = "pkill gammastep";

      # Custom scripts (if they exist)
      "super + l" = "scripts/./control.sh || i3lock";
      "super + g" = "scripts/./wallpaper.sh || feh --randomize --bg-scale ~/Pictures/Wallpapers/*";
      "super + b" = "~/bruh.sh --dunst || notify-send 'Test' 'Notification system'";

      # Kill active window
      "super + c" = "bspc node -c";
      "super + shift + k" = "bspc node -k";

      # Toggle window states
      "super + v" = "bspc node -t ~floating";
      "super + f" = "bspc node -t ~fullscreen";
      "super + p" = "bspc node -t ~pseudo_tiled";

      # Focus/swap nodes
      "super + {Left,Down,Up,Right}" = "bspc node -f {west,south,north,east}";
      "super + shift + {Left,Down,Up,Right}" = "bspc node -s {west,south,north,east}";

      # Focus/send to desktop
      "super + {1-9,0}" = "bspc desktop -f '^{1-9,10}'";
      "super + alt + {1-9,0}" = "bspc node -d '^{1-9,10}' --follow";
      "super + shift + {1-9,0}" = "bspc node -d '^{1-9,10}'";

      # Preselection
      "super + ctrl + {Left,Down,Up,Right}" = "bspc node -p {west,south,north,east}";
      "super + ctrl + space" = "bspc node -p cancel";
      "super + ctrl + shift + space" = "bspc query -N -d | xargs -I id -n 1 bspc node id -p cancel";

      # Resize windows
      "super + ctrl + {h,j,k,l}" = "bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}";
      "super + ctrl + shift + {h,j,k,l}" = "bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}";

      # Move floating window
      "super + {h,j,k,l}" = "bspc node -v {-20 0,0 20,0 -20,20 0}";

      # Focus monitor
      "super + {comma,period}" = "bspc monitor -f {prev,next}";

      # Send to monitor
      "super + shift + {comma,period}" = "bspc node -m {prev,next} --follow";

      # Cycle through nodes
      "alt + Tab" = "bspc node -f next.local.!hidden.window";
      "alt + shift + Tab" = "bspc node -f prev.local.!hidden.window";

      # Quit/restart bspwm
      "super + shift + Delete" = "bspc quit";
      "super + shift + r" = "bspc wm -r";

      # Special workspace (scratchpad-like)
      "super + 0" = "bspc desktop -f '^10'";
      "super + alt + 0" = "bspc node -d '^10' --follow";

      # Close all notifications
      "super + n" = "dunstctl close-all || swaync -C";
    };
  };
}
