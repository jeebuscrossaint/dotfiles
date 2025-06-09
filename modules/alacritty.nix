{
  programs.alacritty = {
    enable = false;
    settings = {
      general = {
        live_config_reload = true;
        ipc_socket = true;
      };
      
      window = {
        padding = { x = 5; y = 5; };
        decorations = "full";
        dynamic_title = true;
      };
      
      font = {
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
