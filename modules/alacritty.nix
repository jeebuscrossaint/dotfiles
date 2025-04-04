{
  programs.alacritty = {
    enable = false;
    settings = {
      general = {
        live_config_reload = true;
        ipc_socket = true;
        import = ["~/.cache/wal/colors-alacritty.toml"];
      };
      
      window = {
        padding = { x = 5; y = 5; };
        decorations = "full";
        dynamic_title = true;
      };
      
      font = {
        #normal = { family = "MonaspiceNe Nerd Font"; style = "Regular"; };
        #size = 10.0;
        offset = { y = 4; };
      };
      
      selection = {
        save_to_clipboard = true;
      };
      
      cursor = {
        style = { shape = "Beam"; blinking = "On"; };
      };
    };
  };
}
