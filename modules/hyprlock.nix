{
  programs.hyprlock = {
    enable = true;
    settings = {
      # Font definitions
      "$font_family" = "MonaspiceNe Nerd Font";
      "$font_family_clock" = "MonaspiceNe Nerd Font";
      "$font_material_symbols" = "MonaspiceNe Nerd Font";
      
      # Input field
      input-field = {
        monitor = "";
        size = "250, 50";
        outline_thickness = 2;
        dots_size = 0.25;
        dots_spacing = 0.3;
        fade_on_empty = false;
        shadow_passes = 1;
        shadow_size = 5;
        position = "0, -40";
        halign = "center";
        valign = "center";
      };
      
      # Date and time labels
      label = [
        # Date
        {
          text = "cmd[update:1000] date \"+%A, %B %d, %Y (%V)\"";
          monitor = "";
          shadow_passes = 1;
          shadow_boost = 0.5;
          font_size = 22;
          font_family = "$font_family";
          shadow_size = 5;
          position = "0, 375";
          halign = "center";
          valign = "center";
        }
        
        # Clock
        {
          text = "cmd[update:1000] date \"+%I:%M:%S %p\"";
          monitor = "";
          shadow_passes = 1;
          shadow_boost = 0.5;
          font_size = 65;
          font_family = "$font_family_clock";
          shadow_size = 5;
          position = "0, 300";
          halign = "center";
          valign = "center";
        }
        
        # Lock icon
        {
          text = "lock";
          monitor = "";
          shadow_passes = 1;
          shadow_boost = 0.5;
          font_size = 21;
          font_family = "$font_material_symbols";
          shadow_size = 5;
          position = "0, 65";
          halign = "center";
          valign = "bottom";
        }
        
        # "locked" text
        {
          text = "locked";
          monitor = "";
          shadow_passes = 1;
          shadow_boost = 0.5;
          font_size = 14;
          font_family = "$font_family";
          shadow_size = 5;
          position = "0, 45";
          halign = "center";
          valign = "bottom";
        }
        
      ];
    };
  };
}
