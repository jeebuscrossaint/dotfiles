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
        prompt = "> ";
        placeholder = "Type to search...";
        hide-before-typing = false;
        show-actions = true;
        list-executables-in-path = false;
        delayed-filter-ms = 300;
        delayed-filter-limit = 10000;
        icon-theme = "rose-pine-dawn";
      };
      border = {
        width = 1;
        radius = 0;
      };
    };
  };
}
