{pkgs, ...}: {
  wayland.windowManager.river = {
    enable = true;
    xwayland.enable = true;
  };
}
