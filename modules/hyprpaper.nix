{
  pkgs,
  config,
  ...
}: {
  services.hyprpaper = {
    enable = false;
    settings = {
      ipc = "on";
      splash = false;
      wallpaper = [",/home/amarnath/walls/mountain/a_snowy_mountain_tops_with_blue_sky.jpg"];
    };
  };
}
