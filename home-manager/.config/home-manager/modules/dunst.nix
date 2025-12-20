{
  config,
  lib,
  pkgs,
  ...
}: {
  services.dunst = {
    enable = true;
    package = pkgs.emptyDirectory;
    settings = {
      global = {
        # Display settings
        width = 400;
        height = 400;
        offset = "20x50";
        origin = "top-right";

        # Behavior settings
        follow = "mouse";
        idle_threshold = 120;
        show_age_threshold = 60;

        # Performance settings
        notification_limit = 20;

        # Notification settings
        show_indicators = true;
        sticky_history = true;
        history_length = 20;

        # Format settings
        format = "<b>%s</b>\n%b";
        word_wrap = true;
        indicate_hidden = true;
        alignment = "left";

        # Geometry
        corner_radius = 0;
        gap_size = 2;
        padding = 8;
        horizontal_padding = 8;

        # Icons
        icon_position = "left";
        min_icon_size = 0;
        max_icon_size = 32;
      };

      # Urgency levels
      urgency_low = {
        timeout = 5;
      };

      urgency_normal = {
        timeout = 10;
      };

      urgency_critical = {
        timeout = 0; # Never time out
      };

      # Shortcuts
      shortcuts = {
        close = "ctrl+space";
        close_all = "ctrl+shift+space";
        history = "ctrl+grave";
        context = "ctrl+shift+period";
      };
    };
  };
}
