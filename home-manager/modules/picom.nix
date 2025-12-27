# In your home.nix file
{
  services.picom = {
    enable = true;
    
    # Fading configuration
    fade = true;
    fadeDelta = 10;
    fadeSteps = [0.028 0.03]; # No commas needed in this list style
    fadeExclude = [
      "window_type = 'dock'"
      "window_type = 'desktop'"
    ];
    
    # Shadow configuration
    shadow = false;
    shadowOffsets = [(- 15) (- 15)]; # Proper syntax for negative numbers in lists
    shadowOpacity = 0.75;
    shadowExclude = [
      "name = 'Notification'"
      "class_g = 'Conky'"
      "class_g ?= 'Notify-osd'"
      "class_g = 'Cairo-clock'"
      "_GTK_FRAME_EXTENTS@:c"
    ];
    
    # Opacity configuration
    activeOpacity = 1.0;
    inactiveOpacity = 0.9;
    menuOpacity = 0.95;
    
    # Window type settings
    wintypes = {
      tooltip = { opacity = 0.95; shadow = false; fade = true; };
      dock = { shadow = false; };
      dnd = { shadow = false; };
      popup_menu = { opacity = 0.95; };
      dropdown_menu = { opacity = 0.95; };
    };
    
    # Opacity rules
    opacityRules = [
      "90:class_g = 'URxvt'"
      "90:class_g = 'Alacritty'"
      "90:class_g = 'kitty'"
      "95:class_g = 'Firefox' && focused"
      "90:class_g = 'Firefox' && !focused"
    ];
    
    # Backend and other settings
    backend = "glx";
    vSync = true;
    
    # Extra args if needed
    extraArgs = [
      # "--log-level=warn"
      # "--log-file=/tmp/picom.log"
    ];
    
    # Additional settings using the settings option
    settings = {
      # GLX backend settings
      glx-no-stencil = true;
      glx-no-rebind-pixmap = true;
      
      # Corners
      corner-radius = 0;
      rounded-corners-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
      ];
      
      # Blur
      blur = {
        method = "gaussian";
        size = 10;
        deviation = 5.0;
      };
      
      blur-background-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
        "_GTK_FRAME_EXTENTS@:c"
      ];
      
      # Other settings
      mark-wmwin-focused = true;
      mark-ovredir-focused = true;
      detect-rounded-corners = true;
      detect-client-opacity = true;
      detect-transient = true;
      detect-client-leader = true;
      
      # Performance
      unredir-if-possible = true;
      unredir-if-possible-exclude = [
        "class_g = 'Firefox' && argb"
      ];
    };
  };
}
