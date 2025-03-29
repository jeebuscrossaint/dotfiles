{
  config,
  pkgs,
  ...
}: {
  programs.fuzzel = {
    enable = true;
    package = pkgs.fuzzel;
    settings = {
      main = {
        terminal = "${pkgs.foot}/bin/foot";
        layer = "top";
        anchor = "center";
        width = 60;
        lines = 15;
        match-mode = "fuzzy";
        fuzzy-min-length = 3;
        fuzzy-max-length-discrepancy = 2;
        fuzzy-max-distance = 3;
        prompt = "> ";
        placeholder = "Type to search...";
        hide-before-typing = false;
        show-actions = true;
        list-executables-in-path = false;
        counter = true;
        delayed-filter-ms = 300;
        delayed-filter-limit = 10000;
      };
      border = {
        width = 1;
        radius = 0;
      };
      padding = {
        horizontal = 40;
        vertical = 8;
        inner = 0;
      };
      rendering = {
        dpi-aware = "auto";
        no-icons = true;
        line-height = 1.0;
        letter-spacing = 0;
        render-workers = 0;
      };
      matching = {
        match-workers = 0;
        no-sort = false;
      };
      logging = {
        log-level = "warning";
        log-colorize = "auto";
        log-no-syslog = false;
      };
      dmenu = {
        dmenu = false;
        dmenu0 = false;
        index = false;
        no-run-if-empty = false;
      };
      launching = {
        launch-prefix = "";
      };
      misc = {
        no-exit-on-keyboard-focus-loss = false;
      };
      filtering = {
        filter-desktop = false;
      };
    };
  };
}
