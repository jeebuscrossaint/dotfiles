{
  pkgs,
  config,
  ...
}: {
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      wallpaper = [",tile:~/tiles/gnu-linux_tile.png"];
    };
  };
}
