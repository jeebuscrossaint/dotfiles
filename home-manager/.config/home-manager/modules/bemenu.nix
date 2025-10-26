{
  config,
  pkgs,
  ...
}: {
  programs.bemenu = {
    enable = true;
    settings = {
      ignorecase = true;
      list = 10;
      prefix = ">";
      prompt = "run:";
    };
  };
}
