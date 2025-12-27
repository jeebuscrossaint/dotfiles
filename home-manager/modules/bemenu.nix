{
  config,
  pkgs,
  ...
}: {
  programs.bemenu = {
    enable = true;
    # package = pkgs.emptyDirectory;
    settings = {
      ignorecase = true;
      list = 10;
      prefix = ">";
      prompt = "run:";
    };
  };
}
