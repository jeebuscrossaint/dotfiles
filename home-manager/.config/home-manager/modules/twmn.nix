{
  # Enable twmn notification daemon
  services.twmn = {
    enable = false;
    
    # How long notifications stay visible (in milliseconds)
    duration = 4000;  # 4 seconds
    
    # Network settings
    host = "127.0.0.1";
    port = 9797;
    
    # Multi-monitor setup (set to specific screen number if needed)
    screen = null;  # null means use default screen
    
    # Sound command to play when notification appears
    soundCommand = ""; # You can set this to a specific sound command if needed
    
    # Icon paths for different notification types
    icons = {
      critical = null; # Will use default or set to specific path if needed
      info = null;
      warning = null;
    };
    
    # Text styling
    text = {
      color = "#ffffff";  # White text
      maxLength = 100;    # Truncate long messages
      
      font = {
        package = null; # Use system default font
        family = "Noto Sans";
        size = 14;
        variant = "medium";
      };
    };
    
    # Window appearance and behavior
    window = {
      # Always keep notifications on top
      alwaysOnTop = true;
      
      # Window styling
      color = "#2d3748";      # Dark gray background
      height = 24;            # Height in pixels
      opacity = 95;           # Slightly transparent
      position = "top_right"; # Where notifications appear
      
      # Position offset from screen edge
      offset = {
        x = -10;  # 10 pixels from right edge
        y = 30;   # 30 pixels from top
      };
      
      # Animation settings
      animation = {
        # Slide in animation
        easeIn = {
          curve = 38;      # Qt easing curve (OutCubic)
          duration = 300;  # 300ms slide in
        };
        
        # Slide out animation  
        easeOut = {
          curve = 37;      # Qt easing curve (InCubic)
          duration = 200;  # 200ms slide out
        };
        
        # Bounce effect when new notification appears
        bounce = {
          enable = true;
          duration = 150;  # Short bounce
        };
      };
    };
    
    # Extra configuration options
    extraConfig = {
      # You can add additional twmn config sections here
      # For example:
      # main.activation_command = "${pkgs.hello}/bin/hello";
    };
  };
}
